# 2024/02/20
# phoenix
# APPLY GARCH TO CACULATE THE TIME-VARIED CORRELATION BETWEEN TIME SEIRIES


library(tidyverse)
getwd()
da <- read_csv("time_corr.csv")
rtn.var1 <- ts(da[["var1"]],start=c(1976,2),frequency = 12)
rtn.var2 <- ts(da[["var2"]],start=c(1976,2),frequency = 12)
plot(
  rtn.var1,
  main="rtn of var1",
  major.ticks="years",minor.ticks=NULL,
  grid.ticks.on="years",
  col="red"
)
plot(
  rtn.var2,
  main="rtn of var2",
  major.ticks="years",minor.ticks=NULL,
  grid.ticks.on="years",
  col="red"
)
# Adapt LB test to determine ARCH effect
Box.test((rtn.var1 - mean(rtn.var1))^2, 
         lag=12, type="Ljung")
acf(rtn.var1,lag.max=30,main="")
acf(rtn.var2,lag.max=30,main="")
library(fGarch)
sigvar1 <- garchFit(~1+garch(1,1),data=rtn.var1,trace=FALSE)
summary(sigvar1)
#                         Statistic      p-Value
# Jarque-Bera Test   R    Chi^2   0.4532202 7.972316e-01
# Shapiro-Wilk Test  R    W       0.9977009 6.227317e-01
# Ljung-Box Test     R    Q(10)  66.2659942 2.319153e-10
# Ljung-Box Test     R    Q(15)  67.8535618 1.074249e-08
# Ljung-Box Test     R    Q(20)  71.5842871 1.001903e-07
# Ljung-Box Test     R^2  Q(10)   2.4397040 9.917255e-01
# Ljung-Box Test     R^2  Q(15)   8.1601109 9.172032e-01
# Ljung-Box Test     R^2  Q(20)  13.6470518 8.479309e-01
# LM Arch Test       R    TR^2    4.5573489 9.711568e-01
# JB and SW test is used to test whether the residual obeys a normal distribution
# If the p-value is small, then the residual may not ~N
# LM Arch Test is used to detect ARCH effect in residual
# Big p-value means posibility of ARCH effect
plot(sigvar1, which=13)
sigvar2 <- garchFit(~1+garch(1,1),data=rtn.var2,trace=FALSE)
summary(sigvar2)
# Now calculate the time-varied covariance
plus <- garchFit(~1+garch(1,1),data=rtn.var1+rtn.var2,trace=FALSE)
minus <- garchFit(~1+garch(1,1),data=rtn.var1-rtn.var2,trace=FALSE)
cov <- 1/4*(volatility(plus)^2 - volatility(minus)^2)
rho <- cov / volatility(sigvar1) / volatility(sigvar2)
rho <- ts(rho,start=c(1976,2),frequency = 12)
plot(rho,type="l",xlab="year",ylab="correlation",col="red")
correlation <- cor(da["var1"],da["var2"])
abline(h=correlation,lty=4,col="blue")
abline(h=0,lty=4,col="black")
write.csv(x=rho,file="rho.csv")
