import pandas as pd
from sklearn.preprocessing import MinMaxScaler
import numpy as np
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense,Dropout
from tensorflow.keras.callbacks import EarlyStopping
import matplotlib.pyplot as plt
scaler = MinMaxScaler(feature_range=(0, 1))
# 用Pandas读取CSV文件
df = pd.read_csv("data/asset.csv")  # 替换为你的文件名

# 选择前5个变量作为X，第6个变量作为Y
X_data = df.iloc[:, 1:6].values
Y_data = df.iloc[:, 6].values.reshape(-1, 1)  # 确保Y是正确的形状
# 归一化特征
scaler_X = MinMaxScaler(feature_range=(0, 1))
X_scaled = scaler_X.fit_transform(X_data)

scaler_Y = MinMaxScaler(feature_range=(0, 1))
Y_scaled = scaler_Y.fit_transform(Y_data)

# 准备时间序列数据集
def create_dataset(X, Y, time_step=1):
    Xs, Ys = [], []
    for i in range(len(X) - time_step):
        v = X[i:(i + time_step)]
        Xs.append(v)
        Ys.append(Y[i + time_step])
    return np.array(Xs), np.array(Ys)

time_step = 10
X, Y = create_dataset(X_scaled, Y_scaled, time_step)
# 定义模型
model = Sequential([
    LSTM(500, return_sequences=True, input_shape=(time_step, X.shape[2])),
    LSTM(500, return_sequences=True),
    LSTM(500),
    Dense(500, activation='relu'),  # 添加一个全连接层
    Dense(1)  # 输出层
])

model.compile(optimizer='adam', loss='mean_squared_error')

# 模型训练
early_stopping = EarlyStopping(monitor='val_loss', patience=10, mode='min')
history = model.fit(X, Y, epochs=100, validation_split=0.2, batch_size=64, callbacks=[early_stopping], verbose=1)
# 使用模型进行预测
predictions = model.predict(X)

# 反归一化预测
predictions = scaler_Y.inverse_transform(predictions)
Y_actual = scaler_Y.inverse_transform(Y)
plt.figure(figsize=(10,6))
plt.plot(Y_actual, label='Actual Value')
plt.plot(predictions, label='Predicted Value', alpha=0.7)
plt.title('Actual vs Predicted Values')
plt.xlabel('Time Step')
plt.ylabel('Value')
plt.legend()
plt.show()
