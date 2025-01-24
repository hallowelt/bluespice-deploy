# BlueSpice "Deploy"
<img style="display:block;margin:auto" src="https://bluespice.com/wp-content/uploads/2022/09/bluespice_logo.png" alt="BlueSpice MediaWiki" />
This repo contains deployment code for the BlueSpice Wiki application

Please see the [official helpdesk entry](https://en.wiki.bluespice.com/wiki/Setup:Installation_Guide/Docker) for more details.

## Development
- Layout based on ["Multi-container Applications docker-compose, Targeting multiple environments"](https://learn.microsoft.com/en-us/dotnet/architecture/microservices/multi-container-microservice-net-applications/multi-container-applications-docker-compose#targeting-multiple-environments)
=======
## For general Usage

### Preparations
Copy all these Files to the destinated Directory/disk

copy .evn.example to .env and edit .env to your needs
make bluespice-prepare and bluespice-deploy executable

```sh
chmod +x bluespice-prepare bluespice-deploy

```

run bluespice-prepare as sudo to create subdirectories and change Ownership of these Directories to the Container-UID

```sh
sudo ./bluespice-prepare
```

This also creates and enables  bluespice.service to start und gracefully stop the Containers on reboot/shutdown of the Server

If you have a valid Subscription please Contact support@hallowelt.com for access to our docker-registry and change EDITION accordingly.

bluespice-deploy will check for your credentials and log you in.

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
Same goes for `bluespice/wiki` wich is now related to user 1002:1002
```sh
sudo chown -R 1002:1002 ${DATADIR}/wiki
```
The bluespice-prepare script cares for this in advance

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
>>>>>>> upstream/main
