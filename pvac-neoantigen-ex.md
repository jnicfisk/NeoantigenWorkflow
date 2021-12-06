---
title: "Neoantigen Calling"
author: "J. Nick Fisk"
date: "11/23/2021"
output: html_document
---


## Get VCF Files
Do what you must to get a VCF file. I wrote [my own (bad) script](https://github.com/jnickfisk/NeoantigenWorkflow/blob/main/maf-to-vcf.R) to do so from MAF files, but there are probably better solutions, including earlier outputs in the pipeline!


## Install pvactools (comes with NetMHCcons, and a few other callers.)
You can install using this guide:

`https://pvactools.readthedocs.io/en/latest/install.html`


It installs with pip in python and runs in conda well


You do need the IEDB prediction tools, so don't forget those. The other MHC tools can be installed too, if you'd like, but I used NetHMCcons SMM and SMMPMBEC which don't require extra installs~


Or you can use the docker image at griffithlab/pvactools, which comes with them all ready to do. I've done it both ways, works fine either way. I tend to use the docker image, though!

`signularity pull griffithlab/pvactools`


## Load VEP; install plugins
If running from the cluster, load VEP
(otherwise, good luck installing it, it is awful to try and get going right)


`module load VEP`


Ruddle has all the plugins you need for base VEP, but you still need the pvactools specific ones
Installation happens from within pvacseq (more info here: https://pvactools.readthedocs.io/en/latest/pvacseq/input_file_prep/vep.html)

`pvacseq install_vep_plugin vep_plugins`


Howover, I have a hard time using Ruddle's plugins and my own because they are in seperate dirs and couldn't figure the alt pathing out, so I installed all the VEP plugins locally, too, in the same place as the pvactools specigic ones.


`git clone https://github.com/Ensembl/VEP_plugins.git`


the directory for the plugins are speficied using --dir_plugins in vep commands


You'll also need an assembly. I used human_g1k_v37.fasta (1000 genomes build) I'm sure it is loaded somewhere on ruddle, but I ended up hosting my own copy.


## 0/1 VCF Annotation

if you didn't already add 0/1 genotype annotation to your vcf files in your conversion script, you can do so with vcf-genotype-annotator

```
pip install vatools
vcf-genotype-annotator G2428B1.vcf G2428B1 0/1 -o G2428B1-gen.vcf
```

## VEP annotation w/Plugins

`~/programs/ensembl-vep/vep --input_file G2428B1-gen.vcf --output_file G2428B1-filtered-min.vep --format vcf --vcf --symbol --terms SO --tsl --hgvs --fasta human_g1k_v37.fasta --database --port 3337 --plugin Downstream --plugin Wildtype --plugin Frameshift --force_overwrite;`

## Use pvacseq to run NetHMCcons


You'll need the HLA typing from OptiType for each sample!
This command will be different if you have RNA seq data; more to come about that when I actually have some. Until then, you are basically saying that there is no relative difference in expression levels. 


`pvacseq run G2428B1-filtered-min.vep G2428B1 HLA-A*03:01,HLA-A*03:01,HLA-B*08:12,HLA-B*08:04,HLA-C*07:95,HLA-C*07:95 NetMHCcons SMM SMMPMBEC ./ -e2 8,9,10,11 --tdna-vaf 0.0 -b 1000`


This will give you the output

`G2428B1.all_epitopes.aggregated.tsv` 

that is of main relevance. The 

`G2428B1.all_epitopes.tsv`

file has all algorithm predictions on all variants and all neoepitope lengths, so it gets pretty big and includes negative calls. So the aggregated file is what you want. The 8,9,10,11 are the neoepitope sizes being screened and that range is the most common set. Only the best neoepitope size for each neoantigen is reported in the aggregated file.



