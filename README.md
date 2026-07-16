# Enchant

*Authenticated authorization for HTTP*

[![Hippocratic License HL3-CORE](https://img.shields.io/static/v1?label=Hippocratic%20License&message=HL3-CORE&labelColor=5e2751&color=bc8c3d)](https://firstdonoharm.dev/version/3/0/core.html)

Enchant provides authenticated authorization for HTTP requests, particularly intended to be enforced by a Sky HTTP intermediary. It uses a policies document to define a dictionary between domains and policies, where each policy consists of request and response rules evaluated against conditions, loading context, and performing actions.

## Features

- **Policy-based authorization:** Define request and response rules for domains using a simple YAML schema.
- **Dynamic Context:** Load context properties when conditions are met to enrich actions.
- **Rune Integration:** Generate and verify Runes (cryptographic capabilities) for secure, least-privilege authorization.
- **Caching Support:** Built-in caching policies with cache-control parsing and invalidation.
- **Extensible:** Easily add new default context properties and condition/action types.

## Installation

```bash
pnpm install @dashkite/enchant
```

## Usage

Here is a basic example of setting up Enchant with a set of policies and an authorization scheme.

```coffeescript
import { enchant } from "@dashkite/enchant"
import cache from "some-cache-implementation"

# Define policies
policies = [
  request: [
    conditions: [ name: "authorize" ]
    actions: [ name: "forward" ]
  ]
]

# Create the enchanted handler
handler = enchant { policies, authorization: "rune", cache }

# Process a request
# result = await handler request
```

## Other Resources

- [Reference](docs/reference.md)
- [Recipes](docs/recipes.md)
- [Technical Notes](docs/technical-notes.md)
- [Testing](docs/testing.md)
