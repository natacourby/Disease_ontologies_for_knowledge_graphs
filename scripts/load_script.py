#!/usr/bin/env python3
from grakn.client import GraknClient
import csv

grakn_uri = "localhost:48555"
grakn_keyspace = "dokg"
data_folder = "./data/prepared_ontologies/"
ontologies_inserted = 0
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
dict_url = {"EF": "http://www.ebi.ac.uk/efo/",
            "Or": "http://www.orpha.net/ORDO/",
            "MO": "http://purl.obolibrary.org/obo/",
            "HP": "http://purl.obolibrary.org/obo/",
            "NC": "http://purl.obolibrary.org/obo/",
            "DO": "http://purl.obolibrary.org/obo/",
            "UM": "http://linkedlifedata.com/resource/umls/id/",
            "ME": "https://meshb.nlm.nih.gov/record/ui?ui=",
            "GO": "http://purl.obolibrary.org/obo/",
            "OM": "https://omim.org/entry/",
            "IC": "https://icd.who.int/browse10/2019/en/"}
dict_source_unique = {"EF": "EFO",
                      "Or": "Orphanet",
                      "MO": "MONDO",
                      "HP": "HP",
                      "NC": "NCIT",
                      "DO": "DOID",
                      "UM": "UMLS",
                      "ME": "MESH",
                      "OM": "OMIM",
                      "IC": "ICD-10"}
dict_id_unique = dict(EF="efo-id", Or="orphanet-id", MO="mondo-id", HP="hp-id", NC="ncit-id", DO="doid-id",
                      UM="umls-id", ME="mesh-id", OM="omim-id", IC="icd10-id")


# Process input files without ontology arguments;
# Input: dictionary object (file, template)
def build_graph(dict_inputs):
    global grakn_uri
    global grakn_keyspace
    with GraknClient(uri=grakn_uri) as client:
        with client.session(keyspace=grakn_keyspace) as session:
            for dict_input in dict_inputs:
                print("Loading from [" + dict_input["data_path"] + "] into Grakn ...")
                load_data_into_grakn(dict_input, session)


# Process input files with ontology arguments
# (loop through ontology dictionary to pass ontology arguments into "load_data_into_grakn_ontologies" function)
# Input: dictionary object (file, template)
def build_graph_ontologies(dict_inputs):
    global grakn_uri
    global grakn_keyspace
    global dict_source_unique
    global dict_id_unique
    with GraknClient(uri=grakn_uri) as client:
        with client.session(keyspace=grakn_keyspace) as session:
            for item in dict_source_unique:
                for dict_input in dict_inputs:
                    print("Loading from [" + dict_input["data_path"] + "] into Grakn ...")
                    load_data_into_grakn_ontologies(dict_input, session, dict_source_unique[item], dict_id_unique[item])


# Process the line from the input file using particular template without ontology arguments
# Input: dictionary object (file, template) and Grakn session
def load_data_into_grakn(dict_input, session):
    ontologies(session)
    items = parse_data_to_dictionaries(dict_input)
    transaction = session.transaction().write()
    for counter, item in enumerate(items):
        if counter % 100 == 0:
            transaction.commit()
            transaction = session.transaction().write()
        graql_insert_query = dict_input["template"](item)
        print("Executing Graql Query: " + graql_insert_query)
        transaction.query(graql_insert_query)
    transaction.commit()
    transaction.close()
    print("\nInserted " + str(len(items)) + " items from [ " + dict_input["data_path"] + "] into Grakn.\n")


# Process the line from the input file using particular template with ontology arguments
# Input: dictionary object (file, template),
#        Grakn session,
#        ontology name (e.g. "EFO") and
#        corresponding attribute name for Grakn schema (e.g. "efo-id").
def load_data_into_grakn_ontologies(dict_input, session, ontology_name, ontology_id):
    items = parse_data_to_dictionaries_for_ontology(dict_input, ontology_name)
    transaction = session.transaction().write()
    for counter, item in enumerate(items):
        if counter % 100 == 0:
            transaction.commit()
            transaction = session.transaction().write()
        graql_insert_query = dict_input["template"](item, ontology_name, ontology_id)
        print("Executing Graql Query: " + graql_insert_query)
        transaction.query(graql_insert_query)
    transaction.commit()
    transaction.close()
    print("\nInserted " + str(len(items)) + " items from [ " + dict_input["data_path"] + "] into Grakn.\n")


