# %% [markdown]
# # Meta Kaggle: What happened to the team size?
# ## An investigation in team size evolution for winning teams in Kaggle Competitions
# %% [markdown]
# # Introduction
# This note is to investigate how the team sizes evolveed in time.
# Use the data from Meta Kaggle, a dataset with meta-information from Kaggle about Datasets, Competitions, Users, Teams. We will focus on Competitions, Teams and TeamMemberships.
#
# Try to understand how many competitions limited the team size (**MaxTeamSize**) each year. The type of the competition is also an important factor and will show the results as well grouped on competition type (**HostSegmentTitle**).
#
# Look to the number of teams per year and the number of teams, grouped by year and team size.
# %% [markdown]
# ## Load packages
# %%
import numpy as np
import pandas as pd
import plotly.express as px
import plotly.figure_factory as ff
import plotly.graph_objects as go
from plotly.subplots import make_subplots
# %% [markdown]
# ## Read the data
# %%
competition_df = pd.read_csv(
    '../Dataset/meta-kaggle/Competitions.csv')  # type:pd.DataFrame
teams_df = pd.read_csv('../Dataset/meta-kaggle/Teams.csv')  # type:pd.DataFrame
team_membership_df = pd.read_csv(
    '../Dataset/meta-kaggle/TeamMemberships.csv')  # type:pd.DataFrame
# %% [markdown]
# ## Check the data
# %%
print(f'Meta Kaggle Competitions data shape: {competition_df.shape}')
print(f'Meta Kaggle Teams data shape: {teams_df.shape}')
print(f'Meta Kaggle TeamMemberships data shape: {team_membership_df.shape}')
# %% [markdown]
# # Competitions
# ## Check the data
# %%
competition_df.head()
# %%
competition_df.describe()
# %% [markdown]
# Extract the **Deadline Year** from the **Deadline Date**.
# %%
competition_df['DeadlineYear'] = pd.to_datetime(
    competition_df['DeadlineDate']).dt.year
# %% [markdown]
# ## competition types
# **HostSegmentTitle** is more meaningful
# %%
tmp = competition_df.groupby('HostSegmentTitle')['Id'].nunique()
df = pd.DataFrame(
    data={'Competitions': tmp.values},
    index=tmp.index
).reset_index()  # type:pd.DataFrame
# %%
fig = px.bar(
    df,
    x='HostSegmentTitle',
    y='Competitions',
    title='Competitions per type'
)
fig.update_layout(
    xaxis_title='Competition Type',
    yaxis_title='Number of competitions',
)
fig.show()
# %% [markdown]
# Most of the competitions are of type **InClass**,then **Featured** then **Research** ···.
#
# Take a closer look.
# %%
var = ['DeadlineDate', 'DeadlineYear', 'CompetitionTypeId', 'HostSegmentTitle',
       'TeamMergerDeadlineDate', 'TeamModelDeadlineDate', 'MaxTeamSize', 'BanTeamMergers']
competition_df[var].head()
# %% [markdown]
# Check the missing data.
# %%


def missing_data(data):
    total = data.isnull().sum()
    count = data.isnull().count()
    percent = total / count * 100
    tt = pd.concat([total, percent], axis=1, keys=['Total', 'Percent'])
    return tt


