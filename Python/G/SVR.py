# To add a new cell, type '# %%'
# To add a new markdown cell, type '# %% [markdown]'
# %% [markdown]
# # 毕业设计

import os

# %%
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import plotly.figure_factory as ff
import plotly.graph_objects as go
from plotly.subplots import make_subplots
from sklearn.metrics import accuracy_score
from sklearn.model_selection import GridSearchCV, train_test_split
from sklearn.pipeline import Pipeline, make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.svm import SVR

# %%
T = 11
path = '../../../Dataset/Stock/'

# %% [markdown]
# ## 获取数据
# %% [markdown]
# ### Day

# %%
day_path = os.path.join(path, 'day')
day_1 = day_2 = pd.read_csv('Data/test.csv')  # 空文件，迭代用
freq = 'B'  # 工作日


# %%
for file in os.listdir(day_path):
    file_path = os.path.join(day_path, file)
    df = pd.read_csv(file_path, index_col='index',
                     parse_dates=True)  # 读取数据，时间序列索引
    df.dropna(inplace=True)  # 去掉空值

    up = df.query('open<close')  # 阳线
    down = df.query('open>close')  # 阴线
    up = up.tshift(1, freq=freq)  # 将阳线时间戳后移1工作日

    new = up.join(down, how='inner', lsuffix='_up', rsuffix='_down')  # 合并
    new.query('vol_down>vol_up', inplace=True)  # vol(2)>vol(1)

    first = new.query('close_down>close_up')  # close(2)>close(1)
    first_low_mean = []
    # 计算未来T交易日的最低价平均值
    for start in first.index:
        T_1_period = pd.date_range(
            start=start + pd.offsets.BDay(), periods=T, freq=freq)
        # 时间范围可能无效
        try:
            first_low_mean.append(df.loc[T_1_period].low.mean())
        except:
            first.drop(index=start, inplace=True)  # 清除无效行
            continue
    first_low_mean = pd.Series(
        first_low_mean, index=first.index, name='T_mean')
    piece_1 = pd.concat([first, first_low_mean], axis=1,
                        join='inner').reset_index(drop=True)  # 去除时间索引
    day_1 = pd.concat([day_1, piece_1])

    # close(2)>close(1) & low(2)<low(1)
    second = new.query('close_down>close_up & low_down<low_up')
    second_low_mean = []
    # 计算未来T交易日的最低价平均值
    for start in second.index:
        T_2_period = pd.date_range(
            start=start + pd.offsets.BDay(), periods=T, freq=freq)
        try:
            second_low_mean.append(df.loc[T_2_period].low.mean())
        except:
            second.drop(index=start, inplace=True)  # 清除无效行
            continue
    second_low_mean = pd.Series(
        second_low_mean, index=second.index, name='T_mean')
    piece_2 = pd.concat([second, second_low_mean], axis=1,
                        join='inner').reset_index(drop=True)  # 去除时间索引
    day_2 = pd.concat([day_2, piece_2])


# %%
day_1.to_csv(os.path.join('Data', 'T='+str(T), 'day_1.csv'))
day_2.to_csv(os.path.join('Data', 'T='+str(T), 'day_2.csv'))

# %% [markdown]
# ### Week

# %%
week_path = os.path.join(path, 'week')
week_1 = week_2 = pd.read_csv('Data/test.csv')  # 空文件，迭代用
freq = '7D'  # 周


