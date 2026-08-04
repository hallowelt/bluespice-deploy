# bluespice-helm



### Prerequisites
- If you are using a version other than free, update the registry creadentils in global.regcred.
- Update ingress class name and ingress related annotation in ingress section.
- Update the environment variables required for the bluspice application in the env and secret sections (DB_PASS and opensearch details are only required if you are using external services for these).
- Create the `internal-wiki-secrets` Secret in your namespace before deploying:
```bash
kubectl -n <my-namespace> create secret generic internal-wiki-secrets \
  --from-literal=CHAT_AI_CHAT_SERVICE_API_KEY=$(openssl rand -base64 128 | tr -d '/+=\n' | head -c 64) \
  --from-literal=INTERNAL_CHAT_TOKEN=$(openssl rand -base64 128 | tr -d '/+=\n' | head -c 64) \
  --from-literal=INTERNAL_CHAT_WIKI_ACCESS_TOKEN=$(openssl rand -base64 128 | tr -d '/+=\n' | head -c 64) \
  --from-literal=INTERNAL_SIMPLESAMLPHP_ADMIN_PASS=$(openssl rand -base64 64 | tr -d '/+=\n' | head -c 16) \
  --from-literal=INTERNAL_SIMPLESAMLPHP_SECRET_SALT=$(openssl rand -base64 128 | tr -d '/+=\n' | head -c 64) \
  --from-literal=INTERNAL_WIKI_UPGRADEKEY=$(openssl rand -base64 64 | tr -d '/+=\n' | head -c 16) \
  --from-literal=INTERNAL_WIKI_SECRETKEY=$(openssl rand -base64 128 | tr -d '/+=\n' | head -c 64) \
  --from-literal=INTERNAL_WIKI_TOKEN_AUTH_SALT=$(openssl rand -base64 128 | tr -d '/+=\n' | head -c 64) \
  --from-literal=INTERNAL_WIRE_API_KEY=$(openssl rand -base64 128 | tr -d '/+=\n' | head -c 64)
```
- If you want to deploy database and search in k8s, update enabled:true for statefulBackendServices.database and statefulBackendServices.service.
- Also update statefulBackendServices.database.MARIADB_ROOT_PASSWORD and statefulBackendServices.database.MARIADB_PASSWORD if you are deploying an internal database.
- If your storage does not support RWX, set `wikiServicesCombineWebAndTask: true` to run wiki-web and wiki-task in the same pod so they share the same PVC mount.

### Deployment
Use the below sample command to deploy the helm chart.
```bash
   helm install bluespice . --namespace bluespice --create-namespace --values sampleValues.yaml
```  
