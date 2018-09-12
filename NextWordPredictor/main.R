library(shiny)
library(dplyr)
library(ggplot2)
library(stringr)
library(wordcloud)
library(RColorBrewer)

freq.table<-readRDS(file="data/Model_Final_Frequencies.RDS")


MAX_N_GRAMS_CREATED <- 4

####### functions #########
clean_input <- function(txt_input) {
        
    txt_input <- unlist(str_split(txt_input, "[.!?]"))
    txt_input <- txt_input[length(txt_input)]
    
    txt_input <- str_trim(txt_input)
    txt_input<- tolower(txt_input)
    txt_input <- gsub("'", "'", txt_input)
    txt_input <- gsub("[^[:alnum:][:space:]\']", " ", txt_input)
    txt_input <- iconv(txt_input, "latin1", "ASCII", sub = "_0_")
    txt_input <- gsub("\\w*[0-9]\\w*"," ", txt_input)
    txt_input <- gsub(" www(.+) ", " ", txt_input)
    txt_input <- gsub("\\s+[b-hj-z]\\s+", " ", txt_input)
    txt_input <- gsub("\\s+", " ", txt_input)
    txt_input <- str_trim(txt_input)
    
    if(txt_input=="" | typed_context==" ") 
        return("DOT")
    else 
        return(txt_input)
}

predict_next_word <- function(freq.table, typed_context, numberWords=3) {
    stopifnot(numberWords<=5 & numberWords>0)
    
    capitalize_prediction <- FALSE
    typed_context <- clean_input(typed_context)
    
    typed_context <- get_last_n_words(typed_context, n=MAX_N_GRAMS_CREATED-1)
    
    nGramToStartSearch <- nWords(typed_context)+1
    
    if (get_last_word(typed_context) == "DOT")
        capitalize_prediction <- TRUE
    
    searchTerms <- sapply((nGramToStartSearch-1):1, function(i) {
        get_last_n_words(typed_context, i)
    })
    searchTerms <- c(searchTerms, "") 
    
    finalResult<-freq.table %>% 
        filter(as.character(context) %in% searchTerms)
    
    finalResult <-
        finalResult %>% 
        select(predicted, freq, ngram, everything()) %>% 
        mutate(predicted = as.character(predicted)) %>%
        mutate(freq=as.numeric(as.character(freq))) %>%
        mutate(ngram=as.integer(as.character(ngram))) %>%
        mutate( freq = freq * ((0.40)^(nGramToStartSearch-ngram)) ) %>%
        arrange(desc(ngram), desc(freq) )
    
    finalResult$predicted[finalResult$predicted=="DOT"] <- "."
    finalResult$predicted[finalResult$predicted=="i"] <- "I"
    
    if (nrow(finalResult)>numberWords) {
        finalResult <- head(finalResult,numberWords)
    } 
    
    if(capitalize_prediction) {
        finalResult$predicted <- toupper(finalResult$predicted)
    }
    
    finalResult
}

get_last_word <- function(s, sep=" ") {
    #stringr::word(s, -1)
    get_last_n_words(s, n=1L, sep = sep)
}

get_last_n_words <- function(s, n, sep=" ") {
    stopifnot(n>=1)
    words <- unlist(strsplit(s, split = sep))
    len<-length(words)
    if (len<=n)
        return(paste(words, collapse = sep))
    paste(words[-(1:(len-n))], collapse = sep)
}

get_first_n_words <- function(s, n, sep=" ") {
    
    stopifnot(n>=1)
  
    words <- unlist(strsplit(s, split = sep))
    len<-length(words)
    if(len<n) 
        return(paste(words, collapse = sep))
    paste(words[1:n], collapse = sep)
}

nWords <- function(s, sep=" ") {
    s<-as.character(s)
    n=0
    if (nchar(s)!=0) { 
        n=length(unlist( strsplit(s, split = sep)  )) 
    }
    n
}
