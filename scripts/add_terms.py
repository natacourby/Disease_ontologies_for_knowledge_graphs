#!/usr/bin/env python3
from grakn.client import GraknClient
import csv
import sys

grakn_uri = "localhost:48555"
grakn_keyspace = "dokg"
data_folder = "/Users/kdrr532/Documents/Publications/Disease_ontologies/data/"
dict_source = {"EF": "EFO",
               "BF": "EFO",
               "CH": "EFO",
               "GO": "EFO",
               "IA": "EFO",
               "MP": "EFO",
               "OB": "EFO",
               "OG": "EFO",
               "Or": "Orphanet",
               "MO": "MONDO",
               "HP": "HP",
               "NC": "NCIT",
               "DO": "DOID",
               "UM": "UMLS",
               "ME": "MESH",
               "OM": "OMIM",
               "IC": "ICD-10"}
dict_id = {"EF": "efo-id",
           "BF": "efo-id",
           "CH": "efo-id",
           "GO": "efo-id",
           "IA": "efo-id",
           "MP": "efo-id",
           "OB": "efo-id",
           "OG": "efo-id",
           "Or": "orphanet-id",
           "MO": "mondo-id",
           "HP": "hp-id",
           "NC": "ncit-id",
           "DO": "doid-id",
           "UM": "umls-id",
           "ME": "mesh-id",
           "OM": "omim-id",
           "IC": "icd10-id"}


# Process input file with ontology name from command line
# Input: dictionary object (file, template),
#        ontology name from command line (the first argument),
#        version.
# Version describing ontology naming style:
# 1, when ontology name is a part of the ontology term id (e.g. "EFO_0009425");
# 2, when ontology name is NOT a part of ontology term (e.g. "D010930" for MESH term)
def add_terms(dict_inputs, ontology_name, version="1"):
    global grakn_uri
    global grakn_keyspace
    with GraknClient(uri=grakn_uri) as client:
        with client.session(keyspace=grakn_keyspace) as session:
            for dict_input in dict_inputs:
                print("Loading from [" + dict_input["data_path"] + "] into Grakn ...")
                load_data_into_grakn(dict_input, session, ontology_name, version)


# Process the line from the input file using particular template with ontology arguments
# Input: dictionary object (file, template),
#        Grakn session,
#        ontology name (e.g. "EFO") and
#        corresponding attribute name from Grakn schema (e.g. "efo-id"),
#        version describing ontology naming style (see "add_terms" function for description)
def load_data_into_grakn(dict_input, session, ontology_name, version):
    items = parse_data_to_dictionaries(dict_input)
    transaction = session.transaction().write()
    for counter, item in enumerate(items):
        if counter % 100 == 0:
            transaction.commit()
            transaction = session.transaction().write()
        graql_insert_query = dict_input["template"](item, ontology_name, version)
        print("Executing Graql Query: " + graql_insert_query)
        transaction.query(graql_insert_query)
    transaction.commit()
    transaction.close()
    print("\nInserted " + str(len(items)) + " items from [ " + dict_input["data_path"] + "] into Grakn.\n")


# Insert additional parental terms from particular ontology, e.g. for MESH ontology:
# 'insert $disease isa disease, has mesh-id "D000013",
#  has preferred-disease-id "D000013", has disease-name "Congenital Abnormalities";'
# Input: line from additional classes file (format: two columns "term_id" and "label",
#        name of the ontology additonal classes are coming from (e.g. "MESH") and
#        version for this ontology naming style (2 in case of MESH).
def disease_template_add(add_terms, ontology_name, version):
    global dict_source
    global dict_id
    x = add_terms["term_id"]
    if version == "2":
        x = ontology_name
    graql_insert_query = 'insert $disease isa disease, has ' + dict_id[x[:2]] + '"' + add_terms["term_id"] + \
                         '", has preferred-disease-id "' + add_terms["term_id"] + \
                         '", has disease-name "' + add_terms["label"].replace('"', '\\"') + '";'
    return graql_insert_query


# Parse input file, create dictionary (items) with row values of the file
# Input: dictionary object (file, template)
def parse_data_to_dictionaries(dict_input):
    items = []
    with open(dict_input["data_path"] + ".tsv") as data:
        for row in csv.DictReader(data, delimiter='\t', skipinitialspace=True):
            item = {key: value for key, value in row.items()}
            items.append(item)
    return items


# Main function arguments:
# ontology name (e.g. MESH),
# version (1 or 2) for ontology naming style
def main():
    dict_inputs = [
        {
            "data_path": data_folder + "ontologies/" + sys.argv[1] + "_additional_classes",
            "template": disease_template_add
        }
    ]
    add_terms(dict_inputs, sys.argv[1], sys.argv[2])


if __name__ == "__main__":
    main()
