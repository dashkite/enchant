# Objects
* [`Enchant Policy`](#reference-enchant-policy) (root object)
* [`Policy`](#reference-policy)
* [`Rule`](#reference-rule)
    * [`Action`](#reference-action)
    * [`Condition`](#reference-condition)
    * [`Property`](#reference-property)


---------------------------------------
<a name="reference-action"></a>
## Action

**`Action` Properties**

|   |Type|Description|Required|
|---|---|---|---|
|**name**|`string`||No|
|**input**|`string`||No|

Additional properties are not allowed.

### action.name

* **Type**: `string`
* **Required**: No

### action.input

* **Type**: `string`
* **Required**: No




---------------------------------------
<a name="reference-condition"></a>
## Condition

**`Condition` Properties**

|   |Type|Description|Required|
|---|---|---|---|
|**name**|`string`||No|
|**input**|`string`||No|

Additional properties are not allowed.

### condition.name

* **Type**: `string`
* **Required**: No

### condition.input

* **Type**: `string`
* **Required**: No




---------------------------------------
<a name="reference-enchant-policy"></a>
## Enchant Policy

Additional properties are not allowed.




---------------------------------------
<a name="reference-policy"></a>
## Policy

**`Policy` Properties**

|   |Type|Description|Required|
|---|---|---|---|
|**resources**|`object`||No|
|**request**|`rule` `[]`||No|
|**response**|`rule` `[]`||No|

Additional properties are allowed.

### policy.resources

* **Type**: `object`
* **Required**: No

### policy.request

* **Type**: `rule` `[]`
* **Required**: No

### policy.response

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

**`Rule` Properties**

|   |Type|Description|Required|
|---|---|---|---|
|**context**|`array` `[]`||No|
|**conditions**|`condition` `[]`||No|
|**actions**|`action` `[]`||No|

Additional properties are allowed.

### rule.context

* **Type**: `array` `[]`
* **Required**: No

### rule.conditions

* **Type**: `condition` `[]`
* **Required**: No

### rule.actions

* **Type**: `action` `[]`
* **Required**: No


