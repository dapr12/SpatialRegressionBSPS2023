#Authors 2023
#Diego Perez Ruiz has written this code in 2021/2022.   
#A few minor amendments by Wendy Olsen help us access data for different 
#age groups, years, or sex.

#Furthermore, the advisor on all the materials is Arkadiusz Wisniowski,
#and the research assistant in 2021/22 was Madhu Chauhan.

#We thank the funder, University of Manchester - School of Social Sciences. 


# Clear the workspace
rm(list=ls())

# Load required libraries
library(tidyverse)
library(arm)
library(MASS)
library(lme4)
library(performance)
library(ggeffects)
library(sjPlot)
library(tidyverse)

# Set the working directory to the specified path
setwd("/Users/user/Dropbox/Mac (2)/Desktop/Workshop Files/Data Files")
# Load data from files
 Indiaraw <- readRDS("IndiaPLFS201718.rds")
 

set.seed(123456)
N <- 35000
Indiaraw <- Indiaraw[sample(nrow(Indiaraw), N), ]


#   Archive: in previous 2022 round we used this file instead. Indiaraw <- read_csv("data/sampledPLFS201718.rds")
Indiaraw %>% count(female)

# filter out very few cases of other or missing sex
Indiaraw <- Indiaraw %>% filter( sex != "3")

head(Indiaraw)

#note in the questionnaire, (rural =1, urban =2)

India_Employment<-Indiaraw
India_Employment$female<- factor(India_Employment$female, levels = c("Female"=1, "Male"=0), labels =c("Female", "Male"))
India_Employment$rural<- factor(India_Employment$rural, levels = c("Rural"=1, "Urban"=0), labels = c("Rural", "Urban"))

#seek missing values on rural and recode them to rural.  It's not necessary.

error1 <- India_Employment %>% group_by(state) %>% 
  dplyr::summarize(newcount = sum(is.na(rural)))
rm(error1)

#none missing, so no cleaning now.  CLEAN if necessary with care
#   VIA tempdata2 <- tempdata %>% mutate(relation_head = ifelse(is.na(relation_head), 9, relation_head ))  

#******************Here, you can choose to use only certain age groups, or just one sex.* * * * 
#********************Here, in the 2023 workshop we use ages 16 to 30 and both sexes.* * * * 

summary(India_Employment$rural)
summary(India_Employment$female)
summary(India_Employment$age)
India_Employmentbak<-India_Employment
India_Employment <- India_Employment[India_Employment$age<31&India_Employment$age>15,]
summary(India_Employment$age)
hist(India_Employment$age)

table(India_Employment$rural, India_Employment$female)

ggplot(data=India_Employment)+
  geom_bar(mapping=aes(x=female), na.rm=TRUE)

ggplot(data=India_Employment)+
  geom_bar(mapping=aes(x=rural), na.rm=TRUE)

ggplot(data=India_Employment)+
  geom_bar(mapping=aes(x=rural), na.rm=FALSE)

India_Employment$sex<- as.numeric(as.character(India_Employment$sex))

#Check the variables for their correlations and distributions.  Look for outliers. Adjust.
ggplot(data=India_Employment)+
  geom_bar(mapping=aes(x=rural))

ggplot(data=India_Employment)+
  geom_bar(mapping=aes(x=female))

with( India_Employment, hist(logRsincpc, bins=50))

India_Employment %>% count(medwork)
India_Employment %>% count(sex)

#1 is males and 2 is females, as seen in the Annual Report of PLFS 2017/18. 
#We desire a numeric variable. Do not use this in regression.

India_Employment <- subset(India_Employment, is.na(India_Employment$medwork)==FALSE)
India_Employment %>% count(age)
head(India_Employment)
str(India_Employment)

#Analysis of correlation via numerical vectors. Sex is numeric and female is a factor so use sex.
#     Rural is a factor but we construct a numeric equivalent, noting 0 means urban.

df <- India_Employment
df$sector = 0
df$sector[df$rural=="Rural"]=1
head(df)
summary(df$sector)

#continue with cleaning into numeric variables as prep for correlation matrix.
#

head(df)
summary(df)
mycorr <- cor(df[, c(10, 6, 7, 11, 12, 13, 14, 15)])
print(mycorr, digits=2)
#write.csv(mycorr, "basiccorr.csv")

#Could make a prettier correlation matrix
library(Hmisc)
cc <- Hmisc::rcorr(as.matrix(mycorr))
s <- format(round(cc$r, 3), digits = 3)
## add symbols
fstr <- function(x) {
  x[is.na(x)] <- 1
  symnum(x, cutpoints = c(0,0.001, 0.01, 0.05, 0.1,1),
         symbols = c("***", "**", "*","+", " "))
}
s[] <- paste0(s, fstr(cc$P))
print(s, quote = FALSE)
#acknowledging Ben Bolker at URL https://stackoverflow.com/questions/76589717/producing-a-correlation-matrix-with-3-decimal-points accessed June 2023.

#na.rm=TRUE, method=c("Pearson", "Spearman"))
# A stata or spss user will have numeric values with string labels in mind for each categorial variable.
# in R, the default is to have the actual strings repeated throughout all rows of the dataset. (A character variable,
# which in R is switched to a factor at the read_csv point.  But because Hadley Wickham changed his mind about it, this now does not
#happen automatically. So we have to declare each one a factor. Having done that, the labels are still no guaranteed.  So label them.

