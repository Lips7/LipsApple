# %%
import os
import pandas as pd

# %%
path = '../../../Users/Lips Apple/Desktop/Data'

init = pd.DataFrame()
for file in os.listdir(path):
    df = pd.read_table(os.path.join(path, file), error_bad_lines=False,
                       usecols=['TI', 'RP', 'C1', 'UT'], index_col=False)
    init = pd.concat([init, df], axis=0)
init.reset_index(inplace=True)
init

# %%
df = init.drop(['C1', 'RP'], axis=1)
df = df.join(init['C1'].str.split(r'; \[', expand=True).stack().reset_index(
    level=1).rename(columns={'level_1': 'AD_ORDER', 0: 'AD'}))
df = df.join(pd.Series(['C1']*37129, name='AD_TYPE'))
df

# %%
df1 = init.drop(['C1', 'RP'], axis=1)
df1 = df1.join(init['RP'].str.split(r';', expand=True).stack().reset_index(
    level=1).rename(columns={'level_1': 'AD_ORDER', 0: 'AD'}))
df1 = df1.join(pd.Series(['RP']*37129, name='AD_TYPE'))
df1

# %%
new = pd.concat([df, df1]).drop('index', axis=1).reset_index(drop=True)
new = new[['UT', 'TI', 'AD_TYPE', 'AD_ORDER', 'AD']]
new['AD_ORDER'] = new['AD_ORDER'].map(lambda x: x + 1)
new

# %%
new.to_csv(os.path.join(path, 'result.csv'))

# %%
