install.packages("tidyverse")
library(readr)
library(tidyverse)

data1 <- read_csv("../1-data/1-sample_data.csv")
data2 <- read_csv("../1-data/2-additional_data.csv")
additionalFeatures <- read_csv("../1-data/3-additional_features.csv")

joined_data <- inner_join(data, data_additional, by = "id")

write_csv(data_full, "../../../project/1-data/train_data.csv")