# AUTHOR:   
# PURPOSE:  Exploring Data in R
# LICENSE:  MIT
# DATE:     2022-09-14
# UPDATED:

#LOAD PACKAGES ------------------------------------------------------------

# if your libraries do not load, reinstall the package

library(glitr) #remotes::install_github("USAID-OHA-SI/glitr", build_vignettes = TRUE)
library(tidyverse) #install.packages("tidyverse")

# INSPECT DATA ------------------------------------------------------------

#see what datasets exist in the glitr package
data(package = "glitr")

#load the dataset in your Global Environment
data(hfr_mmd)


#prints out a preview of your data; indicators run vertically (with type) and data runs horizontally
glimpse(hfr_mmd)

#your traditional tabular view (like viewing in Excel)
View(hfr_mmd)


#returns data structure (# rows, columns, data type for each variable)
str(hfr_mmd)

# Quick way to count number of a particular variable
hfr_mmd %>% 
  count(snu1)

#get help with ?[function] or place your cursor on the function and hit F1
?hfr_mmd

