# BlueSpice "Deploy"

See ["Multi-container Applications docker-compose, Targeting multiple environments"](https://learn.microsoft.com/en-us/dotnet/architecture/microservices/multi-container-microservice-net-applications/multi-container-applications-docker-compose#targeting-multiple-environments) for more information.

## Example

```sh
docker compose \
	-f docker-compose.persistent-data-services.yml \
	-f docker-compose.stateless-services.yml \
	-f docker-compose.free.yml \
	up -d
```