# PROJECT:  moz-cop22
# AUTHOR:   K. Srikanth | USAID
# PURPOSE:  Review MOZ DP
# LICENSE:  MIT
# DATE:     2022-03-02
# UPDATED:  


#DEPENDENCIES ----------------------------------------------------------------------

library(tameDP)
library(tidyverse)
library(glitr)
library(glamr)
library(gophr)
library(glue)
library(scales)


#Directory ---------------------------------------------------------------------------

path <- "C:/Users/ksrikanth/Documents/Datapack/Mozambique_datapack_Finalized_20220415.xlsx"

clean_number <- function(x, digits = 0){
  dplyr::case_when(x >= 1e9 ~ glue("{round(x/1e9, digits)}B"),
                   x >= 1e6 ~ glue("{round(x/1e6, digits)}M"),
                   x >= 1e3 ~ glue("{round(x/1e3, digits)}K"),
                   TRUE ~ glue("{x}"))
}

#read in Data Pack & tidy
df_dp <- tame_dp(path)

#grab PSNUxIM tab
df_dp_mech <- tame_dp(path, type = "PSNUxIM")

#grab PLHIV tab
df_plhiv <- tame_dp(path, type = "PLHIV")

#munge 
df_plhiv %>%  filter(numeratordenom == "N") %>% 
  group_by(fiscal_year, indicator, numeratordenom) %>% 
  summarise(across(c(cumulative, targets), sum, na.rm = TRUE), .groups = "drop")

#read psnu by im MSD to get last year's data
df_psnu <- si_path() %>% 
  return_latest("PSNU_IM_FY20-22_20220211_v1_1_Mozambique") %>% 
  read_msd()