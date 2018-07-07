library(twitteR)
library(ROAuth)
library(tidytext)
library(tidyverse)
library(streamR)
library(lubridate)

options(scipen = 999)

WC_18_Twitter <- readRDS("Data Files/WC_18_Twitter.rds")

# Plot number of tweets each minute.
## NOTES: ##
##### Den scored their first goal in the 7th minute, Aus scored their penalty in the 37th minute. Do tweets show this? #####
WC_18_Twitter %>%
  # UCT time in hh:mm format
  mutate(created_at=substr(created_at, 12, 16))%>%
  count(game, created_at) %>%
  ggplot(aes(x=as.numeric(as.factor(created_at)), y=n, group=1)) +
  geom_line(size=1, show.legend=FALSE) +
  scale_x_continuous(breaks=c(0,30,60,90,120,
                              150,180,210,240),
                     labels=c("21:00","21:30","22:00","22:30","23:00",
                              "23:30","00:00","00:30","01:00")) +
  labs(x= "Time (AEST)", y= "Num of Tweets", title = "Number of tweets during Australia vs Denmark") +
  theme_bw() +
  facet_wrap(~ game, ncol = 1)


# What were the most tweeted languages?
WC_18_Twitter %>%
  group_by(game, lang) %>%
  summarise(n = n()) %>%
  arrange(desc(n)) %>%
  top_n(n=10) %>%
  ggplot(aes(x=reorder(lang, n), y=n)) +
  geom_col() +
  coord_flip() +
  theme_bw() +
  facet_wrap(~ game, ncol = 1, scales = "free")

# Was there a difference in the percentage of verified users per game?
WC_18_Twitter %>%
  ggplot(aes(x=game, fill = verified)) +
  geom_bar(position = "fill") +
  coord_flip()

# where were people tweeting from during the game (excluding NA locations)?
WC_18_Twitter %>%
  filter(!is.na(location)) %>%
  group_by(game, location) %>%
  summarise(n = n()) %>%
  arrange(desc(n)) %>%
  top_n(n=10) %>%
  ggplot(aes(x=reorder(location, n), y=n)) +
  geom_col() +
  coord_flip() +
  facet_wrap(~ game, scales = "free", ncol = 1)

# who tweeted the most during the game?
WC_18_Twitter %>%
  group_by(game, screen_name) %>%
  summarise(n = n()) %>%
  arrange(desc(n)) %>%
  top_n(n=10) %>%
  ggplot(aes(x=reorder(screen_name, n), y=n)) +
  geom_col() +
  coord_flip() +
  facet_wrap(~ game, scales = "free", ncol = 1)


wc_sentiment <- WC_18_Twitter %>%
  select(game, id_str, created_at, lang, location, text) %>%
  unnest_tokens(word, text) %>%
  anti_join(stop_words, by = "word") %>%
  inner_join(get_sentiments("bing"), by = "word")


tweets_sentiment %>% group_by(id) %>% n_distinct()


ggplot(data = wc_sentiment, aes(x=sentiment))+
  geom_bar(stat = "count") +
  facet_wrap(~game)