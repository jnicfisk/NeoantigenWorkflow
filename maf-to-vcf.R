mfile<-""
MAF<-read.table(mfile,header = T,sep = "\t",stringsAsFactors = F)


allUnis<-unique(MAF$Tumor_Sample_Barcode)
sDir<-getwd()
#INFO=SOMATIC
dQUAL="."
dInfo="."
dFILTER="PASS"
dID="."
for(i in allUnis){
  dir.create(i)
  setwd(i)
  thisSub<-MAF[MAF$Tumor_Sample_Barcode==i,]
  write.table(thisSub,file=paste0(i,"-full.maf"),sep="\t",row.names = F,col.names = T)
  #thisSub<-thisSub[thisSub$Start_Position==thisSub$End_Position,]
  #thisSub<-thisSub[thisSub$FILTER=="PASS",]
  VCF<-data.frame(matrix(nrow=nrow(thisSub),ncol=10))
  colnames(VCF)<-c("CHROM","POS","ID","REF","ALT","QUAL","FILTER","INFO","FORMAT",i)
  iter<-1:nrow(thisSub)
  for(j in iter){
    VCF[j,]<-c(thisSub$Chromosome[j],thisSub$Start_Position[j],dID,thisSub$Reference_Allele[j],thisSub$Tumor_Seq_Allele2[j],dQUAL,dFILTER,dInfo,".",thisSub$Tumor_Seq_Allele2[j])
  }
  write.table(VCF,file = paste0(i,"-filtered-min.tsv"),sep="\t",row.names = F,col.names = F,quote = F)
  writeLines(con=paste0(i,"-filtered-min.vcf"),text = c("##fileformat=VCFv4.1",paste0("#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\t",i),readLines(con = paste0(i,"-filtered-min.tsv"))))
  setwd(sDir)
}
#CHROM
#POS
#ID
#REF
#ALT
#QUAL
#FILTER
#INFO


#VCF<-data.frame(matrix(ncol=8))
#colnames(VCF)<-c("CHROM","POS","ID","REF","ALT","QUAL","FILTER","INFO")
