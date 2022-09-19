


## LOAD LIBRARIES --------------------------------------------------
library(tidyverse) #install.packages("tidyverse")
library(scales) #install.packages("scales")
library(glitr) #remotes::install_github("USAID-OHA-SI/glitr", build_vignettes = TRUE)
library(glamr)
library(here)
library(readxl)

# IMPORT DATA --------------------------------------------------------
#load the dataset in your Global Environment - we are using sample data from the `glitr` package
data(hts)


## VIEW DATA -----------------------------------------------------------
#prints out a preview of your data; indicators run vertically (with type) and data runs horizontally
glimpse(hts)
head(hts)
names(hts)
str(hts)


# PIVOT DATA WIDE --------------------------------------------------------

hts_wide <- hts %>% 
  pivot_wider(names_from= period, values_from = value)

head(hts_wide)


## USING BASE R --------------------------------------------------

#I want to:
  # Filter to prime partner Auriga in FY50
  # Group by indicator and period_type
  # summarize total results

#not intuitive and tricky to understand
aggregate(hts[(hts$primepartner == "Auriga") & (hts$period == "FY50"), ]$value,
  by = list(
    indicator = hts[(hts$primepartner == "Auriga") & (hts$period == "FY50"), ]$indicator,
    period_type = hts[(hts$primepartner == "Auriga") & (hts$period == "FY50"), ]$period_type
  ),
  FUN = sum, na.rm = TRUE
)


## USING TIDYVERSE -------------------------------------------------

# Easier to follow step by step
filter(hts, primepartner == "Auriga" & period == "FY50") %>% 
  group_by(., indicator, period_type) %>% 
  summarise(., total_results = sum(value, na.rm = T))


## FILTER ------------
# The filter function will select rows based on their values. How could we go about filtering the data to only keep TBClinic testing modality for the primepartner Auriga?

hts %>% 
  filter(modality == "TBClinic" & primepartner == "Auriga")


## ARRANGE ------------
# Sort the data frame we just filtered above from highest to lowest value
hts %>% 
  filter(modality == "TBClinic" & primepartner == "Auriga") %>% 
  arrange(desc(value))


## SELECT ------------
# Drop the operatingunit and primepartner from the dataframe
# The negation (!) component in the select call tells R to keep everything
# except the operatingunit and primepartner columns
hts %>% 
  filter(modality == "TBClinic" & primepartner == "Auriga") %>% 
  arrange(desc(value)) %>% 
  select(!c(operatingunit, primepartner))


## MUYTATE ------------
hts %>% 
  filter(modality == "TBClinic" & primepartner == "Auriga") %>% 
  arrange(desc(value)) %>% 
  select(!c(operatingunit, primepartner)) %>% 
  group_by(indicator, period_type) %>% 
  mutate(summed_value = sum(value, na.rm = T)) %>% 
  ungroup()


## SUMMARISE ------------
hts %>% 
  filter(modality == "TBClinic" & primepartner == "Auriga") %>% 
  arrange(desc(value)) %>% 
  select(!c(operatingunit, primepartner)) %>% 
  group_by(indicator, period_type) %>% 
  summarise(summed_value = sum(value, na.rm = T), .groups = "drop")


## TIDY DATA & PIVOTS --------------

hts_wide <- hts %>% 
  pivot_wider(names_from= period, values_from = value)
head(hts_wide)

# PRACTICE -------------------------------------------------------------

# Problem: Use the dplyr verbs discussed to create a data frame that:
#   
#   summarizes indicator results (not targets / cumulative)
#   for the only the first two quarters of FY49
#   for only index-based testing modalities
#   for the primeparter Auriga
#   pivots the data wide by indicator (HTS_TST, HTS_TST_POS)


## ------------------------------------------------------------------------------------------------------------------------
#Homework solutions: Use the dplyr verbs discussed to create a data frame that summarizes indicator results for the first two quarters of FY49 for only index-based testing modalities for Auriga
hts %>% 
  filter(period_type == "results" & str_detect(modality, "Index") & primepartner == "Auriga" & period %in% c("FY49Q1", "FY49Q2")) %>% 
  group_by(indicator, modality) %>% 
  summarise(results_q1_q2 = sum(value, na.rm = T), .groups = "drop") %>% 
  pivot_wider(names_from = indicator, values_from = results_q1_q2)


## ------------------------------------------------------------------------------------------------------------------------
# Another approach, filtering later on in the flow
hts %>% 
  filter(modality %in% c("Index", "IndexMod"), period %in% c("FY49Q1", "FY49Q2")) %>% 
  group_by(indicator, primepartner, period_type, modality) %>% 
  summarise(results_q1_q2 = sum(value, na.rm = T), .groups = "drop") %>% 
  arrange(primepartner) %>% 
  filter(primepartner == "Auriga") %>% 
    pivot_wider(names_from = indicator, values_from = results_q1_q2)


