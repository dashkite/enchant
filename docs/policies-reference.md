# Enchant Policies

Enchant Policies are intended to be enforced by a Sky HTTP intermediary. A policies document defines a dictionary between domains and policies. Each policy consists of an array of request and response rules.

- Request rules are applied to requests for that domain, while response rules are applied to the response.
- Each rule may include conditions, context, and actions. 
- For each rule, the conditions are evaluated, and, if satisfied, the context is loaded and the action is performed.

## Examples

### Request Policy

An example of a request policy might be something like this:

> If the authentication scheme is `rune`, verify the rune. If the verification succeeds, forward the request to the origin and set the response to the origin response. Otherwise, set the response to `403 Forbidden` response.

We would express this policy, like this:

```yaml
request:
  - conditions:
      - name: authorize
    actions:
      - name: forward
  # this acts as a default rule if no prior
  # rule results in a response
  - actions:
      - name: respond
        value:
          - description: forbidden
```

If a rule produces a response, no further request rules are evaluated and we begin evaluating response rules.

> Future versions of Enchant may make this behavior an optional configuration option for a policy. In particular, we could simply use a condition to check if there is a response. This would allow us to continuing firing request rules after a response is generated. However, up to now, we haven’t needed this. If it turns out at some point, we find a need for that, we can introduce a configuration property and have it default to the current behavior.

### Response Policy

An example of a response policy might be something like this:

> If the response is a 200, issue the `dashkite db` Rune and include it in the response header.

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
              email: ${ email }
    actions:
      - name: headers
        value:
          - name: sky-rune
            value: ${ credential.rune }
          - name: sky-nonce
            value: ${ credential.nonce }
```

### Enchant Schema

At the top level, the [Enchant schema](../src/policies.schema.yaml) is a map of domains to an array of properties.

- Each policy has `request` and `response` properties whose values are arrays of rules.
- Each rule may have `conditions`, `context`, and `actions` properties whose values are arrays of clauses.
- Each clause must have a `name` property and may have a resolver, either a `value` or an `action` property.
- The `name` property must be text. The `value` property must be a template. The `action` property is another clause.
- A template may be an array, object, or scalar. Text values, including when nested, may include [Polaris](https://github.com/dashkite/polaris#polaris) expressions.

Clauses are evaluated differently, depending on where they’re used.

- Within `conditions`, the `name` refers to a condition function and the resolver to its operand, if any.
- Within `context`, the `name` refers to the context property and the resolver to its value.
- Within `actions`, the `name` refers to an action function and the resolver to its operand, if any.

Conditions are evaluated first to determine whether the context and action clauses should be evaluated. If the conditions are satisfied, the context clauses are evaluated, enriching the context available for the actions. Finally, the action clauses are evaluated.

## Conditions

Condition functions return a boolean value: if they evaluate to true, the condition is satisfied, otherwise it is not.

### Request Conditions

| Name      | Input                             | Description                                                  |
| --------- | --------------------------------- | ------------------------------------------------------------ |
| authorize | Authorization scheme, ex: `rune`. | Match the authorization scheme, as parsed from the [authorization request header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Authorization#syntax). |
| bindings  | Resource bindings dictionary.     | Match the given resource bindings against those of the request. All the given bindings must match, but any other bindings in the request are considered matched, as though they were wildcard matches. |

### Response Conditions

| Name   | Input                         | Description                                             |
| ------ | ----------------------------- | ------------------------------------------------------- |
| status | Integer or array of integers. | Match the response status against the given status(es). |

### Request And Response Conditions

| Name     | Input                                                        | Description                                                  |
| -------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| resource | An object with optional `include` and `exclude` properties consisting of arrays of resource names. | The resource name is matched against the `include` and `exclude` lists. The condition matches if the named resource is on the include list and not on the exclude list. Thus, it only makes sense to provide one or the other. |
| method   | An object with optional `include` and `exclude` properties consisting of arrays of method names. | The request method is matched against the `include` and `exclude` lists. The condition matches if the named method is on the include list and not on the exclude list. Thus, it only makes sense to provide one or the other. |
| is equal | A object containing a name-value pair. The name refers to a context property and the value may be any value. | The named context property is matched against the given value. If the value is a non-scalar, deep equality is applied. |
| match    | A object containing a name-value pair, where name refers to a context property and the value is a regular expression. | The named context property is matched against the given regular expression. The property must be text. |

### Example

```yaml
name: resource
value:
  exclude:
  	- accounts
