# Clear the R environment
rm(list = ls())

# Load necessary packages
library(tidyverse)
library(spdep)
library(INLA)
library(rstan)


# Enable auto_write option for rstan
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())  


# Set the working directory
setwd("/Users/user/Dropbox/Mac (2)/Desktop/Workshop Files/Data Files")

# Load data
load("India_Employment_withCensus2011_SampleSize.rda")

# Set working directory for source file
setwd("/Users/user/Dropbox/Mac (2)/Desktop/Workshop Files/")
source("icar-functions.R")

# Load data
setwd("/Users/user/Dropbox/Mac (2)/Desktop/Workshop Files/Census_2011")
India_Districts <- st_read("2011_Dist.shp")

# Disable S2 for sf package
sf::sf_use_s2(FALSE)

# Extract geometry
sp <- India_Districts$geometry

# Prepare data for ICAR function in Stan
C <- spdep::nb2mat(spdep::poly2nb(sp, queen = TRUE), style = "B", zero.policy = TRUE)
icar.data <- prep_icar_data(C)

# Notice that the scale_factor is just ones.
icar.data$inv_sqrt_scale_factor

# Calculate the scale factor for each connected group of nodes using scale_c function
k <- icar.data$k
scale_factor <- vector(mode = "numeric", length = k)
for (j in 1:k) {
  g.idx <- which(icar.data$comp_id == j)
  if (length(g.idx) == 1) {
    scale_factor[j] <- 1
    next
  }
  Cg <- C[g.idx, g.idx]
  scale_factor[j] <- scale_c(Cg)
}

# Update the data list for Stan
icar.data$inv_sqrt_scale_factor <- 1 / sqrt(scale_factor)

# Display the new scale factors
print(icar.data$inv_sqrt_scale_factor)

# Data list for Stan
n <- nrow(India_Districts)

# Join data frames
India_Data_Employment_Census2011 <- left_join(India_Districts, India_Sample_Employment, by = "censuscode")

# Fill missing values with zero
India_Data_Employment_Census2011$Freq_State[is.na(India_Data_Employment_Census2011$Freq_State)] <- 0
India_Data_Employment_Census2011$Prop_Females[is.na(India_Data_Employment_Census2011$Prop_Females)] <- 0
India_Data_Employment_Census2011$Prop_Rural[is.na(India_Data_Employment_Census2011$Prop_Rural)] <- 0

# Define data list
dl <- list(
  n = nrow(India_Data_Employment_Census2011),
  y = India_Data_Employment_Census2011$Freq_State,
  x1 = India_Data_Employment_Census2011$Prop_Females,
  x2 = India_Data_Employment_Census2011$Prop_Rural,
  offset = rep(1, n),
  prior_only = 0
)

dl <- c(dl, icar.data)

# Set the working directory
setwd("/Users/user/Dropbox/Mac (2)/Desktop/Workshop Files")

# Compile the Stan model
BYM2 <- stan_model("BYM2.stan")

# Sample from the model
fit <- sampling(BYM2, data = dl, chains = 4, cores = 4,
                control=list(adapt_delta = 0.97, stepsize = 0.1),
                warmup=9000, iter=10000, save_warmup=FALSE)

# View some results
summary(fit)

print(fit, pars=c("alpha", "beta1", "beta2"), probs=c(0.025, 0.5, 0.975));


# View some results from the joint prior probability
plot(fit, pars = "phi_tilde")
plot(fit, pars = "convolution")
plot(fit, pars = "spatial_scale", plotfun = "hist")
plot(fit, pars = "rho", plotfun = "hist")

# Calculate the degree of spatial autocorrelation (SA) in the convolution term
convolution <- as.matrix(fit, pars = "convolution")
sa <- apply(convolution, 1, mc, w = C)
hist(sa)

# Create a simple map of the posterior mean of the convolution term
spx <- st_as_sf(sp)
spx$convolution <- apply(convolution, 2, mean)
plot(spx[, "convolution"])



# Calculate D_diag and phi.var for plotting
D_diag <- rowSums(C)
phi.samples <- as.matrix(fit, pars = "phi_tilde")
phi.var <- apply(phi.samples, 2, var)

# Plot a map
ggplot(India_Districts) +
  geom_sf(aes(fill = log(phi.var))) +
  scale_fill_gradient(
    low = "white",
    high = "darkred"
  )

