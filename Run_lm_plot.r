#for ARO:
library(colorRamps)

RGI <- read.csv("C://Gresham/Project_Transect/RGI/RGI_best_hit_aro_rel_count_distance_factor.csv")
significant_ARO <- read.table("C:/Gresham/Project_Transect/RGI/significant_ARO.txt", quote="\"", comment.char="")
ismax=0

sig_RGI <- merge(RGI, significant_ARO, by.x='RGI_ARO', by.y='V1')
ismax<-max(sig_RGI$value)


colors=rgb.tables(100)
colors=sample(colors, length(significant_ARO$V1), replace = FALSE, prob = NULL)
#my_colors <- colorRamps(c("blue","red"))
#colors=my_colors(100)
#

pdf('C://Gresham/Project_Transect/RGI/ARG_distance_sig.pdf')
ct = 1

aro = significant_ARO[1,1]
print(aro)

RGI_sig <- subset(RGI, RGI$RGI_ARO==aro)
print(RGI_sig)
plot(RGI_sig$dist, RGI_sig$value, col = colors[1], ylim = c(0,ismax))
fit<-lm(RGI_sig$value ~ RGI_sig$dist)
abline(fit, col = colors[1])
summary(fit)

for (i in 2:length(significant_ARO$V1)){
#for (i in 2:3){
  ct = ct+1
  aro = significant_ARO[i,1]
  print(aro)
  
  RGI_sig <- subset(RGI, RGI$RGI_ARO==aro)
  #print(RGI_sig)
  points(RGI_sig$dist, RGI_sig$value, col = colors[i])
  fit<-lm(RGI_sig$value ~ RGI_sig$dist)
  abline(fit, col = colors[i])
  print(summary(fit))
}

legend("topright", legend=significant_ARO$V1 ,fill=colors)
dev.off()


#for interpro:
library(colorRamps)
par(mar=c(5, 4, 4, 8), xpd=TRUE)

ip <- read.delim("C:/Gresham/Project_Transect/MGnify/Interpro/InterPro_sig_by_distance_pos.csv", header=TRUE)
#significant_ARO <- read.table("C:/Gresham/Project_Transect/RGI/significant_ARO.txt", quote="\"", comment.char="")
#ismax=0

#sig_RGI <- merge(RGI, significant_ARO, by.x='RGI_ARO', by.y='V1')

#ismax<-max(ip$rel_value)
ismax<-2281
names<-unique(ip$description)

colors=rgb.tables(100)
colors=sample(colors, length(names), replace = FALSE, prob = NULL)
#my_colors <- colorRamps(c("blue","red"))
#colors=my_colors(100)
#

pdf('C://Gresham/Project_Transect/MGnify/Interpro/IP_distance_sig_pos.pdf')
ct = 1

RGI_sig <- subset(ip, ip$description==names[1])
print(RGI_sig)
plot(RGI_sig$dist, RGI_sig$rel_value, col = colors[1], ylim = c(0,ismax))
fit<-lm(RGI_sig$rel_value ~ RGI_sig$dist)
abline(fit, col = colors[1])
summary(fit)

for (i in 2:length(names)){
  #for (i in 2:3){
  ct = ct+1

  RGI_sig <- subset(ip, ip$description==names[i])
  #print(RGI_sig)
  points(RGI_sig$dist, RGI_sig$rel_value, col = colors[i])
  fit<-lm(RGI_sig$rel_value ~ RGI_sig$dist)
  abline(fit, col = colors[i])
  print(summary(fit))
}

legend("topright",inset=c(-1, 0), legend=names ,fill=colors)
dev.off()


#for interpro:
library(colorRamps)
par(mar=c(5, 4, 4, 8), xpd=TRUE)

ip <- read.delim("C:/Gresham/Project_Transect/MGnify/Interpro/InterPro_sig_by_distance_neg.csv", header=TRUE)
#significant_ARO <- read.table("C:/Gresham/Project_Transect/RGI/significant_ARO.txt", quote="\"", comment.char="")
#ismax=0

#sig_RGI <- merge(RGI, significant_ARO, by.x='RGI_ARO', by.y='V1')

#ismax<-max(ip$rel_value)
ismax<-2281
names<-unique(ip$description)

