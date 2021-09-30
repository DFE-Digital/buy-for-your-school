## Webhooks

Working with incoming webhooks (i.e. contentful) can be made easier by using ngrok (https://ngrok.com/)

### Open Tunnel via Ngrok
```
$ ngrok http 3000
```
Once connected you use the forwarding address for the incoming webhooks and route to the respective controller.

- Web interface will be available on http://localhost:4040 - allowing you view the raw payload of incoming requests.
