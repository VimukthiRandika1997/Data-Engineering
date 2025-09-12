# Airflow Basic

Here we describe the fundemental concepts of Airflow

## Airflow Deployment Modes

| Deployment Mode     | Description                                              | Use Case                                                   |
|---------------------|----------------------------------------------------------|------------------------------------------------------------|
| On VMs              | Manual setup on Compute VMs (bare-metal or cloud).        | Full control, small-scale or legacy setups.                |
| On Kubernetes       | Uses K8s pods to run Scheduler, Webserver, Workers.       | Scalable, containerized, suitable for modern workflows.    |
| Cloud Composer (GCP)| Fully managed Airflow by Google Cloud.                    | Native GCP integration, minimal infra management.          |
| MWAA (AWS)          | Managed Airflow on AWS with auto-scaling and IAM integration. | Tight AWS ecosystem fit, minimal maintenance.              |
| Astronomer          | Commercial managed Airflow platform with enterprise features. | CI/CD, observability, multi-environment setups.            |

## Airflow Components

1. **DAG**

    - Directed Acyclic Graph (DAG) defines the workflow structure and schedule.
    - Written in python

2. **Task**

    - A unit of work inside a DAG:
        - python function,
        - bash command
        - BigQuery job

3. **DAGs Folder Location**

    - Where all DAG python files are stored and scanned
    - This could be vary depending on local / remote / cloud

4. **DAG Parser**

    - Background process that reads DAGs, parses their structure, and stores metadata in DB

5. **Scheduler**

    - Monitors time and task dependencies:
        - queues tasks for execution

6. **Metadata Database**

    - Stores DAG/task state, schedule info, logs, variables, and configuration.
    - Central to Airflow

7. **Executor**

    - Decides how tasks are run:
        - Sequantially, with Celery, Kubernetes, etc

8. **Worker**

    - Actually who runs the DAG
        - can be a docker container, kubernetes pod

9. **webserver**

    - Manages the access to the all components
        - Provides the UI for Airflow: allows the users to manage DAGs, view logs, etc

10. **Plugins**

    - Custom plugins and python packages for specific needs


## Implementation of Airflow

### Airflow on VM

![airflow_on_vm](/tools/airflow/1-intro/assets/airflow_on_vm.png)

1. The Airflow User "authors" DAG files.
2. The Airflow User "installs" components into the Plugin folder & installed packages.
3. The Scheduler "reads" DAG files to understand the workflows.
4. The Plugin folder & installed packages are "installed" and used by both the Scheduler and the Webserver.
5. The Scheduler performs "Parsing, Scheduling & Executing" of tasks and interacts with the Metadata DB to store and retrieve workflow state, task instances, and other metadata.
6. The Webserver (UI) provides an interface for the Airflow User to "operate" Airflow, and it also interacts with the Metadata DB to display DAG status, logs, and configuration.
7. Both the Scheduler and Webserver communicate with the Metadata DB (indicated by solid and dotted red lines), implying read/write operations for maintaining Airflow's state.

### Airflwo on Kubernetes

![airflow_on_vm](/tools/airflow/1-intro/assets/airflow_on_kubernetes.png)

1. DAG Authoring and Storage:
    - A "DAG Author" creates "DAG files", which define the workflows to be executed.
    - These "DAG files" are then "sync"ed to the Airflow "Triggerer(s)" and "Scheduler(s)" components, making the workflow definitions available for processing.
2. Plugin and Package Management:
    - A "Deployment Manager" is responsible for installing Python packages and custom plugins into a "Plugin folder & Installed packages".
    - These installed packages and plugins are then distributed ("install"ed) to the core Airflow components: "Triggerer(s)", "Scheduler(s)", "Worker(s)", and "Webserver(s)". This ensures all components have the necessary dependencies to operate correctly.
3. Parsing, Scheduling, and Executing Tasks (Core Airflow Components):
    - This section, labeled "Parsing, Scheduling & Executing", comprises three key components:
        - Triggerer(s): These components are responsible for triggering tasks based on their defined conditions and interacting with the "Metadata DB" to manage trigger states.
        - Scheduler(s): The Scheduler continuously monitors the "DAG files" for changes, parses them, and determines which tasks need to run. It interacts with the "Metadata DB" to store and retrieve workflow state and task information. It then dispatches tasks to the "Worker(s)" for execution, often via an "Executor" (e.g., Kubernetes Executor) which is implicitly managed between the Scheduler and Workers.
        - Worker(s): Workers execute the actual tasks as instructed by the Scheduler. They also interact with the "Metadata DB" to update task status and store logs.
4. Metadata Database:
    - The "Metadata DB" serves as a central repository for all Airflow components. It stores crucial information such as DAG definitions, task states, connection details, variables, and user configurations, allowing all components to maintain a consistent view of the Airflow environment.
5. User Interface and Operation:
     - The "Webserver(s)" component provides the Airflow User Interface (UI). It fetches information from the "Metadata DB" to display DAGs, task statuses, logs, and other operational data to users.
    - An "Operator" (a user) interacts with the "Webserver(s)" to monitor running workflows, trigger new DAG runs, and manage the Airflow environment.

### Airflow on GCP (Through Cloud Composer)

![airflow_on_vm](/tools/airflow/1-intro/assets/airflow_on_gcp.png)

- Metadatabase, Web-server, Scheduler are fully managed by GCP reducing the burden of maintaining infrastructure setup
- User add DAG python files to GCS bucket
- User can access the DAGs, logs through the Cloud Composer UI