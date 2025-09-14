# Web-server with Load Balancer

- Here a fleet of identical VMs are created (managed by a Managed Instance Group) which runs the web-app, are **health-checked** and **load-balanced** by a global HTTP load balancer, and **scale automatically** based on the load.


This Terraform provisions:

- Instance Template → defines how each web VM looks.
- MIG → runs multiple identical VMs, spread across zones.
- Health Check → checks /health endpoint on port 8080.
- Backend Service → groups MIG instances for load balancing.
- URL Map → HTTP Proxy → Forwarding Rule → implements a Global HTTP Load Balancer (exposing the app on port 80).
- Autoscaler → scales the MIG up/down based on CPU.


In summary:

1. Instance template defines each VM
2. The MIG runs and maintains them
3. The backend service + URL map + proxy + forwarding rule make the load balancer
4. Health-checks tell the load-balancer and MIG who's healthy
5. The auto-scaler changes the number of VMs

This is how a client request ends up:

```markdown
Client -> Global Forwarding Rule (port 80)
       -> Target HTTP Proxy
       -> URL Map (routing rules)
       -> Backend Service (health checks)
       -> Regional MIG (instance group)
       -> Individual VM (instance template)
       -> App (startup script, talks to DB)
```

## Components: What they are and how they connect

### 👁️ Instance Template
(`google_compute_instance_template.web_server_template`)

What it is:

- A blueprint for VMs: machine-type, disk image, network, metadata/startup-script, service account, etc

What it does:

- When the MIG needs a new VM (initial creation, scaling, or a rolling update), it uses this template to create the instance
    - `metadata_startup_script` injects DB, IP/name so the instance can configure the app on boot.
    - tags = ["web-server","ssh-access"] are how firewall rules target these VMs.

    - `access_config` gives an ephemeral external IP to each VM

Why it matters:

- Changing the template is how we roll out new app versions or configuraitons. 
- The MIG will create VMs from the new template

### 👁️ Managed Instance Group (MIG)
(`google_compute_region_instance_group_manager.web_server_group`)

What it is:

- A controller that runs and maintains a set of identical VM instances (based on the instance template).

What it does:

- Keeps `target_size` number of VMs running

- Repairs or replaces unhealthy VMs (auto-healing)

- Works across multiple zones within a region (regional MIG), improving availability

How it links to other parts:

- The backend service uses the MIG’s instance group as the backend pool

- Named ports on the MIG (`named_port { name = "http" port = 8080 }`) map the app port to the backend service port name

Why it matters:

- Central point for scaling, rolling updates, and health-driven repairs


### 👁️ Health Check

(`google_compute_health_check.web_server_health_check`)

What it is:

- A probe the load balancer (and MIG auto-healing) uses to verify instance health.

What it does:

- Periodically sends HTTP requests (here to /`health` on port 8080) to each instance.

- If instances fail the check, the load balancer stops routing traffic to them; the MIG can auto-recreate them.

Key params in the code:

- `check_interval_sec` = 30 and `timeout_sec` = 5 determine how quickly failures are detected.

Why it matters:

- Keeps traffic flowing only to healthy instances and enables automated recovery.


### 👁️ Backend Service

(`google_compute_backend_service.web_server_backend`)

What it is:

- The LB’s concept of a backend pool: which instance groups receive traffic and how to balance to them.

What it does:

- Accepts a list of backends (MIG instance group), the balancing mode, timeout, and attached health checks

- Decides how to route incoming requests to healthy backends

Connection points:

- `group = web_server_group.instance_group` ties the MIG to the LB.

- `health_checks = [web_server_health_check.id]` ensures only healthy instances serve traffic.


### 👁️ URL Map → Target HTTP Proxy → Global Forwarding Rule

These 3 together form the global HTTP Load Balancer's frontend and routing logic.

1. *Global Forwarding Rule*

(`google_compute_global_forwarding_rule.web_server_forwarding_rule`)

- Listens on a public IP + port (here port 80) and forwards requests to the proxy

2. *Target HTTP Proxy*

(`google_compute_target_http_proxy.web_server_proxy`)

- Accepts the forwarded requests and consults the URL maps for routing

3. *URL Map*

(`google_compute_url_map.web_server_url_map`)

- Maps requests (host/path) to backend services. We've set `default_service` so all traffic goes to our backend

How they connect:

- Forwarding rule -> proxy -> url map -> backend service -> MIG instances

- This chain exposes the web-app to the Internet with global reach, allows paht/host routing, and centralizes TLS/HTTP rules (TLS would use target_https_proxy + SSL certs)


### 👁️ Autoscaler

(`google_compute_region_autoscaler.web_server_autoscaler`)

What it is:

- A controller that adjusts MIG size automatically based on metrics (CPU, load, etc.).

What it does:

- Monitors the policy (here CPU utilization) and scales target_size between min_replicas and max_replicas.

Key policy detail in the code:

- cpu_utilization.target = 0.7 → target 70% average CPU across instances; if higher, it scales up; lower, scales down.

Why it matters:

- Lets you handle traffic spikes automatically and reduce cost when demand is low.


## Typical lifecycle & runtime sequences

### 1. Boot / initial deploy

1. Terraform creates the **instance template**
2. Terraform creates the **MIG**, which creates *N* VMs based on that template
3. Each VM runs the **startup script** (install app, configures DB connection using `DB_IP`)
4. The MIG registers instances in the instance group
5. The load balancer's **health check** probe `/health` on each VM. Once healthy, LB routes traffic

### 2. A client request (runtime)

Client -> Global Forwarding Rule (port 80) -> Target HTTP Proxy -> URL Map -> Backend Service -> Regional MIG Instance Group -> Chosen VM -> Web app listens on port 8080 and responds.

### 3. Instance becomes unhealthy

- Health check fails -> LB stops sending its traffic -> MIG auto-healing policy notices the instance is unhealthy (or the LB will mark it out) -> MIG deletes and recreates the instance using the instance template
- New instance boots and registers when healthy

### 4. Autoscaling up

- Average CPU across the group > 70% for a sustained period -> Autoscaler increases MIG target size (up to `max_replicas`) -> MIG creates more instances form the instance template -> LB health checks them and then routes traffic

### 5. Rolling update / deploy new version

- We update the instance template (new startup script or image)
- MIG creates new instances from the new template and gradually replaces old ones (depending on the update policy), so we get minimal downtime
- `lifecycle.create_before_destroy` on the template helps Terraform avoid destroying the template before creating the new one.