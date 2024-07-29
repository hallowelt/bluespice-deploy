# BlueSpice "Deploy"

See ["Multi-container Applications docker-compose, Targeting multiple environments"](https://learn.microsoft.com/en-us/dotnet/architecture/microservices/multi-container-microservice-net-applications/multi-container-applications-docker-compose#targeting-multiple-environments) for more information.

## For general Usage

### Preparations
Copy all these Files to the destinated Directory/disk

copy .evn.example to .env and edit .env to your needs
make bluespice-prepare and bluespice-deploy executable

```sh
chmod +x bluespice-prepare bluespice-deploy

```

run bluespice-prepare as sudo to create subdirectories and change Ownership of these Directories to the Container-Users

```sh
./bluespice-prepare
```

This also creates and enables  bluespice.service to start und gracefully stop the Containers on reboot/shutdown of the Server

Pull images with
```sh
./bluespice-deploy pull
```
and do a first start with

```sh
./bluespice-deploy up -d
```
or 
```sh
systemctl start bluespice.service
```



## Example

```sh
./bluespice-deploy up -d
```

# Data volumes

Persistent data will be stored in the `${DATADIR}` directory.

# Known issues
On the first start, the `bluespice/search` container (OpenSearch) will fail, due to file system permissions. This can be fixed by running the following command:

```sh
sudo chown -R 1000:1000 ${DATADIR}/search
```

# Development

## Hostname
Add the following line to `/etc/hosts`:

```sh
127.0.0.1 mydev.localhost
```

## SSL Certificates
Inside the `${DATADIR}/proxy/certs` directory, run the following command to generate a self-signed certificate for `mydev.localhost`:

```sh
sudo openssl req -x509 -newkey rsa:4096 -keyout mydev.localhost.key -out mydev.localhost.crt -sha256 -days 3650 -nodes -subj "/C=XX/ST=StateName/L=CityName/O=CompanyName/OU=CompanySectionName/CN=CommonNameOrHostname"

sudo chown 1000:1000 mydev.localhost.*
```

You can now access the application via `https://mydev.localhost`.

## Debugging
If the environment variable `DEV_WIKI_DEBUG` is set, one can set the `debug-entrypoint` GPC (=`$_REQUEST`) to a value matching the `MW_ENTRY_POINT` constant in context of the application to enable full debug log to `stdout` for any call to the specified entry point.
