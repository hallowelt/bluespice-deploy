# bluespice-helm



### Prerequisites
- If you are using a version other than free, update the registry creadentils in global.regcred.
- Update ingress class name and ingress related annotation in ingress section.
- Update the environment variables required for the bluspice application in the env and secret sections (DB_PASS and opensearch details are only required if you are using external services for these).
- If you want to deploy database and search in k8s, update enabled:true for statefulBackendServices.database and statefulBackendServices.service.
- Also update statefulBackendServices.database.MARIADB_ROOT_PASSWORD and statefulBackendServices.database.MARIADB_PASSWORD if you are deploying an internal database.
- If your storage does not support RWX, set `wikiServicesCombineWebAndTask: true` to run wiki-web and wiki-task in the same pod so they share the same PVC mount.

### Deployment
Use the below sample command to deploy the helm chart.
```bash
   helm install bluespice . --namespace bluespice --create-namespace --values sampleValues.yaml
```  
