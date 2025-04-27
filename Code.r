install.packages("keras")
install.packages("tensorflow")
install.packages("quantmod")

library(keras)
library(tensorflow)
library(quantmod)

getSymbols("AAPL", src = "yahoo", from = "2015-01-01", to = "2024-01-01")
data <- na.omit(Cl(AAPL))  # Cl() gets Closing Prices

data <- as.numeric(data)
data <- scale(data)

create_dataset <- function(dataset, time_steps = 60) {
  X <- NULL
  Y <- NULL
  for (i in 1:(length(dataset) - time_steps)) {
    X <- rbind(X, dataset[i:(i + time_steps - 1)])
    Y <- c(Y, dataset[i + time_steps])
  }
  list(X = X, Y = Y)
}

time_steps <- 60
dataset <- create_dataset(data, time_steps)

X <- array(dataset$X, dim = c(nrow(dataset$X), time_steps, 1))  # [samples, time_steps, features]
Y <- dataset$Y

train_size <- floor(0.8 * length(Y))
X_train <- X[1:train_size,,]
Y_train <- Y[1:train_size]

X_test <- X[(train_size+1):length(Y),,]
Y_test <- Y[(train_size+1):length(Y)]

model <- keras_model_sequential() %>%
  layer_lstm(units = 50, return_sequences = TRUE, input_shape = c(time_steps, 1)) %>%
  layer_lstm(units = 50) %>%
  layer_dense(units = 1)

model %>% compile(
  optimizer = 'adam',
  loss = 'mean_squared_error'
)

summary(model)

model %>% fit(
  X_train, Y_train,
  epochs = 50,
  batch_size = 32,
  validation_split = 0.1
)

predictions <- model %>% predict(X_test)

plot(Y_test, type = 'l', col = 'blue', main = "Actual vs Predicted", ylab = "Price")
lines(predictions, col = 'red')
legend("bottomleft", legend=c("Actual", "Predicted"), col=c("blue", "red"), lty=1)



