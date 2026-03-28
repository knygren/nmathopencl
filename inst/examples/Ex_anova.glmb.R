set.seed(333)
## Dobson (1990) Page 93: Randomized Controlled Trial :
counts <- c(18, 17, 15, 20, 10, 20, 25, 13, 12)
outcome <- gl(3, 1, 9)
treatment <- gl(3, 3)

ps <- Prior_Setup(counts ~ outcome + treatment, family = poisson())
glmb.D93 <- glmb(
  counts ~ outcome + treatment,
  family = poisson(),
  pfamily = dNormal(mu = ps$mu, Sigma = ps$Sigma)
)
summary(glmb.D93)

# anova for Bayesian Model
# Sequential classical ANOVA (see glm anova below): adding outcome reduces residual deviance;
# adding treatment barely changes it.
# By DIC, the model with outcome but not treatment has the lowest DIC;
# treatment does not improve the criterion.
# Use of traditional anova is questionable in a Bayesian context.
# One may instead use Bayes factors or other approaches.
anova(glmb.D93)


glm.D93 <- glm(counts ~ outcome + treatment, family = poisson())
summary(glm.D93)

# corresponding
anova(glm.D93)
