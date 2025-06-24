# BlueSpice "Deploy"
<img style="display:block;margin:auto" src="https://bluespice.com/wp-content/uploads/2022/09/bluespice_logo.png" alt="BlueSpice MediaWiki logo" />
Toolkit for containerized deployment of BlueSpice Wiki.

## Deployment
Please follow the [installation guide](https://en.wiki5.bluespice.com/wiki/Setup:Installation_Guide/Docker) in the BlueSpice Helpdesk.

## Upgrade to BlueSpice 5
For an existing BlueSpice 4.5.x installation using [an earlier stack](https://github.com/hallowelt/bluespice-deploy/tree/4.5.x) of `bluespice-deploy` docker containers, an automated upgrade is possible.
In that case, `./bluespice-deploy up -d --profile=upgrade` should be used.
Please check the [upgrade guide](https://en.wiki5.bluespice.com/wiki/Setup:Installation_Guide/Update_from_4.5_to_5.1) for more information.

<!--TODO: Upgrade for 4.4.x "all-in-one" container users-->

## Configuration
| Variable Name                | Default Value  | Description                                          | Optional |
|------------------------------|----------------|------------------------------------------------------|----------|
|`BLUESPICE_SERVICE_REPOSITORY`| `bluespice`    | pull Docker images from an alternative service repo  | Yes      |
| `BLUESPICE_WIKI_IMAGE`       |edition-specific| use an alternative image for the wiki-containers     | Yes      |
| `DATADIR`                    | `./_volume`    | Path to persitent Volumes                            | Yes      |
| `KERBEROS`                   | `false`        | enables Kerberos-Authentication                      | Yes      |
| `LETSENCRYPT`                | `false`        | enables LetsEcrpyt cert renew                        | Yes      |

For more variables to set in `compose/.env`, please also check [documentation](https://github.com/hallowelt/docker-bluespice-wiki/blob/main/README.md) of the image behind the wiki-containers.

If the environment variable `DEV_WIKI_DEBUG` is set, one can set the `debug-entrypoint` GPC (=`$_REQUEST`) to a value matching the `MW_ENTRY_POINT` constant in context of the application to enable full debug log to `stdout` for any call to the specified entry point.

## Run BlueSpice for Development
- This layout is based on ["Multi-container Applications docker-compose, Targeting multiple environments"](https://learn.microsoft.com/en-us/dotnet/architecture/microservices/multi-container-microservice-net-applications/multi-container-applications-docker-compose#targeting-multiple-environments)
- The later-loaded docker compose commands will override those earlier-loaded ones. Please be aware of this feature, and make use of it sufficiently. 

### Step 1: load this repo
Enter your chosen base path, e.g `/workspace/bs/`, run
```sh
git clone https://github.com/hallowelt/bluespice-deploy.git -b dev
```
#### Optional: build your own image (content under construction, not applicable for now)
First you need to handle the image for the web and task containers of the wiki, which is a bit special. 
After running `git clone https://github.com/hallowelt/docker-bluespice-wiki.git -b dev`, you need to:
- run `mkdir -p docker-bluespice-wiki/_codebase/bluespice` to make a empty bluespice directory. For development usage, it would be more convenient to map the codebase from the host machine in to the containers. 
- clone a published version SimpleSAMLPHP to `docker-bluespice-wiki/_codebase/simplesamlphp`, see `docker-bluespice-wiki/README.md`. 

Then you can run `docker build -t bs-wiki-dev:4.5.x docker-bluespice-wiki` as well as the following commands:

```sh
git clone https://github.com/hallowelt/docker-bluespice-database.git -b main && docker build -t bluespice/database:4.5.x docker-bluespice-database
git clone https://github.com/hallowelt/docker-bluespice-search.git -b 4.5.x && docker build -t bluespice/search:4.5.x docker-bluespice-search
git clone https://github.com/hallowelt/docker-bluespice-cache.git -b main && docker build -t bluespice/cache:4.5.x docker-bluespice-cache
git clone https://github.com/hallowelt/docker-bluespice-proxy.git -b main && docker build -t bluespice/proxy:4.5.x docker-bluespice-proxy
git clone https://github.com/hallowelt/docker-bluespice-pdf.git -b main && docker build -t bluespice/pdf:4.5.x docker-bluespice-pdf
git clone https://github.com/hallowelt/docker-bluespice-formula.git -b main && docker build -t bluespice/formula:4.5.x docker-bluespice-formula
```
If you are running pro or farm version (need access to https://gitlab.hallowelt.com), please also run
```sh
git clone https://github.com/hallowelt/docker-bluespice-diagram.git -b main && docker build -t bluespice/diagram:4.5.x docker-bluespice-diagram
git clone https://github.com/hallowelt/docker-bluespice-collabpads.git -b main && docker build -t bluespice/collabpads:4.5.x docker-bluespice-collabpads
```
After building all these images, you can proceed with the following steps. 

Building every image on you own can be a helpful practice, when you would like to precisely control the versions of images you use. 
Of course one can also turn to remote images for developing instead (need to make sure that the names of images you use exist remotely).

### Step 2: prepare codebase
Enter your chosen base path, then clone your wanted version and edition of BlueSpice. For example: 
- BlueSpice Free edition, version 5.2.0-alpha: `git clone -b REL1_43 https://github.com/hallowelt/mediawiki.git code`
- BlueSpice Free edition, version 5.1.0: `git clone -b 5.1.0 https://github.com/hallowelt/mediawiki.git code`
- BlueSpice Pro edition, version 5.2.0-alpha: `git clone -b REL1_43 git@gitlab.hallowelt.com:BlueSpice/mediawiki.git code`
- BlueSpice Farm edition, version 5.2.0-alpha: `git clone -b REL1_43 git@gitlab.hallowelt.com:BlueSpiceFarm/mediawiki.git code`

To clone codebase of Pro and Farm editions, you need access to https://gitlab.hallowelt.com .

The codebase is not yet ready for running right after being cloned. To initialize the codebase, you need to use php and composer from your host machine:
```sh
cd code && composer clear-cache && composer update --with-dependencies --prefer-source
```
Alternatively, you can also use a built codebase (e.g unzip a published code package). 

### Step 3: configure environment
Set up `bluespice-deploy-dev/compose/.env` in this project, taking reference of `.env.sample`. 
Please make sure that you fill in correct (absolute) path names of your code and data directories. 

Before running the containers, you still need to configure hostname and its certificate:
#### Hostname
Assume that you would like to use `mydev.localhost` as your hostname. Add the following line to `/etc/hosts`:
```sh
127.0.0.1 mydev.localhost
```
#### SSL Certificates
Inside the `${DATADIR}/proxy/certs` directory, run the following command to generate a self-signed certificate for `mydev.localhost`:
```sh
sudo openssl req -x509 -newkey rsa:4096 -keyout mydev.localhost.key -out mydev.localhost.crt -sha256 -days 3650 -nodes -subj "/C=XX/ST=StateName/L=CityName/O=CompanyName/OU=CompanySectionName/CN=CommonNameOrHostname"

sudo chown 1000:1000 mydev.localhost.*
```

### Step 4: run the containers
At the first run please use `./bluespice-deploy pull`, so that the Docker engine uses your locally built images (rather than pulling from remote registries).

When you are sure that no conflicting containers are listed in `docker ps`, you can run the start-up command:
```sh
./bluespice-deploy up -d
```

## Development with your installation
You can now access the application via `https://mydev.localhost`.
All changes to the codebase will be reflected instantly.

The default user is `Admin`, and its random password is written in `${DATADIR}/wiki/adminPassword`.

### Helpful link paths:
- Articles: `https://mydev.localhost/wiki/$1`
- Scripts: `https://mydev.localhost/w`
- Mailhog: `https://mydev.localhost/_mailhog/`
- PHPMyAdmin: `https://mydev.localhost/_dbadmin/`
- OpenSearch Dashboards: `https://mydev.localhost/_searchdashboards/`
- MongoDB: `https://mydev.localhost/_mongodbadmin/`
- Terminal: `https://mydev.localhost/_terminal/`
There are also many other services considered in this project, for example a variety of identification services. Please browse and edit `compose/docker-compose.dev.yml` to fit your specific needs. 
### Debugging
If the environment variable `DEV_WIKI_DEBUG` is set, one can set the `debug-entrypoint` GPC (=`$_REQUEST`) to a value matching the `MW_ENTRY_POINT` constant in context of the application to enable full debug log to `stdout` for any call to the specified entry point.
### Using Xdebug with your IDE
In the wiki image used for `wiki-web` and `wiki-task` containers, Xdebug is enabled and will try to communicate with your IDE: it connects to the localhost of your client on port `9003`, which is the port your IDE should listen to. Please configure port, IDE type and other settings in `docker-bluespice-wiki/99-dev.ini`.
#### VSCode
- Use your base path as the VSCode workspace
- Install plugin "PHP Debug" by Xdebug, go to "Run and debug" panel, select "create a launch.json file". This will add several configs to `.vscode/launch.json` of your working repo. 
- Modify path mappings as the example below. 
- Now click "Listen for Xdebug" in your "Run and debug" panel, and you will receive corresponding information.
```json
{
    "version": "0.2.0",
    "configurations": [

        {
            "name": "Listen for Xdebug",
            "type": "php",
            "request": "launch",
            "port": 9003,
            "pathMappings": {
                "/app/bluespice/w": "${workspaceFolder}/code",
                "/data": "${workspaceFolder}/data/wiki"
            }
        }
    ]
}
```
#### PHPStorm
- Install chrome xdebug helper: https://chromewebstore.google.com/detail/xdebug-helper/eadndfjplgieldjbigjakmdgkmoaaaoc?pli=1 and enable listening for PHP Debug connections.
- In PHPStorm also start listening for PHP Debug connections.
- Set breakpoint somewhere in your code and open the page in your browser. 
- The debugger should show prompt about accepting incoming connection. Accept it.
- In PHPStorm: Settings -> PHP -> Serves -> check use path mappings.
- There should be an entry after debugging the first time and accepting prompt.
- under "File/Directory" choose your code directory -> Under "Absolute path on the server" set it to "/app/bluespice/w".
#### Troubleshooting 
For example, you can add `xdebug_info();` to your `index.php` to output an information table about Xdebug. It is a know issue that `xdebug.var_display_max_depth=10` will bring problems to e.g creation of a book, though the mechanism is not quite clear. 

On MacOS with Docker Desktop, mapping of directories from host machine into containers does not work, even if the permissions are correctly set. 
### Adjusting `php.ini` settings
You change `php.ini` settings by rebuilding the main image in `docker-bluespice-wiki`. For example, the wiki image uses `date.timezone=Europe/Berlin` by default, but if you write `date.timezone=UTC` in `99-dev.ini`, that will be the final rule that applies. Containers will of course need to be restarted to apply the changes. 
