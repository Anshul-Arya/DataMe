library(FitAR)
library(forecast)

rm(list = ls())
data("EuStockMarkets")
ftse = (EuStockMarkets[,4])
par(mfrow = c(1,1))
plot(ftse, ylab = "EU Stock Market",
           main = "EU STock Market time series")


# as you can see there is a clear upward trend, although there is a sharp downfall 
# in 1998, but overall the trend is upward, we are interested in finding if the
# trend is going to fall or rise upward in Future.

# Lets decompose the series in various component
ftse.comp <- decompose(ftse)
plot(ftse.comp)

# we can see the trend is definetely upward, but there is seasonality in the 
# series which we need to take care of.
# One way is to subtract the seasonal component from the time series.
stat <- ftse.comp$seasonal
# let's try with first differencing and see if it makes the series stationarity
# if not we will try with higher level differencing
ftse_stat <- diff(stat, differences = 1)
plot(ftse_stat, main = "Stationary time series for EU Stock Market",
                ylab = "EU STock Makret Index")
par(mfrow = c(1,2))
# Auto correlation function
acf(ftse_stat, lag.max = 40)
# Partial Auto correlation function
pacf(ftse_stat, lag.max = 40)

# as we have a significant lag in ACF and dampning pattern in PACF, our 
# Series turns out to be Moving Average MA(q)
# Lets train a simple ARIMA model to take into effect the Autoregressive
# compenent as well

# Fit a ARIMA Model as our time series is stationary
fit_ar <- arima(ftse, order = c(1,1,1), seasonal = list(order = c(1,0,0),
                                                        period = 12),
                method = "ML")
# Let's examine the residual, there should not be any trend left in the
# residual and if there is it means the model fails to capture all the 
# trend in the data and it needs more paramters.
par(mfrow = c(1,1))
res <- fit_ar$residuals
plot(res)

# There seems to be no trend in the residuals which means it has covered all
# the information from the series. But to be sure we will perform Ljung-Box test

# Null hypothesis : H0 : The data are independently distributed
# Alternate hypothesis : HA: The data are not independently distributed
Box.test(res, type = "Ljung-Box")

# Ljung box test gives the p value of 0.92, which suggest that we do not have
# significant evidence to reject null hypothesis, that means we can assume
# that the residuals data points are independently distributed

# lets examine the best model using auto.arima() function, it returns the
# best model by using AIC, BIC values.

auto.arima(ftse, trace = TRUE)
# From auto arima function it seems the best model is (0,1,0)
mod <- arima(ftse, order = c(0,1,0), seasonal = list(order = c(1,0,0),
                                                     period = 12),
             method = "ML")
plot(mod$residuals)
Box.test(mod$residuals, type = "Ljung-Box")

# the P value is less, so it is not the best model, so we will stick to our
# original model c(1,1,1)

pred <- forecast(fit_ar, h = 200, level = c(99.5))
plot(pred)
