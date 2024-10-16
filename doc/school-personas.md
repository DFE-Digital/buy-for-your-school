# Educational Establishment Personas

A selection of real schools that can be used to develop against.

- Treat these as personas in tickets.
- Build test fixtures using the same data structures.

## TODO

Additional group data for MAT and federation is likely justification for using the GIAS API
to build out personas 3 and 4 and their respective types.

[Request access](https://form.education.gov.uk/en/AchieveForms/?form_uri=sandbox-publish://AF-Process-2b61dfcd-9296-4f6a-8a26-4671265cae67/AF-Stage-f3f5200e-e605-4a1b-ae6b-3536bc77305c/definition.json&redirectlink=/en&cancelRedirectLink=/en)

All group records.csv, 1.29 MB
https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/allgroupsdata20210215.csv

All group links records.csv, 4.22 MB
https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/alllinksdata20210215.csv


---

| Persona | Name                          | Grouping                                    | Exemplar criteria                                                         |
| :--     | :---                          | :---                                        | :---                                                                      |
| 1       | Abercrombie Primary School    | (**LA**) Local Authority maintained school  |                                                                           |
| 2       | Asfordby Hill Primary School  | (**SAT**) Single Academy Trust              | SAT and school have same name                                             |
| 3       | Aspirations Academy Trust     | (**MAT**) Large Multi Academy Trust         | Address of MAT is nowhere near some of the schools                        |
| 4       | Bilton Community Federation   | Federation (maintained schools)             | A grouping of schools within a federation that are financed through LA    |


## Identifiers

Various identifiers are used throughout the DfE.

- `UKPRN` UK Provider Reference Number
- `URN`   ???
- `UPRN`  ???
- `CRN`   Companies house number (CHNumber)



## Persona 1

**Abercrombie Primary School**

Find using `query.by_ukprn 10077263`

+ Establishment
  - URN: `112670`
  - UPRN: `74079098`
  - UKPRN: `10077263`
  - Establishment Number: `2296`
  - LA: `E10000007`


## Persona 2

**Asfordby Hill Primary School**

Find using `query.by_urn 139340`

+ Establishment
  - URN: `139340`
+ Group
  - UKPRN: `10060309`
  - UID: `2170`
  - Group ID: `TR00092`
  - CRN: `8385139`


## Persona 3

**Aspirations Academy Trust**

API access required

## Persona 4

**Bilton Community Federation**

API access required

