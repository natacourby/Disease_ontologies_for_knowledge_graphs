####################################################################################
# Function to add term into a list of terms if it's not there yet
####################################################################################
merge_when_not_in <- function(term, terms_in){
  if(!grepl(term,terms_in)){
    return(paste(terms_in,term,sep="|"))
  }
  else{
    return(terms_in)
  }
}
####################################################################################
# Function to get cross references from Ontology Lookup Service
####################################################################################
get_ols_cross_references <- function(terms_init){
  require(rols)
  efo <- Ontology("efo")
  ordo <- Ontology("ordo")
  go <- Ontology("go")
  mondo <- Ontology("mondo")
  hp <- Ontology("hp")
  ncit <- Ontology("ncit")
  doid <- Ontology("doid")
  mp <- Ontology("mp")
  terms <- terms_init
  terms <- data.frame(ontology_term=unique(as.character(terms$ontology_term)),ontology="")
  ontology_check <- Vectorize(function(a) {
    switch(as.character(a),
           "EF" = "efo", "HP" = "hp", "Or" = "ordo","MO" = "mondo","GO" = "go","NC" = "ncit","DO" = "doid","MP"="mp")
    
  }, "a")
  
  terms$ontology <- ontology_check(substr(terms$ontology_term,1,2))
  terms$ontology_term <- as.character(terms$ontology_term)
  terms$label <- ""
  terms$MESH <- ""
  terms$UMLS <- ""
  terms$EFO <- ""
  terms$NCIT <- ""
  terms$OMIM <- ""
  terms$DOID <- ""
  terms$Orphanet <- ""
  terms$HP <- ""
  terms$MONDO <- ""
  terms$ICD10 <- ""
  for(i in 1:nrow(terms))  {
    tryCatch({
      if(as.character(terms[i,2])!="NULL"){
        #EFO
        if(as.character(terms[i,2])=="efo"){
          trm <- term(get(as.character(terms[i,2])), terms[i,1])
          terms[i,3]<-termLabel(trm)
          terms[i,6]<-terms[i,1]
          if (!is.null(unlist(trm@annotation$database_cross_reference))){
            for(j in 1:length(unlist(trm@annotation$database_cross_reference))){
              if (grepl("MSH",unlist(trm@annotation$database_cross_reference)[j])){
                terms[i,4]<-merge_when_not_in(unlist(trm@annotation$database_cross_reference)[j],terms[i,4])
              }
              if (grepl("UMLS",unlist(trm@annotation$database_cross_reference)[j])){
                terms[i,5]<-merge_when_not_in(unlist(trm@annotation$database_cross_reference)[j],terms[i,5])
              }
              if (grepl("NCIt",unlist(trm@annotation$database_cross_reference)[j])){
                terms[i,7]<-merge_when_not_in(unlist(trm@annotation$database_cross_reference)[j],terms[i,7])
              }
              if (grepl("OMIM",unlist(trm@annotation$database_cross_reference)[j])){
                terms[i,8]<-merge_when_not_in(unlist(trm@annotation$database_cross_reference)[j],terms[i,8])
              }
              if (grepl("DOID",unlist(trm@annotation$database_cross_reference)[j])){
                terms[i,9]<-merge_when_not_in(unlist(trm@annotation$database_cross_reference)[j],terms[i,9])
              }
              if (grepl("Orphanet",unlist(trm@annotation$database_cross_reference)[j])){
                terms[i,10]<-paste(terms[i,10],unlist(trm@annotation$database_cross_reference)[j],sep="|")
              }
              if (grepl("HP",unlist(trm@annotation$database_cross_reference)[j])){
                terms[i,11]<-merge_when_not_in(unlist(trm@annotation$database_cross_reference)[j],terms[i,11])
              }
              if (grepl("MONDO",unlist(trm@annotation$database_cross_reference)[j])){
                terms[i,12]<-merge_when_not_in(unlist(trm@annotation$database_cross_reference)[j],terms[i,12])
              }
              if (grepl("ICD10",unlist(trm@annotation$database_cross_reference)[j])){
                terms[i,13]<-merge_when_not_in(unlist(trm@annotation$database_cross_reference)[j],terms[i,13])
              }
            }
          }
        }
        #DOID
        if(as.character(terms[i,2])=="doid"){
          trm <- term(get(as.character(terms[i,2])), terms[i,1])
          terms[i,3]<-termLabel(trm)
          terms[i,9]<-terms[i,1]
          if (!is.null(unlist(trm@annotation$database_cross_reference))){
            for(j in 1:length(unlist(trm@annotation$database_cross_reference))){
              if (grepl("MESH",unlist(trm@annotation$database_cross_reference)[j])){
                terms[i,4]<-merge_when_not_in(unlist(trm@annotation$database_cross_reference)[j],terms[i,4])
              }
              if (grepl("UMLS",unlist(trm@annotation$database_cross_reference)[j])){
                terms[i,5]<-merge_when_not_in(unlist(trm@annotation$database_cross_reference)[j],terms[i,5])
              }
              if (grepl("NCI",unlist(trm@annotation$database_cross_reference)[j])){
                terms[i,7]<-merge_when_not_in(unlist(trm@annotation$database_cross_reference)[j],terms[i,7])
              }
              if (grepl("OMIM",unlist(trm@annotation$database_cross_reference)[j])){
                terms[i,8]<-merge_when_not_in(unlist(trm@annotation$database_cross_reference)[j],terms[i,8])
              }
              if (grepl("Orphanet",unlist(trm@annotation$database_cross_reference)[j])){
                terms[i,10]<-paste(terms[i,10],unlist(trm@annotation$database_cross_reference)[j],sep="|")
              }
              if (grepl("HP",unlist(trm@annotation$database_cross_reference)[j])){
                terms[i,11]<-merge_when_not_in(unlist(trm@annotation$database_cross_reference)[j],terms[i,11])
              }
              if (grepl("MONDO",unlist(trm@annotation$database_cross_reference)[j])){
                terms[i,12]<-merge_when_not_in(unlist(trm@annotation$database_cross_reference)[j],terms[i,12])
              }
              if (grepl("ICD10",unlist(trm@annotation$database_cross_reference)[j])){
                terms[i,13]<-merge_when_not_in(unlist(trm@annotation$database_cross_reference)[j],terms[i,13])
              }
            }
          }
        }
        #MONDO
        if(as.character(terms[i,2])=="mondo"){
          trm <- term(get(as.character(terms[i,2])), terms[i,1])
          terms[i,3]<-termLabel(trm)
          terms[i,12]<-terms[i,1]
          if (!is.null(unlist(trm@annotation$property_value))){
            for(j in 1:length(unlist(trm@annotation$property_value))){
              if (grepl("exactMatch http://identifiers.org/mesh/",unlist(trm@annotation$property_value)[j])){
                terms[i,4]<-merge_when_not_in(unlist(trm@annotation$property_value)[j],terms[i,4])
              }
              if (grepl("exactMatch http://linkedlifedata.com/resource/umls",unlist(trm@annotation$property_value)[j])){
                terms[i,5]<-merge_when_not_in(unlist(trm@annotation$property_value)[j],terms[i,5])
              }
              if (grepl("exactMatch NCIT",unlist(trm@annotation$property_value)[j])){
                terms[i,7]<-merge_when_not_in(unlist(trm@annotation$property_value)[j],terms[i,7])
              }
              if (grepl("exactMatch http://identifiers.org/omim/",unlist(trm@annotation$property_value)[j])){
                terms[i,8]<-merge_when_not_in(paste0("OMIM:",unlist(trm@annotation$property_value)[j]),terms[i,8])
              }
              if (grepl("exactMatch DOID",unlist(trm@annotation$property_value)[j])){
                terms[i,9]<-merge_when_not_in(unlist(trm@annotation$property_value)[j],terms[i,9])
              }
              if (grepl("exactMatch Orphanet",unlist(trm@annotation$property_value)[j])){
                terms[i,10]<-merge_when_not_in(unlist(trm@annotation$property_value)[j],terms[i,10])
              }
              if (grepl("exactMatch HP",unlist(trm@annotation$property_value)[j])){
                terms[i,11]<-merge_when_not_in(unlist(trm@annotation$property_value)[j],terms[i,11])
              }
              if (grepl("exactMatch EFO",unlist(trm@annotation$property_value)[j])){
                terms[i,6]<-merge_when_not_in(unlist(trm@annotation$property_value)[j],terms[i,6])
              }
            }
            if (!is.null(unlist(trm@annotation$xref))){
              if (grepl("http://purl.obolibrary.org/obo/EFO_",unlist(trm@annotation$xref)[j])){
                terms[i,6]<-merge_when_not_in(unlist(trm@annotation$xref)[j],terms[i,6])
              }
            }
          }
          if (!is.null(unlist(trm@annotation$database_cross_reference))){    
            for(j in 1:length(unlist(trm@annotation$database_cross_reference))){  
              if (grepl("MSH",unlist(trm@annotation$database_cross_reference)[j])){
                terms[i,4]<-merge_when_not_in(unlist(trm@annotation$database_cross_reference)[j],terms[i,4])
              }
              if (grepl("MESH",unlist(trm@annotation$database_cross_reference)[j])){
                terms[i,4]<-merge_when_not_in(unlist(trm@annotation$database_cross_reference)[j],terms[i,4])
              }
              if (grepl("UMLS",unlist(trm@annotation$database_cross_reference)[j])){
                terms[i,5]<-merge_when_not_in(unlist(trm@annotation$database_cross_reference)[j],terms[i,5])
              }
              if (grepl("NCI",unlist(trm@annotation$database_cross_reference)[j])){
                terms[i,7]<-merge_when_not_in(unlist(trm@annotation$database_cross_reference)[j],terms[i,7])
              }
              if (grepl("OMIM",unlist(trm@annotation$database_cross_reference)[j])){
                terms[i,8]<-merge_when_not_in(unlist(trm@annotation$database_cross_reference)[j],terms[i,8])
              }
              if (grepl("DOID",unlist(trm@annotation$database_cross_reference)[j])){
                terms[i,9]<-merge_when_not_in(unlist(trm@annotation$database_cross_reference)[j],terms[i,9])
              }
              if (grepl("Orphanet",unlist(trm@annotation$database_cross_reference)[j])){
                terms[i,10]<-paste(terms[i,10],unlist(trm@annotation$database_cross_reference)[j],sep="|")
              }
              if (grepl("HP",unlist(trm@annotation$database_cross_reference)[j])){
                terms[i,11]<-merge_when_not_in(unlist(trm@annotation$database_cross_reference)[j],terms[i,11])
              }
              if (grepl("EFO",unlist(trm@annotation$database_cross_reference)[j])){
                terms[i,6]<-merge_when_not_in(unlist(trm@annotation$database_cross_reference)[j],terms[i,6])
              }
              if (grepl("ICD10",unlist(trm@annotation$database_cross_reference)[j])){
                terms[i,13]<-merge_when_not_in(unlist(trm@annotation$database_cross_reference)[j],terms[i,13])
              }
            }
          }
        }
        #NCIT
        if(as.character(terms[i,2])=="ncit"){
          trm <- term(get(as.character(terms[i,2])), terms[i,1])
          terms[i,3]<-termLabel(trm)
          terms[i,7]<-terms[i,1]
          if (!is.null(unlist(trm@annotation$UMLS_CUI))){
            for(j in 1:length(unlist(trm@annotation$UMLS_CUI))){
              #if (grepl("exactMatch http://identifiers.org/mesh/",unlist(trm@annotation$property_value)[j])){
              terms[i,5]<-merge_when_not_in(unlist(trm@annotation$UMLS_CUI)[j],terms[i,5])
              #}
            }
          }
        }
        #HP
        if(as.character(terms[i,2])=="hp"){
          trm <- term(get(as.character(terms[i,2])), terms[i,1])
          terms[i,3]<-termLabel(trm)
          terms[i,11]<-terms[i,1]
          if (!is.null(unlist(trm@annotation$database_cross_reference))){
            for(j in 1:length(unlist(trm@annotation$database_cross_reference))){
              if (grepl("MSH",unlist(trm@annotation$database_cross_reference)[j])){
                terms[i,4]<-merge_when_not_in(unlist(trm@annotation$database_cross_reference)[j],terms[i,4]) 
              }
              if (grepl("UMLS",unlist(trm@annotation$database_cross_reference)[j])){
                terms[i,5]<-merge_when_not_in(unlist(trm@annotation$database_cross_reference)[j],terms[i,5]) 
              }
            }
          }
        }
        #ORDO
        if(as.character(terms[i,2])=="ordo"){
          trm <- term(get(as.character(terms[i,2])), terms[i,1])
          terms[i,3]<-termLabel(trm)
          terms[i,10]<-terms[i,1]
          if (!is.null(unlist(trm@annotation$hasDbXref))){
            for(j in 1:length(unlist(trm@annotation$hasDbXref))){
              if (grepl("MeSH",unlist(trm@annotation$hasDbXref)[j])){
                terms[i,4]<-merge_when_not_in(unlist(trm@annotation$hasDbXref)[j],terms[i,4])
              }
              if (grepl("UMLS",unlist(trm@annotation$hasDbXref)[j])){
                terms[i,5]<-merge_when_not_in(unlist(trm@annotation$hasDbXref)[j],terms[i,5])
              }
              if (grepl("OMIM",unlist(trm@annotation$hasDbXref)[j])){
                terms[i,8]<-merge_when_not_in(unlist(trm@annotation$hasDbXref)[j],terms[i,8])
              }
            }
          }
          
        }
      }
    }, warning = function(w) {
      
    }, error = function(e) {
      
    }, finally = {
      
    })
  }
  terms$ontology<-""
  #terms <- terms[,-2]
  terms <- terms[,-2]
  #cross_references <- read.table("/Users/kdrr532/Documents/Projects/knowledgebase/data/ontologies/cross_references.tsv",header=T,sep="\t",stringsAsFactors = F)
  #colnames(terms) <- colnames(cross_references)
  #res <- unique(rbind(cross_references,terms))
  res<-terms
  
  res<- data.frame(lapply(res, function(x) {gsub("http://identifiers.org/mesh/", "", x)}))  
  res<- data.frame(lapply(res, function(x) {gsub("http://linkedlifedata.com/resource/umls/id/", "", x)}))  
  res<- data.frame(lapply(res, function(x) {gsub("http://linkedlifedata.com/resource/umls", "", x)}))  
  res<- data.frame(lapply(res, function(x) {gsub("http://purl.obolibrary.org/obo/", "", x)})) 
  res<- data.frame(lapply(res, function(x) {gsub("http://identifiers.org/omim/", "", x)}))  
  res<- data.frame(lapply(res, function(x) {gsub("http://www.ebi.ac.uk/efo/", "", x)}))  
  res<- data.frame(lapply(res, function(x) {gsub("exactMatch ", "", x)})) 
  res<- data.frame(lapply(res, function(x) {gsub("MeSH:", "", x)})) 
  res<- data.frame(lapply(res, function(x) {gsub("MSH:", "", x)})) 
  res<- data.frame(lapply(res, function(x) {gsub("MESH:", "", x)})) 
  res<- data.frame(lapply(res, function(x) {gsub("UMLS:", "", x)})) 
  res<- data.frame(lapply(res, function(x) {gsub("UMLS_CUI:", "", x)})) 
  res<- data.frame(lapply(res, function(x) {gsub("ICD10CM:", "", x)})) 
  res<- data.frame(lapply(res, function(x) {gsub("ICD10:", "", x)})) 
  res<- data.frame(lapply(res, function(x) {gsub("OMIM:", "OMIM_", x)})) 
  res<- data.frame(lapply(res, function(x) {gsub("DOID:", "DOID_", x)})) 
  res<- data.frame(lapply(res, function(x) {gsub("Orphanet:", "Orphanet_", x)})) 
  res<- data.frame(lapply(res, function(x) {gsub("MONDO:", "MONDO_", x)})) 
  res<- data.frame(lapply(res, function(x) {gsub("NCI:", "NCIT_", x)})) 
  res<- data.frame(lapply(res, function(x) {gsub("NCIT:", "NCIT_", x)})) 
  res<- data.frame(lapply(res, function(x) {gsub("NCIt:", "NCIT_", x)})) 
  res<- data.frame(lapply(res, function(x) {gsub("EFO:", "EFO_", x)})) 
  res<- data.frame(lapply(res, function(x) {gsub("HP:", "HP_", x)})) 
  res<- data.frame(lapply(res, function(x) {gsub("^\\|", "", x)})) 
  #write.csv(res,"/Users/kdrr532/Documents/Projects/knowledgebase/res.csv",row.names = F)
  return(res)
}
########################################################################
# Function to check cross-references file validity 
########################################################################
cross_references_validity <- function(cross_references_file){
  cross_references <- read.csv(cross_references_file,header = T,stringsAsFactors = F,sep="\t")
  ontology_check <- Vectorize(function(a) {
    switch(as.character(a),
           "EF" = "EFO", "HP" = "HP", "Or" = "Orphanet","MO" = "MONDO","NC" = "NCIT","DO" = "DOID", "GO" = "EFO", "BF" = "EFO", "MP" = "EFO", "OB" = "EFO", "IA" = "EFO",
           "OG" = "EFO", "CH" = "EFO",)
    
  }, "a")
  preferred_ontologies <- c("EFO","NCIT","DOID","Orphanet","HP","MONDO")
  
  
  # Stats
  cross_references$ontology <- as.character(ontology_check(substr(cross_references$preferred_ontology_term,1,2)))
  print(paste("Number of records: ",dim(cross_references)[1],sep=""))
  # 12522
  
  #Number of references
  for(ontology_value in names(cross_references)[2:11]){
    df_total = data.frame()
    for(i in 1:nrow(cross_references))  {
      values <- cross_references[i,ontology_value]
      res <- unlist(strsplit(values, "|", fixed = TRUE))
      if(length(res)>0){
        for(j in 1:length(res)){
          df <- data.frame(res[j])
          df_total <- rbind(df_total,df)
        }
      }
    }
    df_total[duplicated(as.character(df_total$res.j.)),]
    print(paste("Number of references in ",ontology_value,": unique ",dim(unique(df_total))[1]," out of ",dim(df_total)[1],sep="")) 
  }
  
  #Number of preferred terms
  for(ontology_value in preferred_ontologies){
    test<- cross_references[cross_references$ontology==ontology_value,]
    print(paste("Number of preferred terms in ",ontology_value,": ",dim(test)[1],sep=""))
  }
  
  #Number of single references
  for(ontology_value in preferred_ontologies){
    test<- cross_references[cross_references$ontology==ontology_value
                            & cross_references$MESH=="" 
                            & cross_references$UMLS==""  
                            & cross_references$ICD.10==""
                            & rowSums(sapply(cross_references[,setdiff(preferred_ontologies,ontology_value)],`==`,e2=""))==5,]
    print(paste("Number of single references in ",ontology_value,": ",dim(test)[1],sep=""))
  }

  #Check1 - not known ontologies
  if (dim(cross_references[cross_references$ontology=="NULL",])[1]!=0){
    print("There are not known ontologies in the file:")
    cross_references[cross_references$ontology=="NULL",]
  }
  
  cross_references <- as.data.frame(cross_references)
  #Check2 - loops
  for(ontology_value in preferred_ontologies){
    test<- cross_references[cross_references$ontology==ontology_value,]
    test_result <- cross_references[cross_references$ontology!=ontology_value & cross_references[,c(ontology_value)] %in% test$preferred_ontology_term,]
    if (dim(test_result)[1]!=0){
      print(paste("There are loops in ",ontology_value," cross-references:",sep=""))
      test_result
    }
  }
  
}
########################################################################
# Function to extract hierarchy from Bioportal ontologies in CSV format 
########################################################################
bioportal_ontological_hierarchy_preparation <- function(cross_references_file, hierarchy_file, ontology_name, dir_name="./data/prepared_ontologies/"){
  require(data.table)
  url_into_string <- function(url_value){
    list_of_urls <- unlist(strsplit(url_value, "|", fixed = TRUE)) 
    list_of_strings <- ""
    if(length(list_of_urls)>0){
      for(j in 1:length(list_of_urls)){
        list_of_strings <- paste(list_of_strings,gsub('.*\\/', "", list_of_urls[j]),sep="|")
      }
      list_of_strings <- gsub("^\\|", "", list_of_strings)
    }
    else list_of_strings <-url_value
    return(list_of_strings)
  }
  
  # Hierarchy file from Bioportal in csv format with mondatory fields: Class.ID, Parents and Preferred.Label
  hierarchy <- read.csv(hierarchy_file,header = T,stringsAsFactors = F)
  hierarchy <- hierarchy[,c("Class.ID","Parents","Preferred.Label")]
  #hierarchy <- data.frame(lapply(hierarchy, function(x) {gsub("http://purl.obolibrary.org/obo/", "", x)}))
  hierarchy$Parents <- lapply(hierarchy$Parents, function(x) {url_into_string(x)})
  hierarchy$Class.ID <- lapply(hierarchy$Class.ID, function(x) {gsub('.*\\/', "",x)})
  
  hierarchy <- data.frame(lapply(hierarchy, function(x) {gsub('Thesaurus.owl#', paste(ontology_name,"_",sep=""), x)}))
  # if(ontology_name %in% c("OMIM")){
  #   hierarchy$Class.ID <- paste(ontology_name,"_",hierarchy$Class.ID,sep="")
  # }
  setDT(hierarchy)
  setkey(hierarchy,Class.ID)
  
  # Cross references file 
  cross_references <- read.csv(cross_references_file,header = T,stringsAsFactors = F,sep="\t")
  setDT(cross_references)
  setkeyv(cross_references,ontology_name)
  
  # Get all terms that are referencing ontology of interest from cross_references file
  df_total = data.frame()
  for(i in 1:nrow(cross_references))  {
    cr_terms <- as.character(cross_references[,c(ontology_name),with=FALSE][i])
    res <- unlist(strsplit(cr_terms, "|", fixed = TRUE))
    if(length(res)>0){
      for(j in 1:length(res)){
        df <- data.frame(res[j],stringsAsFactors = F)
        df_total <- rbind(df_total,df)
      }
    }
  }
  names(df_total) <- "term_id"
  
  # Select terms from hierarchy that are present in cross_references file
  hierarchy_result <- hierarchy[(hierarchy$Class.ID %in% unique(df_total$term_id)),c("Class.ID","Parents")]
  names(hierarchy_result) <- c("term_id","parent_id")
  # hierarchy_result contains terms and their parents
  
  hierarchy_result$parent_id <- as.character(hierarchy_result$parent_id)
  
  # Get all parents and their parents with labels from hierarchy 
  parental_search <- function(hierarchy_result){  
    hierarchy_result2 = data.frame() 
    for(i in 1:nrow(hierarchy_result))  {
      if(hierarchy_result[,"parent_id"][i]!="" & !(grepl("function",hierarchy_result[,"parent_id"][i]))){
        if (!is.atomic(hierarchy_result[,"parent_id"][i])){
          parents <- as.character((hierarchy_result[,"parent_id"][i])$parent_id)
          parents_list <- unlist(strsplit(parents, "|", fixed = TRUE))
          if(length(parents_list)>0){
            for(j in 1:length(parents_list)){
              parent_of_parent <- hierarchy[(hierarchy$Class.ID==parents_list[j]),]$Parents
              parent_label <- hierarchy[(hierarchy$Class.ID==parents_list[j]),]$Preferred.Label
              if(length(parent_of_parent)==0){
                parent_of_parent="" 
              }
              if(length(parent_label)==0){
                parent_label="" 
              }
              df <- data.frame(term_id=parents_list[j], label=parent_label, parent_id=parent_of_parent)
              hierarchy_result2 <- rbind(hierarchy_result2,df)
            }
          }
        }
      }
    }  
    if(dim(hierarchy_result2)[1]>0)
      if(sum(hierarchy_result2[,"parent_id"]!="")!=0){
        hierarchy_result2 <- unique(hierarchy_result2)
        setDT(hierarchy_result2)
        setkey(hierarchy_result2,term_id)
        return(rbind(hierarchy_result2,parental_search(hierarchy_result2)))
      }
    else 
      return(hierarchy_result2)
    else 
      return(data.frame(term_id="",label="",parent_id=""))
  }  
  
  parental_results <- unique(parental_search(hierarchy_result))
  
  parental_results <- data.frame(lapply(parental_results, function(x) {gsub("owl#Thing", "", x)}))
  hierarchy_result <- data.frame(lapply(hierarchy_result, function(x) {gsub("owl#Thing", "", x)}))
  parental_results <- data.frame(lapply(parental_results, function(x) {gsub("ObsoleteClass", "", x)}))
  hierarchy_result <- data.frame(lapply(hierarchy_result, function(x) {gsub("ObsoleteClass", "", x)}))
  
  prepared_hierarchy <- rbind(hierarchy_result[hierarchy_result$parent_id!="",],parental_results[parental_results$parent_id!="",c(1,3)])
  
  # Remove terms that are already in cross-reference file
  parental_results <- parental_results[!(parental_results$term_id %in% df_total$term_id),]
  
  if(dim(parental_results[parental_results$term_id!="",])[1]>0){
    
    additional_classes <- parental_results[parental_results$term_id!="",1:2]
    additional_classes <- additional_classes[!(additional_classes$term_id %in% cross_references$preferred_ontology_term),]

    additional_classes$label <- as.character(additional_classes$label)
    additional_classes$label <- unlist(lapply(additional_classes$label, function(x) {paste(toupper(substr(x, 1, 1)), substr(x, 2, nchar(as.character(x))), sep="")}))
    names(additional_classes) <- c("ontology_term","label")
    labels <- additional_classes$label
    
    #Cross-references
    additional_classes[,1]<-as.character( additional_classes[,1])
    additional_classes <- get_ols_cross_references(additional_classes)
    
    additional_classes <- additional_classes[,-2]
    additional_classes$label <- labels
    
    additional_classes <- additional_classes[!(additional_classes$MONDO %in% cross_references$preferred_ontology_term),]
    
    names(additional_classes)[1] <- "preferred_ontology_term"
    names(additional_classes)[11] <- "ICD.10"
    
    test_cross_references <- rbind(cross_references[,1:12],additional_classes)
    ontology_check <- Vectorize(function(a) {
      switch(as.character(a),
             "EF" = "EFO", "HP" = "HP", "Or" = "Orphanet","MO" = "MONDO","NC" = "NCIT","DO" = "DOID", "GO" = "EFO", "BF" = "EFO", "MP" = "EFO", "OB" = "EFO", "IA" = "EFO",
             "OG" = "EFO", "CH" = "EFO",)
      
    }, "a")
    preferred_ontologies <- c("EFO","NCIT","DOID","Orphanet","HP","MONDO")
    test_cross_references$ontology <- as.character(ontology_check(substr(test_cross_references$preferred_ontology_term,1,2)))
    test_cross_references <- as.data.frame(test_cross_references)
    for(ontology_value in preferred_ontologies){
      test<- test_cross_references[test_cross_references$ontology==ontology_value,]
      test_result <- test_cross_references[test_cross_references$ontology!=ontology_value & test_cross_references[,ontology_value] %in% test$preferred_ontology_term,]
      if (dim(test_result)[1]!=0){
        print(paste("There are loops in ",ontology_value," cross-references:",sep=""))
        test_result
      }
    }
    
    write.table(additional_classes,paste(dir_name,ontology_name,"_additional_classes.tsv",sep=""),row.names = F,sep="\t")
  }
  write.table(unique(prepared_hierarchy),paste(dir_name,ontology_name,"_prepared_hierarchy.tsv",sep=""),row.names = F,sep="\t")
  
}  

########################################################################
