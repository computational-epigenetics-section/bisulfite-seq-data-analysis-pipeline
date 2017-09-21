library(ggplot2)

#Coveravge file: chromosome", "position", "strand", "methylation percentage", "count methylated", "count unmethylated

cor(C01_HF_merge$Avg.Methylation.x,C01_HF_merge$Avg.Methylation.y)


CO1_HF<-read.csv("./create_plots/C01_HF_1_chr19.bismark.bins.csv")
ggplot(data=CO1_HF, aes(CO1_HF$Avg.Methylation)) + 
  geom_histogram(breaks=seq(0, 100, by =20), 
                 col="red", 
                 aes(fill=..count..)) +
  scale_fill_gradient("Count", low = "green", high = "red") +
  labs(title="C01_HF_Distribution of % methylation in Chr 19 using 200 bp bins") +
  labs(x="% methylation", y="Count")

# ggplot(data=c01_pbl, aes(c01_pbl$Avg.Methylation)) + 
#   geom_histogram(aes(y =..density..), 
#                  breaks=seq(0, 100, by = 10), 
#                  col="red", 
#                  fill="green", 
#                  alpha = .2) + 
#   geom_density(col=2) + 
#   labs(title="Histogram for Age") +
#   labs(x="% methylation", y="Count")

CO2_HF<-read.csv("./create_plots/C02_HF_1_chr19.bismark.bins.csv")
ggplot(data=CO2_HF, aes(CO2_HF$Avg.Methylation)) + 
  geom_histogram(breaks=seq(0, 100, by =10), 
                 col="red", 
                 aes(fill=..count..))+
  scale_fill_gradient("Count", low = "green", high = "red") +
  labs(title="C02_HF_Distribution of % methylation in Chr 19 using 200 bp bins") +
  labs(x="% methylation", y="Count")
  
# ggplot(data=c02_pbl, aes(c02_pbl$Avg.Methylation)) + 
#   geom_histogram(aes(y =..density..), 
#                  breaks=seq(0, 100, by = 10), 
#                  col="red", 
#                  fill="green", 
#                  alpha = .2) + 
#   geom_density(col=2) + 
#   labs(title="C02_PBL_Distribution of % methylation in Chr 19 using 200 bp bins") +
#   labs(x="% methylation", y="Count")
CO1_HF$X <-NULL
CO2_HF$X <-NULL

DF2d<-merge(CO1_HF,CO2_HF,by = "Bin.Name")
#plot(DF2d$Avg.Methylation.x,DF2d$Avg.Methylation.y)


# # Scatter plot with the 2d density estimation
# sp <- ggplot(DF2d, aes(x=Avg.Methylation.x, y=Avg.Methylation.y)) +
#   geom_point()
# sp + geom_density_2d()
# # Gradient color
# sp + stat_density_2d(aes(fill = ..level..), geom="polygon")
# # Change the gradient color
# sp + stat_density_2d(aes(fill = ..level..), geom="polygon")+
#   scale_fill_gradient(low="green", high="red")

DF2d

library(ggplot2)
library(MASS)

## layout settings for ggplot
t2 <- theme(
  axis.line = element_line(colour = "black"),
  axis.text = element_text(colour = "black"),
  axis.ticks = element_line(colour = "black"),
  panel.grid.major.x = element_blank(),
  panel.grid.minor.x = element_blank(),
  panel.grid.major.y = element_blank(),
  panel.grid.minor.y = element_blank(),
  panel.border = element_blank(),
  panel.background = element_blank()
)


## generate the "z" coordinate (density) just for the correct midpoint in the color gradient
z <- kde2d(DF2d$Avg.Methylation.x, DF2d$Avg.Methylation.y,n = 4)

ggplot(DF2d, aes(x=Avg.Methylation.x, y=Avg.Methylation.y)) +
  stat_density2d(aes(fill=..density..), geom="tile", contour=FALSE) +
  scale_fill_gradient2(low="navyblue", mid="yellow", high="red", midpoint=0.0015) +
  ## limit scale ( density is calculated on the limited scale, all other points are removed from calculation)
  #xlim(0,1) +
  #ylim(0,1) +
  ## limit view area ( density is calcluated on all points, no points removed )
  coord_cartesian(xlim = c(0, 100), ylim=c(0,100)) +
  xlab("C01 % Methylation") +
  ylab("C02 % Methylation") +
  ## add points to the density map (comment it if not desired)
  geom_point(size=0.1, colour="white",shape=1, alpha=0) +
  ## make a line from (0,0) - (1,1)
  #geom_segment(aes(x=0, y=0, xend=1, yend=1)) +
  ## or just create a abline with slope 1 and intercept 0
  #geom_abline() +
  t2+
  ggtitle("DNA methylation in HF in highly correlated accros two individuals") +
  theme(plot.title = element_text(hjust = 0.5))

DF2d_HF<-DF2d
DF2d_HF$Residual_HF <- DF2d_HF$Avg.Methylation.x - DF2d_HF$Avg.Methylation.y
#######################

CO1_PBL<-read.csv("./create_plots/C01_PBL_1_chr19.bismark.bins.csv")
CO2_PBL<-read.csv("./create_plots/C02_PBL_1_chr19.bismark.bins.csv")

DF2d_PBL<-merge(CO2_PBL,CO1_PBL,by = "Bin.Name")
DF2d_PBL$Residual_PBL <- DF2d_PBL$Avg.Methylation.x - DF2d_PBL$Avg.Methylation.y
DF2d_PBL$X.x <- NULL
DF2d_PBL$X.y <- NULL


residual <- merge(DF2d_PBL,DF2d_HF,by = "Bin.Name")
plot(residual$Residual_PBL,residual$Residual_HF)


z <- kde2d(residual$Residual_PBL, residual$Residual_HF,n = 4)

ggplot(residual, aes(residual$Residual_PBL, y=residual$Residual_HF)) +
  stat_density2d(aes(fill=..density..), geom="tile", contour=FALSE) +
  scale_fill_gradient2(low="darkgreen", mid="yellow", high="red", midpoint=0.001) +
  ## limit scale ( density is calculated on the limited scale, all other points are removed from calculation)
  #xlim(0,1) +
  #ylim(0,1) +
  ## limit view area ( density is calcluated on all points, no points removed )
  coord_cartesian(xlim = c(-100, 100), ylim=c(-100,100)) +
  xlab("PBL residual") +
  ylab("HF residual") +
  ## add points to the density map (comment it if not desired)
  geom_point(size=0.1, colour="white",shape=1, alpha=0) +
  ## make a line from (0,0) - (1,1)
  #geom_segment(aes(x=0, y=0, xend=1, yend=1)) +
  ## or just create a abline with slope 1 and intercept 0
  #geom_abline() +
  t2 + 
  ggtitle("Residuals (C01-C02) in HF vs PBL") +
  theme(plot.title = element_text(hjust = 0.5))



