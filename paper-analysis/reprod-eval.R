## Statistical analysis in paper
## Author: Adam Brentnall
## Date: 30th October 2023

## Libraries
library("tidyverse")
library(RColorBrewer)
library("ggpubr")

## Functions

fn.summarise.dta3 <- function(mydta, mylen=c(2,3,6)){

    mydta$idx<-mydta$riskgroupidx*mydta$num

    mydta$idx[mydta$idx==0]<-NA

    myout<-list()
    
    idy<-0
    
    myh<-sort(unique(mydta$h))
    
    for(idx in myh){
        ##print(idx)
        idy<-idy+1
        ind<-mydta[mydta$h==idx,]
        ##print(ind)
        myout[[idy]]<-tapply(ind$idx,ind$strategy, min,na.rm=TRUE)-1
        myout[[idy]][is.infinite(myout[[idy]])]<-NA
    }

    ##3strat (call them 1 - 2 - 3)    
    mycut<-t(matrix(unlist(myout),nrow=3))
    
    my1y<-100-mycut[,1] #interval 1
    
    my1y[is.infinite(my1y)]<-0
    
    my1y[is.na(my1y)]<-0

    my3y<-mycut[,2] - mycut[,3] #interval 3
    
    my3y[is.infinite(my3y)]<-0
    
    my3y[is.nan(my3y)]<-0
    
    my3y[is.na(my3y)]<-0

    my2y<-(100-my1y)-my3y

    my2y[is.infinite(my2y)]<-0

    myplotdta<-data.frame(pc=c(my1y, my2y, my3y), interval=as.factor(rep(mylen, each=length(my1y))), h=rep(myh,3)/200)

    myplotdta <- myplotdta %>%
        filter(!is.infinite(pc)) %>%
        filter(!is.nan(pc)) %>%
        filter(h>0.5)

    myplotdta
    
    }

##4 strategies
fn.summarise.dta4<-function(mydta, mylen=c(1,2,3,6)){

    mydta$idx<-mydta$riskgroupidx*mydta$num

    mydta$idx[mydta$idx==0]<-NA

    myout<-list()
    
    idy<-0
    
    myh<-sort(unique(mydta$h))
    
    for(idx in myh){
    
        idy<-idy+1

        ind<-mydta[mydta$h==idx,]
    
        myout[[idy]]<-tapply(ind$idx,ind$strategy, min,na.rm=TRUE)-1
        
        myout[[idy]][is.infinite(myout[[idy]])]<-NA
    }

    ##4strat
    mycut<-t(matrix(unlist(myout),nrow=4))

    my1y<-100-mycut[,1] #1y
    my1y[is.infinite(my1y)]<-0
    my1y[is.na(my1y)]<-0

    my4y<-mycut[,3] - mycut[,4] #6y
    my4y[is.infinite(my4y)]<-0
    my4y[is.nan(my4y)]<-0
    my4y[is.na(my4y)]<-0

    my3y<-mycut[,2]-my4y
    my3y[is.infinite(my3y)]<-0

    my2y<-(100-my1y)-mycut[,2] 
    my2y[is.infinite(my2y)]<-0

 
    myplotdta<-data.frame(pc=c(my1y, my2y, my3y, my4y), interval=as.factor(rep(mylen, each=length(my1y))), h=rep(myh,4)/200)


    myplotdta <- myplotdta %>%
        filter(!is.infinite(pc)) %>%
        filter(!is.nan(pc)) %>%
        filter(h>0.5)
}

## sensitivity analysis
fn.preparedat<-function(infile, inadj, inname){
    myadv134_a42<-read_csv(infile)

    myadv134_a42[1:46,2]<-NA
    myadv134_a42[1:46,3]<-NA
    
    myall<-myadv134_a42[,1:3]

    myall$option<-rep(inname, nrow(myadv134_a42))

    colnames(myall)<-c("idx", "h", "advcan", "Scenario")

    myall$h<-myall$h/200

    myall$advcan<-myall$advcan/inadj

    myall<-myall %>%
        filter(!is.na(h))

    myall
    
}

## Analysis

## load output file
mydta<-read_csv("data/out236.csv")
myplotdta.236<-fn.summarise.dta3(mydta, c(2,3,6))

mydta<-read_csv("data/out134.csv")
myplotdta.134<-fn.summarise.dta3(mydta, c(1,3,4))

mydta<-read_csv("data/out136.csv")
myplotdta.136<-fn.summarise.dta3(mydta, c(1,3,6))

mydta<-read_csv("data/out1236.csv")
myplotdta.1236<-fn.summarise.dta4(mydta, c(1,2,3,6))


##plot
myplot.236<-ggplot(myplotdta.236, aes(x=h, y=pc, fill=interval)) +
    geom_area() +
    scale_x_continuous(trans='log10') +
    xlab("Resource") +
    ylab("Percentage (%)")+
    geom_vline(xintercept = 1)+
    theme_bw(base_size = 24)

myplot.136<-ggplot(myplotdta.136, aes(x=h, y=pc, fill=interval)) +
    geom_area() +
    scale_x_continuous(trans='log10') +
    xlab("Resource") +
    ylab("Percentage (%)")+
    geom_vline(xintercept = 1)+
    theme_bw(base_size = 24)

