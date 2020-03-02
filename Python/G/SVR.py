# To add a new cell, type '# %%'
# To add a new markdown cell, type '# %% [markdown]'
# %% [markdown]
# # 毕业设计

# %%
import os

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import plotly.figure_factory as ff
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
from sklearn.metrics import mean_squared_error
from sklearn.model_selection import GridSearchCV, train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.svm import SVR

# %% [markdown]
# ## 获取数据

# %%
path = '../../../Dataset/Stock/'
freq_dict = {
    'day': 'B',
    'week': '7D',
    'month': 'BM'
}
offset_dict = {
    'day': pd.offsets.BDay(),
    'week': pd.offsets.Week(),
    'month': pd.offsets.BusinessMonthEnd()
}


def get_data(frequency: str, T: int):
    data_path = os.path.join(path, frequency)
    data_1 = data_2 = pd.read_csv('Data/test.csv')  # 空文件，迭代用
    freq = freq_dict[frequency]
    offset = offset_dict[frequency]

    for file in os.listdir(data_path):
        df = pd.read_csv(os.path.join(data_path, file),
                         index_col='index', parse_dates=True)  # 以时间序列为索引
        df.dropna(inplace=True)  # 去除空值

        up = df.query('open<close')  # 阳线
        down = df.query('open>close')  # 阴线
        up = up.tshift(1, freq=freq)  # 将阳线时间戳后移

        new = up.join(down, how='inner', lsuffix='_up', rsuffix='_down')  # 合并
        new.query('vol_down>vol_up', inplace=True)  # vol(2)>vol(1)

        first = new.query('close_down>close_up')  # close(2)>close(1)
        first_low_mean = pd.Series(index=first.index, name='T_mean')
        for start in first.index:
            period_1 = pd.date_range(
                start=start + offset, periods=T, freq=freq)
            # 时间范围可能无效
            try:
                first_low_mean[start] = df.loc[period_1].low.mean()
            except:
                first.drop(index=start, inplace=True)  # 清除无效行
                continue
        first_low_mean = pd.Series(
            first_low_mean, index=first.index, name='T_mean')
        piece_1 = pd.concat([first, first_low_mean], axis=1,
                            join='inner').reset_index(drop=True)  # 去除时间索引
        data_1 = pd.concat([data_1, piece_1])

        # close(2)>close(1) & low(2)<low(1)
        second = new.query('close_down>close_up & low_down<low_up')
        second_low_mean = pd.Series(index=second.index, name='T_mean')
        for start in second.index:
            period_2 = pd.date_range(
                start=start + offset, periods=T, freq=freq)
            try:
                second_low_mean[start] = df.loc[period_2].low.mean()
            except:
                second.drop(index=start, inplace=True)  # 清除无效行
                continue
        second_low_mean = pd.Series(
            second_low_mean, index=second.index, name='T_mean')
        piece_2 = pd.concat([second, second_low_mean], axis=1,
                            join='inner').reset_index(drop=True)  # 去除时间索引
        data_2 = pd.concat([data_2, piece_2])

    data_1.to_csv(os.path.join('Data', 'T='+str(T),
                               frequency+'_1.csv'), index=False)
    data_2.to_csv(os.path.join('Data', 'T='+str(T),
                               frequency+'_2.csv'), index=False)


# %%
for T in np.arange(3, 16):
    for frequency in ['day', 'week']:  # month数据量太少，无意义
        get_data(frequency, T)

# %% [markdown]
# ## 构建模型

# %%
path = 'Data/'
T = 15

# %%
def del_outliers(df: pd.DataFrame):
    return df[~ ((df['T_mean'] - df['T_mean'].mean()).abs() > (3 * df['T_mean'].std()))]

# %% [markdown]
# ### Day

# %%
day_2 = pd.read_csv(os.path.join(path, 'T='+str(T), 'day_2.csv')
                    )
day_2 = del_outliers(day_2)
day_2.describe()

# %%
X = day_2.drop('T_mean', axis=1)
y = day_2['T_mean']

# %%
std_scaler = StandardScaler()
X = std_scaler.fit_transform(X)

# %%
X_train, y_train, X_test, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42)

# %%
param_grid = [
    {
        'kernel': ['rbf'],
        'gamma': np.logspace(-6, 3, 10),
        'C': np.logspace(-2, 7, 10)
    },
    {
        'kernel': ['poly'],
        'degree': [3, 4, 5, 6],
        'gamma': np.logspace(-6, 3, 10),
        'C': np.logspace(-2, 7, 10)
    }
]
grid = GridSearchCV(SVR(), param_grid=param_grid,
                    scoring='neg_mean_squared_error', n_jobs=-1, refit=True, cv=5)
grid.fit(X_train, y_train)

# %%
grid.best_params_, grid.best_score_


# %%