# Insert disease ontologies: EFO, Orphanet, MONDO, NCIT, DOID, UMLS, MESH, OMIM and ICD-10
def ontologies(session):
    global ontologies_inserted
    global dict_source_unique
    global dict_id_unique
    if ontologies_inserted == 0:
        print("Loading disease ontologies into Grakn ...")
        for item in dict_source_unique:
            with session.transaction().write() as transaction:
                graql_insert_query = 'insert $ontology isa ontology, has URL "' + dict_url[
                    item] + '", has ontology-name  "' + dict_source_unique[item] + '";'
                print("Executing Graql Query: " + graql_insert_query)
                transaction.query(graql_insert_query)
                transaction.commit()
        print("\nInserted " + str(len(dict_id_unique)) + " ontologies  into Grakn.\n")
    ontologies_inserted = 1


# Insert ontological terms, e.g.
# 'insert $x isa efo-id; $x "EFO_0009425";'
# Input: line from "cross_reference.tsv" file
def ontology_term_template(cross_reference):
    global dict_source
    global dict_id
    x = cross_reference["preferred_ontology_term"]
    graql_insert_query = 'insert $x isa ' + \
                         dict_id[x[:2]] + \
                         ';$x "' + \
                         cross_reference["preferred_ontology_term"] + \
                         '";'
    return graql_insert_query


# Insert sources for ontological terms, e.g.
# 'match $o isa ontology, has ontology-name "EFO"; $x "EFO_0009425";'
# 'insert $new-disease-id-ontology(ontological-source: $o, disease-id-in-ontology: $x) isa disease-id-ontology;'
# Input: line from "cross_reference.tsv" file
def ontology_term_source_template(cross_reference):
    global dict_source
    x = cross_reference["preferred_ontology_term"]
    graql_insert_query = 'match $o isa ontology, has ontology-name "' + \
                         dict_source[x[:2]] + \
                         '"; $x "' + \
                         cross_reference["preferred_ontology_term"] + \
                         '"; insert $new-disease-id-ontology (ontological-source: $o, disease-id-in-ontology: $x) ' \
                         'isa disease-id-ontology;'
    return graql_insert_query


# Insert disease nodes, e.g.
# 'match $x isa efo-id; $x "EFO_0009425";'
# 'insert $disease isa disease, has efo-id $x,
#  has preferred-disease-id $x,
#  has disease-name "Yersinia pestis infectious disease";'
# Input: line from "cross_reference.tsv" file
def disease_template(cross_reference):
    global dict_id
    x = cross_reference["preferred_ontology_term"]
    graql_insert_query = 'match $x isa ' + dict_id[x[:2]] + '; $x "' + \
                         cross_reference["preferred_ontology_term"] + \
                         '"; insert $disease isa disease, has ' + \
                         dict_id[x[:2]] + \
                         ' $x, has preferred-disease-id "' + \
                         cross_reference["preferred_ontology_term"] + \
                         '", has disease-name "' + \
                         cross_reference["label"].replace('"', '\\"') + '";'
    return graql_insert_query


# Insert cross-referencing terms from particular ontology, e.g. for MESH ontology:
# 'match $d isa disease, has preferred-disease-id "EFO_0009425";'
# 'insert $x0 isa mesh-id; $x0 "D010930"; $x1 isa mesh-id; $x1 "D015009";'
# Input: line from "cross_reference.tsv" file,
#        ontology name (e.g. "EFO") and
#        corresponding attribute name for Grakn schema (e.g. "efo-id").
def cross_reference_ontology_term_template(cross_reference, ontology_name, ontology_id):
    graql_insert_query = 'match $d isa disease, has preferred-disease-id "' + cross_reference[
        "preferred_ontology_term"] + '";'
    graql_insert_query2 = ' insert'
    if (cross_reference[ontology_name] != "" and
            cross_reference[ontology_name] != cross_reference["preferred_ontology_term"]):
        values = cross_reference[ontology_name].split("|")
        for i in range(len(values)):
            value = ' $x' + str(i)
            graql_insert_query2 += value + ' isa ' + ontology_id + '; ' + value + ' "' + values[i] + '";'
        graql_insert_query += graql_insert_query2
    else:
        graql_insert_query += 'get;'
    return graql_insert_query


