# Disease ontologies 
Data integration to build a drug discovery knowledge graph is a challenge. There are multiple disease ontologies used in data sources and publications. Each disease ontology has its hierarchy, and the common task is to map ontologies, to find disease clusters, finally to build your representation of the disease area.

Here we present a knowledge graph solution that uses disease ontologies cross-references and allows easy switch between ontology hierarchies for data integration purpose, as well as to perform other tasks. 

## Load diseases into Grakn using prepared database
1. Unzip ./data/db.zip file => ./data/db
2. Use Grakn docker image with an extrenal volume
```
docker run -d -v ./data/db/:/grakn-core-all-linux/server/db/ -p 48555:48555 graknlabs/grakn
```
3. Use local Grakn install

Change the data-dir in [Grakn configuration file](https://dev.grakn.ai/docs/running-grakn/configuration) to data-dir=<full path>/data/db/:
```
vi /usr/local/Cellar/grakn-core/1.8.0/libexec/server/conf/grakn.properties
```


## Load diseases into Grakn using python scripts
Code was tested Grakn 1.8, python 3.6

1. Build python environment:
```
conda create --name graknenv python=3.6
conda activate graknenv
pip3 install grakn-client
```

2. [Install Grakn](https://dev.grakn.ai/docs/running-grakn/install-and-run) 

3. Load schema
```
grakn server start
grakn console -k dokg -f ./scripts/schema.gql
```
4. Load diseases

NB! Loading process takes around 2 hours.

```
conda activate graknenv
python3 ./scripts/load_script.py

# Check in Grakn console
grakn console -k dokg
match $d isa disease, has efo-id "EFO_0009425", has disease-id $di; get;
```
6. Load MONDO hierarchy

add_hierarchy.py has two parameters: ontology_name and naming version (1 or 2)
* naming version 1 corresponds to cross-reference file column with ontology_name as prefix (e.g. "MONDO_", "EFO_") 
* naming version 2 means that ontology_name is not used as prefix (e.g. in case of UMLS and MESH) 

```
python3 ./scripts/add_hierarchy.py MONDO 1
python3 ./scripts/add_hierarchy.py EFO 1

# Check in Grakn console
grakn console -k dokg
match $dh (superior-disease: $x, subordinate-disease: $y, $o)  isa disease-hierarchy; $x isa disease, has efo-id 'EFO_0003884'; $o isa ontology, has ontology-name "MONDO"; $y isa disease, has disease-name $dn; get $dn;
```
6. Load MESH hierarchy

MESH is not our primary ontology (we don't have all parental terms of it). Parental terms by default are loaded for DOID, EFO, MONDO and Orphanet.
So, in order to load MESH hierarchy we have to add parental terms first:
```
python3 ./scripts/add_terms.py MESH 2
python3 ./scripts/add_hierarchy.py MESH 2

# Check in Grakn console
grakn console -k dokg
match $dh (superior-disease: $x, subordinate-disease: $y, $o)  isa disease-hierarchy; $x isa disease, has efo-id 'EFO_0003884'; $o isa ontology, has ontology-name "MESH"; $y isa disease, has disease-name $dn; get $dn;
```
7. Usage examples
We can get all children of 'EFO_0003884' regardless the hierarchy:
```
grakn console -k dokg
match $dh (superior-disease: $x, subordinate-disease: $y, $o)  isa disease-hierarchy; $x isa disease, has efo-id 'EFO_0003884'; $o isa ontology, has ontology-name $on; $y isa disease, has disease-name $dn; get $dn, $on;

# Using EFO hierarchy
match $dh (superior-disease: $x, subordinate-disease: $y, $o)  isa disease-hierarchy; $x isa disease, has efo-id 'EFO_0003884'; $o isa ontology, has ontology-name "EFO"; $y isa disease, has disease-name $dn; get $dn;
```
We can get all parents of 'EFO_0003884' regardless the hierarchy:
```
grakn console -k dokg
match $dh (superior-disease: $x, subordinate-disease: $y, $o) isa disease-hierarchy; $y isa disease, has efo-id 'EFO_0003884'; $o isa ontology, has ontology-name $on; $x isa disease, has disease-name $dn; get $dn, $on;

# Using MONDO hierarchy
match $dh (superior-disease: $x, subordinate-disease: $y, $o) isa disease-hierarchy; $y isa disease, has efo-id 'EFO_0003884'; $o isa ontology, has ontology-name "MONDO"; $x isa disease, has disease-name $dn; get $dn;
```
Now if want to add ontology hierarchy that is not used in cross references file:
```
# Add ontology
grakn console -k dokg
insert $ontology isa ontology, has URL "...", has ontology-name  "Custom_ontology";
```
Prepare parental classes: ./data/prepared_ontologies/Custom_ontology_add_classes.tsv

Use add_terms.py script to add parental classes (second parameter should be 2)

Use add_hierarchy.py to add hierarchy (term_id and parent_id should be either in cross_reference preferred-ontology-id column or in ./data/prepared_ontologies/Custom_ontology_add_classes.tsv file)

## Data colllections

/data/prepared_ontologies/

Collected cross references, prepared hierarchies and additional parental terms:
* cross-references.tsv
* DOID_prepared_hierarchy.tsv
* EFO_prepared_hierarchy.tsv
* MONDO_prepared_hierarchy.tsv
* Orphanet_prepared_hierarchy.tsv
* HP_additional_classes.tsv
* HP_prepared_hierarchy.tsv
* MESH_additional_classes.tsv
* MESH_prepared_hierarchy.tsv
* NCIT_additional_classes.tsv
* NCIT_prepared_hierarchy.tsv

**cross-references.tsv** - main file that contains cross-references of terms from different disease ontologies.

Statistics for **cross-references.tsv** file

|                                 | MESH  | UMLS | EFO  | NCIT | OMIM | DOID | Orphanet | HP  | MONDO | ICD10 | Total  |
| --------------------------------|:-----:| :---:|:----:|:----:|:----:|:----:|:--------:|:---:|:-----:|:-----:|:------:|
| # of terms only in this ontology| 0     | 0    | 1540 | 53   | 0    | 2    | 163      | 80  | 81    | 0     | 1919   |
| # of preferred terms            | 0     | 0    | 2374 | 519  | 0    | 3    | 824      | 916 | 8932  | 0     | 13568  |
| # of references                 | 5011  | 10279| 6626 | 4747 | 6680 | 4320 | 6556     | 1450| 8942  | 8146  | 62757  |
| # of unique references          | 4867  | 10008| 6626 | 4747 | 5614 | 4320 | 6532     | 1450| 8942  | 3272  | 56378  |


## Data preparation

Code was tested R version 3.6.1

R libraries:
* rols
* data.table

### Extract hierarchy and prepare additional parental classes if not present in cross-references.tsv file
```
source("./scripts/data_preparation.R")
cross_references_file <- "./data/prepared_ontologies/cross-references.tsv"
hierarchy_file <-paste("./Documents/Projects/imed-knowledge-graph/data/ontologies/bioportal_ontologies/",ontology_value,".csv",sep="")
ontology_name <- "DOID"
bioportal_ontological_hierarchy_preparation(cross_references_file, hierarchy_file, ontology_name)
```
### Check for loops in cross-references.tsv file
To use if you update cross-references.tsv file

```
source("./scripts/data_preparation.R")
cross_references_file <- "./data/prepared_ontologies/cross-references.tsv"
cross_references_validity(cross_references_file)
```
