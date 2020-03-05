# To add a new cell, type '# %%'
# To add a new markdown cell, type '# %% [markdown]'
# %% [markdown]
# # 毕业设计

# %%
import os

import numpy as np
import pandas as pd
import plotly.express as px
import plotly.figure_factory as ff
import plotly.graph_objects as go
from plotly.subplots import make_subplots
from sklearn.metrics import mean_squared_error
from sklearn.model_selection import (GridSearchCV, KFold,
                                     train_test_split)
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


def get_data(frequency: str, T: str) -> None:
    data_path = os.path.join(path, frequency)
    data_1 = pd.read_csv('Data/test.csv')  # 空文件，迭代用
    freq = freq_dict[frequency]
    offset = offset_dict[frequency]

    for file in os.listdir(data_path):
        df = pd.read_csv(os.path.join(data_path, file), index_col='index', parse_dates=True)  # 以时间序列为索引
        df.dropna(inplace=True)  # 去除空值

        up = df.query('open<close')  # 阳线
        down = df.query('open>close')  # 阴线
        up = up.tshift(1, freq=freq)  # 将阳线时间戳后移

        new = up.join(down, how='inner', lsuffix='_up', rsuffix='_down')  # 合并
        new.query('vol_down>vol_up', inplace=True)  # vol(2)>vol(1)

        # close(2)>close(1)
        first = new.query('close_down>close_up')
        low_mean = pd.Series(index=first.index, name='T_mean')
        for start in first.index:
            period = pd.date_range(start=start + offset, periods=int(T), freq=freq)
            # 时间范围可能无效
            try:
                low_mean[start] = df.loc[period].low.mean()
            except:
                first.drop(index=start, inplace=True)  # 清除无效行
                continue
        low_mean = pd.Series(low_mean, index=first.index, name='T_mean')
        piece = pd.concat([first, low_mean], axis=1, join='inner').reset_index(drop=True)  # 去除时间索引
        data_1 = pd.concat([data_1, piece])

    # close(2)>close(1) & low(2)<low(1)
    data_2 = data_1.query('low_down<low_up')

    data_1.to_csv(os.path.join('Data', 'T=' + T, frequency + '_1.csv'), index=False)
    data_2.to_csv(os.path.join('Data', 'T=' + T, frequency + '_2.csv'), index=False)


# %%
for T in np.arange(2, 16).astype(np.str):
    for frequency in ['day', 'week']:  # month数据量太少，无意义
        get_data(frequency, T)

# %% [markdown]
# ## 构建模型

# %%
path = 'Data/'

# %%


def del_outliers(df: pd.DataFrame) -> pd.DataFrame:
    q1 = df['T_mean'].quantile(0.25)
    q3 = df['T_mean'].quantile(0.75)
    iqr = q3 - q1
    low = q1 - 1.5 * iqr
    high = q3 + 1.5 * iqr
    return df[(df['T_mean'] > low) & (df['T_mean'] < high)]

# %%


def training_with_all(frequency: str, state: str, T_range: np.ndarray, param: dict) -> pd.DataFrame:
    result = pd.DataFrame(columns=['MSE', 'param'], index=['T=' + s for s in T_range])

    print(frequency, state, ' begin.')

    for T in T_range:
        data_path = os.path.join(path, 'T=' + T, frequency + '_' + state + '.csv')
        df = pd.read_csv(data_path)

        new = del_outliers(df)

        X = new.drop(columns='T_mean')
        y = new['T_mean']

        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
        std_scaler = StandardScaler()
        X_train = std_scaler.fit_transform(X_train)
        X_test = std_scaler.transform(X_test)

        cv = KFold(n_splits=5, random_state=42)
        gridcv = GridSearchCV(SVR(kernel='rbf'), param_grid=param, scoring='neg_mean_squared_error', cv=cv)
        gridcv.fit(X_train, y_train)

        y_pred = gridcv.predict(X_test)
        mse = mean_squared_error(y_test, y_pred)
        result['MSE']['T=' + T] = mse
        result['param']['T=' + T] = gridcv.best_params_
        print('T=' + T + ': complete.', 'mse=', mse, ', param=', gridcv.best_params_)

    print(frequency, ' ', state, ' complete.')

    return result


# %%
T_range = np.arange(2, 16).astype(np.str)
param = {
    'gamma': np.logspace(-4, 0, 5),
    'C': np.logspace(0, 4, 5)
}
for frequency in ['day', 'week']:
    for state in ['1', '2']:
        result = training_with_all(frequency=frequency, state=state, T_range=T_range, param=param)
        result.to_csv('result_' + frequency + '_' + state + '.csv', index_label='T')

# %% [markdown]
# ### 测试
# %%
T_range = np.arange(2, 16).astype(np.str)
param = {
    'gamma': np.logspace(-4, -1, 10),
    'C': np.logspace(1, 4, 10)
}
test = training_with_all(frequency='week', state='1', T_range=T_range, param=param)
test.to_csv('result_week_1.csv', index_label='T')

# %% [markdown]
# ## 结论
