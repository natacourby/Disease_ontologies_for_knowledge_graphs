# Software "Disease_ontologies_for_knowledge_graphs" - a knowledge base solution that uses Grakn core and disease ontologies cross-references to allow easy switch between ontology hierarchies for data integration purpose.
# Copyright (C) 2021  Natalja Kurbatova, Rowan Swiers

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# This script finds a MESH-ID for each MONDO-id using the database
# The results are stored in a dictionary indexed by a MONDO disease anatomy heading
# Using the dictionary it is now possible to select Mesh IDs which relate to a particular anatomy
# This is something we would be unable to do using the MESH ontology alone.

#!/usr/bin/env python3
import pandas as pd
from grakn.client import GraknClient
import joblib

def mondo_children(mondoid):
    """
    Return the first level children of mondoid from the mondo ontology
    """

    query="""
    match $x isa disease, has mondo-id "{}";
    $dh (superior-disease: $x, subordinate-disease: $y,ontological-source: $o)
     isa disease-hierarchy;
    $y has mondo-id $meshid;
    $o has ontology-name "MONDO";
    get $meshid;
    """
    with GraknClient(uri="localhost:48555") as client:
        with client.session(keyspace="dokg") as session:
            with session.transaction().read() as read_transaction:
                answer_iterator = read_transaction.query(query.format(mondoid)).get()
                children=[ans.get('meshid').value() for ans in answer_iterator]
                return children


def get_mesh_mappings(mondoid): 
    """
    Returns all the mesh mappings for all the children of a mondo id
    """

    query="""
    match $y isa disease, has mondo-id "{}";
    $dh (superior-disease: $x, subordinate-disease: $y, $o)  isa disease-hierarchy;
    $y isa disease, has disease-name $diseasename, has mesh-id $meshid; 
    get $diseasename, $meshid; limit 1;
    """
    ret=[]
    def _helper(n,ret):
        with GraknClient(uri="localhost:48555") as client:
            with client.session(keyspace="dokg") as session:
                with session.transaction().read() as read_transaction:
                    answer_iterator = read_transaction.query(query.format(n)).get()
                    ans=[(ans.get('diseasename').value(),ans.get('meshid').value()) for ans in answer_iterator]
                    print(n,ans)
                    ret.append([n,ans])
        for nextn in mondo_children(n):
            _helper(nextn,ret)
    _helper(mondoid,ret)
    return ret

if __name__=='__main__':
    mondo_clusters={}
    for mondo_id in mondo_children('MONDO_0021199'):
        print('getting mesh ids for {}'.format(mondo_id))
        cluster=get_mesh_mappings(mondo_id)
        mondo_clusters[mondo_id]=cluster
    joblib.dump(mondo_clusters,'mondo_clusters.joblib')
