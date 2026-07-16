# Technical Notes

## Core Concepts

### Enchant Policies

Enchant Policies are intended to be enforced by a Sky HTTP intermediary (a server or edge function sitting between the client and the origin server). A policies document defines a dictionary between domains and policies. Each policy consists of an array of request and response rules.

- Request rules are applied to requests for that domain, while response rules are applied to the response.
- Each rule may include conditions, context, and actions.
- For each rule, the conditions are evaluated, and, if satisfied, the context is loaded and the action is performed.

This aligns with the [Policy-based Access Control (PBAC)](https://en.wikipedia.org/wiki/Policy-based_access_control) model, where dynamic context is evaluated alongside conditions to determine access.

### Request Policies

An example of a request policy might be:

> If the authentication scheme is `rune`, verify the rune. If the verification succeeds, forward the request to the origin and set the response to the origin response. Otherwise, set the response to `403 Forbidden` response.

If a rule produces a response, no further request rules are evaluated and we begin evaluating response rules.

### Response Policies

An example of a response policy might be:

> If the response is a 200, issue the `dashkite db` Rune and include it in the response header.

Response policies allow intermediaries to attach caching headers, sign tokens, or inject extra headers right before the response is returned to the client.

### Runes

Enchant extensively uses **Runes**, which are cryptographic capability tokens. Similar to Macaroons, they authorize a request while enforcing conditions and the [principle of least privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilege).

### HTTP Intermediaries and Edge Computing

By pushing authorization to an intermediary (a gateway or edge function), Enchant decouples the business logic inside the microservice from the authentication/authorization concerns. This is a well-established pattern within modern distributed systems and [Service Mesh](https://en.wikipedia.org/wiki/Service_mesh) architectures.

## Architecture & Implementation

### Preservation Of Least Privilege

With Runes, request actions must also provide the supporting Runes to authorize them. We could do the same for policies, although we may need to bootstrap the available credentials. At least thus far, the requests we're contemplating do not appear to represent a privilege escalation threat. For example, requesting a description of a Rune does not, by itself, represent a privilege escalation threat, since it must also be signed to be useful.

That said, we should be careful about allowing request actions. For this reason, they are currently disabled.

### Not In Scope

Enchant explicitly does not handle the following responsibilities, which should be handled before or after Enchant has executed the policies:

- Request or response normalization (to Sublime formats).
- Request or response header normalization.
- Enriching the request with the resource description (decoded from the URL).
- Returning 404, 405, 406, or 415 based on matching against the API description.

For example, Enchant assumes that the requested resource can be satisfied by the origin. 

### Advantages

- **Extensibility:** we can easily add new default context properties and condition and action types.
- **Decoupling:** services don't need to worry about authorization or caching, among other things.
- **Security:** authorization happens in an isolated process space, which allows us to preserve least-privilege.

## Integration & Ecosystem

### Relationship To Other DashKite Technologies

#### Web Queries

Policy rules are similar to Web Queries. They combine the query part with conditions and actions. We could possibly factor that out into a Web Query module, especially since we have the same functionality for Runes.

#### Runes

Runes use a variant of Web Queries that preserves least-privilege, which we need to adapt to Enchant. Runes add conditions, although these tend to express authorization rules (ex: the subscription must be valid).

Given that both Enchant and Runes incorporate conditions into their use of Web Queries, we could also possibly pull this into its own module as well.

#### Web Grants

While one of the benefits of Web Grants is reduce the need for Web Queries for authorization, they will still play a role in cases where using Web Signatures is too complicated. The proto-Web Query implementation in Enchant and Runes will thus help us commercialize Web Grants down the road.

#### Polaris

We use Polaris to evaluate the values passed into context properties, conditions, and actions. Polaris currently relies on JSON Query, which works well enough for Node environments but doesn't run in the browser (due to not having an ESM-friendly release). Unfortunately, the alternatives seem to have their own limitations. In addition, the available transformations are somewhat limited. In any event, the expression syntax is likely to change.

## Roadmap & Future

### Future Plans

- Allow rule configuration to allow for variants of the main evaluation algorithm.
- Reduce the privileges for Enchant intermediaries to the minimum required to execute the policies.
- Add more default properties.
- Add more condition and action types.
- Allow conditions to be composed via booleans (presently we only support implicit AND). This could probably be done by simply adding `and`, `or`, and `not` actions. That gets a little verbose, though.
