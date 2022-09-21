OHA R Packages
================
Author: Karishma Srikanth
9/21/2022

  - [Introduction](#introduction)
      - [Why did we decide to build R packages for our
        work?](#why-did-we-decide-to-build-r-packages-for-our-work)
  - [Closer Look at Core OHA R
    Packages](#closer-look-at-core-oha-r-packages)
      - [glamr](#glamr)
      - [gophr](#gophr)
      - [tameDP](#tamedp)
      - [grabR](#grabr)
      - [glitr](#glitr)
      - [gisr](#gisr)
      - [gagglr](#gagglr)
  - [Additional OHA Packages](#additional-oha-packages)
      - [mindthegap](#mindthegap)
      - [selfdestructin5](#selfdestructin5)
      - [COVIDutilities](#covidutilities)
      - [cascade](#cascade)

## Introduction

This is the third session in the series of R Trainings for the
PEPFAR/Mozambique team in September 2022.

This tutorial is adapted from the [coRps R Building Blocks Series
(RBBS)](https://usaid-oha-si.github.io//learn/categories/#rbbs).

In order to make the most of this training series, participants should
have a number of account setup and software pre-configured so you can
actively participate during the sessions. Please ensure you have
RStudio, RTools and R installed on your device prior to this session, as
well as Git and Github Desktop.

  - Learning Objectives:
      - Learn about the intuition between creating R packages for our
        team’s workflow
      - Overview of OHA’s R Package Environment
      - Deep Dive into specific packages that are useful to your
        workflow

### Why did we decide to build R packages for our work?

In the beginning of our office’s journey with R, the group of R user’s
grew from a team of 1 person to a group of people using R for their day
to day analytics and wrangling. AS collaboration and automation
continued to increase, the team felt the need to automate code and
workflows that were being consistently utilized to both save time and
free up headspace for future analytics.

Another critical benefit of using packages is that it lowers the barrier
to entry to using R, especially when working with PEPFAR data. Having a
standard set of tools that are accessibile to all, with thorough
documentation of the functions and use cases, significantly alleviates
the burden of learning how to work with PEPFAR data in R.

And finally, PEPFAR’s data streams operate on predictable cycles, of
mostly quarterly/monthly data - using packages meant that we didn’t have
to keep reinventing the wheel each quarter, and could instead automate
tasks every cycle.

  - TL;DR - R packages helped us to:
      - Standardize workflows, better consistency
      - Improve reproducibility and efficiency
      - Make work more approachable

#### Load Libraries

``` r
library(tidyverse) #install.packages("tidyverse")
```

    ## -- Attaching packages --------------------------------------- tidyverse 1.3.2 --
    ## v ggplot2 3.3.6     v purrr   0.3.4
    ## v tibble  3.1.8     v dplyr   1.0.9
    ## v tidyr   1.2.0     v stringr 1.4.1
    ## v readr   2.1.2     v forcats 0.5.1

    ## Warning: package 'ggplot2' was built under R version 4.1.3

    ## Warning: package 'tibble' was built under R version 4.1.3

    ## Warning: package 'dplyr' was built under R version 4.1.3

    ## Warning: package 'stringr' was built under R version 4.1.3

    ## -- Conflicts ------------------------------------------ tidyverse_conflicts() --
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

``` r
library(scales)
```

    ## Warning: package 'scales' was built under R version 4.1.3

    ## 
    ## Attaching package: 'scales'
    ## 
    ## The following object is masked from 'package:purrr':
    ## 
    ##     discard
    ## 
    ## The following object is masked from 'package:readr':
    ## 
    ##     col_factor

``` r
library(glitr) #remotes::install_github("USAID-OHA-SI/glitr", build_vignettes = TRUE)
library(glamr)
library(gophr)
library(grabr)
```

    ## 
    ## Attaching package: 'grabr'
    ## 
    ## The following object is masked from 'package:glamr':
    ## 
    ##     package_check

``` r
library(tameDP)
```

## Closer Look at Core OHA R Packages

### glamr

#### <img src="logos/glamr-logo.png" align="right" height="120" />

**Motivation:** Utility function package to make it easier to optimize
the teams workflow when working with PEPFAR data

  - Some helpful functions:
      - `glamr::si_setup()` - sets up standard project setup
      - `glamr::si_paths()` - creates standard folder paths
      - `glamr::load_secrets()` - loads stored credentials
      - `glamr::return_latest()` - returns the latest file in a folder
        and checks for a pattern that is specified, if so

<!-- end list -->

``` r
glamr::si_setup()
```

``` r
glamr::si_path() #let's set up this path if we havent already to route to a Data folder
```

    ## [1] "C:/Users/ksrikanth/Documents/Data"

``` r
glamr::load_secrets()
```

    ## i The following items have been stored for use in this session:
    ## v email set as 'ksrikanth@usaid.gov'
    ## v `googledrive` authenticated using email
    ## v `googlesheets4` authenticated using email
    ## v datim username set as 'ksrikanth'
    ## v baseurl set to 'https://final.datim.org/'
    ## v pano username set as 'ksrikanth'
    ## v S3 keys set in 'access_key' and 'secret_key'

``` r
glamr::si_path() %>% 
  glamr::return_latest("Mozambique")
```

    ## [1] "C:/Users/ksrikanth/Documents/Data/MER_Structured_Datasets_PSNU_IM_FY20-23_20220812_v1_1_Mozambique.zip"

### gophr

#### <img src="logos/gophr-logo.png" align="right" height="120" />

**Motivation:** Utility function package to optimize working with the
MER Structured Dataset in R

  - Some helpful functions:
      - `gophr::read_msd()` - imports MER dataset from .txt and coverts
        to .rds file
      - `gophr::reshapse_msd()` - reshapes MSD long or wide
      - `gophr::clean_*()` - cleans up data in specific areas
        (`clean_agency()`, `clean_indicator()`, etc.)
      - `gophr::source_info()` - extracts MSD source information

Let’s work through a quick example of putting `glamr` and `gophr`
together - let’s say we wanted to work with the latest PSNU by IM MER
Structured Dataset for Mozambique. I am going to pull that down from
Panorama (this can also be automated using an R package for API calls
called `grabr`) and save this to the data folder that my `si_path()`
routes to. This will be the folder that I save all of my MSDs in.

``` r
df_msd <- glamr::si_path() %>% #grab data folderpath
  glamr::return_latest("MER_Structured_Datasets_PSNU_IM_FY20-23_20220812_v1_1_Mozambique") %>% #return latest file to match the pattern specified
  gophr::read_msd() #read the MSD in to R

head(df_msd) #inspect
```

    ## # A tibble: 6 x 43
    ##   operating~1 opera~2 country snu1  snu1uid psnu  psnuuid snupr~3 typem~4 dreams
    ##   <chr>       <chr>   <chr>   <chr> <chr>   <chr> <chr>   <chr>   <chr>   <chr> 
    ## 1 Mozambique  h11Oyv~ Mozamb~ Namp~ hxMhtp~ Naca~ rzyQVC~ 2 - Sc~ N       N     
    ## 2 Mozambique  h11Oyv~ Mozamb~ Sofa~ SEWXP7~ Nham~ aKC8ch~ 2 - Sc~ N       N     
    ## 3 Mozambique  h11Oyv~ Mozamb~ Zamb~ BdBJXn~ Inha~ MrzLUX~ 2 - Sc~ N       Y     
    ## 4 Mozambique  h11Oyv~ Mozamb~ Namp~ hxMhtp~ Riba~ DkiQIZ~ 2 - Sc~ N       N     
    ## 5 Mozambique  h11Oyv~ Mozamb~ Namp~ hxMhtp~ Mecu~ YLkTM4~ 2 - Sc~ N       N     
    ## 6 Mozambique  h11Oyv~ Mozamb~ Namp~ hxMhtp~ Ango~ xIowtH~ 2 - Sc~ N       N     
    ## # ... with 33 more variables: prime_partner_name <chr>, funding_agency <chr>,
    ## #   mech_code <chr>, mech_name <chr>, prime_partner_duns <chr>,
    ## #   prime_partner_uei <chr>, award_number <chr>, indicator <chr>,
    ## #   numeratordenom <chr>, indicatortype <chr>, disaggregate <chr>,
    ## #   standardizeddisaggregate <chr>, categoryoptioncomboname <chr>,
    ## #   ageasentered <chr>, age_2018 <chr>, age_2019 <chr>, trendscoarse <chr>,
    ## #   sex <chr>, statushiv <chr>, statustb <chr>, statuscx <chr>, ...

Now, let’s try to put this all together. We have our MSD loaded, so now
we can draw on some of our tidyverse skills to work answer some analytic
questions.

  - **Question**:
      - Want to identify TX\_CURR Total Numerator by funding agency and
        prime partner
      - in FY22 by quarter
      - in Sofala province

First, let’s inspect our data. I am going to do some basic counts to
show the utility of the `clean_*()` functions in `gophr`.

``` r
df_msd %>% 
  count(funding_agency) #notice how we get HHS/CDC and HHS/HRSA and have some inconsistent naming patterns
```

    ## # A tibble: 8 x 2
    ##   funding_agency      n
    ##   <chr>           <int>
    ## 1 Dedup            1913
    ## 2 Default          3224
    ## 3 DOD              8411
    ## 4 HHS/CDC        977384
    ## 5 HHS/HRSA           12
    ## 6 PC               1700
    ## 7 State/AF          350
    ## 8 USAID          300670

``` r
#we can correct this by using the clean_agency() function
df_msd %>% 
  gophr::clean_agency() %>% 
  count(funding_agency)
```

    ## # A tibble: 8 x 2
    ##   funding_agency      n
    ##   <chr>           <int>
    ## 1 CDC            977384
    ## 2 DEDUP            1913
    ## 3 DEFAULT          3224
    ## 4 DOD              8411
    ## 5 HRSA               12
    ## 6 PC               1700
    ## 7 STATE             350
    ## 8 USAID          300670

Spot the difference? Small tweaks like this can b incredibly valuable in
your data wrangling. Now, let’s apply what we know about the tidyverse
to try to answer the question above.

Let’s build our filters first:

``` r
# We know we want TX_CURRdata only for USAID and CDC in Sofala in FY22, and standardizeddisaggregate =Total Numerator

# Dont forward to filter on total numerator!
df_msd %>% 
  gophr::clean_agency() %>% 
  filter(snu1 == "Sofala",
         fiscal_year == 2022,
         funding_agency %in% c("CDC", "USAID"),
         indicator == "TX_CURR",
         standardizeddisaggregate == "Total Numerator")
```

    ## # A tibble: 23 x 43
    ##    operatin~1 opera~2 country snu1  snu1uid psnu  psnuuid snupr~3 typem~4 dreams
    ##    <chr>      <chr>   <chr>   <chr> <chr>   <chr> <chr>   <chr>   <chr>   <chr> 
    ##  1 Mozambique h11Oyv~ Mozamb~ Sofa~ SEWXP7~ Nham~ aKC8ch~ 2 - Sc~ N       N     
    ##  2 Mozambique h11Oyv~ Mozamb~ Sofa~ SEWXP7~ Caia  yui33D~ 2 - Sc~ N       Y     
    ##  3 Mozambique h11Oyv~ Mozamb~ Sofa~ SEWXP7~ Beira c4qdq9~ 2 - Sc~ N       Y     
    ##  4 Mozambique h11Oyv~ Mozamb~ Sofa~ SEWXP7~ Marr~ ZMR1mJ~ 2 - Sc~ N       N     
    ##  5 Mozambique h11Oyv~ Mozamb~ Sofa~ SEWXP7~ Chib~ Bp2zX2~ 2 - Sc~ N       N     
    ##  6 Mozambique h11Oyv~ Mozamb~ Sofa~ SEWXP7~ Beira c4qdq9~ 2 - Sc~ N       Y     
    ##  7 Mozambique h11Oyv~ Mozamb~ Sofa~ SEWXP7~ Buzi  qwJ8zD~ 2 - Sc~ N       N     
    ##  8 Mozambique h11Oyv~ Mozamb~ Sofa~ SEWXP7~ Cher~ lZAKLV~ 2 - Sc~ N       N     
    ##  9 Mozambique h11Oyv~ Mozamb~ Sofa~ SEWXP7~ Goro~ iuqTSk~ 2 - Sc~ N       N     
    ## 10 Mozambique h11Oyv~ Mozamb~ Sofa~ SEWXP7~ Dondo QJviLU~ 2 - Sc~ N       N     
    ## # ... with 13 more rows, 33 more variables: prime_partner_name <chr>,
    ## #   funding_agency <chr>, mech_code <chr>, mech_name <chr>,
    ## #   prime_partner_duns <chr>, prime_partner_uei <chr>, award_number <chr>,
    ## #   indicator <chr>, numeratordenom <chr>, indicatortype <chr>,
    ## #   disaggregate <chr>, standardizeddisaggregate <chr>,
    ## #   categoryoptioncomboname <chr>, ageasentered <chr>, age_2018 <chr>,
    ## #   age_2019 <chr>, trendscoarse <chr>, sex <chr>, statushiv <chr>, ...

Now that we have all the filters we need, let’s get to grouping and
summarizing\! Notice, since I want to summarize across all the variables
in the MSD that represent quarters, I will use
`summarize(across(starts_with("qtr")))` as a series of heper functions.

``` r
df_msd %>% 
  gophr::clean_agency() %>% 
  filter(snu1 == "Sofala",
         fiscal_year %in% c(2021, 2022),
         funding_agency %in% c("CDC", "USAID"),
         indicator == "TX_CURR",
         standardizeddisaggregate == "Total Numerator") %>% 
  group_by(snu1, fiscal_year, indicator, standardizeddisaggregate, funding_agency, prime_partner_name) %>% 
  summarise(across(starts_with("qtr"), sum, na.rm = TRUE), .groups = "drop") 
```

    ## # A tibble: 4 x 10
    ##   snu1   fiscal_year indic~1 stand~2 fundi~3 prime~4   qtr1   qtr2   qtr3   qtr4
    ##   <chr>        <int> <chr>   <chr>   <chr>   <chr>    <dbl>  <dbl>  <dbl>  <dbl>
    ## 1 Sofala        2021 TX_CURR Total ~ CDC     MINIST~  30718  32875  33854  34794
    ## 2 Sofala        2021 TX_CURR Total ~ USAID   Abt As~  90174  94914  98400 106581
    ## 3 Sofala        2022 TX_CURR Total ~ CDC     MINIST~  36828  33084  35853      0
    ## 4 Sofala        2022 TX_CURR Total ~ USAID   Abt As~ 117243 124825 131395      0
    ## # ... with abbreviated variable names 1: indicator,
    ## #   2: standardizeddisaggregate, 3: funding_agency, 4: prime_partner_name

We’re almost there\! Now that our data is summarize, we want to reshape
this long so we can more easily filter for the periods we are interested
in. We’ll use `gophr::reshape_msd()` to achieve this.

``` r
df_msd %>% 
  gophr::clean_agency() %>% 
  filter(snu1 == "Sofala",
         fiscal_year %in% c(2021, 2022),
         funding_agency %in% c("CDC", "USAID"),
         indicator == "TX_CURR",
         standardizeddisaggregate == "Total Numerator") %>% 
  group_by(snu1, fiscal_year, indicator, standardizeddisaggregate, funding_agency, prime_partner_name) %>% 
  summarise(across(starts_with("qtr"), sum, na.rm = TRUE), .groups = "drop") %>% 
  gophr::reshape_msd()
```

    ## # A tibble: 14 x 8
    ##    snu1   period indicator standardizeddisaggre~1 fundi~2 prime~3 perio~4  value
    ##    <chr>  <chr>  <chr>     <chr>                  <chr>   <chr>   <chr>    <dbl>
    ##  1 Sofala FY21Q1 TX_CURR   Total Numerator        CDC     MINIST~ results  30718
    ##  2 Sofala FY21Q2 TX_CURR   Total Numerator        CDC     MINIST~ results  32875
    ##  3 Sofala FY21Q3 TX_CURR   Total Numerator        CDC     MINIST~ results  33854
    ##  4 Sofala FY21Q4 TX_CURR   Total Numerator        CDC     MINIST~ results  34794
    ##  5 Sofala FY21Q1 TX_CURR   Total Numerator        USAID   Abt As~ results  90174
    ##  6 Sofala FY21Q2 TX_CURR   Total Numerator        USAID   Abt As~ results  94914
    ##  7 Sofala FY21Q3 TX_CURR   Total Numerator        USAID   Abt As~ results  98400
    ##  8 Sofala FY21Q4 TX_CURR   Total Numerator        USAID   Abt As~ results 106581
    ##  9 Sofala FY22Q1 TX_CURR   Total Numerator        CDC     MINIST~ results  36828
    ## 10 Sofala FY22Q2 TX_CURR   Total Numerator        CDC     MINIST~ results  33084
    ## 11 Sofala FY22Q3 TX_CURR   Total Numerator        CDC     MINIST~ results  35853
    ## 12 Sofala FY22Q1 TX_CURR   Total Numerator        USAID   Abt As~ results 117243
    ## 13 Sofala FY22Q2 TX_CURR   Total Numerator        USAID   Abt As~ results 124825
    ## 14 Sofala FY22Q3 TX_CURR   Total Numerator        USAID   Abt As~ results 131395
    ## # ... with abbreviated variable names 1: standardizeddisaggregate,
    ## #   2: funding_agency, 3: prime_partner_name, 4: period_type

Now we have stacked data with the period as a variable in the dataset\!
This is just one example of the numerous different things we can do when
we combine the `tidyverse` and the OHA packages.

### tameDP

#### <img src="logos/tameDP-logo.png" align="right" height="120" />

**Motivation:** Easily import PSNUxIM targets from Data Pack and make
tidy/usable

  - Some helpful functions:
      - `tameDP::tame_dp()` - export tidy data from Data Pack
        `tameDP::tame_plhiv()` - export TIDY PLHIV data from Data Pack

<!-- end list -->

``` r
library(tameDP)

#datapack file path
path <- "C:/Users/ksrikanth/Documents/Datapack/Mozambique_datapack_Finalized_20220415.xlsx"


#read in Data Pack & tidy
df_dp <- tame_dp(path)

#grab PSNUxIM tab
df_dp_mech <- tame_dp(path, type = "PSNUxIM")

#grab PLHIV tab
df_plhiv <- tame_dp(path, type = "PLHIV")

head(df_dp)
```

    ## # A tibble: 6 x 17
    ##   operatin~1 count~2 snu1  psnu  psnuuid snupr~3 fisca~4 indic~5 stand~6 numer~7
    ##   <chr>      <chr>   <chr> <chr> <chr>   <chr>     <dbl> <chr>   <chr>   <chr>  
    ## 1 Mozambique Mozamb~ _Mil~ _Mil~ siMZUt~ 97 - A~    2021 CXCA_S~ Age/Se~ N      
    ## 2 Mozambique Mozamb~ _Mil~ _Mil~ siMZUt~ 97 - A~    2021 CXCA_S~ Age/Se~ N      
    ## 3 Mozambique Mozamb~ _Mil~ _Mil~ siMZUt~ 97 - A~    2021 CXCA_S~ Age/Se~ N      
    ## 4 Mozambique Mozamb~ _Mil~ _Mil~ siMZUt~ 97 - A~    2021 CXCA_S~ Age/Se~ N      
    ## 5 Mozambique Mozamb~ _Mil~ _Mil~ siMZUt~ 97 - A~    2021 CXCA_S~ Age/Se~ N      
    ## 6 Mozambique Mozamb~ _Mil~ _Mil~ siMZUt~ 97 - A~    2021 PREP_C~ Age/Sex N      
    ## # ... with 7 more variables: ageasentered <chr>, sex <chr>, modality <chr>,
    ## #   statushiv <chr>, otherdisaggregate <chr>, cumulative <dbl>, targets <dbl>,
    ## #   and abbreviated variable names 1: operatingunit, 2: countryname,
    ## #   3: snuprioritization, 4: fiscal_year, 5: indicator,
    ## #   6: standardizeddisaggregate, 7: numeratordenom

### grabR

#### <img src="logos/grabr-logo.png" align="right" height="120" />

**Motivation:** Extend glamr utilities functions to API utility
functions to extract from DATIM and Pano

  - Some helpful functions:
      - `pano_elements()` - extract data element details from html
        content
      - `datim_dimesions()` - get PEPFAR/DATIM dimensions
      - `get_*()` - extract various orgunit hierarchy metadata from
        DATIM

Let’s say I wanted to get the orgunituid for each OU. I could use the
function `grabr::get_orguids()` to grab ever uid at the specific level I
determine. In this case, I’ll specify level = 3 to get the OU level.

``` r
grabr::get_orguids(level = 3)
```

    ## # A tibble: 28 x 2
    ##    uid         orgunit                         
    ##    <chr>       <chr>                           
    ##  1 XOivy2uDpMF Angola                          
    ##  2 ptVxnBssua6 Asia Region                     
    ##  3 l1KFEXKI4Dg Botswana                        
    ##  4 Qh4XMQJhbk8 Burundi                         
    ##  5 bQQJe0cC1eD Cameroon                        
    ##  6 ds0ADyc9UCU Cote d'Ivoire                   
    ##  7 ANN4YCOufcP Democratic Republic of the Congo
    ##  8 NzelIFhEv3C Dominican Republic              
    ##  9 V0qMZH29CtN Eswatini                        
    ## 10 IH1kchw86uA Ethiopia                        
    ## # ... with 18 more rows

### glitr

#### <img src="logos/glitr-logo.png" align="right" height="120" />

**Motivation:** Allows user to easily adorn plots created in ggplot() in
a standardized SI style

  - Some helpful functions:
      - `glitr::si_style()` - standard SI styles applied to plots
      - `glitr::si_palettes()` - color palette developed by OHA/SIEI for
        use

We’ll cover visualization more later, but here’s a snapshot of
OHA/SIEI’s base color palette that was developed.

``` r
show_col(si_palettes$siei_pairs)
```

![](Introduction-to-OHA-Packages_files/figure-gfm/unnamed-chunk-11-1.png)<!-- -->

### gisr

#### <img src="logos/gisr-logo.png" align="right" height="120" />

**Motivation:** OHA geospatial analytics utilities package

  - Some helpful functions:
      - `gisr::get_basemap()` - pulls basemap
      - `gisr::extract_boundaries()` - extract PEPFAR Orgunit Boundaries

### gagglr

#### <img src="logos/gagglr-logo.png" align="right" height="120" />

**Motivation:** Similar to the tidyverse, this package provides a check
to users to ensure they have the latest versions of the core OHA utility
packages

  - Some helpful functions:
      - `gagglr::oha_check()` - check for OHA package updates
      - `gagglr::oha_update()`- update OHA packages

<!-- end list -->

``` r
library(gagglr)
```

    ## -- Attaching packages ---------------------------------- OHA tools 0.0.0.9000 --

    ## v gisr 0.2.1 *
    ## x glamr
    ## x glitr
    ## x gophr

``` r
#run a check on the updates needed for OHA packages
gagglr::oha_check()
```

    ## -- R & RStudio -----------------------------------------------------------------
    ## * R: 4.1.2
    ## -- Core packages ---------------------------------------------------------------
    ## * gisr            (0.2.1     ) [2022-03-09]
    ## * glamr           (1.1.0     )
    ## * glitr           (0.1.0     ) [2022-02-25]
    ## * gophr           (3.1.0     )
    ## -- Non-core packages -----------------------------------------------------------
    ## * COVIDutilities  (1.1.0     ) [2022-03-04]
    ## * gagglr          (0.0.0.9000) [2022-08-04]
    ## * mindthegap      (1.0.0     ) [2022-08-25]
    ## * selfdestructin5 (0.1.0     ) [2022-04-05]
    ## * tameDP          (4.0.2     ) [2022-03-02]
    ## * Wavelength      (2.4.0     ) [2022-04-12]

## Additional OHA Packages

### mindthegap

#### <img src="logos/mindthegap-logo.png" align="right" height="120" />

**Motivation:** Package to clean, process, and tidy annual UNAIDS
estimates for ease of data access

### selfdestructin5

#### <img src="logos/selfdestructin5-logo.png" align="right" height="120" />

**Motivation:** SI utilities package to create Mission Director Briefer
Tables from MSDs that summarize results and targets

### COVIDutilities

#### <img src="logos/COVIDutilities-logo.png" align="right" height="120" />

**Motivation:** Automates data fetching exercises and standardizes the
COVID-19 data to be compatible with other PEPFAR dataset

### cascade

#### <img src="logos/cascade-logo.png" align="right" height="120" />

**Motivation:** Generate automated cascade plots for various analytic
use cases