# Insert cross-referencing sources from particular ontology, e.g. for MESH ontology:
# 'match $d isa disease, has preferred-disease-id "EFO_0009425"; $o isa ontology, has ontology-name "MESH";
#  $x0 isa mesh-id; $x0 isa mesh-id; $x0 "D010930"; $x1 isa mesh-id; $x1 "D015009";'
# 'insert $new-disease-id-ontology0 (ontological-source: $o, disease-id-in-ontology: $x0) isa disease-id-ontology;
#  $new-disease-id-ontology1 (ontological-source: $o, disease-id-in-ontology: $x1) isa disease-id-ontology;'
# Input: line from "cross_reference.tsv" file,
#        ontology name (e.g. "MESH") and
#        corresponding attribute name for Grakn schema (e.g. "mesh-id").
def cross_reference_ontology_term_source_template(cross_reference, ontology_name, ontology_id):
    # to insert ontology id and disease-id-ontology relation
    graql_insert_query = 'match $d isa disease, has preferred-disease-id "' + \
                         cross_reference["preferred_ontology_term"] + '";'
    graql_insert_query2 = ' insert'
    if (cross_reference[ontology_name] != "" and
            cross_reference[ontology_name] != cross_reference["preferred_ontology_term"]):
        graql_insert_query += ' $o isa ontology, has ontology-name "' + ontology_name + '";'
        values = cross_reference[ontology_name].split("|")
        for i in range(len(values)):
            value = ' $x' + str(i)
            graql_insert_query += value + ' isa ' + ontology_id + '; ' + value + ' "' + values[i] + '";'
            graql_insert_query2 += ' $new-disease-id-ontology' + str(i) + \
                                   ' (ontological-source: $o, disease-id-in-ontology: ' + \
                                   value + ') isa disease-id-ontology;'
        graql_insert_query += graql_insert_query2
    else:
        graql_insert_query += 'get;'
    return graql_insert_query


# Insert cross-referencing for disease node from particular ontology, e.g. for MESH ontology:
# 'match $d isa disease, has preferred-disease-id "EFO_0009425";
#  $x0 isa mesh-id; $x0 isa mesh-id; $x0 "D010930"; $x1 isa mesh-id; $x1 "D015009";'
# 'insert $d has mesh-id $x0; $d has mesh-id $x1;'
# Input: line from "cross_reference.tsv" file,
#        ontology name (e.g. "MESH") and
#        corresponding attribute name from Grakn schema (e.g. "mesh-id").
def cross_reference_disease_template(cross_reference, ontology_name, ontology_id):
    # to insert disease has ontology id
    graql_insert_query = 'match $d isa disease, has preferred-disease-id "' + cross_reference[
        "preferred_ontology_term"] + '";'
    graql_insert_query2 = ' insert'
    if (cross_reference[ontology_name] != "" and
            cross_reference[ontology_name] != cross_reference["preferred_ontology_term"]):
        values = cross_reference[ontology_name].split("|")
        for i in range(len(values)):
            value = ' $x' + str(i)
            graql_insert_query += value + ' isa ' + ontology_id + '; ' + value + ' "' + values[i] + '";'
            graql_insert_query2 += ' $d has ' + ontology_id + ' ' + value + ';'
        graql_insert_query += graql_insert_query2
    else:
        graql_insert_query += 'get;'
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


# Parse input file, create dictionary (items) with row values of the file only if value for named ontology exists
# Input: dictionary object (file, template),
#        ontology name
def parse_data_to_dictionaries_for_ontology(dict_input, ontology_name):
    items = []
    with open(dict_input["data_path"] + ".tsv") as data:
        for row in csv.DictReader(data, delimiter='\t', skipinitialspace=True):
            if row[ontology_name] != "" and row[ontology_name] != row["preferred_ontology_term"]:
                item = {key: value for key, value in row.items()}
                items.append(item)
    return items

# Dictionary object for templates where ontology is not taken into account
dict_inputs = [
    {
        "data_path": data_folder + "cross_references",
        "template": ontology_term_template
    },
    {
        "data_path": data_folder + "cross_references",
        "template": ontology_term_source_template
    },
    {
        "data_path": data_folder + "cross_references",
        "template": disease_template
    }
]


# Dictionary object for templates where ontology is passed as the second argument
dict_inputs_ontologies = [
    {
        "data_path": data_folder + "cross_references",
        "template": cross_reference_ontology_term_template
    },
    {
        "data_path": data_folder + "cross_references",
        "template": cross_reference_ontology_term_source_template
    },
    {
        "data_path": data_folder + "cross_references",
        "template": cross_reference_disease_template
    }
]

build_graph(dict_inputs)

build_graph_ontologies(dict_inputs_ontologies)
