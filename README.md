# BlueSpice "Deploy"

## Example

```sh
docker compose \
	-f docker-compose.persistent-data-services.yml \
	-f docker-compose.stateless-services.yml up \
	-f docker-compose.free.yml up \
	-d
```
