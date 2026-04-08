###########################  Example for lmb function

## Annette Dobson (1990) "An Introduction to Generalized Linear Models".
## Page 9: Plant Weight Data.
ctl <- c(4.17,5.58,5.18,6.11,4.50,4.61,5.17,4.53,5.33,5.14)
trt <- c(4.81,4.17,4.41,3.59,5.87,3.83,6.03,4.89,4.32,4.69)
group <- gl(2, 10, 20, labels = c("Ctl","Trt"))
weight <- c(ctl, trt)

ps <- Prior_Setup(weight ~ group, family = gaussian())

lmb.D9 <- lmb(
  weight ~ group,
  pfamily = dNormal_Gamma(
    ps$mu,
    Sigma_0 = ps$Sigma_0,
    shape = ps$shape,
    rate  = ps$rate
  )
)
summary(lmb.D9)

###########################  Example for glmb function

## Dobson (1990) Page 93: Randomized Controlled Trial :
counts <- c(18,17,15,20,10,20,25,13,12)
outcome <- gl(3,1,9)
treatment <- gl(3,3)
print(d.AD <- data.frame(treatment, outcome, counts))

ps <- Prior_Setup(counts ~ outcome + treatment, family = poisson(), data = d.AD)

glmb.D93 <- glmb(
  counts ~ outcome + treatment,
  family  = poisson(),
  pfamily = dNormal(mu = ps$mu, Sigma = ps$Sigma)
)
summary(glmb.D93)

## Menarche logit model with default (non-informative) Prior_Setup prior
data(menarche, package = "MASS")
Age2 <- menarche$Age - 13

ps_m <- Prior_Setup(
  cbind(Menarche, Total - Menarche) ~ Age2,
  family = binomial(logit),
  data = menarche
)

glmb.out1 <- glmb(
  cbind(Menarche, Total - Menarche) ~ Age2,
  family  = binomial(logit),
  pfamily = dNormal(mu = ps_m$mu, Sigma = ps_m$Sigma),
  data    = menarche
)
summary(glmb.out1)

## Posterior mean fitted probabilities on response scale
require(graphics)
pred1 <- predict(glmb.out1, type = "response")
pred1_m <- colMeans(pred1)
plot(
  Menarche / Total ~ Age,
  data = menarche,
  main = "Proportion with menarche (data and posterior mean fit)"
)
lines(menarche$Age, pred1_m, col = "blue", lwd = 2)
