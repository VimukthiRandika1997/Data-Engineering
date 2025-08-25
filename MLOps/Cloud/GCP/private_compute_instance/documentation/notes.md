# Notes

# Firewall

- **source_ranges** in GCP firewall rules are CIDR blocks of where the traffic is allowed to originate from.
- We always want to restrict them as narrowly as possible:
  - Internal rules → just your subnets.
  - Admin access → only trusted sources (IAP, VPN, bastion, corporate IP ranges).
  - Never leave sensitive ports (like 22, 3389, 5432) open to 0.0.0.0/0.


## 1. SSH Access to the Compute Engine

```terraform
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "${var.network_name}-allow-iap-ssh"
  network = google_compute_network.vpc.name

  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["35.235.240.0/20"] 

  target_service_accounts = [google_service_account.vm_sa.email]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}
```

- Allow SSH only via IAP to instances using a service account
- IAP TCP forwarding egress range: `35.235.240.0/20` 

### source_ranges = ["35.235.240.0/20"] (IAP SSH rule):

👉 `35.235.240.0/20` is basically the “gatekeeper” range for IAP tunnels. Google publishes and maintains this IP range.

  - This rule only allows ingress from **Google IAP’s fixed IP range (`35.235.240.0/20`)**, which is where IAP TCP forwarding traffic originates.
  - Without this, we'd have to open SSH(`tcp:22`) to the whole Internet (`0.0.0.0/0`), which is unsafe..
  - By blocking this down to just the IAP proxy addresses, the only way to SSH into your VMs is via Google's Identity-Aware Proxy service.
  - This ensures:
    - No direct Internet SSH (protect against brute-force attacks).
    - All SSH access is authenticated and authorized via IAM policies before even hitting your VM.
    - You get audit logging through IAP for who accessed what

## 2. Internal Access (within VPC)

```terraform
# Allow internal east-west traffic (only within this VPC)
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.network_name}-allow-internal"
  network = google_compute_network.vpc.name

  direction = "INGRESS"
  priority  = 65534

  source_ranges = ["10.10.0.0/16"] # tighten to exact subnets if preferred

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "icmp"
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}
```

### source_ranges = ["10.10.0.0/16"] (Internal traffic rule):

👉 Best practice: keep internal communication scoped to your VPC’s IP ranges, rather than allowing `0.0.0.0/0`.

  - This rule allows ingress traffic only if the**source IP address belongs to your VPC's CIDR range** (10.10.0.0/16)
  - This ensures:
    - Ensures only east-west traffic (between your own subnets, like `10.10.0.0/24` and `10.10.1.0/24`) is allowed.
    - Prevents external clients or other VPCs from connecting directly.
    - A `/16` was chosen because it encompasses both the public and private subnets (`10.10.0.0/24` and `10.10.1.0/24`).

we could tighten this further:

```terraform
source_ranges = [
  "10.10.0.0/24", # public subnet
  "10.10.1.0/24"  # private subnet
]

```

# IAP (Identity Aware Proxy)

## How it works:

1. **User makes a request** → to your app/VM behind IAP (e.g., a Cloud Run service, GKE app, or Compute Engine VM).
2. **IAP intercepts the request** → checks if the user is authenticated with Google Identity (or your identity provider via IAM / Cloud Identity / Workspace).
3. **Policy check** → IAP consults your IAM policy to see if that user has the right role (e.g., `roles/iap.httpsResourceAccessor`).
4. **Request forwarded** → If allowed, IAP forwards the request along with an **identity token (JWT)** containing the user’s verified identity.
5. **Your app can verify** → Optionally, your backend app can validate that token to enforce fine-grained rules.

## Common Use Cases:

- Protect **Cloud Run** services with login-based access.
- Restrict access to **internal apps** hosted on GKE, App Engine, or Compute Engine without setting up VPNs.
- Control access to remote developer tools: like internal dashboards.