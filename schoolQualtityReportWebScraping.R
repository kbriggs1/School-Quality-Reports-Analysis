#Script Name:  "SchoolQualityReport"
#author: "Krystal Briggs"
#date: "5/7/2020"
#description: "The following R script will fetch the latest year from the url."
library(rvest)
library(stringr)
library(tidyverse)
library(slackr)

# PLEASE FILL UP YOUR CHANNEL DETAILS AND APP DETAIL IN FOLLOWING VARIABLES #
# channel = "#YOUR_CHANNEL_NAME"
# username = "SLACK_CUSTOM_APPNAME_FOR_INTEGRATION"
# icon_emoji = "EMOJI YOU WANT TO SET UP ON"
# api_token = "SLACK_CUSTOM_APP_TOKEN"
# incoming_webhook_url = "SLACK_CUSTOM_APP_WEBHOOK_URL"

text_slackr(text = read_html("https://infohub.nyced.org/reports/school-quality/school-quality-reports-and-resources/school-quality-report-citywide-data") %>%
              html_nodes("div.rte-content") %>%
              html_nodes("h2") %>%
              html_text() %>%
              as.data.frame() %>%
              .[1,] %>%
              as.character() %>%
              str_c(" are available. Please download it from https://infohub.nyced.org/reports/school-quality/school-quality-reports-and-resources/school-quality-report-citywide-data"))
        
