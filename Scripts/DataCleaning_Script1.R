# Clear the R environment
rm(list = ls())

# Load necessary packages
library(tidyverse)

# Define a custom '%notin%' operator
`%notin%` <- Negate(`%in%`)

# Set the working directory to the specified path
setwd("/Users/user/Dropbox/ArkadDiegoWOMadhuonSOSS/Data")

# Load data from files
load("CensusLinking.rda")
Indiaraw <- readRDS("IndiaPLFS201718.rds")
sample_sizes <- readRDS("Sample_Sizes.rds")


set.seed(123456)
N <- 35000
Indiaraw <- Indiaraw[sample(nrow(Indiaraw), N), ]


# Data preprocessing
India_Employment <- Indiaraw %>%
  filter(sex != "3" & ( age>="14"  & age <= "24") ) %>%
  mutate(
    distnew = str_pad(district, 2, pad = "0"),
    statenew = str_pad(state, 2, pad = "0"),
    distcode = paste0(statenew, '', distnew)
  ) 

# Aggregate data by various criteria
India_Employment_State <- India_Employment %>%
  group_by(statenew) %>%
  summarise(Freq_State = sum(medwork))

India_Employment_District <- India_Employment %>%
  group_by(distcode) %>%
  summarise(Freq_Medwork = sum(medwork))

India_Employment_Males <- India_Employment %>%
  group_by(distcode) %>%
  summarise(Prop_Males = sum(female))

India_Employment_Rural <- India_Employment %>%
  group_by(distcode) %>%
  summarise(Prop_Rural = sum(rural))

# Perform left joins to merge data frames
India_Employment <- India_Employment %>%
  left_join(India_Employment_State, by = "statenew") %>%
  left_join(India_Employment_District, by = "distcode") %>%
  left_join(sample_sizes, by = "distcode") %>%
  left_join(India_Employment_Males, by = "distcode") %>%
  left_join(India_Employment_Rural, by = "distcode")

# Create a plot
plot(log(India_Employment$sample_size), India_Employment$Freq_Medwork, 
     xlab = "log(population)", ylab = "observed events", pch = 20)

# Create a new data frame for further analysis
India_Employment_By_District <- India_Employment %>%
  dplyr::select(distcode, Freq_State, Prop_Males, Prop_Rural, sample_size) %>%
  distinct()

# Data transformation
India_Employment_By_District <- India_Employment_By_District %>%
  mutate(
    Prop_Males = Prop_Males / sample_size,
    Prop_Females = 1 - Prop_Males,
    Prop_Rural = Prop_Rural / sample_size,
    Prop_Urban = 1 - Prop_Rural
  )

# Join data frames
India_Sample_Employment <- India_Employment_By_District %>%
  left_join(Key_Censsu2011, by = "distcode")

head(India_Sample_Employment)
dim(India_Sample_Employment)

# Save the resulting data frame to an RDA file
save(India_Sample_Employment, file = "India_Employment_withCensus2011_SampleSize.rda")


