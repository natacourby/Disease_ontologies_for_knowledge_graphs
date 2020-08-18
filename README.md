# Disease ontologies 
Project consists of two parts: data preparation and Grakn schema and loading

# Data colllections

/data/prepared_ontologies/
Collected cross references
* cross-references.tsv - main file that contains cross-references of terms from different disease ontologies

Statistics for cross-references.tsv file


|                                 | MESH  | UMLS | EFO  | NCIT | OMIM | DOID | Orphanet | HP  | MONDO | ICD-10 | Total  |
| --------------------------------|:-----:| ----:|--- -:|-----:|-----:|-----:|---------:|----:|------:|-------:|----- -:|
| # of terms only in this ontology| 0     | 0    | 1540 | 53   | 0    | 2    | 163      | 80  | 81    | 0      | 1919   |
| # of preferred terms            | 0     | 0    | 2374 | 519  | 0    | 3    | 824      | 916 | 8932  | 0      | 13568  |
| # of references                 | 5011  | 10279| 6626 | 4747 | 6680 | 4320 | 6556     | 1450| 8942  | 8146   | 62757  |
| # of unique references          | 4867  | 10008| 6626 | 4747 | 5614 | 4320 | 6532     | 1450| 8942  | 3272   | 56378  |


Prepared hierarchies and additional parental terms
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

# Data preparation

Code was tested R version 3.6.1

R libraries:
* rols
* data.table

## Extract hierarchy and prepare additional parental classes if not present in cross-references.tsv file
```
source("./scripts/data_preparation.R")
cross_references_file <- "./data/prepared_ontologies/cross-references.tsv"
hierarchy_file <-paste("./Documents/Projects/imed-knowledge-graph/data/ontologies/bioportal_ontologies/",ontology_value,".csv",sep="")
ontology_name <- "DOID"
bioportal_ontological_hierarchy_preparation(cross_references_file, hierarchy_file, ontology_name)
```
## Check for loops in cross-references.tsv file
To use if you are updating cross-references.tsv file

```
source("./scripts/data_preparation.R")
cross_references_file <- "./data/prepared_ontologies/cross-references.tsv"
cross_references_validity(cross_references_file)
```


# Load data into Grakn

