

import pandas as pd


years = pd.read_csv('election_ids.csv')['year']



# define function to get republican shares

def get_r_share(election):

    # drop two empty columns
    election = election.drop(election.columns[[1,2]], axis = 1)
    # set parties as headers
    election.columns = election.iloc[0]
    # rename columns as needed
    election.columns.values[-1] = 'Total'
    election.columns.values[0] = 'County/City'
    # remove first/redundant row
    election = election.drop(election.index[0,])

    # subset to just republican and total
    e_r = election[['County/City', 'Republican', 'Total']]

    # convert strings with commas to floats
    e_r['Republican'] = e_r['Republican'].str.replace(",","").astype(float)
    e_r['Total'] = e_r['Total'].str.replace(",","").astype(float)

    # calculate republican share
    e_r['R_SHARE'] = e_r['Republican']/e_r['Total']

    # leave unuseful columns
    unuseful = ['Republican', 'Total']
    e_r = e_r.drop(unuseful, axis = 1)

    return e_r



# get republican shares for all elections

r_shares = []

for year in years:
    # keep track of year
    year_num = str(year)
    # read in csv
    election = pd.read_csv(year_num + '.csv')
    # get republican share
    r_share = get_r_share(election)
    # add Year column
    r_share['Year'] = year_num
    r_shares.append(r_share)


# concatenate republican shares of all elections, write to one csv

republican_shares = pd.concat(r_shares)
republican_shares.to_csv('republican_shares.csv', index = False)
