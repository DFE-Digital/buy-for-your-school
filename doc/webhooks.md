# Webhooks

We use Contentful webhooks to notify our application of new and updated content.

## Settings

The following are the minimal required settings for two types of webhook. Both are needed for each application environment to ensure the content there is up-to-date.

### Cache busting webhook

This webhook is triggered when any action is performed on a Contentufl entry, e.g. create, save, delete, etc.
This lets our application know that there has been a content change and the old version of the entry is deleted from the cache.

|              |                                    |
|--------------|------------------------------------|
| **Env**:     |`CONTENTFUL_ENVIRONMENT=staging`    |
| **Filter**:  |`sys.environment.sys.id == staging` |
| **Headers**: |`Authorization Token xxxxxx`        |
|              |`Content-Type application/json`     |

**Payload**:
```json
{
  "entityId": "{ /payload/sys/id }",
  "spaceId": "{ /payload/sys/space/sys/id }",
  "parameters": {
    "text": "Entity version: { /payload/sys/version }"
  }
}
```

### Published category webhook

This webhook is triggered when a `Category` entry has been (re)published.

|              |                                      |
|--------------|--------------------------------------|
| **Env**:     | `CONTENTFUL_ENVIRONMENT=staging`     |
| **Filters**: | `sys.environment.sys.id == staging`  |
|              | `sys.contentType.sys.id == category` |
| **Headers**: | `Authorization Token xxxxxx`         |
|              | `Content-Type application/json`      |
| **Payload**: | default                              |

## Open Tunnel via Ngrok

Working with incoming webhooks (i.e. contentful) can be made easier by using ngrok (https://ngrok.com/)

```
$ ngrok http 3000
```
Once connected you use the forwarding address for the incoming webhooks and route to the respective controller.

- Web interface will be available on http://localhost:4040 - allowing you view the raw payload of incoming requests.
