> **Warning:** This document is automatically generated. To make changes, edit the [schema YAML](../src/policies.schema.yaml).
# Objects
* [`Enchant Policy`](#reference-enchant-policy) (root object)
* [`Policies`](#reference-policies)
    * [`Policy`](#reference-policy)
* [`Rule`](#reference-rule)
    * [`Action`](#reference-action)
    * [`Condition`](#reference-condition)
    * [`Property`](#reference-property)


---------------------------------------
<a name="reference-action"></a>
## Action

An action name and optional input expression. The named action will run against the request or response. For request actions, once a  response is generated, no further actions will fire.

**`Action` Properties**

|   |Type|Description|Required|
|---|---|---|---|
|**name**|`string`|The name of a defined action.| &#10003; Yes|
|**input**|`string`|The input for the action.| &#10003; Yes|

Additional properties are not allowed.

### action.name

The name of a defined action.

* **Type**: `string`
* **Required**:  &#10003; Yes

### action.input

The input for the action.

* **Type**: `string`
* **Required**:  &#10003; Yes




---------------------------------------
<a name="reference-condition"></a>
## Condition

A condition name and optional input expression. The named condition will be evaluated against the request or response. If a condition fails, the corresponding actions will not fire.

**`Condition` Properties**

|   |Type|Description|Required|
|---|---|---|---|
|**name**|`string`|| &#10003; Yes|
|**input**|`string`|| &#10003; Yes|

Additional properties are not allowed.

### condition.name

* **Type**: `string`
* **Required**:  &#10003; Yes

### condition.input

* **Type**: `string`
* **Required**:  &#10003; Yes




---------------------------------------
<a name="reference-enchant-policy"></a>
## Enchant Policy

Enchant Policies make it easy to define authorization policies for resources. See the [Policy Reference](./policies-reference.md) for more information.

Additional properties are not allowed.




---------------------------------------
<a name="reference-policies"></a>
## Policies

An array of policies.



---------------------------------------
<a name="reference-policy"></a>
## Policy

A policy consists of an optional set of resources, and array of request and response rules.

**`Policy` Properties**

|   |Type|Description|Required|
|---|---|---|---|
|**request**|`rule` `[]`|The list of rules to be applied to the request.|No|
|**response**|`rule` `[]`|The list of rules to be applied to the response.|No|

Additional properties are allowed.

### policy.request

The list of rules to be applied to the request.

* **Type**: `rule` `[]`
* **Required**: No

### policy.response

The list of rules to be applied to the response.

* **Type**: `rule` `[]`
* **Required**: No




---------------------------------------
<a name="reference-property"></a>
## Property

A key-value pair that will be loaded into the context, referenceable from conditions and actions.

**`Property` Properties**

|   |Type|Description|Required|
|---|---|---|---|
|**name**|`string`|The name of the context property, used to reference it in conditions and actions.| &#10003; Yes|
|**expression**|`string`|An expression that will be evaluted to determine the value of the context property.| &#10003; Yes|

Additional properties are not allowed.

### property.name

The name of the context property, used to reference it in conditions and actions.

* **Type**: `string`
* **Required**:  &#10003; Yes
* **Pattern**: `^[a-z_]+$`

### property.expression

An expression that will be evaluted to determine the value of the context property.

* **Type**: `string`
* **Required**:  &#10003; Yes




---------------------------------------
<a name="reference-rule"></a>
## Rule

A rule describes a context, conditions, and actions for a policy rule.

**`Rule` Properties**

|   |Type|Description|Required|
|---|---|---|---|
|**context**|`property` `[]`|A list of context properties that must be evaluated before the conditions or actions.|No|
|**conditions**|`condition` `[]`|A list of conditions that must be satisfied before firing the rule action.|No|
|**actions**|`action` `[]`|A list of actions to fire for the rule.| &#10003; Yes|

Additional properties are allowed.

### rule.context

A list of context properties that must be evaluated before the conditions or actions.

* **Type**: `property` `[]`
* **Required**: No

### rule.conditions

A list of conditions that must be satisfied before firing the rule action.

* **Type**: `condition` `[]`
* **Required**: No

### rule.actions

A list of actions to fire for the rule.

* **Type**: `action` `[]`
* **Required**:  &#10003; Yes


