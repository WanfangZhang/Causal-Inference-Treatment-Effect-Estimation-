###############################################
# causal_analysis.R (single-file, end-to-end)
# Methods:
# 1) Propensity Score Matching (PSM)
# 2) IPTW + Weighted Regression + Doubly Robust
# 3) TMLE
# 4) Bayesian ATE (brms)
###############################################

# --- packages (assume installed) ---
library(MatchIt)
library(cobalt)
library(tableone)
library(dplyr)
library(ggplot2)
library(WeightIt)
library(survey)
library(tmle)
library(SuperLearner)
library(brms)
library(bayesplot)
library(readr)
library(broom)
library(ggridges)

# --- create output folders if not exist ---
dir.create("tables", showWarnings = FALSE)
dir.create("figures", showWarnings = FALSE)

# --- load data ---
data("lalonde", package = "MatchIt")
df=lalonde

# create dummy race vars
df=df %>%
  mutate(
    black = ifelse(race == "black", 1, 0),
    hispan = ifelse(race == "hispan", 1, 0),
    white = ifelse(race == "white", 1, 0)
  )

###############################################################
# 1) Propensity Score Matching (PSM)
###############################################################

fmla=treat ~ age + educ + black + hispan + married + nodegree + re74 + re75

m.out=matchit(fmla, data = df, method = "nearest", distance = "logit", caliper = 0.2)
matched=match.data(m.out)

psm_att=with(matched, mean(re78[treat == 1]) - mean(re78[treat == 0]))

bal_psm=bal.tab(m.out)$Balance
readr::write_csv(as.data.frame(bal_psm), file.path("tables", "balance_psm.csv"))

readr::write_csv(matched, file.path("tables", "matched_data_psm.csv"))

psm_res=data.frame(method = "PSM (ATT)", estimand = "ATT", estimate = psm_att)
readr::write_csv(psm_res, file.path("tables", "psm_result.csv"))

lp=love.plot(m.out, stats = "mean.diffs", binary = "std", abs = TRUE, var.order = "unadjusted")
if (inherits(lp, "ggplot")) {
  ggsave(filename = file.path("figures", "love_plot.png"), plot = lp, width = 9, height = 6, dpi = 300)
} else {
  png(file.path("figures", "love_plot.png"), width = 900, height = 600)
  print(lp)
  dev.off()
}

###############################################################
# 2) IPTW + Weighted Regression + Doubly Robust (DR)
###############################################################

w.out=weightit(
  treat ~ age + educ + black + hispan + married + nodegree + re74 + re75,
  data = df, method = "ps", estimand = "ATE"
)

bal_iptw=bal.tab(w.out)$Balance
readr::write_csv(as.data.frame(bal_iptw), file.path("tables", "balance_iptw.csv"))

svy.df=svydesign(ids = ~1, data = df, weights = ~ w.out$weights)

iptw_mean_treated=svymean(~re78, subset(svy.df, treat == 1))
iptw_mean_control=svymean(~re78, subset(svy.df, treat == 0))
iptw_ate=as.numeric(coef(iptw_mean_treated) - coef(iptw_mean_control))

iptw_var_treated=as.numeric(attr(iptw_mean_treated, "var"))
iptw_var_control=as.numeric(attr(iptw_mean_control, "var"))
iptw_se=sqrt(iptw_var_treated + iptw_var_control)

iptw_res=data.frame(method = "IPTW", estimand = "ATE", estimate = iptw_ate, se = iptw_se)
readr::write_csv(iptw_res, file.path("tables", "iptw_result.csv"))

fit_dr=svyglm(re78 ~ treat + age + educ + black + hispan + married + nodegree + re74 + re75,
                 design = svy.df)
dr_coef=broom::tidy(fit_dr) %>% filter(term == "treat") %>%
  transmute(method = "DR (weighted regression)", estimand = "ATE", estimate = estimate, std.error = std.error, p.value = p.value)
readr::write_csv(dr_coef, file.path("tables", "dr_result.csv"))

dr_effect=dr_coef$estimate

###############################################################
# 3) Targeted Maximum Likelihood Estimation (TMLE)
###############################################################

Y=df$re78
A=df$treat
W=df %>% select(age, educ, black, hispan, married, nodegree, re74, re75)

tmle_fit=tmle(
  Y = Y, A = A, W = W,
  Q.SL.library = c("SL.glm", "SL.mean"),
  g.SL.library = c("SL.glm")
)

tmle_ate =as.numeric(tmle_fit$estimates$ATE$psi)
tmle_ci  =tmle_fit$estimates$ATE$CI
tmle_pval=tmle_fit$estimates$ATE$pvalue

tmle_res=data.frame(method = "TMLE", estimand = "ATE", estimate = tmle_ate,
                       ci_lower = tmle_ci[1], ci_upper = tmle_ci[2], p_value = tmle_pval)
readr::write_csv(tmle_res, file.path("tables", "tmle_result.csv"))

tmle_df_plot=data.frame(method = "TMLE", estimate = tmle_ate, ci_low = tmle_ci[1], ci_high = tmle_ci[2])
p_tmle=ggplot(tmle_df_plot, aes(x = method, y = estimate)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = ci_low, ymax = ci_high), width = 0.2) +
  labs(title = "TMLE ATE estimate", y = "ATE (re78)", x = "") +
  theme_minimal()
ggsave(filename = file.path("figures", "tmle_results.png"), plot = p_tmle, width = 6, height = 4, dpi = 300)

###############################################################
# 4) Bayesian ATE (brms)
###############################################################

set.seed(2025)
n=800
W1=rnorm(n)
W2=rbinom(n, 1, 0.4)
A_sim=rbinom(n, 1, plogis(0.5*W1 - 0.3*W2))
Y_sim=1 + 2*A_sim + 1.2*W1 - 1*W2 + rnorm(n)
df_sim=data.frame(Y = Y_sim, A = A_sim, W1 = W1, W2 = W2)

fit_bayes=brm(Y ~ A + W1 + W2, data = df_sim,
                 chains = 2, iter = 2000, seed = 2025, refresh = 0)

post=posterior_samples(fit_bayes, pars = "b_A")
readr::write_csv(post, file.path("tables", "bayes_posterior_samples.csv"))

bayes_summary=data.frame(mean = mean(post$b_A), sd = sd(post$b_A))
readr::write_csv(bayes_summary, file.path("tables", "bayes_A_summary.csv"))

p_bayes=mcmc_areas(as.matrix(post), probs = c(0.5, 0.8, 0.95)) +
  ggtitle("Posterior distribution for treatment effect (b_A)")
ggsave(filename = file.path("figures", "bayes_posterior.png"), plot = p_bayes, width = 7, height = 5, dpi = 300)

###############################################################
# Save combined summary table
###############################################################

results=data.frame(
  Method = c("PSM ATT", "IPTW ATE", "DR ATE", "TMLE ATE", "Bayesian ATE mean"),
  Estimate = c(
    as.numeric(psm_att),
    as.numeric(iptw_ate),
    as.numeric(dr_effect),
    as.numeric(tmle_ate),
    as.numeric(bayes_summary$mean)
  )
)

readr::write_csv(results, file.path("tables", "causal_results_summary.csv"))

cat("Causal inference analysis completed.\nOutputs saved under ./tables and ./figures\n")
