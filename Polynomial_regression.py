# Import all the required libraries
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
# for calculating mean sqaured error
from sklearn.metrics import mean_squared_error

# creating a dataset with curvilinear relationship
x = 10*np.random.normal(0, 1, 70)
y = 10*(-x**2)+np.random.normal(-100, 100, 70)

# Plotting dataset
plt.figure(figsize=(10, 5))
plt.scatter(x, y, s=15)
plt.xlabel('Predictor', fontsize=16)
plt.ylabel('Target', fontsize=16)
plt.show()

# importing Linear Regression
from sklearn.linear_model import LinearRegression

# Training Model
lm = LinearRegression()
lm.fit(x.reshape(-1, 1), y.reshape(-1, 1))

y_pred = lm.predict(x.reshape(-1, 1))

# Plotting Prediction
plt.figure(figsize=(10, 5))
plt.scatter(x, y, s=15)
plt.plot(x, y_pred, color='r')
plt.xlabel('Predictor', fontsize=16)
plt.ylabel('Target', fontsize=16)
plt.show()

print('RMSE for Linear Regression =>', np.sqrt(mean_squared_error(y, y_pred)))

# Linear Regression is not able to fit the data well and RMSE is also very high
# Let's fit Polynomial regression
from sklearn.preprocessing import PolynomialFeatures
# for creating pipelines
from sklearn.pipeline import Pipeline
# Creating pipeline and fitting on the data
Input = [('polynomial', PolynomialFeatures(degree=2)),
         ('modal', LinearRegression())]
pipe = Pipeline(Input)
pipe.fit(x.reshape(-1, 1), y.reshape(-1, 1))

# Lets take a look at our model performance
poly_pred = pipe.predict(x.reshape(-1, 1))
# Sorting predicted value with respect to predictor
sorted_zip = sorted(zip(x, poly_pred))
x_poly, poly_pred = zip(*sorted_zip)
# Plotting Prediction
plt.figure(figsize=(10, 6))
plt.scatter(x, y, s=15)
plt.plot(x, y_pred, color='r', label='Linear Regression')
plt.plot(x_poly, poly_pred, color='g', label='Polynomial Regression')
plt.xlabel('Predictor', fontsize=16)
plt.ylabel('Target', fontsize=16)
plt.legend()
plt.show()

print('RMSE for Polynomial Regression=>',
      np.sqrt(mean_squared_error(y, poly_pred)))
