# -*- coding: utf-8 -*-
"""
Created on Sun Nov  3 19:43:38 2024

@author: pspea
"""
import numpy as np

infile_name = ('C:/Gresham/tiny_projects/Project_Transect_2/Supplemental_Material/ST4_BC_distances.txt')

def parse_similarity(infile_name, source, left, right):
    infile = open(infile_name)
    
    temp_list = []
    
    for line in infile:
        if line[0] != 'S':
            #Source	SubjectID1	SubjectID2	Group1	Group2	BCDistance
            line = line.strip()
            sourceis, _id1, _id2, leftis, rightis, bcd = line.split('\t')
            
            if (sourceis == source) and (leftis == left) and (rightis == right):
                pct_sim = 1 - float(bcd)
                temp_list.append(pct_sim)
                
    infile.close()
    
    outline = ('{source} {left} {right}: {pct}%').format(
        source = source,
        left = left,
        right = right,
        pct = np.median(temp_list))
    
    print(outline)
    
for source in set(['16S', 'ITS']):
    for left in set(['F8W', 'F80', 'F8300', 'F8600']):
        parse_similarity(infile_name, source, left, left)

for source in set(['16S', 'ITS']):            
    for left in set(['F8W', 'F80', 'F8300', 'F8600']):
        for right in set(['F8W', 'F80', 'F8300', 'F8600']):
            if left != right:
                parse_similarity(infile_name, source, left, right)
        
# 16S - same same: np.median([0.42855, 0.39, 0.41359999999999997, 0.4376]) #0.421075

''' 16S - diff diff: 
    np.median([0.21599999999999997,0.3492,0.40980000000000005,0.21599999999999997,0.19920000000000004,0.19925000000000004,0.3492,
               0.19920000000000004,0.33975,0.40980000000000005,0.19925000000000004,0.33975]) #0.277875
    '''
    
for source in set(['16S']):            
    for left in set(['F8W','F80', 'F8300', 'F8600']):
        for right in set(['F80','F8300', 'F8600']):
            if left != right:
                parse_similarity(infile_name, source, left, right)