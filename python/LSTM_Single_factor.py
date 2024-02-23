import numpy as np
import pandas as pd
from sklearn.preprocessing import MinMaxScaler
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense
from tensorflow.keras.callbacks import EarlyStopping
import matplotlib.pyplot as plt



# 用Pandas读取CSV文件
df = pd.read_csv('data/asset.csv')  # 替换为你的文件名
# 假设时间序列数据在第一列，可以根据需要调整
time_series_data = df[df.columns[2]].values
time_series_data = time_series_data.reshape(-1, 1)
# 归一化特征
scaler = MinMaxScaler(feature_range=(0, 1))
time_series_scaled = scaler.fit_transform(time_series_data)

# 准备时间序列数据集
def create_dataset(data, time_step=1):
    X, Y = [], []
    for i in range(len(data) - time_step - 1):
        a = data[i:(i + time_step), 0]
        X.append(a)
        Y.append(data[i + time_step, 0])
    return np.array(X), np.array(Y)

time_step = 10  # 使用5个时间步
X, Y = create_dataset(time_series_scaled, time_step)
X = X.reshape(X.shape[0], X.shape[1], 1)  # 为了LSTM，需要[样本数, 时间步, 特征数]
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
model.fit(X, Y, epochs=100, validation_split=0.2, batch_size=64, callbacks=[early_stopping], verbose=1)
# 使用模型进行预测
predictions = model.predict(X)

# 反归一化预测
predictions = scaler.inverse_transform(predictions)
# 假设 `Y_test` 是测试数据集的真实值
# 因为我们已经有了 `predictions`，我们可以直接使用它
# 首先，我们需要反归一化测试集的真实值（如果之前进行了归一化的话）
Y_test_scaled = scaler.inverse_transform(Y.reshape(-1, 1))

# 绘制真实值和预测值
plt.figure(figsize=(10,6))
plt.plot(Y_test_scaled, label='Actual Value')
plt.plot(predictions, label='Predicted Value')
plt.title('Time Series Prediction')
plt.xlabel('Time')
plt.ylabel('Value')
plt.legend()
plt.show()

# 你可以在这里添加更多的代码来评估模型性能，比如计算预测和真实值之间的误差
# 假设 `model.fit()` 的输出被赋值给了 `history` 变量
history = model.fit(X, Y, epochs=100, validation_split=0.2, batch_size=64, callbacks=[early_stopping], verbose=1)

# 绘制训练损失和验证损失
plt.plot(history.history['loss'], label='Training Loss')
plt.plot(history.history['val_loss'], label='Validation Loss')
plt.title('Model Loss')
plt.ylabel('Loss')
plt.xlabel('Epoch')
plt.legend()
plt.show()
