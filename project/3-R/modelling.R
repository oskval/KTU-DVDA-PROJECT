
library(h2o)
library(readr)
h2o.init(max_mem_size = "6g")

df <- h2o.importFile("C:/Users/oskaras.valentinavic/Desktop/SMD S01E01/SMD S01E01/P160M132 Fuck/Project/KTU-DVDA-PROJECT/project/1-data/train_data.csv")
test_data <- h2o.importFile("C:/Users/oskaras.valentinavic/Desktop/SMD S01E01/SMD S01E01/P160M132 Fuck/Project/KTU-DVDA-PROJECT/project/1-data/test_data.csv")
df

class(df)
summary(df)

y <- "y"
x <- setdiff(names(df), c(y, "id"))
df$y <- as.factor(df$y)
summary(df)

splits <- h2o.splitFrame(df, c(0.7, 0.2), seed  = 1234)
train <- h2o.assign(splits[[1]], "train")
valid <- h2o.assign(splits[[2]], "valid")
test <- h2o.assign(splits[[3]], "test")

# automl
drf_model <- h2o.randomForest(x = x,
                             y = y,
                             sample_rate = 0.8,
                             col_sample_rate_per_tree = 0.8,
                             ntrees = 70,
                             max_depth = 50,
                             min_rows = 20,
                             calibrate_model = TRUE,
                             calibration_frame = valid,
                             binomial_double_trees = TRUE,
                             training_frame = train,
                             validation_frame = valid)
drf_model

h2o.performance(drf_model, valid)

