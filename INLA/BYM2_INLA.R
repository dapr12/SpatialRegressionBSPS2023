# Clear the R environment
rm(list = ls())

# Load necessary packages
library(tidyverse)
library(spdep)
library(INLA)
library(rstan)
library(ggplot2)
library(patchwork)

# Enable auto_write option for rstan
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# Set the working directory
setwd("/Users/user/Dropbox/Mac (2)/Desktop/Workshop Files/Data Files")

# Load data
load("India_Employment_withCensus2011_SampleSize.rda")

# Set a different working directory
setwd("/Users/user/Dropbox/Mac (2)/Desktop/Workshop Files/Census_2011")
India_Districts <- st_read("2011_Dist.shp")

# Disable S2 for sf package
sf::sf_use_s2(FALSE)

# Extract geometry
sp <- India_Districts$geometry

# Create a blank plot with a black-and-white theme
ggplot() + geom_sf(data = sp, fill = NA) + theme_bw()

# Define the neighbor structure
W.nb <- poly2nb(sp)
nb2INLA("W.adj", W.nb)

# Data list for Stan
n <- nrow(India_Districts)

# Join data frames
India_Data_Employment_Census2011 <- left_join(India_Districts, India_Sample_Employment, by = "censuscode")

# Fill missing values with zero
India_Data_Employment_Census2011$Freq_State[is.na(India_Data_Employment_Census2011$Freq_State)] <- 0
India_Data_Employment_Census2011$Prop_Females[is.na(India_Data_Employment_Census2011$Prop_Females)] <- 0
India_Data_Employment_Census2011$Prop_Rural[is.na(India_Data_Employment_Census2011$Prop_Rural)] <- 0

# Rename columns
names(India_Data_Employment_Census2011)
India_Data_Employment_Census2011$ID <- seq(1:nrow(India_Data_Employment_Census2011))

# Create plots and store them in p1 and p2
ggplot() + geom_sf(data = India_Data_Employment_Census2011, aes(fill = Prop_Rural), col = NA) + scale_fill_viridis_c() + theme_bw() -> p1
ggplot() + geom_sf(data = India_Data_Employment_Census2011, aes(fill = Prop_Males), col = NA) + scale_fill_viridis_c() + theme_bw() -> p2

# Combine p1 and p2
p1 | p2

# Define a formula for the INLA model
formula <- India_Data_Employment_Census2011$Freq_State ~ 1 + f(ID, model = "bym2", graph = "W.adj", scale.model = TRUE, constr = TRUE,
                                                               # priors
                                                               hyper = list(theta1 = list("PCprior", c(1, 0.01)),
                                                                            theta2 = list("PCprior", c(0.5, 0.5)))
)

# Fit the INLA model
strokes_DM <- inla(formula, data = India_Data_Employment_Census2011, family = "poisson",
                   control.predictor = list(compute = TRUE),
                   control.inla = list(strategy = "laplace", fast = FALSE),
                   control.compute = list(dic = TRUE, waic = TRUE),
                   verbose = TRUE, debug = TRUE, silent = FALSE)

# Summarize the model
summary(strokes_DM)

# Plot the model
plot(strokes_DM)

# Create a plot for the posterior of the mixing parameter
ggplot() + geom_line(data = as.data.frame(strokes_DM$marginals.hyperpar$`Phi for ID`),
                     aes(x = x, y = y)) + theme_bw() +
  ggtitle("Posterior of sd of the mixing parameter")

# Add the posterior to the dataset
India_Data_Employment_Census2011$sp_eco <- strokes_DM$summary.random$ID$`0.5quant`[1:641]

# Create a plot with the spatial field
ggplot() + geom_sf(data = India_Data_Employment_Census2011, aes(fill = sp_eco), col = NA) + theme_bw() +
  scale_fill_viridis_c()

# Get summary of hyperparameters
strokes_DM$summary.hyperpar

# Compute posterior of the spatial field
sd_mar <- as.data.frame(inla.tmarginal(function(x) exp(-1/2*x),
                                       strokes_DM$internal.marginals.hyperpar$`Log precision for ID`))
head(sd_mar)

# Create plots for posterior of the spatial field and mixing parameter
ggplot() + geom_line(data = sd_mar, aes(x = x, y = y)) + theme_bw() +
  ggtitle("Posterior of sd of the spatial field") -> p1

ggplot() + geom_line(data = as.data.frame(strokes_DM$marginals.hyperpar$`Phi for ID`),
                     aes(x = x, y = y)) + theme_bw() +
  ggtitle("Posterior of sd of the mixing parameter") -> p2

# Combine p1 and p2
p1 | p2

# Add the spatial field to the dataset
India_Data_Employment_Census2011$sp <- strokes_DM$summary.random$ID$`0.5quant`[1:641]

# Compute exceedance probabilities
threshold <- log(1)
exceed.prob <- lapply(X = strokes_DM$marginals.random$ID[1:641], FUN = function(x) inla.pmarginal(marginal = x, threshold))
exceed.prob <- 1 - unlist(exceed.prob)

# Create a boxplot of exceedance probabilities
ggplot() + geom_boxplot(data = as.data.frame(exceed.prob), aes(y = exceed.prob)) +
  geom_hline(yintercept = 0.95, col = "red") + theme_bw() + xlim(c(-0.6, 0.6)) +
  ylab("") +
  theme(axis.text.x = element_blank()) -> p1

# Add exceedance probabilities to the dataset
India_Data_Employment_Census2011$ex <- exceed.prob

# Select data points with exceedance probability >= 0.95
temp.ex <- India_Data_Employment_Census2011[India_Data_Employment_Census2011$ex >= 0.95,]

# Create a plot with exceedance probabilities
ggplot() + geom_sf(data = India_Data_Employment_Census2011, aes(fill = ex), col = NA) + scale_fill_viridis_c() +
  geom_sf(data = temp.ex, col = "red", fill = NA) + theme_bw() -> p2

# Combine p1 and p2 with a plot annotation
(p1 | p2) + plot_annotation(title = "Posterior probability")

# Fit an alternative model with an unstructured random effect
formula_2 <- y ~ 1 + f(ID, model = "iid", constr = TRUE,
                       hyper = list(theta = list("PCprior", c(1, 0.01))))

strokes_DM_unstr <- inla(formula_2, data = stroke,
                         family = "binomial", offset = Offset, Ntrials = pop,
                         control.compute = list(dic = TRUE, waic = TRUE), verbose = F)

# Compare DIC values between the two models
strokes_DM$dic$dic; strokes_DM_unstr$dic$dic
