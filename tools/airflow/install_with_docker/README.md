# Install Apache Airflow Using Docker

For complex data workflows, apache airflow is the go to way approach as it can be used in the production-grade settings. The Docker integration provides more flexibility with Airflow for custom use-cases.

## Configurations

we can add additional configurations to `docker-compose.yaml` file.

### ENV variables

Key environment variables for customizing Airflow installation:

- `AIRFLOW__CORE__EXECUTOR`: Choose between LocalExecutor, CeleryExecutor, or KubernetesExecutor
- `AIRFLOW__CORE__LOAD_EXAMPLES`: Set to false to avoid loading example DAGs
- `AIRFLOW__WEBSERVER__EXPOSE_CONFIG`: Set to true to expose configuration in the web UI
- `AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION`: Set to false to auto-start new DAGs

### Volumes

Essential directories to mount as volumes:

- `./dags`: Store your workflow definitions
- `./logs`: Access Airflow logs from the host
- `./plugins`: Add custom operators and hooks
- `./config`: Store custom configuration files

### Run the Airflow within Docker containers

```bash
bash run.sh
```

## Useful commands

```bash
# View logs
docker-compose logs airflow-webserver
docker-compose logs airflow-scheduler
# Execute commands in running containers
docker-compose exec airflow-webserver airflow dags list
docker-compose exec airflow-webserver airflow tasks list hello_world_dag
# Restart services
docker-compose restart airflow-scheduler
docker-compose restart airflow-webserver
# Clean up
docker-compose down --volumes --remove-orphans
```

## Production considerations (Need to work on this)

For production deployments, consider the following security measures:

- Change Default Passwords: Never use default credentials in production
- Use Secrets Backend: Store sensitive information in a secrets management system
- Enable HTTPS: Configure SSL/TLS for the web server
- Network Security: Use proper firewall rules and network segmentation

For high-volume workloads, consider:

- CeleryExecutor: Use Redis or RabbitMQ as message broker
- KubernetesExecutor: For cloud-native deployments
- Multiple Schedulers: Airflow 3.0 supports multiple scheduler instances
- Database Scaling: Use read replicas for better performance

For performance optimization:

- Resource Allocation: Allocate sufficient CPU and memory based on your workload
- Database Tuning: Use a production-grade database like PostgreSQL with proper tuning
- Parallelism: Configure appropriate parallelism settings for your executors
- Monitoring: Implement comprehensive monitoring and alerting