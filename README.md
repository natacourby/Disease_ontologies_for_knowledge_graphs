# Disease ontologies 
Data integration to build a drug discovery knowledge graph is a challenge. There are multiple disease ontologies used in data sources and publications. Each disease ontology has its hierarchy, and the common task is to map ontologies, to find disease clusters, finally to build your representation of the disease area.

Here we present a knowledge graph solution that uses disease ontologies cross-references and allows easy switch between ontology hierarchies for data integration purpose, as well as to perform other tasks. 

## Load diseases into Grakn using prepared database
1. Unzip ./data/db.zip file => ./data/db
2. Use Grakn docker image with an extrenal volume
```
docker run -d -v ./data/db/:/grakn-core-all-linux/server/db/ -p 48555:48555 graknlabs/grakn

# Check using Grakn console
grakn console -k dokg
match $d isa disease, has efo-id "EFO_0009425", has disease-id $di; get;
```
3. or use local Grakn install with data-dir pointing to ./data/db
```
# Change "data-dir" in Grakn configuration file: data-dir=<full path>/data/db/:
vi /usr/local/Cellar/grakn-core/1.8.0/libexec/server/conf/grakn.properties
```
[Grakn configuration file](https://dev.grakn.ai/docs/running-grakn/configuration)

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
```
conda activate graknenv
python3 ./scripts/load_script.py
```
6. Load MONDO hierarchy

add_hierarchy.py has one parameter: ontology_name
```
python3 ./scripts/add_hierarchy.py MONDO
python3 ./scripts/add_hierarchy.py EFO
```
6. Load MESH hierarchy

MESH is not our primary ontology (we don't have all parental terms of it). Parental terms by default are loaded for DOID, EFO and MONDO.
So, in order to load MESH hierarchy we have to add parental terms first:
```
python3 ./scripts/add_terms.py MESH
python3 ./scripts/add_hierarchy.py MESH
```
## Usage examples
To get all disease ontologies ids for the disease of interest (e.g. "chronic kidney disease"):
```
grakn console -k dokg
match $d isa disease, has disease-name "chronic kidney disease", has disease-id $di; get;
```
There are two types of relations for disease-hierarchy: **"disease-hierarchy"** for hierarchical relation directly loaded from ontologies and **"disease-hierarchy-inferred"** for hierarchical relation both loaded from ontologies and inferred using Grakn logical reasoning.

To get **direct** children of "chronic kidney disease" using EFO ontology id ("EFO_0003884") and MONDO ontology hierarchy:
```
grakn console -k dokg
match $x isa disease, has efo-id 'EFO_0003884'; $o isa ontology, has ontology-name "MONDO"; $dh (superior-disease: $x, subordinate-disease: $y, $o)  isa disease-hierarchy; $y isa disease, has disease-name $dn; get $dn;
```
To get **all** children of "chronic kidney disease" using EFO ontology id ("EFO_0003884") and MONDO ontology hierarchy:
```
grakn console -k dokg
match $x isa disease, has efo-id 'EFO_0003884'; $o isa ontology, has ontology-name "MESH"; $dh (superior-disease: $x, subordinate-disease: $y, $o)  isa disease-hierarchy-inferred; $y isa disease, has disease-name $dn; get $dn;
```
To get all children of "chronic kidney disease" using EFO ontology id ("EFO_0003884") regardless the hierarchy:
```
grakn console -k dokg
match $x isa disease, has efo-id 'EFO_0003884'; $o isa ontology; $dh (superior-disease: $x, subordinate-disease: $y, $o)  isa disease-hierarchy-inferred; $y isa disease, has disease-name $dn; get $dn;
```
We can get all parents of "chronic kidney disease" using EFO ontology id ("EFO_0003884") regardless the hierarchy:
```
grakn console -k dokg
match $y isa disease, has efo-id 'EFO_0003884'; $o isa ontology; $dh (superior-disease: $x, subordinate-disease: $y, $o)  isa disease-hierarchy-inferred; $x isa disease, has disease-name $dn; get $dn;
```

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
cross_references_file <- "./data/prepared_ontologies/cross_references.tsv"
hierarchy_file <-paste("./Documents/Projects/imed-knowledge-graph/data/ontologies/bioportal_ontologies/",ontology_value,".csv",sep="")
ontology_name <- "DOID"
bioportal_ontological_hierarchy_preparation(cross_references_file, hierarchy_file, ontology_name)
```
### Check for loops in cross-references.tsv file
To use if you update cross-references.tsv file

```
source("./scripts/data_preparation.R")
cross_references_file <- "./data/prepared_ontologies/cross_references.tsv"
cross_references_validity(cross_references_file)
```