missing_data(competition_df[var])
# %% [markdown]
# MaxTeamSize missed 90+%, which means the team size is not restricted.
#
# Replace MaxTeamSize with -1.
# %%
competition_df.loc[competition_df['MaxTeamSize'].isnull(), 'MaxTeamSize'] = -1
# %% [markdown]
# ## Number of competitions, grouped by year and MaxTeamSize
# %%
tmp = competition_df.groupby('DeadlineYear')['MaxTeamSize'].value_counts()
df = pd.DataFrame(
    data={'Competitions': tmp.values},
    index=tmp.index
).reset_index()  # type:pd.DataFrame
dataset = df.query('MaxTeamSize > -1')  # type:pd.DataFrame
# %%
fig = px.bar(
    dataset,
    x='DeadlineYear',
    y='Competitions',
    color='MaxTeamSize',
    barmode='group',
    title='Number of competitions with max team size per year'
)
fig.update_layout(
    xaxis_title='Year',
    yaxis_title='Number of competitions'
)
'''
max_team_sizes = (dataset.groupby('MaxTeamSize')[
                  'MaxTeamSize'].nunique()).index
fig = go.Figure()
for max_team_size in max_team_sizes:
    dts = dataset.query('MaxTeamSize == @max_team_size')
    fig.add_bar(
        x=dts['DeadlineYear'],
        y=dts['Competitions'],
        name=max_team_size
    )
fig.update_layout(
    barmode='group',
    title='Number of competitions with max team size per year',
    xaxis_title='Year',
    yaxis_title='Number of competitions'
)
'''
fig.show()
# %%
tmp = competition_df.query('MaxTeamSize > -1')['DeadlineYear'].value_counts()
df = pd.DataFrame(
    data={'Competitions': tmp.values},
    index=tmp.index
).reset_index()  # type:pd.DataFrame
# %%
fig = px.bar(
    df,
    x='index',
    y='Competitions',
    title='Total number of competitions with max team size per year'
)
fig.update_layout(
    xaxis_title='Year',
    yaxis_title='Number of competitions',
)
fig.show()
# %%
tmp = competition_df['DeadlineYear'].value_counts()
df = pd.DataFrame(
    data={'Competitions': tmp.values},
    index=tmp.index
).reset_index()  # type:pd.DataFrame
# %%
fig = px.bar(
    df,
    x='index',
    y='Competitions',
    title='Total number of competitions per year'
)
fig.update_layout(
    xaxis_title='Year',
    yaxis_title='Number of competitions'
)
fig.show()
# %% [markdown]
# In 2017, the number of competition and the number of competition limiting the number of team members increased to more than double in the precious year.
#
# In 2018, the number of competition was larger than 2017, but the number of competition limiting the number of team members decreased to a number smaller than 2016.
#
# In 2019, the data is incomplete.
# %% [markdown]
# ## Number of competitions, grouped by year, MaxTeamSize and HostSegmentTitle
# %%
tmp = competition_df.groupby(['DeadlineYear', 'MaxTeamSize'])[
    'HostSegmentTitle'].value_counts()
df = pd.DataFrame(
    data={'Competitions': tmp.values},
    index=tmp.index
).reset_index()  # type:pd.DataFrame
df['CompLog'] = np.log(df['Competitions'] + 1)  # for visualizing the size
# %%
fig = px.scatter_3d(
    df,
    x='DeadlineYear',
    y='CompLog',
    z='MaxTeamSize',
    size='CompLog',
    color='HostSegmentTitle',
    title='Number of competitions per year and max team size, grouped by competition type'
)
fig.update_layout(
    xaxis_title='Year',
    yaxis_title='Competitions [log scale]'
)
fig.show()
# %% [markdown]
# Most of the Competitions with **MaxTeamSize** not set (-1) are **InClass** competitions since 2016.
#
# In 2017 and 2018 almost all competitions are **InClass**
#
# Majority of competitions either **Featured** and **Research** and most are with no **MaxTeamSize** set.
#
# In 2018, There is only one **Featured** competition with **MaxTeamSize** set to 3.
# %% [markdown]
# ## Competition Reward
# Analyze the competition reward, grouped by year adn competition type.(exclude **InClass**)
# %%
tmp = competition_df.query("HostSegmentTitle!='InClass'")
tmp = tmp.groupby(['DeadlineYear', 'RewardQuantity'])[
    'HostSegmentTitle'].value_counts()
df = pd.DataFrame(
    data={'Competitions': tmp.values},
    index=tmp.index
).reset_index()  # type:pd.DataFrame
df['RewardLog'] = np.log(df['RewardQuantity'] + 1)  # for visualizing the size
# %%
fig = px.scatter_3d(
    df,
    x='DeadlineYear',
    y='Competitions',
    z='RewardLog',
    size='RewardLog',
    color='HostSegmentTitle',
    title='Number OF Competitions per year and reward amount, grouped by Competition type'
)
fig.update_layout(
    xaxis_title='Year',
    yaxis_title='Competitions'
)
fig.show()
# %% [markdown]
# The year **2019** has only partial data.
# %%
tmp = competition_df.query("HostSegmentTitle!='InClass'")
tmp = tmp.groupby(['DeadlineYear', 'HostSegmentTitle'])['RewardQuantity'].sum()
df = pd.DataFrame(
    data={'Total amount': tmp.values},
    index=tmp.index
).reset_index()  # type:pd.DataFrame
# %%
fig = px.bar(
    df,
    x='DeadlineYear',
    y='Total amount',
    color='HostSegmentTitle',
    barmode='group',
    title='Total amount of reward per year, grouped by Competition type'
)
fig.update_layout(
    xaxis_title='Year',
    yaxis_title='Total amount'
)
fig.show()
# %% [markdown]
# # Teams
# ## Check the data
# %%
teams_df.head()
# %%
teams_df.describe()
# %%
missing_data(teams_df)
# %%
print(f"Different teams:{teams_df['Id'].nunique()}")
# %% [markdown]
# Over **2M** teams registered in more than 10K competitions.
#
# Merge team data with competition data (haven't missing **CompetitionId**, which is the merge field).
# %%
team_membership_df.head()
# %%
team_membership_df.describe()
# %%
missing_data(team_membership_df)
# %% [markdown]
# ## Teams per year and teams per year and team size
# Merge Competitions, Teams and TeamMemberships data.
# %%
comp_team_df = competition_df.merge(
    teams_df, left_on='Id', right_on='CompetitionId')  # type:pd.DataFrame
