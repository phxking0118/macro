import yfinance as yf
import pandas as pd

def rm_timeZone(df):
    aa = df.to_csv("aa.csv",index=False)
    df1 = pd.read_csv("aa.csv")
    #df1["Date"] = df1["Date"].dt.tz_localize(None)
    return df1
def getInfo(code):
    stock = yf.Ticker(code)
    trade = stock.history(period="max")
    trade = rm_timeZone(trade)
    cash = stock.cashflow
    income = stock.income_stmt
    balance = stock.balance_sheet
    fileName = "yahoo/" +code+".xlsx"
    with pd.ExcelWriter(fileName, engine='openpyxl') as writer:
        trade.to_excel(writer, sheet_name='Trading History')
        cash.to_excel(writer, sheet_name='Cashflow')
        income.to_excel(writer, sheet_name='Income')
        balance.to_excel(writer, sheet_name='Balance Sheet')
    print(code+" has been downloaded")

firms = ["AAPL","MSFT","AMZN","NVDA","META","TSLA","GOOGL"]
for firm in firms:
    getInfo(firm)

