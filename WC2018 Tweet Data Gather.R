library(twitteR)
library(ROAuth)
library(tidytext)
library(tidyverse)
library(streamR)
library(lubridate)


options(scipen = 999)

####################################################
#---------- Setup Twitter authentication ----------#
####################################################

# # Parameters configuration
# 
# reqURL <- "https://api.twitter.com/oauth/request_token"
# accessURL <- "https://api.twitter.com/oauth/access_token"
# authURL <- "https://api.twitter.com/oauth/authorize"
# 
# options(httr_oauth_cache=T)

consumer_key <- consumer
consumer_secret <- secret
access_token <- token
access_secret <- token_secret


## Alternatively, it is also possible to create a token without the handshake:
my_oauth <- list(consumer_key = consumer,
                 consumer_secret = secret,
                 access_token= token,
                 access_token_secret = token_secret)



###################################################
#---------- Twitter stream data capture ----------#
###################################################

#####################
##### DEN v AUS #####
#####################

# capture tweets mentioning the DEN v AUS world cup Match from 9pm-12:30amAEST "DENAUS" hashtag
DEN_AUS <- filterStream(file="", track="DENAUS",
                       timeout=12600, oauth=my_oauth )


tweets_df <- parseTweets(DEN_AUS)

tweets_df$game <- "DEN_AUS"


#####################
##### BEL v TUN #####
#####################

## capture tweets mentioning the BEL v TUN world cup Match from 10pm-1amAEST "DENAUS" hashtag
BEL_TUN <- filterStream(file="", track="BELTUN",
                        timeout=10800, oauth=my_oauth )


tweets_Bel_Tun <- parseTweets(BEL_TUN)

tweets_Bel_Tun$game <- "BEL_TUN"


#####################
##### ENG v PAN #####
#####################

## capture tweets mentioning the ENG v PAN world cup Match from 9pm-1amAEST "ENGPAN" hashtag
ENG_PAN <- filterStream(file="", track= c("ENGPAN", "ENG"),
                        timeout=14440, oauth=my_oauth )


tweets_Eng_Pan <- parseTweets(ENG_PAN)

tweets_Eng_Pan$game <- "ENG_PAN"


####################################
#---------- Final output ----------#
####################################

# Join the three games into one DF
WC_18_Twitter <- bind_rows(tweets_df, tweets_Bel_Tun, tweets_Eng_Pan)

# Remove the individual objects
rm(tweets_df, tweets_Bel_Tun, BEL_TUN, DEN_AUS, tweets_Eng_Pan, ENG_PAN);gc()

# inspect the data
head(WC_18_Twitter)

# where are thre NAs?
print(colSums(is.na(WC_18_Twitter)))


############################################
#---------- Write final Dataset ----------#
############################################

saveRDS(WC_18_Twitter, "Data Files/WC_18_Twitter.rds")
