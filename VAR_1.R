# 多变量时间序列预测，VAR模型，美国宏观变量简单VAR模型
library(FredR)
library(tidyverse)
api.key = "9021f5de1f8c0b71b551541812525967"
fred <- FredR(api.key)
# 导入数据
IR <- fred$series.observations(series_id = 'REAINTRATREARAT10Y')
IR[["value"]] <- as.numeric(IR[["value"]])
ts.ir <- ts(IR[["value"]],start = c(1982,1),frequency = 12)

NonA <- fred$series.observations(series_id = 'LNS12032192')
NonA[["value"]] <- as.numeric(NonA[["value"]])
ts.nona <- ts(NonA[["value"]],start = c(1948,1),frequency = 12)

FX <- fred$series.observations(series_id = 'EXJPUS')
FX[["value"]] <- as.numeric(FX[["value"]])
ts.fx <- ts(FX[["value"]],start = c(1971,1),frequency = 12)

CPI <- fred$series.observations(series_id = 'CORESTICKM159SFRBATL')
CPI[["value"]] <- as.numeric(CPI[["value"]])
ts.cpi <- ts(CPI[["value"]],start = c(1967,12),frequency = 12)

M2 <- read_csv("M2.csv")
ts.m2 <- ts(M2[["Value"]],start=c(1959,1),frequency = 12)
PMI <- read_csv("PMI.csv")
ts.pmi <- ts(PMI[["Value"]],start=c(1948,1),frequency = 12)

# 以交集的方式合并数据
ts.macro <- ts.intersect(ts.cpi, ts.nona,ts.fx,ts.ir,ts.m2,ts.pmi)
ts.macrod <- diff(log(1+ts.macro))*100
library(xts)
plot(as.xts(ts.macrod), type="l", 
     multi.panel=TRUE, theme="white",
     main="英国、加拿大、美国GDP的季度增长率(%)",
     major.ticks="years",
     grid.ticks.on = "years")
Z <- coredata(as.xts(ts.macro))

# 格兰杰因果检验
library(MTS, quietly = TRUE)
GrangerTest(Z, p=2, locInput=4)
GrangerTest(Z, p=2, locInput=3)
GrangerTest(Z, p=2, locInput=2)
GrangerTest(Z, p=2, locInput=1)
# 显示其他是cpi和fx的格兰杰原因
# 选阶数
VARorder(Z)
m1.macro <- VAR(Z, 13)
resi <- m1.macro$residuals
mq(resi, adj=3^2 * 2)
m2.macro <- refVAR(m1.macro, thres=1.96)
a <- VARpred(m2.macro, 8)


# 使用vars做VAR和预测图像
library(vars)
# 估计VAR模型，根据AIC自动选阶数
var2 <- vars::VAR(Z, ic="AIC", lag.max=15)
summary(var2)

# 进行预测，n.ahead是预测的步数
predictions <- predict(var2, n.ahead = 20)

# 绘制预测图像
plot(predictions)
# 协整检验
# Johansen协整检验
# 可以看trace的Values of teststatistic and critical values of test
# 从下往上依次看test是不是超过来确定协整数量
# 特征值方法的结论则有所不同
library(urca)
summary(ca.jo(Z, type="trace", K=2, season=12))




