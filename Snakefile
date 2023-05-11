import os
import pandas as pd

current= os.getcwd()
directory = input("Enter directory:")
path=os.path.join(current, directory)

fastqs = []
for root, folder, files in os.walk(path):
    for file in files:
        if file.endswith('.fastq.gz'):
            fullname = os.path.join(directory,file)
            fastqs.append(fullname)
fastqs.sort()

df_full = pd.DataFrame(fastqs)
df_full[1] = df_full[0].str.split('_L', n=1).str[0].str.split('/').str[1]

df_full.columns=["fastq", "sample_name"]
df = df_full.groupby("sample_name")["fastq"].apply(', '.join).reset_index()
df[['r1', 'r2']] = df.fastq.str.split(',', expand=True)
df.drop('fastq', axis=1, inplace=True)

samples = sorted(df['sample_name'].drop_duplicates().values)

R1 = str("_L001_R1_001")
R2 = str("_L001_R2_001")
ext = str(".fastq.gz")
print(samples)

rule all:
    input:
        expand([path+'/{sn}'+R1+'.fastq.gz', path+'/{sn}'+R2+'.fastq.gz'], sn=samples),
        expand(directory+'_results/{sn}.breseq/output/output.vcf', sn=samples),
        directory+'_results/breseq_results/concatenated_results.csv',
        expand(directory+'_results/breseq_results/{sn}.breseq.html', sn=samples),
        expand(directory+'_results/breseq_results/{sn}.breseq.csv', sn=samples),
      
rule breseq:
    input:
        reads = [path+'/{sn}'+R1+'.fastq.gz', path+'/{sn}'+R2+'.fastq.gz'],
        ref = current+'/data/MN908947.3.gbk'
    output:
        directory+'_results/{sn}.breseq/output/output.vcf'
    log:
        directory+'_results/{sn}.breseq/{sn}_breseq.log',
    threads:
        4
    params:
        outdir = directory+'_results/{sn}.breseq'

    shell:
        "breseq -r {input.ref} --num-processors {threads} --polymorphism-prediction --brief-html-output --output {params.outdir} {input.reads} > {log} 2>&1 || touch {output}"

rule html2csv:
    input: 
        script = current+'/script/htmlToCSV.py',
        current = current,
        hold = expand(directory+'_results/{sn}.breseq/output/output.vcf', sn=samples)
    output:
        df = directory+'_results/breseq_results/concatenated_results.csv',
        csvs = expand(directory+'_results/breseq_results/{sn}.breseq.csv', sn=samples),
        breseq = expand(directory+'_results/breseq_results/{sn}.breseq.html', sn=samples)
    params:
        dir=directory+"_results",
    shell:
        "python {input.script} {input.current} {params.dir} || touch {output} || touch {input.hold}"