comp_team_membership_df = comp_team_df.merge(
    team_membership_df, left_on='Id_y', right_on='TeamId')  # type:pd.DataFrame
# %%
tmp = comp_team_df['DeadlineYear'].value_counts()
df = pd.DataFrame(
    data={'Teams': tmp.values},
    index=tmp.index
).reset_index()  # type:pd.DataFrame
# %%
fig = px.bar(
    df,
    x='index',
    y='Teams',
    title='Total number of teams per year'
)
fig.update_layout(
    xaxis_title='Year',
    yaxis_title='Number of teams'
)
fig.show()
# %%
tmp = comp_team_df.groupby('DeadlineYear')['HostSegmentTitle'].value_counts()
df = pd.DataFrame(
    data={'Competitions': tmp.values},
    index=tmp.index
).reset_index()  # type:pd.DataFrame
# %%
fig = px.bar(
    df,
    x='DeadlineYear',
    y='Competitions',
    color='HostSegmentTitle',
    barmode='group',
    title='Number of teams per year, grouped by Competition type'
)
fig.update_layout(
    xaxis_title='Year',
    yaxis_title='Competitions'
)
fig.show()
# %% [markdown]
# ## Number of teams per team size and year heatmap (all competitions)
# %%
tmp = comp_team_membership_df.groupby(['DeadlineYear', 'TeamId'])['Id'].count()
df1 = pd.DataFrame(
    data={'Teams': tmp.values},
    index=tmp.index
).reset_index()  # type:pd.DataFrame
# %%
tmp = df1.groupby(['DeadlineYear', 'Teams']).count()
df2 = pd.DataFrame(
    data=tmp.values,
    index=tmp.index
).reset_index()  # type:pd.DataFrame
df2.columns = ['Year', 'Team size', 'Teams']
# %%
df2.head()
# %%


def plot_heatmap_count(data_df, feature1, feature2, title):
    matrix = data_df.pivot(feature1, feature2, 'Teams')  # type:pd.DataFrame
    matrix.fillna(value=-1, inplace=True)
    fig = ff.create_annotated_heatmap(
        z=matrix.values,
        x=list(matrix.columns),
        y=list(matrix.index)
    )
    fig.update_layout(
        height=1000,
        width=1000,
        title=title
    )
    fig.show()


# %%
plot_heatmap_count(df2, 'Team size', 'Year',
                   'Number of teams, grouped by year and team size')
# %% [markdown]
# 2012 (40 and 23 team members);
# 2017 (34 team members)
# 2014 (24, 25 team members)
# 2013 (24 team members)
#
# Remove the InClass competitions and plot again the number of teams grouped by year and team size.
# %% [markdown]
# ## Number of teams for team size and year heatmap (no InClass competitions)
# %%
without_inclass_df = comp_team_membership_df.query(
    "HostSegmentTitle!='Inclass'")
tmp = without_inclass_df.groupby(['DeadlineYear', 'TeamId'])['Id'].count()
df1 = pd.DataFrame(
    data={'Teams': tmp.values},
    index=tmp.index
).reset_index()  # type:pd.DataFrame
tmp = df1.groupby(['DeadlineYear', 'Teams']).count()
df2 = pd.DataFrame(
    data=tmp.values,
    index=tmp.index
).reset_index()  # type:pd.DataFrame
df2.columns = ['Year', 'Team size', 'Teams']
# %%
plot_heatmap_count(df2, 'Team size', 'Year',
                   'Number of teams, grouped by year and team size (without InClass competition)')
