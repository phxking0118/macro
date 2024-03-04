# 以GDP为例可以进行的若干种单变量操作

library(FredR)
library(tidyverse)
library(forecast)
library(fGarch)
api.key = "9021f5de1f8c0b71b551541812525967"
fred <- FredR(api.key)
# 从fred获取中国GDP年度数据
gdp <- fred$series.observations(series_id = 'MKTGDPCNA646NWDB')
ts.gdp <- ts(as.numeric(gdp[["value"]]),start = c(1960,1),frequency = 1)
gdp[["value"]] <- as.numeric(gdp[["value"]])
plot(
  ts.gdp,
  main="ChN GDP",
  major.ticks="years",minor.ticks=NULL,
  grid.ticks.on="years",
  col="red"
)
# 计算GDP同比增长率
ts.dgdp <- diff(gdp[["value"]])/lag(gdp[["value"]])
ts.dgdp <- ts(na.omit(ts.dgdp),start = c(1961,1),frequency = 1)
# 一、通过局部水平模型计算增长率滤波
# 1.使用StructTS
sts.al <- StructTS(ts.dgdp, type="level")
sts.al
plot(ts.dgdp,
     main="Alcoa smoothed with StructTS")
lines(tsSmooth(sts.al), col="green")
legend("topleft", lty=c(1,1), 
       col=c("black", "green"),
       legend=c("Obs", "Smoothed"))
# 2.使用statespacer
library(statespacer)
ssr1 <- statespacer(
  y = cbind(as.vector(ts.dgdp)),
  local_level_ind = TRUE,
  initial = rep(0.5*(var(ts.dgdp)), 2),
  verbose = TRUE)
plot(ts.dgdp, ylim=c(-0.2,0.4))
# （1）filtered表现卡尔曼滤波
lines(as.vector(time(ts.dgdp)), 
      ssr1$filtered$level, col="green")
# （2）predicted是一步预测
lines(as.vector(time(ts.dgdp)), 
      ssr1$predicted$yfit, col="red")
legend("topleft", lty=1, col=c("black", "green", "red"),
       legend=c("Obs", "Filtered", "Predicted 1 step"))
# （3）误差
plot(as.vector(time(ts.dgdp)), 
     ssr1$predicted$v, 
     type="l", ylim=c(-0.2, 0.4),
     xlab="", ylab="error")
# （4）95%预测范围
plot(ts.dgdp, ylim=c(-0.2, 0.4))
lines(as.vector(time(ts.dgdp)), 
      ssr1$filtered$level, col="red")
lines(as.vector(time(ts.dgdp)), 
      ssr1$filtered$level + 1.96*sqrt(ssr1$filtered$P[1,1,]), 
      col="green", lty=3)
lines(as.vector(time(ts.dgdp)), 
      ssr1$filtered$level - 1.96*sqrt(ssr1$filtered$P[1,1,]), 
      col="green", lty=3)
legend("topleft", lty=c(1,1,3), col=c("black", "red", "green"),
       legend=c("Obs", "Filtered", "95% CI of level"))
# （5）状态平滑
plot(ts.dgdp, ylim=c(-0.2,0.4))
lines(as.vector(time(ts.dgdp)), 
      ssr1$smoothed$level, col="red")
lines(as.vector(time(ts.dgdp)), 
      ssr1$smoothed$level + 1.96*sqrt(ssr1$smoothed$V[1,1,]), 
      col="green", lty=3)
lines(as.vector(time(ts.dgdp)), 
      ssr1$smoothed$level - 1.96*sqrt(ssr1$smoothed$V[1,1,]), 
      col="green", lty=3)
legend("topleft", lty=c(1,1,3), col=c("black", "red", "green"),
       legend=c("Obs", "Smoothed", "95% CI of level"))

# 二、分解趋势(季度数据)
gdp <- fred$series.observations(series_id = 'CHNGDPNQDSMEI')
gdp[["value"]] <- as.numeric(gdp[["value"]])
ts.gdp <- ts(gdp[["value"]],start = c(1992,1),frequency = 4)
gdp_hw <- HoltWinters(
  ts.gdp,
  seasonal = "multiplicative")
plot(gdp_hw)
plot(gdp_hw$fitted, main="分解成分滤波结果")
ts.dgdp <- diff(gdp[["value"]])/lag(gdp[["value"]])
ts.dgdp <- ts(na.omit(ts.dgdp),start = c(1992,4),frequency = 4)
# 一、预测模型搭建
# 1.预测模型的提前准备acf，pacf，arch效应
acf(ts.dgdp,main='')
pacf(ts.dgdp,main="")
Box.test((ts.dgdp - mean(ts.dgdp))^2, 
         lag=12, type="Ljung")
# 2.建模以及预测
mod.gdp <- arima(
  ts.dgdp, order=c(5,0,0),
  seasonal=list(order=c(0,0,8), period=4)
)
mod.gdp
tsdiag(mod.gdp)
future_gdp <- forecast(mod.gdp,h=20)
future_gdp
plot(future_gdp)


