# AUTHOR:   
# PURPOSE: practice tidyverse on Enhanced monitoring scripts
# LICENSE:  MIT
# DATE:     2022-09-20
# UPDATED: 

# DEPENDENCIES ------------------------------------------------------------
  
  library(tidyverse)
  library(glue) # install.packages("glue")
  library(readxl) #install.packages("readxl")


# DEFINE VALUES AND PATHS --------------------------------------------------

# update each month
month <- "2022-08-20" 
file <- "TPT_2022_08"

# update each month
filename <- "Data/MonthlyEnhancedMonitoringTemplates_FY22_August2022_ECHO.xlsx"


# IMPORT ------------------------------------------------------------------

#let's first inspect the readxl::read_excel() function documentation
  # we need to supply 2 main arguments: filename and sheet (tab)
  # we can also specify the column variable types and how many numbers to skip
    # we are going to force the column types 
    # we are also going to skip 7 lines for those additional headers
df <- readxl::read_excel(filename, sheet = "TPT Completion", 
                 col_types = c("numeric", 
                               "text", "text", "text", "text", "text", 
                               "numeric", "text", "numeric", "numeric", 
                               "numeric", "numeric", "numeric", 
                               "numeric", "numeric", "numeric", 
                               "text"),
                 skip = 7)

# DATA PREP -------------------------------------------------------------------

#now, let's just select the columns we want and filter to ECHO as our partner
  # reassign dataframe `df` as `tpt`
tpt <- df %>%
  select(c(No,
           Partner,
           Province,
           District,
           `Health Facility`,
           DATIM_code,
           SISMA_code,
           Period,
           TX_CURR,
           TX_CURR_TPT_Com,
           TX_CURR_TPT_Not_Comp,
           TX_CURR_TB_tto,
           TX_CURR_TPT_Not_Comp_POS_Screen,
           TX_CURR_Eleg_TPT_Comp,
           TX_CURR_W_TPT_last7Mo,
           TX_CURR_Eleg_TPT_Init)) %>%
  #count(Partner)
  filter(Partner == "ECHO")

# Now, we are going to add some calculated variables
  # TPT_Candidates
  # TPT_ineligible
  # TPT_active_complete

tpt_tidy <- tpt %>%
  mutate(TPT_candidates = TX_CURR - (TX_CURR_TPT_Com + TX_CURR_W_TPT_last7Mo) - (TX_CURR_TB_tto + TX_CURR_TPT_Not_Comp_POS_Screen),
         TPT_ineligible = TX_CURR_TB_tto + TX_CURR_TPT_Not_Comp_POS_Screen,
         TPT_active_complete = TX_CURR_W_TPT_last7Mo + TX_CURR_TPT_Com)

# we have all of these calcuated variables now that are attributes - if we want to stack these data
# long, we need to pivot_longer()
  # we are then going to add a indicator variable that matches the attribute column
  # we are doing this so we can recode the indicator variable to different names using mutate() and recode()
# Lastly, we are going to get rid of what we dont need by filtering out some indicators and deselect the `No` column

tpt_tidy_final <- tpt_tidy %>%
  pivot_longer(TX_CURR:TPT_active_complete, names_to = "attribute", values_to = "value") %>%
  mutate(indicator = attribute) %>%
  mutate(indicator = recode(indicator,
                            "TX_CURR_W_TPT_last7Mo"= "Actively on TPT", # use to create new indicator
                            "TX_CURR_TB_tto" = "Recent Active TB TX",
                            "TX_CURR_TPT_Not_Comp_POS_Screen" = "Recent Pos TB Screen",
                            "TX_CURR_TPT_Com" = "TPT Completed",  # use to create new indicator
                            "TPT_candidates" = "TPT Candidates",
                            "TPT_ineligible" = "TPT Ineligible",
                            "TX_CURR_TPT_Not_Comp" = "TPT Not Comp",
                            "TPT_active_complete" = "TPT Completed/Active"),
         Period = {month} # we specified this month variable earlier! since we did that, R will call on that variable
  ) %>%
  filter(!indicator %in% c("TX_CURR_Eleg_TPT_Init", "TX_CURR_Eleg_TPT_Comp")) %>%
  select(-c(No))

# EXPORT ----------------------------------------------------------

# Let's export this dataset alone as a .csv file
# we'll readr::write_csv() to write this dataframe out to our local folders
  # (Let's use the Dataout folder we created earlier)

readr::write_csv(tpt_tidy_final, "Dataout/TPT_tidy_2022_08_20.csv")

#Helpful hint! We can use some really cool functions in the `glue` package to
# automate the filepath that we export

# the Glue package allows you to glue strings together based on values that you have stored locally in your R env
# For example, we stored the month in the beginning of this script `month <- "2022-08-20`
# with glue, we can add that at the end of the filepath so we dont have to change this manually every time down here

readr::write_csv(tpt_tidy_final, glue::glue("Dataout/TPT_tidy_{month}.csv"))


