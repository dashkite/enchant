# Reference

## Policy Schema

Enchant policies are the core mechanism used for determining request routing and response handling. A policies document defines a dictionary between domains and policies. 

Policies can be defined directly in code using standard language data structures (such as arrays and objects), or they can be stored and loaded as YAML documents. 

At the top level, the Enchant schema is a map of domains to an array of properties.

- Each policy has `request` and `response` properties whose values are arrays of rules.
- Each rule may have `conditions`, `context`, and `actions` properties whose values are arrays of clauses.
- Each clause must have a `name` property and may have a resolver, either a `value` or an `action` property.
- The `name` property must be text. The `value` property must be a template. The `action` property is another clause.
- A template may be an array, object, or scalar. Text values, including when nested, may include Polaris expressions.

Clauses are evaluated differently, depending on where they're used.

- Within `conditions`, the `name` refers to a condition function and the resolver to its operand, if any.
- Within `context`, the `name` refers to the context property and the resolver to its value.
- Within `actions`, the `name` refers to an action function and the resolver to its operand, if any.

Conditions are evaluated first to determine whether the context and action clauses should be evaluated. If the conditions are satisfied, the context clauses are evaluated, enriching the context available for the actions. Finally, the action clauses are evaluated.

### Conditions

Condition functions return a boolean value: if they evaluate to true, the condition is satisfied, otherwise it is not.

#### Request Conditions

| Name      | Input                             | Description                                                  |
| --------- | --------------------------------- | ------------------------------------------------------------ |
| authorize | Authorization scheme, ex: `rune`. | Match the authorization scheme, as parsed from the authorization request header. |
| bindings  | Resource bindings dictionary.     | Match the given resource bindings against those of the request. All the given bindings must match, but any other bindings in the request are considered matched. |

#### Response Conditions

| Name   | Input                         | Description                                             |
| ------ | ----------------------------- | ------------------------------------------------------- |
| status | Integer or array of integers. | Match the response status against the given status(es). |

#### Request And Response Conditions

| Name     | Input                                                        | Description                                                  |
| -------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| resource | An object with optional `include` and `exclude` properties consisting of arrays of resource names. | The condition matches if the named resource is on the include list and not on the exclude list. |
| method   | An object with optional `include` and `exclude` properties consisting of arrays of method names. | The condition matches if the named method is on the include list and not on the exclude list. |
| is equal | A object containing a name-value pair. The name refers to a context property and the value may be any value. | The named context property is matched against the given value. If the value is a non-scalar, deep equality is applied. |
| match    | A object containing a name-value pair, where name refers to a context property and the value is a regular expression. | The named context property is matched against the given regular expression. The property must be text. |

#### Example

```yaml
name: resource
value:
  exclude:
    - accounts
```

### Context

Context clauses describe properties to add to the context. The context is initially populated with the request and response objects, normalized per the Sublime schema. The request includes a Sky resource description.

> [!NOTE]
> Define schemas for Sublime request and response objects and the Sky resource description and link to them.

> [!IMPORTANT]
> The context is only evaluated based if the conditions are satisifed, to avoid unnecessary processing. If a condition requires additional context, you may precede it with a rule that has no conditions or actions.
>
> Properties added to the context are carried over between rules. Context is never discarded until the policy has been fully evaluated and a response has been sent to the client.

#### Example

```yaml
name: email
value: ${ request.resource.bindings.email }
```

### Actions

Actions may be used to create or update responses or, when used as resolvers, to dynamically add data to the context.

#### General Actions

| Name       | Input                                                        | Description                                                  | Returns                                |
| ---------- | ------------------------------------------------------------ | ------------------------------------------------------------ | -------------------------------------- |
| respond    | A Sublime response object.                                   | Generate a response to the request.                          | The generated response.                |
| request    | A Sublime request object.                                    | Make a request for a resource, typically to add to the context. | The Sublime response from the request. |
| issue rune | A policy property, whose name is the value of a named Rune and the value (or action generating it) describe any applicable bindings for the Rune. | Generates (and signs) a Rune.                                | The generated Rune.                    |