# %%
for file in os.listdir(week_path):
    file_path = os.path.join(week_path, file)
    df = pd.read_csv(file_path, index_col='index',
                     parse_dates=True)  # 读取数据，时间序列索引
    df.dropna(inplace=True)  # 去掉空值

    up = df.query('open<close')  # 阳线
    down = df.query('open>close')  # 阴线
    up = up.tshift(1, freq=freq)  # 将阳线时间戳后移1周

    new = up.join(down, how='inner', lsuffix='_up', rsuffix='_down')  # 合并
    new.query('vol_down>vol_up', inplace=True)  # vol(2)>vol(1)

    first = new.query('close_down>close_up')  # close(2)>close(1)
    first_low_mean = []
    # 计算未来T周的最低价平均值
    for start in first.index:
        T_1_period = pd.date_range(
            start=start + pd.offsets.Week(), periods=T, freq=freq)
        # 时间范围可能无效
        try:
            first_low_mean.append(df.loc[T_1_period].low.mean())
        except:
            first.drop(index=start, inplace=True)  # 清除无效行
            continue
    first_low_mean = pd.Series(
        first_low_mean, index=first.index, name='T_mean')
    piece_1 = pd.concat([first, first_low_mean], axis=1,
                        join='inner').reset_index(drop=True)  # 去除时间索引
    week_1 = pd.concat([week_1, piece_1])

    # close(2)>close(1) & low(2)<low(1)
    second = new.query('close_down>close_up & low_down<low_up')
    second_low_mean = []
    # 计算未来T周的最低价平均值
    for start in second.index:
        T_2_period = pd.date_range(
            start=start + pd.offsets.Week(), periods=T, freq=freq)
        try:
            second_low_mean.append(df.loc[T_2_period].low.mean())
        except:
            second.drop(index=start, inplace=True)  # 清除无效行
            continue
    second_low_mean = pd.Series(
        second_low_mean, index=second.index, name='T_mean')
    piece_2 = pd.concat([second, second_low_mean], axis=1,
                        join='inner').reset_index(drop=True)  # 去除时间索引
    week_2 = pd.concat([week_2, piece_2])


# %%
week_1.to_csv(os.path.join('Data', 'T='+str(T), 'week_1.csv'))
week_2.to_csv(os.path.join('Data', 'T='+str(T), 'week_2.csv'))

''' 
T>3后Month数据量太少，无意义
# %% [markdown]
# ### Month

# %%
month_path = os.path.join(path, 'month')
month_1 = month_2 = pd.read_csv('Data/test.csv')  # 空文件，迭代用
freq = 'BM'  # 工作日月末


# %%
for file in os.listdir(month_path):
    file_path = os.path.join(month_path, file)
    df = pd.read_csv(file_path, index_col='index',
                     parse_dates=True)  # 读取数据，时间序列索引
    df.dropna(inplace=True)  # 去掉空值

    up = df.query('open<close')  # 阳线
    down = df.query('open>close')  # 阴线
    up = up.tshift(1, freq=freq)  # 将阳线时间戳后移1月

    new = up.join(down, how='inner', lsuffix='_up', rsuffix='_down')  # 合并
    new.query('vol_down>vol_up', inplace=True)  # vol(2)>vol(1)

    first = new.query('close_down>close_up')  # close(2)>close(1)
    first_low_mean = []
    # 计算未来T月的最低价平均值
    for start in first.index:
        T_1_period = pd.date_range(
            start=start + pd.offsets.BusinessMonthEnd(), periods=T, freq=freq)
        # 时间范围可能无效
        try:
            first_low_mean.append(df.loc[T_1_period].low.mean())
        except:
            first.drop(index=start, inplace=True)  # 清除无效行
            continue
    first_low_mean = pd.Series(
        first_low_mean, index=first.index, name='T_mean')
    piece_1 = pd.concat([first, first_low_mean], axis=1,
                        join='inner').reset_index(drop=True)  # 去除时间索引
    month_1 = pd.concat([month_1, piece_1])

    # close(2)>close(1) & low(2)<low(1)
    second = new.query('close_down>close_up & low_down<low_up')
    second_low_mean = []
    # 计算未来T月的最低价平均值
    for start in second.index:
        T_2_period = pd.date_range(
            start=start + pd.offsets.BusinessMonthEnd(), periods=T, freq=freq)
        try:
            second_low_mean.append(df.loc[T_2_period].low.mean())
        except:
            second.drop(index=start, inplace=True)  # 清除无效行
            continue
    second_low_mean = pd.Series(
        second_low_mean, index=second.index, name='T_mean')
    piece_2 = pd.concat([second, second_low_mean], axis=1,
                        join='inner').reset_index(drop=True)  # 去除时间索引
    month_2 = pd.concat([month_2, piece_2])


# %%
month_1.to_csv(os.path.join('Data', 'T='+str(T), 'month_1.csv'))
month_2.to_csv(os.path.join('Data', 'T='+str(T), 'month_2.csv'))
'''
# %% [markdown]
# ## 构建模型

# %%
