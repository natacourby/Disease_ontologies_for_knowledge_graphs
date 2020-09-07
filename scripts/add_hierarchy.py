#!/usr/bin/env python3
from grakn.client import GraknClient
import csv
import sys

grakn_uri = "localhost:48555"
grakn_keyspace = "dokg"
data_folder = "./data/prepared_ontologies/"
dict_id = {"EF": "efo-id",
           "MP": "efo-id",
           "Or": "orphanet-id",
           "MO": "mondo-id",
           "HP": "hp-id",
           "NC": "ncit-id",
           "DO": "doid-id",
           "UM": "umls-id",
           "ME": "mesh-id",
           "OM": "omim-id",
           "IC": "icd10-id"}


# Process input files with ontology name from command line
# Input: dictionary object (file, template),
#        ontology name from command line (the first argument),
#        version describing ontology naming style:
#         1, when ontology name is a part of the ontology term id (e.g. "EFO_0009425");
#         2, when ontology name is NOT a part of ontology term (e.g. "D010930" for MESH term)
def add_hierarchy(dict_inputs, ontology_name):
    global grakn_uri
    global grakn_keyspace
    with GraknClient(uri=grakn_uri) as client:
        with client.session(keyspace=grakn_keyspace) as session:
            for dict_input in dict_inputs:
                print("Loading from [" + dict_input["data_path"] + "] into Grakn ...")
                load_data_into_grakn(dict_input, session, ontology_name)


# Process the line from the input file using particular template with ontology arguments
# Input: dictionary object (file, template),
#        Grakn session,
#        ontology name (e.g. "EFO"),
#        corresponding attribute name for Grakn schema (e.g. "efo-id"),
#        version describing ontology naming style (see "add_hierarchy" function for description)
def load_data_into_grakn(dict_input, session, ontology_name):
    items = parse_data_to_dictionaries(dict_input)
    transaction = session.transaction().write()
    for counter, item in enumerate(items):
        if counter % 100 == 0:
            transaction.commit()
            transaction = session.transaction().write()
        graql_insert_query = dict_input["template"](item, ontology_name)
        print("Executing Graql Query: " + graql_insert_query)
        transaction.query(graql_insert_query)
    transaction.commit()
    transaction.close()
    print("\nInserted " + str(len(items)) + " items from [ " + dict_input["data_path"] + "] into Grakn.\n")


# Insert ontological hierarchy from ontology, e.g. for MONDO ontology:
# 'match $o isa ontology, has ontology-name "MONDO";
#  $d isa disease, has mondo-id "MONDO_0000188"; $d0 isa disease, has mondo-id "MONDO_0019214";'
# 'insert $new-disease-id-ontology0 (superior-disease: $d0, subordinate-disease: $d, ontological-source: $o)
#  isa disease-hierarchy;'
# Input: line from hierarchy file
#        ontology name the hierarchy is comping from (e.g. "MONDO") and
#        version for this ontology naming style.
# (File format: two columns "term_id" and "parent_id",
# where parent_id can have multiple values separated by symbol "|").
def hierarchy_template(hierarchy, ontology_name):
    global dict_id
    x = ontology_name
    graql_insert_query = 'match $o isa ontology, has ontology-name "' + ontology_name + '"; $d isa disease, has ' + \
                         dict_id[x[:2]] + ' "' + hierarchy["term_id"] + '";'
    graql_insert_query2 = ' insert'
    values = hierarchy["parent_id"].split("|")
    for i in range(len(values)):
        value = ' $d' + str(i)
        y = ontology_name
        graql_insert_query += value + ' isa disease, has ' + dict_id[y[:2]] + ' "' + values[i] + '";'
        graql_insert_query2 += ' $new-disease-id-ontology' + str(i) + \
                               ' (superior-disease: ' + value + \
                               ', subordinate-disease: $d, ontological-source: $o) isa disease-hierarchy;'
    graql_insert_query += graql_insert_query2
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
def main():
    dict_inputs = [
        {
            "data_path": data_folder + sys.argv[1] + "_prepared_hierarchy",
            "template": hierarchy_template
        }
    ]
    add_hierarchy(dict_inputs, sys.argv[1])


if __name__ == "__main__":
    main()