#### Response Actions

Response actions require a response to be available in the context.

| Name           | Input                                                        | Description                                                  | Returns                          |
| -------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | -------------------------------- |
| cache          | A caching policy.                                            | Use the given caching policy to attach caching headers to the response. | The resulting modified response. |
| append headers | A list of policy properties, where the names are the name of a response header and the values are scalars. | Add headers to the response using the given name and value. Dates will be converted to ISO 8601 format. | The resulting modified response. |

#### Example

```yaml
name: respond
value:
  description: not found
```

### Named Runes

The `issue rune` action takes a policy property as its value. The name of this property references a named Rune. These are considered to be external to the policies themselves. Eventually, these may become URLs (or resource descriptions), where the names are simply aliases. We could thus generalize incorporating external resources into policies. We could also do away with this action in favor of a request action.

### Complete Policy Example (YAML)

Enchant policies are most commonly defined and stored as YAML documents. Below is a moderately sized example showcasing a combined request and response pipeline.

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
              email: ${ email }
    actions:
      - name: append headers
        value:
          - name: sky-rune
            value: ${ credential.rune }
          - name: sky-nonce
            value: ${ credential.nonce }
```

## Core API

### enchant

$enchant: [options] \to decorator$

Creates a request decorator configured with authorization rules and caching policies.

```coffeescript
import { enchant } from "@dashkite/enchant"
import assert from "@dashkite/assert"

cache = new Map()
handler = enchant { policies: [], authorization: "rune", cache }

assert.equal typeof handler, "function"
```

### Registry

The `Registry` object handles the registration of custom condition, context, and action types.

#### register

$register: [keys, value] \to \emptyset$

Registers a custom action or condition.

```coffeescript
import { Registry } from "@dashkite/enchant"
import assert from "@dashkite/assert"

Registry.register [ "actions", "customAction" ], ( result, context ) -> "modified"
assert.equal ( Registry.lookup [ "actions", "customAction" ] )?, true
```

#### lookup

$lookup: [keys] \to value$

Retrieves a registered action or condition.

```coffeescript
import { Registry } from "@dashkite/enchant"
import assert from "@dashkite/assert"

action = Registry.lookup [ "actions", "customAction" ]
assert.equal typeof action, "function"
```

### Policies

The `Policies` object handles the execution of policy rules.

#### apply

$apply: [options, request] \dashrightarrow response$

Applies the loaded policies to a given HTTP request, evaluating conditions and triggering actions.

```coffeescript
import { Policies } from "@dashkite/enchant"
import assert from "@dashkite/assert"

policies = [ request: [ actions: [ name: "respond", value: description: "forbidden" ] ] ]
response = await Policies.apply { policies }, { method: "get", resource: { name: "test" } }

assert.equal response.description, "forbidden"
```

### Action

The `Action` object handles evaluating specific action clauses.

#### apply

$apply: [action, context] \dashrightarrow result$

Evaluates a single action recursively if nested, applying context expansions and looking up the action logic in the registry.

```coffeescript
import { Action } from "@dashkite/enchant"
import assert from "@dashkite/assert"

context = { request: {}, registry: {}, env: {} }
result = await Action.apply { name: "respond", value: status: 200 }, context

assert.equal result.status, 200
```

### Cache

The `Cache` module handles request/response caching when integrated into policies.

#### initialize

$initialize: [cache] \to \emptyset$

Initializes the cache implementation used by the Enchant system.

#### cache

$cache: [options, handler] \dashrightarrow response$

Retrieves a cached response if one exists, otherwise defers to the handler.

#### set

$set: [request, response] \dashrightarrow response$

Sets a cache entry for a given cacheable GET request if cache directives allow it.

#### invalidate

$invalidate: [value, context] \dashrightarrow \emptyset$

Invalidates cached entries corresponding to specific requests.
