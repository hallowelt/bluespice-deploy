# BlueSpice "Deploy"
<img style="display:block;margin:auto" src="https://bluespice.com/wp-content/uploads/2022/09/bluespice_logo.png" alt="BlueSpice MediaWiki" />
This repo contains deployment code for the BlueSpice Wiki application

Please see the [official helpdesk entry](https://en.wiki.bluespice.com/wiki/Setup:Installation_Guide/Docker) for more details.

## Hint
- This layout is based on ["Multi-container Applications docker-compose, Targeting multiple environments"](https://learn.microsoft.com/en-us/dotnet/architecture/microservices/multi-container-microservice-net-applications/multi-container-applications-docker-compose#targeting-multiple-environments)
- The later-loaded docker compose commands will override those earlier-loaded ones. Please be aware of this feature, and make use of it sufficiently. 
=======
# Data volumes

Persistent data will be stored in the `${DATADIR}` directory.

# Development

## Develop BlueSpice 4.5.x with self-built images
Enter your chosen base path, e.g `/workspace/bs-4-5/`, clone this project. Under the same path you need to run:
```sh
git clone https://github.com/hallowelt/docker-bluespice-wiki.git -b dev-4.5.x && docker build -t bs-wiki-dev:4.5.x docker-bluespice-wiki
git clone https://github.com/hallowelt/docker-bluespice-database.git -b main && docker build -t bluespice/database:4.5.x docker-bluespice-database
git clone https://github.com/hallowelt/docker-bluespice-search.git -b 4.5.x && docker build -t bluespice/search:4.5.x docker-bluespice-search
git clone https://github.com/hallowelt/docker-bluespice-cache.git -b main && docker build -t bluespice/cache:4.5.x docker-bluespice-cache
git clone https://github.com/hallowelt/docker-bluespice-proxy.git -b main && docker build -t bluespice/proxy:4.5.x docker-bluespice-proxy
git clone https://github.com/hallowelt/docker-bluespice-pdf.git -b main && docker build -t bluespice/pdf:4.5.x docker-bluespice-pdf
git clone https://github.com/hallowelt/docker-bluespice-formula.git -b main && docker build -t bluespice/formula:4.5.x docker-bluespice-formula
```
If you are running pro version (need access to https://gitlab.hallowelt.com), please also run
```sh
git clone https://github.com/hallowelt/docker-bluespice-diagram.git -b main && docker build -t bluespice/diagram:4.5.x docker-bluespice-diagram
git clone https://github.com/hallowelt/docker-bluespice-collabpads.git -b main && docker build -t bluespice/collabpads:4.5.x docker-bluespice-collabpads
```
After building all these images, you can proceed setting up `bluespice-deploy-dev/compose/.env` in this project, taking reference of `.env.sample`. With a properly set `.env` you can then run:
```sh
cd bluespice-deploy-dev/compose
sudo ./bluespice-prepare
```
Configuring hostname and certificates as mentioned in the following sections, you can the run the containers.

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

## Run the containers
At the first run please use `./bluespice-deploy pull`, so that the Docker engine uses your locally built images (rather than pulling from remote registries).

When you are sure that no conflicting containers are listed in `docker ps`, you can run the start-up command:
```sh
./bluespice-deploy up -d
```

You can now access the application via `https://mydev.localhost`.

## Debugging
If the environment variable `DEV_WIKI_DEBUG` is set, one can set the `debug-entrypoint` GPC (=`$_REQUEST`) to a value matching the `MW_ENTRY_POINT` constant in context of the application to enable full debug log to `stdout` for any call to the specified entry point.

On MacOS with Docker Desktop, mapping of directories from host machine into containers does not work, even if the permissions are correctly set. 

## Use xdebug
tba
