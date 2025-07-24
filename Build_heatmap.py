# -*- coding: utf-8 -*-
"""
Created on Mon Dec 26 11:58:29 2022

@author: pspea
"""
import statsmodels.stats.multitest as smt

from scipy import stats
import seaborn as sns
import matplotlib.pyplot as plt


from scipy.cluster.hierarchy import linkage, dendrogram, fcluster
from scipy.spatial.distance import squareform



import numpy as np
import pandas as pd

#import plotly.graph_objects as go

import plotly.io as pio
pio.renderers.default = "browser"


import plotly.graph_objects as go

output_file_name = ('C:/Gresham/Project_Transect/heatmap/linregression_details_sig_no_resistance.txt')
output_file = open(output_file_name, 'w')
header = ('InterPro_id\tRGI_ARO\tSlope\tIntercept\tR\tPval\n')
output_file.write(header)

filename = ('C://Gresham/Project_Transect/RGI/RGI_best_hit_aro_rel_count_noWater.txt')
rgi_df = pd.read_table(filename, index_col=0, sep='\t')
rgi_df=rgi_df.mul(1e9)
rgi_dict = rgi_df.to_dict('index')

output_df_file_name = ('C:/Gresham/Project_Transect/heatmap/linregression_results_sig_no_resistance.txt')

filename = ("C:/Gresham/Project_Transect/MGnify/Interpro/InterPro_normalized_filtered.txt")
ip_df = pd.read_table(filename, index_col=0, sep='\t')
interpro_dict = ip_df.to_dict('index')

corr_dict = {}

uid_list = []
pvalue_list = []
adj_pval_list = []

sample_list = ['F10_1', 'F10_2', 'F10_3',
               'F300_1', 'F300_2', 'F300_3',
               'F600_1', 'F600_2', 'F600_3']

filename = ("C:/Gresham/Project_Transect/MGnify/description_lookup.csv")
lookup_dict = {}
infile = open(filename)

for line in infile:
    if 'resistance' in line.lower():
        print(line)
        #1/0
    
    if 'resistance' not in line.lower():
        ip_raw = line[:10]
        desc = line[10:].strip()
        
        if ',' not in ip_raw:
            print(ip_raw)
        else:
            ip_raw = ip_raw.split(',')[0]
            
        lookup_dict[ip_raw]=desc

ip_num = 0

for ip in interpro_dict:
    if ip in lookup_dict:
        if ip not in corr_dict:
            corr_dict[ip] = {}
            
        for aro in rgi_dict:
            uid = ('{}+{}').format(ip,aro)
            uid_list.append(uid)
            
            # if aro not in corr_dict[ip]:
            #     corr_dict[ip][aro]=0
                
            ip_list = []
            aro_list = []
            
            for sample in sample_list:
                if sample in rgi_dict[aro] and sample in interpro_dict[ip]:
                    ip_list.append(interpro_dict[ip][sample])
                    aro_list.append(rgi_dict[aro][sample])
            
            ip_ct = len([x for x in ip_list if x > 0])
            aro_ct = len([x for x in aro_list if x > 0])
            
            res = stats.linregress(ip_list, aro_list)
            pvalue_list.append(res.pvalue)
                
            corr_dict[ip][aro] = {'res':res,
                                  'ip_ct':ip_ct,
                                  'aro_ct':aro_ct,
                                  'adj_pval':1}
                
        ip_num+=1
        print(ip)
        print(ip_num, ip_num/len(lookup_dict))

bool_results, adj_pval_list = smt.fdrcorrection(pvalue_list)
#

for i in range(len(uid_list)):
    #if bool_results[i]:
    uid = uid_list[i]
    ip, aro = uid.split('+')
    adj_pval = adj_pval_list[i]
    corr_dict[ip][aro]['adj_pval'] = adj_pval
    
    #if res.pvalue <= 0.05:
    #if res.pvalue*(6923*625) <= 0.05:
    #corr_dict[ip][aro] = res.rvalue
    
    res = corr_dict[ip][aro]['res']
                    
    outline = ('{ip}\t{aro}\t{slope}\t{intercept}\t{r2}\t{pval}\t{adj_pval}\n').format(
        ip = ip,
        aro = aro,
        slope = res.slope, intercept = res.intercept, 
        r2 = res.rvalue,
        pval = res.pvalue,
        adj_pval = adj_pval)
    
    output_file.write(outline)
    
output_file.close()

corr_df = pd.DataFrame.from_dict(corr_dict, orient='index')
corr_df.to_csv(output_df_file_name, sep='\t')

out_filename = ("C:/Gresham/Project_Transect/MGnify/description_lookup.tab")
out_file = open(out_filename, 'w')

for ip, desc in lookup_dict.items():
    outline = ('{}\t{}\n').format(ip, desc)
    out_file.write(outline)
    
out_file.close()
    
#lookup_df = pd.read_table(filename, index_col=0, sep=',')
#lookup_dict = lookup_df.to_dict('index')

ip_set = set()
aro_set = set()

for ip in corr_dict:
    z_temp = []
    
    for aro in corr_dict[ip]:
        if ((corr_dict[ip][aro]['adj_pval']) <= 0.05
            ) and (corr_dict[ip][aro]['ip_ct'] > 4
                   ) and (corr_dict[ip][aro]['aro_ct'] > 4):
            res = corr_dict[ip][aro]['res']
            rval = res.rvalue
            z_temp.append(rval)
            
            if rval != 0:
                aro_set.add(aro)
        
    if sum(z_temp) != 0:
        ip_set.add(ip)
        #aro_set.add(aro)
        
for_r_dict = {}
        
y_list = list(ip_set)
y_list.sort()
  
x_list = list(aro_set)
x_list.sort()

z_list = []

desc_list = []

for ip in y_list:
    desc = lookup_dict[ip]
    desc_list.append(desc)
    z_temp = []
    
    for_r_dict[desc] = {}
    
    for aro in x_list:
        if aro in corr_dict[ip]:
            res = corr_dict[ip][aro]['res']
            rval = res.rvalue
            z_temp.append(rval)
            
            for_r_dict[desc][aro] = rval
            
        else:
            z_temp.append(0)
            for_r_dict[desc][aro] = 0
        
    z_list.append(z_temp)
        

fig = go.Figure(data=go.Heatmap(
                   z=z_list,
                   x=x_list,
                   y=desc_list,
                   hoverongaps = False))
fig.show()

###


r_df_file_name = ('C:/Gresham/Project_Transect/heatmap/linregression_results_forR_5p.txt')
for_r_df = pd.DataFrame.from_dict(for_r_dict, orient='index')
for_r_df.to_csv(r_df_file_name, sep='\t')

results_df_file_name = ('C:/Gresham/Project_Transect/heatmap/linregression_results_sig_no_resistance.txt')
corr_df = pd.read_table(results_df_file_name, index_col=0, sep='\t')
#corr_df = results_df.to_dict('index')

sig_ip = set()
sig_aro = set()



for ip in corr_dict:    
    for aro in corr_dict[ip]:
        if ((corr_dict[ip][aro]['adj_pval']) <= 0.01
            ) and (corr_dict[ip][aro]['ip_ct'] > 4
                   ) and (corr_dict[ip][aro]['aro_ct'] > 4):
                   
                   sig_aro.add(aro)
                   sig_ip.add(ip)
        
len(sig_aro)
len(sig_ip)

len(corr_dict)

len(corr_dict[ip])
        