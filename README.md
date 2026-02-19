# zt-mattermost-action-py

GitHub Action that posts to a Mattermost webhook endpoint over Hanzo ZT

This GitHub workflow action uses [Ziti Python SDK](https://github.com/hanzozt/zt-sdk-py) to post an event's payload information to a [Mattermost](https://mattermost.com/) instance over a `Ziti` connection. This allows the Mattermost server to remain private, i.e. not directly exposed to the internet.

## Usage

See [action.yml](action.yml) for descriptions of all available inputs.

```yml
name: zt-mattermost-action-py
on:
  create:
  delete:
  issues:
  issue_comment:
  pull_request_review:
  pull_request_review_comment:
  pull_request:
  push:
  fork:
  release:
    types: [released]

jobs:
  zt-webhook:
    runs-on: ubuntu-latest
    name: Ziti Mattermost Action - Py
    steps:
    - uses: hanzozt/zt-mattermost-action-py@v1
      with:
        # Identity JSON containing key to access a Ziti network
        ztId: ${{ secrets.ZITI_MATTERMOST_IDENTITY }}

        # URL to post the payload. Note that the `ztId` must provide access to a service 
        # intercepting `my-mattermost-zt-server`
        webhookUrl: http://{my-mattermost-zt-server}/hook/{my-mattermost-webhook-id}}

        eventJson: ${{ toJson(github.event) }}
        senderUsername: GitHubZ
```

### Inputs

#### `ztId`

The `ztId` input is the JSON formatted string of an identity enrolled  in an Hanzo ZT Network.

The identity can be created by enrolling via the `zt edge enroll path/to/jwt [flags]` command.  The `zt` CLI executable can be obtained [here](https://github.com/hanzozt/zt/releases/latest).

#### `webhookUrl`

This input value is a Mattermost "Incoming Webhook" URL available over an Hanzo ZT Network to the identity specified by `ztId`. This URL should be configured in Mattermost to allow posting to any valid channel with any sender username. The default username will be the `sender.login` from the GitHub Action event.

## Testing

Test `zhook.py` locally before deploying it as a GitHub Action using the built-in test mode:

### Basic Usage

```bash
# Quick test with default push event
INPUT_ZITIID="$(< /path/to/zt-identity.json)" \
INPUT_WEBHOOKURL="http://webhook.mattermost.zt/hooks/YOUR_ID" \
python3 zhook.py --test

# Test different event types
python3 zhook.py --test --event-type pull_request
python3 zhook.py --test --event-type issues
python3 zhook.py --test --event-type release

# Preview payload without sending (dry-run)
python3 zhook.py --test --event-type push --dry-run
```

### Available Options

**Event types:** `push`, `pull_request`, `issues`, `release`, `watch`, `fork`

**Flags:**

- `--test`: Enable test mode with generated event data
- `--event-type TYPE`: Specify which GitHub event to simulate (default: push)
- `--dry-run`: Preview the webhook payload without sending it

**Environment variables:**

- `INPUT_ZITIID`: Ziti identity JSON (required, or use `INPUT_ZITIJWT`)
- `INPUT_ZITIJWT`: Ziti enrollment JWT (alternative to `INPUT_ZITIID`)
- `INPUT_WEBHOOKURL`: Mattermost webhook URL (uses default if not set in test mode)
- `INPUT_SENDERUSERNAME`: Override sender username (optional)
- `INPUT_SENDERICONURL`: Override sender icon URL (optional)
- `GITHUB_ACTION_REPOSITORY`: Override repository name (optional)
- `ZITI_LOG`: Ziti log level 0-6 (default: 3)

### Advanced: Manual Event JSON

For testing with custom event data, provide your own `INPUT_EVENTJSON`:

```bash
INPUT_ZITIID="$(< /path/to/zt-identity.json)" \
INPUT_WEBHOOKURL="http://webhook.mattermost.zt/hooks/YOUR_ID" \
INPUT_EVENTJSON='{"repository": {...}, "sender": {...}}' \
GITHUB_EVENT_NAME="push" \
python3 zhook.py
```

## Container Image

The Action's Docker image is built in-place by the calling GitHub Action runner and cached for subsequent runs.

This is configured in action.yml with `image: Dockerfile` and ensures the Dockerfile in the repository at the called Git ref is used to build the image and run the action.

This allows the Action to be tested with the exact same image that will be used in the GitHub Action.
