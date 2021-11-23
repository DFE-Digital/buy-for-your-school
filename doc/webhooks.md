# Webhooks

We use Contentful webhooks to notify our application of new and updated content.

## Settings

The following are the minimal required settings for two types of webhook. Both are needed for each application environment to ensure the content there is up-to-date.

### Cache busting webhook

This webhook is triggered when any action is performed on a Contentufl entry, e.g. create, save, delete, etc.
This lets our application know that there has been a content change and the old version of the entry is deleted from the cache.

|              |                                     |
| ------------ | ----------------------------------- |
| **Env**:     | `CONTENTFUL_ENVIRONMENT=staging`    |
| **Filter**:  | `sys.environment.sys.id == staging` |
| **Headers**: | `Authorization Token xxxxxx`        |
|              | `Content-Type application/json`     |

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
| ------------ | ------------------------------------ |
| **Env**:     | `CONTENTFUL_ENVIRONMENT=staging`     |
| **Filters**: | `sys.environment.sys.id == staging`  |
|              | `sys.contentType.sys.id == category` |
| **Headers**: | `Authorization Token xxxxxx`         |
|              | `Content-Type application/json`      |
| **Payload**: | default                              |

### Published page webhook

This webhook is triggered when a `Page` entry has been (re)published.

|              |                                     |
| ------------ | ----------------------------------- |
| **Env**:     | `CONTENTFUL_ENVIRONMENT=staging`    |
| **Filters**: | `sys.environment.sys.id == staging` |
|              | `sys.contentType.sys.id == page`    |
| **Headers**: | `Authorization Token xxxxxx`        |
|              | `Content-Type application/json`     |
| **Payload**: | default                             |

### Deleted page webhook

This webhook is triggered when a `Page` entry has been deleted or unpublished.

|              |                                     |
| ------------ | ----------------------------------- |
| **Env**:     | `CONTENTFUL_ENVIRONMENT=staging`    |
| **Filters**: | `sys.environment.sys.id == staging` |
|              | `sys.contentType.sys.id == page`    |
| **Headers**: | `Authorization Token xxxxxx`        |
|              | `Content-Type application/json`     |
| **Payload**: | default                             |

## Open Tunnel via Ngrok

Working with incoming webhooks (i.e. contentful) can be made easier by using [ngrok](https://ngrok.com/). The easiest way to install ngrok is probably through brew (`$ brew install ngrok`), otherwise docs can be found [here](https://dashboard.ngrok.com/get-started/setup) upon setting up a free account.

Upon starting the local server (`$ script/server`), you can then run ngrok:

```
$ ngrok http https://localhost:3000
```

Once connected, you use the forwarding address which appears in the terminal for the incoming webhooks and route to the respective controller. With a free ngrok account, the forwarding address for each developer is different every time, so the webhooks in Contentful will need to be updated regularly.

To avoid any confusion, and adopt a common convention, the name of the developer can be used when naming the webhook in Contentful.

- Web interface will be available on http://localhost:4040 - allowing you view the raw payload of incoming requests.