# %% [markdown]
# By removing **InClass** competitions,majority of the teams are formed for Featured competitions.
# %% [markdown]
# ## Time variation of number of teams vs. team size
# %%
tmp = comp_team_membership_df.groupby(
    ['DeadlineYear', 'TeamId', 'HostSegmentTitle'])['Id'].count()
df1 = pd.DataFrame(
    data={'Teams': tmp.values},
    index=tmp.index
).reset_index()  # type:pd.DataFrame
tmp = df1.groupby(['DeadlineYear', 'HostSegmentTitle', 'Teams']).count()
df2 = pd.DataFrame(
    data=tmp.values,
    index=tmp.index
).reset_index()  # type:pd.DataFrame
df2.columns = ['Year', 'HostSegmentTitle', 'Team size', 'Teams']
df2['TeamsSqrt'] = np.sqrt(df2['Teams'] + 2)
# %%
fig = px.scatter(
    df2,
    x='Team size',
    y='Teams',
    color='Team size',
    size='TeamsSqrt',
    size_max=100,
    hover_name='HostSegmentTitle',
    animation_frame='Year',
    title='Number of Teams vs. Team size - time variation (years)',
    log_y=True,
    range_x=[-5, 41],
    range_y=[0.1, 10**7]
)
fig.update_layout(
    xaxis_title='Team size',
    yaxis_title='Number of Teams [log scale]'
)
fig.show()
# %% [markdown]
# ## Time variation of number of winning teams vs. team size
# ### Featured competitions
# Focus on the winning teams (teams with bronze, silver or gold medals).
# %%
feature_df = comp_team_membership_df.query("HostSegmentTitle=='Featured'")
tmp = feature_df.groupby(['DeadlineYear', 'TeamId', 'Medal'])['Id'].count()
df1 = pd.DataFrame(
    data={'Teams': tmp.values},
    index=tmp.index
).reset_index()  # type:pd.DataFrame
tmp = df1.groupby(['DeadlineYear', 'Medal', 'Teams']).count()
df2 = pd.DataFrame(
    data=tmp.values,
    index=tmp.index
).reset_index()  # type:pd.DataFrame
df2.columns = ['Year', 'Medal', 'Team size', 'Teams']
df2['Rank'] = (df2['Medal'] - 1) / 2
df2['Size'] = 4 - df2['Medal']
# %%
bins = [-0.01, 0.49, 0.99, np.inf]
names = ['Gold', 'Silver', 'Bronze']
df2['Medal Name'] = pd.cut(df2['Rank'], bins, labels=names)
# %%
fig = px.scatter(
    df2,
    x='Team size',
    y='Teams',
    color='Rank',
    color_discrete_map={
        '0': 'gold',
        '0.5': 'silver',
        '1': 'brown'
    },
    hover_name='Medal Name',
    size='Size',
    animation_frame='Year',
    title='Number of Winning Teams vs. Team size - time variation (years) - Featured competitions',
    log_y=True,
    range_x=[-5, 41],
    range_y=[0.1, 10**4]
)
fig.update_layout(
    xaxis_title='Team size',
    yaxis_title='Number of Teams [log scale]'
)
fig.show()
# %% [markdown]
# 2010: 1 team winning gold, with 4 members;
# 2011: 1 team winning gold, with 12 members;
# 2012: 1 team winning bronze, with 40 members;
# 2013: 2 teams winning gold, with 24 members;
# 2014: 1 team winning bronze, with 6 members;
# 2015: 1 team winning bronze, with 18 members;
# 2016: 1 team winning gold, with 13 members;
# 2017: 1 team winning bronze, with 34 members;
# 2018: 1 team winning silver, with 23 members;
# 2019: 2 teams winning gold with 8 members and 4 teams winning silver with 8 members
# %%
df = df2.query('Medal==1.0')
plot_heatmap_count(df, 'Team size', 'Year',
                   'Number of Gold winning teams, grouped by year and by team size (Featured competitions)')