colors=rgb.tables(100)
colors=sample(colors, length(names), replace = FALSE, prob = NULL)
#my_colors <- colorRamps(c("blue","red"))
#colors=my_colors(100)
#

pdf('C://Gresham/Project_Transect/MGnify/Interpro/IP_distance_sig_neg.pdf')
ct = 1

RGI_sig <- subset(ip, ip$description==names[1])
print(RGI_sig)
plot(RGI_sig$dist, RGI_sig$rel_value, col = colors[1], ylim = c(0,ismax))
fit<-lm(RGI_sig$rel_value ~ RGI_sig$dist)
abline(fit, col = colors[1])
summary(fit)

for (i in 2:length(names)){
  #for (i in 2:3){
  ct = ct+1
  
  RGI_sig <- subset(ip, ip$description==names[i])
  #print(RGI_sig)
  points(RGI_sig$dist, RGI_sig$rel_value, col = colors[i])
  fit<-lm(RGI_sig$rel_value ~ RGI_sig$dist)
  abline(fit, col = colors[i])
  print(summary(fit))
}

legend("topright",inset=c(-1, 0), legend=names ,fill=colors)
dev.off()


#for 16S genus:
library(colorRamps)
T16S <- read.csv("C:/Gresham/Project_Transect/qiime_results/Transect_16S_genus_distance_relabun.txt")
ismax<-0.05
names<-unique(T16S$X16S_taxa)


colors=rgb.tables(length(names))
#colors=sample(colors, length(names), replace = FALSE, prob = NULL)
#my_colors <- colorRamps(c("blue","red"))
#colors=my_colors(100)
#

pdf('C:/Gresham/Project_Transect/qiime_results/16S_taxa_distance_sig.pdf')
ct = 1

RGI_sig <- subset(T16S, T16S$X16S_taxa==names[1])
plot(RGI_sig$dist, RGI_sig$rel_abundance, col = colors[1], ylim = c(0,ismax))
fit<-lm(RGI_sig$rel_abundance ~ RGI_sig$dist)
abline(fit, col = colors[1])
summary(fit)

for (i in 2:length(names)){
  #for (i in 2:3){
  ct = ct+1
  
  RGI_sig <- subset(T16S, T16S$X16S_taxa==names[i])
  #print(RGI_sig)
  points(RGI_sig$dist, RGI_sig$rel_abundance, col = colors[i])
  fit<-lm(RGI_sig$rel_abundance ~ RGI_sig$dist)
  abline(fit, col = colors[i])
  print(summary(fit))
}

legend("topright",inset=c(-5, 0), legend=names ,fill=colors)
dev.off()


#for ITS genus:
library(colorRamps)
ITS <- read.csv("C:/Gresham/Project_Transect/ITS_qiime_results/Transect_ITS_genus_distance_relabun_filter_F10_1.txt")
ismax<-0.05
names<-unique(ITS$ITS_taxa)


colors=rgb.tables(length(names))
#colors=sample(colors, length(names), replace = FALSE, prob = NULL)
#my_colors <- colorRamps(c("blue","red"))
#colors=my_colors(100)
#

pdf('C:/Gresham/Project_Transect/ITS_qiime_results/ITS_taxa_distance_sig_filter_F10_1.pdf')
ct = 1

RGI_sig <- subset(ITS, ITS$ITS_taxa==names[1])
plot(RGI_sig$dist, RGI_sig$rel_abundance, col = colors[1], ylim = c(0,ismax))
fit<-lm(RGI_sig$rel_abundance ~ RGI_sig$dist)
abline(fit, col = colors[1])
summary(fit)

for (i in 2:length(names)){
  #for (i in 2:3){
  ct = ct+1
  
  RGI_sig <- subset(ITS, ITS$ITS_taxa==names[i])
  #print(RGI_sig)
  points(RGI_sig$dist, RGI_sig$rel_abundance, col = colors[i])
  fit<-lm(RGI_sig$rel_abundance ~ RGI_sig$dist)
  abline(fit, col = colors[i])
  print(summary(fit))
}

legend("topright",inset=c(-5, 0), legend=names ,fill=colors)
dev.off()