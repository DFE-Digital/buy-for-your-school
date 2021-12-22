# Microsoft Graph

This library (currently located at `lib/microsoft_graph`) has been developed to aid with interacting with the Microsoft Graph API using ruby.

## Environment variables setup

|Env|Description|
|--|--|
|`MS_GRAPH_ENABLED`|Enable ms graph functionality pre-go live|
|`MS_GRAPH_TENANT`|Azure tenant id|
|`MS_GRAPH_CLIENT_ID`|Azure app registration client id|
|`MS_GRAPH_CLIENT_SECRET`|Azure app registration client secret|
|`MS_GRAPH_SHARED_MAILBOX_FOLDER_INBOX`|Name of shared folder Inbox - Usually just "Inbox"|
|`MS_GRAPH_SHARED_MAILBOX_FOLDER_SENT_ITEMS`|Name of shared folder Sent Items - Usually just "SentItems"|
|`MS_GRAPH_SHARED_MAILBOX_USER_ID`|Id of user to access shared mailbox|