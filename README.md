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
| `ANTIVIRUS`                  | `false`        | enables ClamAV antivirus service                     | Yes      |
| `LETSENCRYPT`                | `false`        | enables LetsEcrpyt cert renew                        | Yes      |
| `KERBEROS`                   | `false`        | enables Kerberos-Authentication                      | Yes      |
| `TZ`                         | `UTC`          | Timezone for BlueSpice and container system time     | Yes      |

For more variables to set in `compose/.env`, please also check [documentation](https://github.com/hallowelt/docker-bluespice-wiki/blob/main/README.md) of the image behind the wiki-containers.

If the environment variable `DEV_WIKI_DEBUG` is set, one can set the `debug-entrypoint` GPC (=`$_REQUEST`) to a value matching the `MW_ENTRY_POINT` constant in context of the application to enable full debug log to `stdout` for any call to the specified entry point.

## Development
Please check the [`dev` branch](https://github.com/hallowelt/bluespice-deploy/tree/dev) of this repo