# %% [markdown]
# The largest teams winning gold were in 2013 (24, 10 members), 2012 (23, 15, 12 members), 2011 (12 members), 2016 (13 and 11 members) and 2017 (10 members)
# %% [markdown]
# ### Research competitions
# Focus on the winning teams (teams with bronze, silver or gold medals).
# %%
research_df = comp_team_membership_df.query("HostSegmentTitle=='Research'")
tmp = feature_df.groupby(['DeadlineYear', 'TeamId', 'Medal'])['Id'].count()
df1 = pd.DataFrame(
    data={'Teams': tmp.values},
    index=tmp.index
).reset_index()  # type:pd.DataFrame
tmp = df1.groupby(['DeadlineYear', 'Medal', 'Teams']).count()
df2 = pd.DataFrame(
    data=tmp.values,
    index=tmp.index
).reset_index()  # type:pd.DataFrame
df2.columns = ['Year', 'Medal', 'Team size', 'Teams']
df2['Rank'] = (df2['Medal'] - 1) / 2
df2['Size'] = 4 - df2['Medal']
# %%
bins = [-0.01, 0.49, 0.99, np.inf]
names = ['Gold', 'Silver', 'Bronze']
df2['Medal Name'] = pd.cut(df2['Rank'], bins, labels=names)
# %%
fig = px.scatter(
    df2,
    x='Team size',
    y='Teams',
    color='Rank',
    color_discrete_map={
        '0': 'gold',
        '0.5': 'silver',
        '1': 'brown'
    },
    hover_name='Medal Name',
    size='Size',
    animation_frame='Year',
    title='Number of Winning Teams vs. Team size - time variation (years) - Research competitions',
    log_y=True,
    range_x=[-5, 41],
    range_y=[0.1, 10**4]
)
fig.update_layout(
    xaxis_title='Team size',
    yaxis_title='Number of Teams [log scale]'
)
fig.show()
# %% [markdown]
# 2012: 1 team winning gold and one silver, with 11 members;
# 2013: 1 team winning bronze, with 9 members;
# 2014: 1 team winning bronze, with 24 members;
# 2015: 1 team winning silver, with 8 members;
# 2016: 1 team winning silver, with 8 members;
# 2017: 4 teams winning bronze, with 8 members;
# 2018: 1 team winning gold, with 9 members
# %%
df = df2.query('Medal==1.0')
plot_heatmap_count(df, 'Team size', 'Year',
                   'Number of Gold winning teams, grouped by year and by team size (Research competitions)')
# %% [markdown]
# The number of teams winning golds with multiple teams members (as well as with one team member) increased in 2019 compared with previous years (2015 to 2018), although 2019 has still partial results.
# %% [markdown]
# ## Team size and teams rankings
# ### Featured competitions
# %%
tmp = feature_df.groupby('TeamId')['Id'].count()
df1 = pd.DataFrame(
    data={'Team Size': tmp.values},
    index=tmp.index
).reset_index()  # type:pd.DataFrame
# merge back df with teams_df
df2 = df1.merge(teams_df, legt_on='TeamId', right_on='Id')
var = ['Team Size', 'PublicLeaderboardRank', 'PrivateLeaderboardRank']
teams_ranks_df = df2[var]
# %%
corr = teams_ranks_df.corr()
fig = ff.create_annotated_heatmap(
    z=corr,
    x=list(corr.columns),
    y=list(corr.index),
    showscale=True,
    height=500,
    width=500
)
fig.show()
# %% [markdown]
# There is an obvious strong correlation between the public and private leaderboard rank.
# There is no correlation between the team size and the public and private leaderboard rank.
# %% [markdown]
# # Conclusion
# Analyzing the competitions and teams data we understood that large teams winning medals were equaly frequent in past years, with very large size teams winning competitions as early as 2012.
#
# Although there was a recent perception of increase in frequency of large size teams formed to win medals, this is not a recent phenomena; there were larger teams in the past winning medals. What changed dramatically recently is actually the number of Kagglers.
# %% [markdown]
# ## A explanation of the perception
# Will show the number of new users registered every year.
# %%
users_df = pd.read_csv(
    '../../Dataset/meta-kaggle/Users.csv')  # type:pd.DataFrame
# %%
users_df.head()
# %%
users_df.describe()
# %%
users_df['RegisterYear'] = pd.to_datetime(
    users_df['RegisterDate'], format='%m/%d/%Y').dt.year
# %%
tmp = users_df['RegisterYear'].value_counts()
df = pd.DataFrame(
    data={'Users': tmp.values},
    index=tmp.index
).reset_index()  # type:pd.DataFrame
# %%
fig = px.bar(
    df,
    x='index',
    y='Users',
    title='Total number of new users per year'
)
fig.update_layout(
    xaxis_title='Year',
    yaxis_title='Number of new users'
)
fig.show()
