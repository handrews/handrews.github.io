# Self-Identification

## Metadata

|Tag |Value |
|---- | ---------------- |
|Proposal |[2024-10-16 Object-Identification](https://github.com/OAI/OpenAPI-Specification/tree/main/proposals/{2024-10-16-Object-Identification.md})|
|Relevant Specification(s)|OAS, Arazzo|
|Authors|[Henry Andrews](https://github.com/handrews)|
|Review Manager | TBD |
|Status |Proposal|
|Implementations |n/a|
|Issues | |
|Previous Revisions | |

## Change Log

|Date |Responsible Party |Description |
|---- | ---------------- | ---------- |
|2024-10-16 | @handrews | Initial submission

## Introduction

The OAS uses JSON Schema as its data modeling system.
This works well for JSON, but is not an obvious fit for other media types, nor for formats such as HTTP headers that are not defined as media types.

This proposal introduces a `dataModel` field holding a newly proposed Data Model Object, along with a registry of data modeling technologies and strategies used to interpret the new Object.

## Motivation

The OAS currently offers additional Objects to adapt JSON Schema for certain other media types: `application/xml`, `application/x-www-form-urlencoded`, and `multipart/form-data`.

This approach requires changing the OAS whenever new, or newly popular, media types appear.
It also does not address hot to model data formats, such as HTTP headers, that are not defined as media types.
Finally, it does not allow for experimentation with alternative descriptive technologies such as XSD or CDDL.

### Problems with the current features

There are several ways in which the current system is too complex, both for users and for vendors who might want to offer extensions.

#### Similar media types are not handled in similar ways

There are three supported scenarios (plus a class of scenarios intended to be supported that never, in fact, worked) that all share many elements, but with no two working quite the same way.

* `application/x-www-form-urlencoded` is handled differently when it appears in the query string vs an HTTP message body; some mechanisms are shared, but with subtle differences and limitations
* `multipart/form-data` mostly, but not entirely, shares the HTTP message body approach of `application/x-www-form-urlencoded`
* `multipart` support in the OAS was intended to cover all `multipart` media types, but only supports those with named parts (meaning only `form-data`)

#### Objects relate to each other in different ways

Looking at this a different way, there are three different structures for data modeling information:

* **_Wrapping the Schema Object:_**  The Parameter Object (and Header Object) does this, either directly or by way of a Media Type Object
    * **Name in Object:** Parameter Object
    * **Name in parent property:** Header Object
* **_Paralleling the Schema Object:_**  The Media Type Object's `encoding` field provides an object of Encoding Objects, where the property names MUST match the top-level schema properties
* **_Within the Schema Object:_** The XML Object is embedded in the Schema Object via the `xml` field, modifying its behavior during XML serialization and parsing

The location of the name also varies:

* **_Name in Object_**: Parameter Object
* **_Name in parent property_**: Header Object, Encoding Object, XML Object
* **_Name correlates with parallel Schema Object_**: Encoding Object

Finally, the Header, Parameter, and Encoding Objects all have two modes, one which includes complex object property mapping and character encoding rules (`style`, `explode`, `allowReserved`) and one involving a Media Type Object (`content`).

#### Existing schema complexity

As of OAS 3.1, full JSON Schema compatibility allows changing the schema dialect in sub-schema resources (subschemas with a `$id`) or separate schema documents.

While there are some implementations that support this, it is generally not well-understood despite being in use in the wild (particularly regarding draft-07 standalone schemas, as draft-07 is the most widely supported JSON Schema draft at this time, and also supported by AsyncAPI).

This is mostly important in showing that we already support changing the data modeling technology.
We just have not really followed through with the implications or ensured that tooling can succeed at this complex task.

### Lack of extensibility

Given the problems above, it's hard to see how anyone wanting to experiment in this area could successfully do so with a few `x-` extension keywords, which is our usual recommendation.

It's unclear which of the existing approaches should be followed for any given data modeling problem.  The 

With such a complex landscape, it is very challenging to see how to extend the OAS to support new media types, or 
Our standard advice for experimenting with new OAS features is to add `x-` extension fields and gather feedback from real use.
This is not feasible with data modeling variations, for two reasons:

1. Data modeling strategies don't always involve additional keywords
2. Extending data modeling behavior involves shifting some fundamental assumptions

Related to the second point, if we encourage unconstrained experimentation in this area, different experiments are unlikely to share common architectural principles and implementation patters.
Data modeling is too large and complex of a problem to 
In other areas of the OAS, it is reasonable to advise people to add `x-` extension fields to experiment with new features.
However, data modeling is often not a matter of adding fields, but a matter of mapping existing Schema Object structures (sometimes with help from additional Objects and fields) to a different data model.
Individual `x-` extension fields cannot solve this problem.

### Use Cases

There are nearly 30 issues in our backlog that have to do with modeling currently-unsupported or under-supported media types, or other data formats including custom query string syntax and HTTP fields:

* Novel query string formats: 3084, 2511, 2374, 1710, 1706, 1504, 1502, 1501
* JSON streaming: 3730
* JSON-LD: 1100
* CBOR: 3108
* Non-`form-data` `multipart` media types: 3721, 3725
* Accessing `multipart` bodies in callbacks: 2146
* Encryption signatures: 1464
* Proper modeling of HTTP fields (a.k.a. headers): 2748, 2402, 2342, 2296, 1980, 1572, 1237, 738, 667
* XML: 3959, 1652, 1435, 630

Crafting individual solutions for each of these, if we even want to give each one full support, would be a monumental effort.
A data modeling registry would allow us to fix the most important handful directly, and encourage users and tooling vendors to experiment with the use cases that are too niche to justify full support at this time.

## Proposed solution

To each Object that contains a `schema` field, I propose adding a field named along the lines of `schemaModel` or perhaps `dataModel`.
This field would take a new Object, which we'll provisionally call the Data Model Object to go with the `dataModel` field (the exact names are not important at this stage).

The Data Model Object would have two standard fields:  One for the URI (or other name?) of the entry in the Data Modeling Registry, and another that would be similar to the old [`alternativeSchema` proposal](001_Alternative Schema Proposal.md).

At least one of these fields MUST be present.



### Alternative data model

This field would be u

For example, to use XSD, the field analogous to `alternativeSchema` would be used.  This cou

## Detailed design

`application/json-seq`, `application/*+json-seq`, `application/jsonl`, `applicatoin/x-ndjson`

`multipart/mixed` and any derivations

`rfc9110` or `httpField`

`rfc9651` or `structuredField`
```YAML
type: array
prefixItems:
- 
```

```Markdown
# Schema

...

## Data Model Object

### Fixed Fields

Field Name | Type | Description
---|:---|:---
model | `string` | A URI-reference (or a plain name?) identifying the modeling approach being used. _TODO:_ Are only registered values allowed here?  What about local experimentation?_
modelType | `string` | A name identifying the underlying syntax used by the modeling approach.  The default value is `"JSON Schema"`.
modelInfo | Map[`string`, Any] | An object with a syntax defined by the modeling approach.
```

The `modelInfo` field is intended to avoid needing a variable set of per-modeling approach fields (`x-` or otherwise) in the Data Model Object proper.
This makes it easier to parse and validate the Data Model Object, and potentially to have some sort of hook for validating `modelInfo` based on `model` (and `modelType`?).

For example, a model that wants to do something similar to the Media Type Object's `encoding` field and its map of Encoding Objects would place the necessary fields under `modelInfo`.

## Backwards compatibility

## Alternatives considered