```

## Context

Context clauses describe properties to add to the context. The context is initially populated with the request and response objects, normalized per the Sublime schema. The request includes a Sky resource description.

> **Todo:** Define schemas for Sublime request and response objects and the Sky resource description and link to them.

>  **Important:** The context is only evaluated based if the conditions are satisifed, to avoid unnecessary processing. If a condition requires additional context, you may precede it with a rule that has no conditions or actions.
>
> **Important:** Properties added to the context are carried over between rules. Context is never discarded until the policy has been fully evaluated and a response has been sent to the client.

### Example

```yaml
name: email
value: ${ request.resource.bindings.email }
```

## Actions

Actions may be used to create or update responses or, when used as resolvers, to dynamically add data to the context.

### General Actions

| Name       | Input                                                        | Description                                                  | Returns                                |
| ---------- | ------------------------------------------------------------ | ------------------------------------------------------------ | -------------------------------------- |
| respond    | A Sublime response object.                                   | Generate a response to the request.                          | The generated response.                |
| request    | A Sublime request object.                                    | Make a request for a resource, typically to add to the context. | The Sublime response from the request. |
| issue rune | A policy property, whose name is the value of a named Rune and the value (or action generating it) describe any applicable bindings for the Rune. | Generates (and signs) a Rune.                                | The generated Rune.                    |

### Response Actions

Response actions require a response to be available in the context.

| Name           | Input                                                        | Description                                                  | Returns                          |
| -------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | -------------------------------- |
| cache          | A caching policy.                                            | Use the given caching policy to attach caching headers to the response. | The resulting modified response. |
| append headers | A list of policy properties, where the names are the name of a response header and the values (or the actions generating them) are scalars. | Add headers to the response using the given name and value. Dates will be converted to ISO 8601 format. | The resulting modified response. |

### Example

```yaml
name: respond
value:
  description: not found
```

## Named Runes

The `issue rune` action takes the a policy property as its value. The name of this property references as a named Rune. These are considered to be external to the policies themselves. Eventually, these may become URLs (or resource descriptions), where the names are simply aliases. We could thus generalize incorporating external resources into policies. We could also do away with this action in favor of a request action.

## Preservation Of Least Privilege

With Runes, request actions must also provide the supporting Runes to authorize them. We could do the same for policies, although we may need to bootstrap the available credentials. At least thus far, the requests we’re contemplating do not appear to represent a privilege escalation threat. For example, requesting a description of a Rune does not, by itself, represent a privilege escalation threat, since it must also be signed to be useful.

That said, we should be careful about allowing request actions. For this reason, they are currently disabled.

## Not In Scope

- Request or response normalization (to Sublime formats).
- Request or response header normalization.
- Enriching the request with the resource description (decoded from the URL).
- Returning 404, 405, 406, or 415 based on matching against the API description.

These responsibilities should all be handled before or after Enchant has executed the policies. For example, Enchant assumes that the requested resource can be satisfied by the origin. 

## Advantages

- Extensiblity: we can easily add new default context properties and condition and action types.
- Decoupling: services don’t need to worry about authorization or caching, among other things.
- Security: authorization happens in an isolated process space, which allows us to preserve least-privilege.

## Relationship To Other DashKite Technologies

### Web Queries

Policy rules are similar to Web Queries. They combine the query part with conditions and actions. We could possibly factor that out into a Web Query module, especially since we have the same functionality for Runes.

### Runes

Runes use a variant of Web Queries that preserves least-privilege, which we need to adapt to Enchant. Runes add conditions, although these tend to express authorization rules (ex: the subscription must be valid).

Given that both Enchant and Runes incorporate conditions into their use of Web Queries, we could also possibly pull this into its own module as well.

### Web Grants

While one of the benefits of Web Grants is reduce the need for Web Queries for authorization, they will still play a role in cases where using Web Signatures is too complicated. The proto-Web Query implementation in Enchant and Runes will thus help us commercialize Web Grants down the road.

### Polaris

We use Polaris to evaluate the values passed into context properties, conditions, and actions. Polaris currently relies on JSON Query, which works well enough for Node environments but doesn’t run in the browser (due to not having an ESM-friendly release). Unfortunately, the alternatives seem to have their own limitations. In addition, the available transformations are somewhat limited. In any event, the expression syntax is likely to change.

## Future

- Allow rule configuration to allow for variants of the main evaluation algorithm.
- Reduce the privileges for Enchant intermediaries to the minimum required to execute the policies.
- Add more default properties.
- Add more condition and action types.
- Allow conditions to be composed via booleans (presently we only support implicit AND). This could probably be done by simply adding `and`, `or`, and `not` actions. That gets a little verbose, though.
