import pandas as pd
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.metrics import r2_score, mean_absolute_error, mean_squared_error

# load data
df = pd.read_csv("auto-mpg.csv")
print(df.head())

# horsepower has ? values, replace them with median
df["horsepower"] = pd.to_numeric(df["horsepower"], errors="coerce")
df["horsepower"] = df["horsepower"].fillna(df["horsepower"].median())

# features and target
X = df.drop(["mpg", "car_name"], axis=1)
y = df["mpg"]

# train test split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# model
model = LinearRegression()
model.fit(X_train, y_train)

# coefficients
for name, c in zip(X.columns, model.coef_):
    print(name, ":", c)

# evaluation
y_pred = model.predict(X_test)
mse = mean_squared_error(y_test, y_pred)
print("R2 score:", r2_score(y_test, y_pred))
print("MAE:", mean_absolute_error(y_test, y_pred))
print("MSE:", mse)
print("RMSE:", mse ** 0.5)

# actual vs predicted plot
plt.scatter(y_test, y_pred)
plt.plot([10, 45], [10, 45], color="red")
plt.xlabel("Actual MPG")
plt.ylabel("Predicted MPG")
plt.title("Actual vs Predicted")
plt.show()