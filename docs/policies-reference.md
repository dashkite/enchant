# Enchant Policies

Enchant Policies are intended to be enforced by a Sky HTTP intermediary. A policies document defines a dictionary between domains and policies. Each domain may have an array of request and response polices. 

- Request policies are applied to requests for that domain, while response policies are applied to the response.
- Each policy consists of an array of rules. Each rule consists of a context, a condition, and an action. 
- For each rule, the context is loaded, the condition is evaluated, and, if satisfied, the action is performed. The context and condition are optional. If there’s no condition, the action will always be performed.

An example of a request policy might be something like this:

> If the authentication scheme is `rune`, verify the rune. If the verification succeeds, forward the request to the origin and set the response to the origin response. Otherwise, set the response to `403 Forbidden` response.

If a rule produces a response, no further request rules are evaluated and we begin evaluating response rules.

> Future versions of Enchant may make this behavior an optional configuration option for a policy.

An example of a response policy might be something like this:

> If the response is a 200, add a header with a given credential.

## Resources

- [Schema Reference](./policies.schema.md)

## Expressions

Rules may use [Polaris](https://github.com/dashkite/polaris#polaris) expressions in context properties or condition and action inputs.

## Context Properties

The polcy context is initially populated with the request and response objects, normalized per the Sublime schema. The request includes a Sky resource description. Additional properties may be added by provide an array of property objects. Each object includes a name and expression.

> **Todo:** Define schemas for Sublime request and response objects and the Sky resource description and link to them.

### Example

```yaml
name: email
expression: ${ request.resource.bindings.email }
```

[View the schema.](./policies.schema.md#reference-property)

## Conditions

Conditions are specified by name with an optional input.

### Request Conditions

| Name          | Input                             | Description                                                  |
| ------------- | --------------------------------- | ------------------------------------------------------------ |
| authorization | Authorization scheme, ex: `rune`. | Match the authorization scheme, as parsed from the [authorization request header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Authorization#syntax). |
| bindings      | Resource bindings dictionary.     | Match the given resource bindings against those of the request. All the given bindings must match, but any other bindings in the request are considered matched, as though they were wildcard matches. |

### Response Conditions

| Name   | Input                         | Description                                             |
| ------ | ----------------------------- | ------------------------------------------------------- |
| status | Integer or array of integers. | Match the response status against the given status(es). |

### Request And Response Conditions

| Name     | Input                                                        | Description                                                  |
| -------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| resource | An object with optional `include` and `exclude` properties consisting of arrays of resource names. | The resource name is matched against the `include` and `exclude` lists. The condition matches if the named resource is on the include list and not on the exclude list. Thus, it only makes sense to provide one or the other. |
| equal    | A object containing a name-value pair. The name refers to a context property and the value may be any value. | The named context property is matched against the given value. If the value is a non-scalar, deep equality is applied. |

### Future Conditions

More conditions will be added as needed. For example, a `match` condition would work similarly to `equal` but use a regular expression to match against instead of a value.

## Actions

### Request Actions

| Name      | Input                      |                                                              |
| --------- | -------------------------- | ------------------------------------------------------------ |
| authorize | -                          | Attempt to authorize the request based on the given authorization scheme. |
| respond   | A Sublime response object. | Generate a response to the request.                          |

### Response Actions

| Name   | Input                                                        | Description                                                  |
| ------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| cache  | A caching policy.                                            | Use the given caching policy to attach caching headers to the response. |
| header | A name-value pair, where the name is the name of a response header and the value is scalar. | Add a header to the response using the given name and value. Dates will be converted to ISO 8601 format. |

