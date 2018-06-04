
import pandas as pd
import matplotlib.pyplot as plt
get_ipython().run_line_magic('matplotlib', 'inline')
import seaborn as sbn

acs = pd.read_csv('acs.csv')
r_shares = pd.read_csv('republican_shares.csv')



# subset republican share to year 2016
r_2016 = r_shares.loc[r_shares['Year']==2016]



# unify county/city names by capitalizing all
acs['County/City'] = acs['County/City'].str.upper()
r_2016['County/City'] = r_shares['County/City'].str.upper()


# join dataframes
r_acs = pd.merge(acs, r_2016, on='County/City')


sbn.pairplot(r_acs, vars=['Household Income', 'Medicare Coverage', 'Foreign Born', 'R_SHARE'])
fig2 = plt.gcf()



fig2.savefig('pairplot.png', bbox_inches='tight')



from statsmodels.regression.linear_model import OLS



# define variables for regression
X = r_acs[['Household Income','Medicare Coverage','Foreign Born']]
X['Intercept'] = 1
y = r_acs['R_SHARE']



# run regression
reg = OLS(y,X)
fit = reg.fit()
fit.summary()




# save coefficients
pd.DataFrame(fit.params).to_csv('coefficients.csv')
