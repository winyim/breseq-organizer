# breseq-organizer

This Snakemake workflow is intended for calling variants with [breseq] against severe acute respiratory syndrome coronavirus 2 (SARS-CoV2) reference [genome] for Illumina pair-end sequence data.  This workflow will then use a custom python script to take all main results pages (index.html) files and rename them to appropriate sample names. After which they will be moved to a new folder and concantenated to a single csv file with sample names attached.  This concatentated data can be used for subsequent analyses of your choosing. 

## Setup/Installation
1. Clone github repo
```bash
git clone https://github.com/winyim/breseq-organizer
```
2. Create conda environment and install packages
```bash
conda create -c bioconda -c anaconda -n breseq breseq snakemake pandas lxml 
conda activate breseq
```
  Note: if ```conda``` is not installing your packages, ```mamba``` can be used
  ```bash
  conda install -c conda-forge mamba
  mamba create -c bioconda -c anaconda -n breseq breseq snakemake pandas lxml 
  conda activate breseq
  ```
## Usage
Move into downloaded git repo folder
```bash
cd breseq-output-organization
```
Create a symlink (a shortcut) to where the raw Illumina paired-end fastq files are stored.
```bash
ln -s [directory_to_fastqs]
```
Run snakemake workflow (number of cores can be set based on your system)
```bash
snakemake --cores 4
```
It will ask for the directory name (symlinked in the previous step)

## Outputs

The workflow will generate all the breseq outputs in a directory called ```[symlinked_dir_name]_results```.  Also contained within this result folder will be a directory called ```breseq_results``` where you will find all the breseq main result ```html``` and ```csv``` files as well as the ```concatenated_results.csv```.

[breseq]: <https://barricklab.org/twiki/pub/Lab/ToolsBacterialGenomeResequencing/documentation/>
[genome]: <https://www.ncbi.nlm.nih.gov/nuccore/MN908947>
