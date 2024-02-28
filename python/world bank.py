import requests
import zipfile
import os
import pandas as pd
import sqlite3
import time
from pandas.errors import EmptyDataError
def download_and_unzip(code, extract_to='.'):
    """
    下载ZIP文件并解压到指定目录。

    参数:
    - url: ZIP文件的下载链接。
    - extract_to: 解压目录路径。默认为当前目录。
    """
    url = "https://api.worldbank.org/v2/en/country/" + code + "?downloadformat=csv"
    # 获取文件名
    filename = url.split('/')[-1]

    # 下载文件
    print(f"Downloading {filename}...")
    response = requests.get(url)
    with open(filename, 'wb') as file:
        file.write(response.content)
    print(f"Downloaded {filename}.")

    # 解压文件
    print(f"Extracting {filename}...")
    with zipfile.ZipFile(filename, 'r') as zip_ref:
        zip_ref.extractall(extract_to)
    print(f"Extracted {filename} to {extract_to}.")

    # 清理下载的ZIP文件
    os.remove(filename)
    print(f"Removed {filename}.")

def clearDownload(code):
    download_and_unzip(code, 'download/')
    directory = 'download/'  # 替换为你的目录路径
    # 遍历目录中的所有文件
    for filename in os.listdir(directory):
        # 检查文件名是否以"API"开头
        if filename.endswith(".csv") and not filename.startswith("API"):
            # 构建完整的文件路径
            file_path = os.path.join(directory, filename)
            # 删除文件
            os.remove(file_path)
            print(f"Deleted '{filename}'")
        if filename.startswith("API") and filename.endswith(".csv"):
            # 构建完整的文件路径
            old_file = os.path.join(directory, filename)
            # 定义新文件名
            new_file = os.path.join(directory, code+".csv")
            # 重命名文件
            os.rename(old_file, new_file)
            filename = code + ".csv"
            print(f"Renamed '{filename}' to filename")


# 使用示例
#clearDownload("JPN")
def into_SQL(code):
    clearDownload(code)
    try:
        df = pd.read_csv("download/"+code+".csv",skiprows=4)
        conn = sqlite3.connect('macro.db')
        # 将数据写入新表（如果表已存在则替换）
        df.to_sql(code, conn, if_exists='replace', index=False)
        conn.close()
        print("Have writen to Database.")
    except EmptyDataError:
        # 如果文件为空或无法读取，则跳过
        print(f"No data, skipping...")
# into_SQL("JPN")


df = pd.read_csv("countryName.csv")
countryList = list(df["code"])
for code in countryList:
    start = time.time()
    into_SQL(code)
    end = time.time()
    print(end-start)

#download_and_unzip("JPN", 'output/')  # 替换为解压目录路径