#but, remember that a label is not an attribute of a vector. It's just for convenience when doing some output in R.

#For more help with levels vs labels output from a factor, see url
#https://stackoverflow.com/questions/5869539/confusion-between-factor-levels-and-factor-labels
#and one could perhaps amend the input but allow default output into the findMethodSignatures(). 

#a more radical solution is to change the data, adapting each value to its label using fct_recode. See Chapter 12, 1st ed. R for Data Science 

#If one wants to order the levels in a particular way, or order by frequency, see URL https://r4ds.had.co.nz/factors.html
glimpse(India_Employment$rural)
unique(India_Employment$rural)

# Descriptive Statistics - Summary Tables 

# Do for the complete dataset.  
#The code provided below gives a 95% bootstrapped confidence interval which is symmetric around the mean.
#If we are being consistently Bayesian we may use this bootstrap method as a substitute for p-value-type C.I.s. 
#see URL https://data-se.netlify.app/2018/06/10/visualizing-summary-statistics-the-tidyverse-way/
#The graph below needs a numeric variable for each individual working. 

India_Employment$isinwork <- as.numeric(India_Employment$medwork)
ggplot(India_Employment, aes(age, isinwork, fill = factor(female)))+
  facet_wrap(rural~female)+
  stat_summary(fun.data = mean_cl_boot, geom = "errorbar")+
  theme_ggeffects()+
  labs(
    title = "Indian Proportion Who Were Working, by Sex within Rural/Urban",
    subtitle = "2017-2018 Periodic LFS, 95% interval via bootstrapping",
    x = "Age of Person",
    y = "Prevalence of Working"
  )


#################################################
######## GLM Models ########
#################################################

###note that the hhweight is combined weight across rural and urban cluster samples, hence, 'comb_wt'. 
###
#     #     #     #     #    One may adjust the equation to allow for better choice of variables. 
model <- glm(medwork ~ female + age + I(age^2) + I(age^3) + logRsincpc           ,
             data =India_Employment, family = "binomial")

summary(model)

#check the role of the hhold weights
model2 <- glm(medwork ~ female + age + I(age^2) + I(age^3) + logRsincpc + comb_wt,
              data =India_Employment, family = "binomial")

summary(model2)

tab_model(model,  p.style = "numeric", show.aic = T)

dim(India_Employment)


#Representation at District Level 

table( India_Employment$district )

#Representation at State level 

table( India_Employment$state )

# sex + age + I(age^2) + I(age^3) + rural + hhweight,
# my.lmer <- lmer(medwork ~ 1 + sex + age + (1 + sex + age | state), 
#                       data = India_Employment)


#my.lmer <-  glmer(medwork ~ 1 + (1 | state), 
#                  family =  binomial(logit), data = India_Employment)

#summary(my.lmer)

#my.lmer <-  glmer(medwork ~ 1 + female + (1 + female| state), 
#                  family =  binomial(logit), data = India_Employment)

#summary(my.lmer)

##################################################################
# ICC
##################################################################



# BRMS 
#  Poisson Model - 
#  1st Model - Usual Poisson Log Normal Regression (from BYM) - 
#  2nd Model - Poisson Log Normal with Random Effect ( + theta )
#  3rd Model - BYM ( + theta + phi ) 

library(brms)

m0.brms <- brm(data = India_Employment,
               family = bernoulli(link = logit),
               medwork ~ 1 + (1 | state),
               control=list(adapt_delta = 0.97, stepsize = 0.1),
               thin = 10, chains = 4, cores = 4, 
               warmup=9000, iter=10000, save_warmup=FALSE)
 

summary(m0.brms)

# extracting tau^2 for the varying intercept
tau2 <- brms::VarCorr(m0.brms)[[1]]$sd[1]^2

# computing the ICC for the intercept
ICC1 <- tau2 / (tau2 + (pi^2 / 3) )
ICC1


pairs(m0.brms)

icc(m0.brms, ppd = T)

#Approach 2 - Simulation

# extracting the model estimates
est <- brms::fixef(m0.brms)[,1]


# number of simulations
N <- 1e5

# drawing varying effects from the estimated distribution of varying effects
a_dpt <- rnorm(N, mean = est[1], sd = sqrt(tau2) )

# computing the ICC for females
# probability of the outcome
pA <- exp(a_dpt  ) / (1 + exp(a_dpt   ) )
# compute the Bernoulli level-1 residual variance
vA <- pA * (1 - pA)
# mean of Bernoulli variances
sA <- mean(vA)
# compute the ICC
ICC2 <- var(pA) / (var(pA) + sA)

ICC2

# Approach 3: Evaluate ICC

# evaluating pi at the mean of the distribution of the level 2 varying effect
p <- exp(est[1]) / (1 + exp(est[1] ) )

# computing var(p)
sig1 <- p * (1 - p)

# computing var(yij)
sig2 <- tau2 * p^2 * (1 + exp(est[1] ) )^(-2)

# computing the ICC
ICC3 <- sig2 / (sig1 + sig2)

ICC3


