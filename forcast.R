library(FredR)
library(tidyverse)
library(forecast)
library(fGarch)
api.key = "9021f5de1f8c0b71b551541812525967"
fred <- FredR(api.key)
gdp <- fred$series.observations(series_id = 'GDPC1')
ts.gdp <- ts(as.numeric(gdp[["value"]]),start = c(1947,1),frequency = 4)
gdp[["value"]] <- as.numeric(gdp[["value"]])
plot(
  ts.gdp,
  main="US GDP",
  major.ticks="years",minor.ticks=NULL,
  grid.ticks.on="years",
  col="red"
)
ts.dgdp <- diff(gdp[["value"]])/lag(gdp[["value"]])
ts.dgdp <- ts(na.omit(ts.dgdp),start = c(1947,4),frequency = 4)
plot(
  ts.dgdp,
  main="US GDP ",
  major.ticks="years",minor.ticks=NULL,
  grid.ticks.on="years",
  col="red"
)
gdp_hw <- HoltWinters(
  ts.gdp,
  seasonal = "multiplicative")
plot(gdp_hw)
plot(gdp_hw$fitted, main="分解成分滤波结果")
acf(ts.dgdp,main='')
pacf(ts.dgdp,main="")
Box.test((ts.dgdp - mean(ts.dgdp))^2, 
         lag=12, type="Ljung")
sigvar1 <- garchFit(~1+garch(1,1),data=rtn.var1,trace=FALSE)
summary(sigvar1)
mod.gdp <- arima(
  ts.dgdp, order=c(1,0,0),
  seasonal=list(order=c(2,0,0), period=8)
)
mod.gdp

mod.gdp <- arima(
  ts.dgdp, order=c(2,0,3),
  seasonal=list(order=c(4,0,0), period=8),
  include.mean = FALSE
)
mod.gdp
tsdiag(mod.gdp)
mod.gdp <- arima(
  ts.gdp, order=c(2,1,3),
  seasonal=list(order=c(4,0,0), period=8),
  include.mean = FALSE
)
aa <- forecast(mod.gdp,h=2)
aa
plot(aa)
mod.dgdp <- arima(
  ts.dgdp, order=c(2,0,3),
  seasonal=list(order=c(4,0,0), period=8),
  include.mean = FALSE
)
aa <- forecast(mod.dgdp,h=200)
aa
plot(aa)
gdp.mod2 <- garchFit(
  ~ arma(2,3) + garch(1,1),
  data=ts.dgdp,
  include.mean=FALSE, trace=FALSE
)
aa <- forecast(gdp.mod2,h=200)
