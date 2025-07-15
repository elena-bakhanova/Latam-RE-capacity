###
# Data is taken from IRENA (2023), Renewable energy statistics 2023, International Renewable Energy Agency, Abu Dhabi
# https://pxweb.irena.org/pxweb/en/IRENASTAT
###

# Install packages
# install.packages("tidyverse")
# install.packages("ggplot2")
# install.packages("purrr")

# Load packages
library(tidyverse)
library(ggplot2)
library(haven)
library(readxl)
library(purrr)

# Define the root directory path
current_dir <- getwd()

# Arrange data frames together
data_files <- c(
  "data/01_Latam RE Capacity.xlsx",
  "data/02_Latam Hydropower Capacity.xlsx",
  "data/03_Latam Wind Energy Capacity.xlsx",
  "data/04_Latam Solar Capacity.xlsx",
  "data/05_Latam Bioenergy Capacity.xlsx"
)

# Name data frames
energy_types <- c("Total", "Hydro", "Wind", "Solar", "Bioenergy")

# Load data
full_path <- file.path(current_dir, data_files)
list_of_dfs <- map(full_path, read_excel)

# Reshape all the data frames into long format
read_and_reshape <- function(files, energy_type) {
  df <- read_excel(files)
  # Handle n/a
  df <- df %>%
    mutate(across(-Pais, as.character))
 
  df_long <- df %>%
    pivot_longer(
      cols = -Pais,
      names_to = "Year",
      values_to = "Capacity"
    ) %>%
    mutate(
      Capacity = na_if(Capacity, "n/a"),   # Replace "n/a" with NA
      Capacity = as.numeric(Capacity),     # Convert to numeric 
      Year = as.integer(Year),
      Energy_Type = energy_type
    )
  return(df_long)
}

# Combine long tables together
combined_long <- map2_df(data_files, energy_types, read_and_reshape)

# See the result 
glimpse(combined_long)
head(combined_long)

# Save long version of vizualisation in Tableau
write.csv(combined_long, "latam_renewables_combined_long.csv", row.names = FALSE)
