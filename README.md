# BlueSpice "Deploy"
<img style="display:block;margin:auto" src="https://bluespice.com/wp-content/uploads/2022/09/bluespice_logo.png" alt="BlueSpice MediaWiki logo" />
Toolkit for containerized deployment of BlueSpice Wiki.

## Deployment
Please follow the [installation guide](https://en.wiki5.bluespice.com/wiki/Setup:Installation_Guide/Docker) in the BlueSpice Helpdesk 📚. For questions and support, please use the contact [form 🌐](https://bluespice.com/contact/) or visit the [community forums 💡](https://community.bluespice.com/).

## Upgrade to BlueSpice 6
For an existing BlueSpice 5.x installation using `bluespice-deploy`, an automated upgrade is possible.
In that case, `./bluespice-deploy up -d --profile=upgrade` should be used. The upgrade runs once, before the
stack is started. `--profile=upgrade-force` forces a rerun. See `${DATADIR}/wiki/bluespice/logs/backend_upgrade_6.log`
for the log. Upgrades from older versions (e.g. 4.5.x) are not supported, upgrade to 5.x first.

## Configuration
| Variable Name                | Default Value  | Description                                          | Optional |
|------------------------------|----------------|------------------------------------------------------|----------|
|`BLUESPICE_SERVICE_REPOSITORY`| `bluespice`    | pull Docker images from an alternative service repo  | Yes      |
| `SERVICES_REPOSITORY_PATH`   | none           |a previous alias to set `BLUESPICE_SERVICE_REPOSITORY`| Yes      |
| `BLUESPICE_WIKI_IMAGE`       |edition-specific| use an alternative image for the wiki-containers     | Yes      |
| `COMPOSE_PROJECT_NAME`       | `bluespice`    | use an alternate-docker-compose-name                 | Yes      |
| `DATADIR`                    | `./_volume`    | Path to persitent Volumes                            | Yes      |
| `ANTIVIRUS`                  | `false`        | enables ClamAV antivirus service                     | Yes      |
| `LETSENCRYPT`                | `false`        | enables LetsEcrpyt cert renew                        | Yes      |
| `KERBEROS`                   | `false`        | enables Kerberos-Authentication                      | Yes      |
| `TZ`                         | `UTC`          | Timezone for BlueSpice and container system time     | Yes      |
| `CHAT`                       | `false`        | enables [Chat service connection](https://en.wiki.bluespice.com/wiki/Manual:Extension/ChatBot)                          | Yes      |
| `AI`                         | `false`        | enables [AI service connection](https://en.wiki.bluespice.com/wiki/Manual:AI_integrations_-_Overview)                              | Yes      |
| `ADMIN_MAIL`                 | none           | contact e-mail for LetsEncrypt certificates          | No, if `LETSENCRYPT` is `true` |
| `RESTART_POLICY`             | `unless-stopped` | restart policy of the long-running services        | Yes      |
| `RUN_BACKUP`                 | `false`        | enables the backup container (`backup` service)      | Yes      |
| `BACKUPDIR`                  | `${DATADIR}/backup` | path to the backups on the host                 | Yes      |
| `CHATBOT_OAUTH_CLIENT_ID`    | none           | client ID of the OAuth consumer the chatbot uses to act on behalf of users, see [Chatbot OAuth consumer](#chatbot-oauth-consumer) | Yes |
| `CHATBOT_OAUTH_CLIENT_SECRET`| none           | client secret of the OAuth consumer of the chatbot, see [Chatbot OAuth consumer](#chatbot-oauth-consumer) | Yes |
| `PARALLEL_RUNJOBS_SERVICE_LOGLEVEL` | `error` (`WIKI_LOG_LEVEL` of the image) | log level of the job runner in `wiki-task` (`debug`, `info`, `notice`, `warn`, `error`) | Yes |

For more variables to set in `compose/.env`, please also check [documentation](https://github.com/hallowelt/docker-bluespice-wiki/blob/main/README.md) of the image behind the wiki-containers.

## MCP server
The MCP server (`<wiki>/_mcp/`) has no access to the wiki on its own. The tools run on behalf of the users, with
their permissions, using OAuth2. The MCP server has no OAuth2 client of its own and needs no configuration in
`compose/.env`. Instead, each MCP client (e.g. Claude Desktop) is registered on the wiki as an OAuth2 consumer. After the
installation, an administrator:

1. Proposes the consumer at `Special:OAuthConsumerRegistration/propose/oauth2` on the wiki (on the main wiki in a
   farm). The account needs a valid email address.
   - OAuth "callback" URL: the one of the MCP client, e.g. `http://localhost:3334/oauth/callback` for `mcp-remote`
   - "This consumer is for use only by …" (owner-only): not checked
   - Client is confidential: checked
   - Allowed OAuth2 grant types: "Authorization code" and "Refresh token"
   - Applicable grants: "Basic rights", "Edit existing pages", "Create, edit, and move pages" and
     "Delete pages, revisions, and log entries"
2. Approves the consumer at `Special:OAuthManageConsumers/proposed`.
3. Hands the client key and the client secret (shown only once) over to the users, who configure them in their
   MCP client.

## Chatbot OAuth consumer
With `AI` enabled, the chatbot calls the MCP server on behalf of the users. It needs an OAuth consumer on the
wiki with the callback URL `<WIKI_PROTOCOL>://<WIKI_HOST><WIKI_BASE_PATH>_chat/oauth/callback`. After the
installation, create it with the maintenance script `extensions/WikiMCPTools/maintenance/createChatbotOAuthConsumer.php`
(run in `wiki-task`), which prints the client ID and the client secret.
Set them in `compose/.env` and recreate the AI service:
```
CHATBOT_OAUTH_CLIENT_ID=<client ID>
CHATBOT_OAUTH_CLIENT_SECRET=<client secret>
```
```
./bluespice-deploy up -d ai
```

If the environment variable `DEV_WIKI_DEBUG` is set, one can set the `debug-entrypoint` GPC (=`$_REQUEST`) to a value matching the `MW_ENTRY_POINT` constant in context of the application to enable full debug log to `stdout` for any call to the specified entry point.
