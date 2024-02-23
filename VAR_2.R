# 考察美国股票市场，美元，债券市场，黄金，石油资产的VAR模型
library(tidyverse)
da <- read_csv("asset.csv")
ts.asset <- ts(as.matrix(da[,c("stock", "dollar", "cpi","r","gold","oil")]), 
              start=c(1990,2), frequency=12)
library(xts)
plot(as.xts(ts.asset), type="l", 
     multi.panel=TRUE, theme="white",
     main="资产数据",
     major.ticks="years",
     grid.ticks.on = "years")
Z <- coredata(as.xts(ts.asset))
# 格兰杰因果检验
library(MTS, quietly = TRUE)
GrangerTest(Z, p=2, locInput=6)
GrangerTest(Z, p=2, locInput=5)
GrangerTest(Z, p=2, locInput=4)
GrangerTest(Z, p=2, locInput=3)
GrangerTest(Z, p=2, locInput=2)
GrangerTest(Z, p=2, locInput=1)
# 使用vars做VAR和预测图像
library(vars)
# 估计VAR模型，根据AIC自动选阶数
var2 <- vars::VAR(Z, 10)
summary(var2)

# 进行预测，n.ahead是预测的步数
predictions <- predict(var2, n.ahead = 5)
predictions
# 绘制预测图像
plot(predictions)
