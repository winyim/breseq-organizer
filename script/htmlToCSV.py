#!/usr/bin/env python3
import pandas as pd
import os
import glob
import re,sys, shutil
from shutil import copyfile
from pathlib import Path

user_input = sys.argv[1]
output = sys.argv[2]
directory="breseq_results"
path=os.path.join(user_input,output, directory)

for dirpath, dirs, files in os.walk((os.path.normpath(output)), topdown=False):
    for name in files:
        if name.endswith('index.html'):
            parent = os.path.split(os.path.split(dirpath)[0])[1]
            subfolder = os.path.split(os.path.split(dirpath)[1])[1]
            os.rename(os.path.join(dirpath, name), 
                      os.path.join(dirpath, parent + '.html')) 
            totalCopyPath = os.path.join(dirpath, parent + '.html') 
            shutil.copy(totalCopyPath,path)

os.chdir(path)

for file in glob.glob("*.html"):
    df = pd.read_html(file)
    df = pd.DataFrame(data=df[1])
    del df[df.columns[0]]
    basename=Path(file).stem
    df['sample'] = basename 
    df.to_csv(basename+'.csv', index=False, header=None)

#get CSV files list from folder
csv_files=glob.glob("*.csv")
print(csv_files)
regex = re.compile(r"_S([0-9]*).breseq|.breseq")

# #concatenate all dataframes 
df_list2 = (pd.read_csv(file,
     names = ["position", "mutation", "freq","annotation", 
        "gene", "description","sample"]) for file in csv_files)
big_df   = pd.concat(df_list2, ignore_index=True)
big_df["sample"] = big_df["sample"].str.replace(regex, "", regex=True)
big_df.to_csv('concatenated_results.csv', index=False)
