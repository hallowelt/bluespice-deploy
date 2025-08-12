# BlueSpice "Deploy"
<img style="display:block;margin:auto" src="https://bluespice.com/wp-content/uploads/2022/09/bluespice_logo.png" alt="BlueSpice MediaWiki" />
This repo contains deployment code for the BlueSpice Wiki application

Please see the [official helpdesk entry](https://en.wiki.bluespice.com/wiki/Setup:Installation_Guide/Docker) for more details.

For more Variables please also check:
https://github.com/hallowelt/docker-bluespice-wiki/blob/main/README.md
## Development
- Layout based on ["Multi-container Applications docker-compose, Targeting multiple environments"](https://learn.microsoft.com/en-us/dotnet/architecture/microservices/multi-container-microservice-net-applications/multi-container-applications-docker-compose#targeting-multiple-environments)


## Automated Update
To run the automated update use `./bluespice-deploy up -d --profile=upgrade`
Please see https://github.com/hallowelt/docker-bluespice-helper and 
[official uppgrade Documention](https://en.wiki5.bluespice.com/wiki/Setup:Installation_Guide/Update_from_4.5_to_5.1) for more information. 

## Debugging
If the environment variable `DEV_WIKI_DEBUG` is set, one can set the `debug-entrypoint` GPC (=`$_REQUEST`) to a value matching the `MW_ENTRY_POINT` constant in context of the application to enable full debug log to `stdout` for any call to the specified entry point.

## ENV vars

| Variable                     | Default Value  | Description                                          | Optional |
|------------------------------|----------------|------------------------------------------------------|----------|
| `DATADIR`                    | `./_volume`    | Path to persitent Volumes                            | Yes      |
| `ANTIVIRUS`                  | `false`        | enables ClamAV antivirus service                     | Yes      |
| `LETSENCRYPT`                | `false`        | enables LetsEcrpyt cert renew                        | Yes      |
| `KERBEROS`                   | `false`        | enables Kerberos-Authentication                      | Yes      |
| `BLUESPICE_WIKI_IMAGE`       | ``             | define custom imagepath for wiki-containers          | Yes      |
| `SERVICES_REPOSITORY_PATH`   | ``             | define custom Services-Repo (mostly for Testing)     | Yes      |
| `TZ`                         | `UTC`          | Timezone for BlueSpice and container system time     | Yes      |
