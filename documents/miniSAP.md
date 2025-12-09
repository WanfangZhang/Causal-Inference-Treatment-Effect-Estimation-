# Mini Statistical Analysis Plan (SAP)
## Causal Inference — Treatment Effect Estimation

Project: Causal Inference Treatment Effect Estimation  
Code: code/demo code.R  
Data: Lalonde dataset from MatchIt; simulated dataset for Bayesian module  

------------------------------------------------------------
Methods
------------------------------------------------------------

1 Propensity Score Estimation  

Propensity score is defined as:

$$
e(X) = P(A = 1 \mid X)
$$

Estimated via logistic regression using covariates:
(age, educ, black, hispan, married, nodegree, re74, re75).

Used for: matching, weighting, DR, and TMLE.

------------------------------------------------------------

2 Propensity Score Matching (PSM)

Matching uses nearest-neighbor 1:1 with caliper = 0.2 (logit scale).

ATT estimator:

$$
ATT = \frac{1}{n_1} \sum_{i:A_i=1} \left( Y_i - Y_{j(i)} \right)
$$

Outputs:
- matched dataset  
- covariate balance table  
- Love plot  

------------------------------------------------------------

3 Inverse Probability of Treatment Weighting (IPTW)

Weights:

For treated:

$$
w_i = \frac{1}{e(X_i)}
$$

For control:

$$
w_i = \frac{1}{1 - e(X_i)}
$$

ATE estimator:

$$
ATE_{IPTW}
= \frac{\sum_i w_i A_i Y_i}{\sum_i w_i A_i}
 - \frac{\sum_i w_i (1-A_i) Y_i}{\sum_i w_i (1-A_i)}
$$

Outputs:
- weighted covariate balance  
- IPTW estimate  

------------------------------------------------------------

4 Doubly Robust Estimator (DR)

Outcome regression:

$$
E[Y \mid A, X] = \beta_0 + \beta_A A + f(X)
$$

Estimator is consistent if **either**:
- PS model is correct, OR  
- outcome model is correct.

DR effect estimate is the coefficient associated with \(A\), adjusted via IPTW.

------------------------------------------------------------

5 Targeted Maximum Likelihood Estimation (TMLE)

Initial estimate:

$$
Q_0 = E[Y \mid A, X]
$$

Targeting step:

$$
Q^\* = Q_0 + \epsilon \, H(A, X)
$$

Final ATE:

$$
ATE_{TMLE} = \text{mean}\left( Q^\*(1,X) - Q^\*(0,X) \right)
$$

Outputs:
- ATE  
- 95% CI  
- p-value  
- TMLE visualization  

------------------------------------------------------------

6 Bayesian ATE Estimation (brms)

Bayesian regression model:

$$
Y = \beta_0 + \beta_A A + \beta_1 W_1 + \beta_2 W_2 + \epsilon
$$

Posterior treatment effect:

$$
ATE_{Bayes} = E[\beta_A \mid \text{data}]
$$

Outputs:
- posterior samples  
- posterior summary  
- posterior density plot  

------------------------------------------------------------
Output Specifications
------------------------------------------------------------

#  Key Figures (Visual Outputs)

| Description | File |
|------------|------|
| Love Plot — Covariate Balance (PSM) | [love_plot.png](/figures/love_plot.png) |
| TMLE ATE Estimate (with 95% CI) | [tmle_results.png](/figures/tmle_results.png) |
| Bayesian Posterior Distribution (ATE) | [bayes_posterior.png](/figures/bayes_posterior.png) |

---

#  Detailed CSV Results 

| Description | File |
|------------|------|
| PSM Balance Table | [balance_psm.csv](/tables/balance_psm.csv) |
| Matched Dataset (PSM) | [matched_data_psm.csv](/tables/matched_data_psm.csv) |
| PSM ATT Result | [psm_result.csv](/tables/psm_result.csv) |
| IPTW Balance Table | [balance_iptw.csv](/tables/balance_iptw.csv) |
| IPTW ATE Result | [iptw_result.csv](/tables/iptw_result.csv) |
| Doubly Robust Result | [dr_result.csv](/tables/dr_result.csv) |
| TMLE ATE Result | [tmle_result.csv](/tables/tmle_result.csv) |
| Bayesian Posterior Samples | [bayes_posterior_samples.csv](/tables/bayes_posterior_samples.csv) |
| Bayesian Summary | [bayes_A_summary.csv](/tables/bayes_A_summary.csv) |
| Combined Summary | [causal_results_summary.csv](/tables/causal_results_summary.csv) |

---

------------------------------------------------------------
Software
------------------------------------------------------------

R packages:
MatchIt, WeightIt, survey, tmle, SuperLearner, brms, bayesplot, ggplot2, dplyr

Reproducibility:
[demo_code.R](/code/demo_code.R)

------------------------------------------------------------
Notes
------------------------------------------------------------

This Mini SAP is designed for documentation, reproducibility, and interview demonstration.  
Its structure mirrors analysis plans used in real-world biostatistics and RWE workflows.
