# Webhooks

We use Contentful webhooks to notify the application when published content changes.

The application currently exposes a single webhook endpoint:

- `POST /contentful_webhooks`

This endpoint handles multiple Contentful entry types and actions by inspecting the standard Contentful webhook payload and the `X-Contentful-Topic` header.

## Supported Contentful content types

The webhook currently handles these Contentful content types:

- `solution`
- `redirect`

Any other content type is accepted but ignored.

## Supported Contentful topics

The webhook currently processes these topics:

- `ContentManagement.Entry.publish`
- `ContentManagement.Entry.unpublish`
- `ContentManagement.Entry.archive`
- `ContentManagement.Entry.delete`

Any other topic is accepted but ignored.

## Behaviour

### Solution entries

For `solution` entries:

- `ContentManagement.Entry.publish` updates the search index entry for the solution
- `ContentManagement.Entry.unpublish` removes the solution from the search index
- `ContentManagement.Entry.archive` removes the solution from the search index
- `ContentManagement.Entry.delete` removes the solution from the search index

### Redirect entries

For `redirect` entries:

- `ContentManagement.Entry.publish` invalidates the cached redirect list
- `ContentManagement.Entry.unpublish` invalidates the cached redirect list
- `ContentManagement.Entry.archive` invalidates the cached redirect list
- `ContentManagement.Entry.delete` invalidates the cached redirect list

## Contentful webhook configuration

Create one webhook per application environment.

Recommended minimal settings:

|              |                                     |
| ------------ | ----------------------------------- |
| **Env**:     | `CONTENTFUL_ENVIRONMENT=staging`    |
| **Filters**: | `sys.environment.sys.id == staging` |
|              | `sys.type == Entry`                 |
| **Headers**: | `X-Contentful-Webhook-Signature: xxxxxx` |
|              | `Content-Type: application/json`    |
| **Payload**: | default                             |

Notes:

- Use the default Contentful payload. The application reads `sys.id` and `sys.contentType.sys.id` from the request body.
- The custom header X-Contentful-Webhook-Signature must be added with a secure secret value.
- The webhook secret must match `CONTENTFUL_WEBHOOK_SECRET` in the Rails application.
- The `Content-Type` header must be set to `application/json` so Rails parses the webhook body into `params`.
- Set the environment filter to the correct Contentful environment for the target app, for example:
  - `sys.environment.sys.id == development`
  - `sys.environment.sys.id == master`
  - `sys.environment.sys.id == staging`
- Filtering to `sys.type == Entry` helps avoid irrelevant non-entry webhook traffic.
- Additional filters can be added if needed, but are not required by the application.

## Testing webhooks locally with ngrok

ngrok is a simple way to expose your local Rails application to Contentful.

Install ngrok on macOS with Homebrew:

```sh
brew install ngrok
```

Connect ngrok to your account:

```sh
ngrok config add-authtoken <your-authtoken>
```

Start the local Rails server first. If you are running Rails over HTTPS on port 3000:

```sh
script/server
```

Then start ngrok and point it at the local HTTPS app:

```sh
ngrok http https://localhost:3000
```

Use the HTTPS forwarding URL shown by ngrok as the base URL for the Contentful webhook, for example:

```text
https://<random-subdomain>.ngrok-free.app/contentful_webhooks
```

Notes:

- With a free ngrok account, the public URL usually changes when ngrok restarts.
- If the URL changes, update the webhook URL in Contentful.
- The local ngrok inspection UI is available at `http://localhost:4040`.
- The inspection UI is useful for checking headers, payload shape and delivery attempts.

## References

- [Ngrok quickstart](https://ngrok.com/docs/guides/share-localhost/quickstart)
- [Ngrok CLI reference](https://ngrok.com/docs/agent/cli)
