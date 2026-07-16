# Usage Guides and Recipes

## Implementing a Default Deny Policy

This task establishes a fundamental security baseline by blocking all unauthenticated traffic while forwarding valid requests to the underlying services.

Enchant evaluates request rules sequentially. By placing an authorization check first and a catch-all rejection rule second, any request that bypasses the first rule due to invalid credentials automatically triggers the second rule and is denied.

```coffeescript
import { enchant } from "@dashkite/enchant"
# cache implementation goes here
# cache = initializeCache()

policies = [
  request: [
    conditions: [ name: "authorize" ]
    actions: [ name: "forward" ]
  ,
    actions: [ 
      name: "respond"
      value:
        description: "forbidden"
    ]
  ]
]

handler = enchant { policies, authorization: "rune", cache }
```

**YAML Policy Definition:**

```yaml
request:
  - conditions:
      - name: authorize
    actions:
      - name: forward
  - actions:
      - name: respond
        value:
          description: forbidden
```

1. Evaluate the first rule to check if the `authorize` condition is satisfied (e.g., the request has a valid rune).
2. If the condition is met, execute the `forward` action, skip any subsequent rules, and send the request to the origin.
3. If the condition fails, proceed to the second rule.
4. Execute the `respond` action in the second rule to return a `403 Forbidden` response to the client.

## Restricting Access by HTTP Method

This task allows read-only access (GET requests) for the public, but requires strict authorization for any mutating requests (POST, PUT).

The `method` condition enables Enchant to filter rules based on the HTTP verb. By combining this with the `authorize` condition, you can segment permissions cleanly within a single policy.

```coffeescript
import { enchant } from "@dashkite/enchant"
# cache implementation goes here
# cache = initializeCache()

policies = [
  request: [
    # Allow GET requests unconditionally
    conditions: [ 
      name: "method"
      value: 
        include: [ "get" ] 
    ]
    actions: [ name: "forward" ]
  ,
    # Require authorization for all other requests
    conditions: [ name: "authorize" ]
    actions: [ name: "forward" ]
  ,
    # Default Deny
    actions: [ 
      name: "respond"
      value:
        description: "forbidden"
    ]
  ]
]

handler = enchant { policies, authorization: "rune", cache }
```

**YAML Policy Definition:**

```yaml
request:
  - conditions:
      - name: method
        value:
          include:
            - get
    actions:
      - name: forward
  - conditions:
      - name: authorize
    actions:
      - name: forward
  - actions:
      - name: respond
        value:
          description: forbidden
```

1. Evaluate the first rule to check if the request method is listed in the `include` array (i.e., `get`).
2. If it is a GET request, execute the `forward` action and skip remaining rules.
3. If it is not a GET request, proceed to the second rule and check the `authorize` condition.
4. If authorized, execute the `forward` action.
5. If unauthorized, fall back to the final rule and return a forbidden response.

## Enforcing Tenant Isolation via Resource Bindings

This task ensures that a user can only query resources that specifically belong to their assigned tenant workspace.

The `bindings` condition compares a provided dictionary against the actual bindings parsed from the request resource. This ensures that structural routing arguments strictly match the required authorization parameters.

```coffeescript
import { enchant } from "@dashkite/enchant"
# cache implementation goes here
# cache = initializeCache()

policies = [
  request: [
    conditions: [ 
      name: "bindings"
      value: 
        tenantId: "dashkite-core"
    ]
    actions: [ name: "forward" ]
  ,
    actions: [ 
      name: "respond"
      value:
        description: "forbidden"
    ]
  ]
]

handler = enchant { policies, authorization: "rune", cache }
```

1. Evaluate the first rule to verify that the request's resource bindings contain `tenantId: "dashkite-core"`.
2. If the bindings match, execute the `forward` action to proxy the request.
3. If the bindings do not match or are missing, proceed to the next rule.
4. Execute the `respond` action to deny access.

## Context-Aware Responses

This task provides a custom error message that dynamically references specific details parsed from the incoming request.

Enchant allows rules to load properties into a shared `context` object. Subsequent actions can interpolate these properties using Polaris expressions, enabling dynamic, context-aware configurations.

```coffeescript
import { enchant } from "@dashkite/enchant"
# cache implementation goes here
# cache = initializeCache()

policies = [
  request: [
    context: [
      name: "rejectedMethod"
      value: "${ request.method }"
    ]
    actions: [ 
      name: "respond"
      value:
        description: "Method ${ rejectedMethod } is not supported here."
    ]
  ]
]

handler = enchant { policies, authorization: "rune", cache }
```

1. Evaluate the rule. (Since there are no conditions, it executes unconditionally).
2. Evaluate the `context` clause by interpolating `${ request.method }` and assigning it to the `rejectedMethod` property in the shared context.
3. Evaluate the `actions` clause by interpolating `${ rejectedMethod }` into the `respond` description value.
4. Return the generated dynamic response to the client.

## Issuing Capability Tokens upon Successful Login

This task automatically generates a capability token (Rune) and attaches it to the response headers when a user successfully authenticates.

Response policies intercept the response from the origin server before it reaches the client. Using the `issue rune` action generates cryptographic capabilities on the fly, and `append headers` safely injects them into the HTTP response.

```coffeescript
import { enchant } from "@dashkite/enchant"
# cache implementation goes here
# cache = initializeCache()

policies = [
  response: [
    conditions: [ 
      name: "status"
      value: 200 
    ]
    context: [
      name: "credential"
      action:
        name: "issue rune"
        value:
          name: "dashkite db"
          value:
            email: "${ request.resource.bindings.email }"
    ]
    actions: [
      name: "append headers"
      value: [
        name: "sky-rune"
        value: "${ credential.rune }"
      ,
        name: "sky-nonce"
        value: "${ credential.nonce }"
      ]
    ]
  ]
]

handler = enchant { policies, authorization: "rune", cache }
```

**YAML Policy Definition:**

```yaml
response:
  - conditions:
      - name: status
        value: 200
    context:
      - name: credential
        action:
          name: issue rune
          value:
            name: dashkite db
            value:
              email: ${ request.resource.bindings.email }
    actions:
      - name: append headers
        value:
          - name: sky-rune
            value: ${ credential.rune }
          - name: sky-nonce
            value: ${ credential.nonce }
```

1. Evaluate the rule by checking if the origin response status is `200`.
2. If the status matches, execute the `context` clause.
3. Within the context clause, execute the nested `issue rune` action to generate a capability token using the `email` binding from the request. Assign the result to the `credential` property.
4. Execute the `append headers` action, interpolating the `rune` and `nonce` from the `credential` context object.
5. Return the modified response to the client.

## Applying Dynamic Cache Controls

This task attaches specific caching directives to successful read-only responses, improving performance without polling backend logic.

The `cache` response action allows the intermediary to decorate responses with cache policies conditionally. By tying this to the response `status`, we ensure errors are never accidentally cached.

```coffeescript
import { enchant } from "@dashkite/enchant"
# cache implementation goes here
# cache = initializeCache()

policies = [
  response: [
    conditions: [ 
      name: "status"
      value: 200 
    ]
    actions: [
      name: "cache"
      value:
        "max-age": 3600
        "public": true
    ]
  ]
]

handler = enchant { policies, authorization: "rune", cache }
```

1. Evaluate the rule by checking if the origin response status is `200`.
2. If the status matches, execute the `cache` action using the provided configuration (`max-age` and `public` flags).
3. The cache action parses and attaches standard HTTP `Cache-Control` headers to the response object.
4. Return the heavily cached response to the client.
