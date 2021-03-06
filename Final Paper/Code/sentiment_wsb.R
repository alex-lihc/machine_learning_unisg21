# Machine Learning Final Project
# Reddit — WallStreetBets Sentiment Analysis / Machine Learning
library(dplyr)
library(quanteda)
library(readtext)
library(stringr)
library(tidyverse)


setwd("~/Desktop/Uni/FS21/Machine Learning/machine_learning_unisg21/Final Paper")

# Data
data = read.csv("Data/wsb_reddit_complete_clean.csv")

#######
# Data Cleaning
#data$body = recode(data$body, "[removed]"="", .default = data$body)
#data$body = recode(data$body, "[deleted]"="", .default = data$body)
#data$body = recode(data$body, "nan"="", .default = data$body)
#
## mutate Text column combining title and body
#data = data %>%
#  mutate(Text = paste(title, body, sep = " "))
#
## remove unnecessary columns
#data = data[,-(7)]
#data = data[,-(4:5)]
#data = data[,-(1:2)]
#data = data[,c(4,1,2,3)]
#
#write.csv(data, file="Data/wsb_reddit_complete_clean.csv")
#######

############################## Sentiment Analysis ##############################
# Quanteda
reddit_corpus = corpus(data$Text)
reddit_tokens = tokens(reddit_corpus)

reddit_tokens = tokens(reddit_tokens, remove_punct = TRUE, 
                       remove_numbers = TRUE)

reddit_tokens = tokens_select(reddit_tokens, stopwords('english'),selection='remove')

reddit_tokens = tokens_wordstem(reddit_tokens)

reddit_tokens = tokens_tolower(reddit_tokens)

reddit_dfm = dfm(reddit_final, remove_numbers = TRUE, 
                 stem = TRUE, 
                 remove = stopwords("english"))

reddit_final = dfm(reddit_tokens)

# Trim
reddit_dfm.trim =
  dfm_trim(
    reddit_final,
    min_docfreq = 0.075,
    # min 7.5%
    max_docfreq = 0.90,
    #  max 90%
    docfreq_type = "prop"
  ) 

# Loughran & McDonald 2014 Financial Dictionary
dict = dictionary(file = "Data/WordStat/Loughran_McDonald_2014.cat",format = "wordstat")

#
reddit_dfm.un = dfm(reddit_dfm.trim, groups = "country", dictionary = dict)
un.topics.pa <- convert(reddit_dfm.un, "data.frame") %>%
  dplyr::rename(country = document) %>%
  select(country, immigration, intl_affairs, defence) %>%
  tidyr::gather(immigration:defence, key = "Topic", value = "Share") %>%
  group_by(country) %>%
  mutate(Share = Share / sum(Share)) %>%
  mutate(Topic = haven::as_factor(Topic))