myplot.134<-ggplot(myplotdta.134, aes(x=h, y=pc, fill=interval)) +
    geom_area() +
    scale_x_continuous(trans='log10') +
    xlab("Resource") +
    ylab("Percentage (%)")+
    geom_vline(xintercept = 1)+
    theme_bw(base_size = 24)

myplot.1236<-ggplot(myplotdta.1236, aes(x=h, y=pc, fill=interval)) +
    geom_area() +
    scale_x_continuous(trans='log10') +
    xlab("Resource") +
    ylab("Percentage (%)")+
    geom_vline(xintercept = 1)+
    theme_bw(base_size = 24)

myallplot<-ggarrange(myplot.134, myplot.136, myplot.236, myplot.1236, labels=c("(a)", "(b)", "(c)", "(d)"), nrow=2, ncol=2)

##fig 3
ggsave("figures/fig3.pdf", myallplot, height=10, width=15) 
                     
#########################
## Fig 2

myadv1236<-read_csv("data/out2_1236.csv")
myadv236<-read_csv("data/out2_236.csv")
myadv136<-read_csv("data/out2_136.csv")
myadv134<-read_csv("data/out2_134.csv")

## not possible for these with only 4y screening
myadv134[1:46,2]<-NA
myadv134[1:46,3]<-NA

myall<-bind_rows(myadv1236, myadv236, myadv136, myadv134)[,1:3]

myall$option<-as.factor(rep(c("1236","236", "136","134"), each=nrow(myadv1236)))

colnames(myall)<-c("idx", "h", "advcan", "option")

myall$h<-myall$h/200

myall$advcan<-myall$advcan/0.7367

myall2<-myall %>%
    filter(!is.na(h))

colnames(myall2)[4]<-"Options"

myresplot<-ggplot(myall2, aes(x=h, y=(advcan-1)*1000, group=Options)) +
    geom_line(aes(linetype=Options, color=Options), size=2) +
    geom_hline(yintercept = 1) +
    scale_x_continuous(trans='log10') +
    xlab("Resource vs triannual") +
    ylab("Change in advanced cancers per 1000 cancers") +
    theme_bw(base_size = 24)

ggsave("figures/fig2.pdf", myresplot, height=10, width=15) 

### Fig 4 - sensitivity analysis

adv3y<-c(0.7367, #baseline
         0.8909, # adv canc 3y all, 32%sd CANCER, 53% INTERVAL
         0.5826, # adv canc 3y all, 12%SD CANCER, 53% INTERVAL
         0.6671, # adv canc 3y all, 22%SD CANCER, 43% INTERVAL
         0.8118 # adv canc 3y all, 22%SD CANCER, 63% INTERVAL
         )

myall<-rbind(fn.preparedat("data/out2_134.csv", adv3y[1], "Base scenario"),
             fn.preparedat("data/out2_134_s32.csv", adv3y[2], "Screen detected N+ 32%"),
             fn.preparedat("data/out2_134_s12.csv", adv3y[3], "Screen detected N+ 12%"),
             fn.preparedat("data/out2_134_i42.csv", adv3y[4], "Interval cancer N+ 43%"), 
             fn.preparedat("data/out2_134_i62.csv", adv3y[5], "Interval cancer N+ 63%"),
             fn.preparedat("data/out2_134_plus5pcsd.csv", 0.7012, "+5% screen detection"),
             fn.preparedat("data/out2_134_less5pcsd.csv", 0.7723, "-5% screen detection"),
             fn.preparedat("data/out2_134_3ybetter.csv", 0.7367, "-5% screen detection 1y,4y only")
             )

myall$ltype<-1+as.integer(as.factor(myall$Scenario))
myall$ltype[myall$Scenario=="Base scenario"]<-1
myall$ltype<-as.character(myall$ltype)

#define custom color scale
myall$Scenario<-as.factor(myall$Scenario)
myall$Scenario<-relevel(myall$Scenario, ref="Base scenario")
myColors <- brewer.pal(8, "Spectral")
names(myColors) <- levels(as.factor(myall$Scenario))
custom_colors <- scale_colour_manual(name = "Scenario", values = myColors)

myresplot<-ggplot(myall, aes(x=h, y=(advcan-1)*1000, group=Scenario)) +
    geom_line(aes(linetype=Scenario, color=Scenario), size=2) +
    geom_hline(yintercept = 1) +
    scale_x_continuous(trans='log10') +
    xlab("Resource vs triannual") +
    ylab("Change advanced cancers per 1000 cancers") +
    theme_bw(base_size = 24)+
    custom_colors

ggsave("figures/fig4.pdf", myresplot, height=10, width=15) 

##reductions in advanced cancers per 1000
myred<-myall %>%
    filter(h==1) %>%
    select(advcan) %>%
    c() %>%
    unlist()

1000*(1-sort(myred))

round(1000*(1-(myred)))

###########
## histogram figure 1
mydf2<- read_csv("data/histo.csv")
mydf2$Subject <- relevel(as.factor(mydf2$Subject), ref="Control")

myplt<-ggplot(mydf2, aes(x=Risk,y=p, fill=Subject)) +
    geom_bar(stat="identity",        position = position_dodge2(width=1)) +
        ylab("Percentage (%)") +
    xlab("Mirai 3y risk (%)") +
    scale_fill_grey()+
    theme_bw(base_size = 24)

ggsave("figures/fig1.pdf",myplt,height=10, width=15) 
