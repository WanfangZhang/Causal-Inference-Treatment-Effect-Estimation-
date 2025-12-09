# Mini Statistical Analysis Plan (SAP)
## Causal Inference — Treatment Effect Estimation

Project: Causal Inference Treatment Effect Estimation  
Code: code/demo code.R  
Data: Lalonde dataset from MatchIt; simulated dataset for Bayesian module  

------------------------------------------------------------
1. Objectives & Estimands
------------------------------------------------------------

Primary Objective:
Estimate the Average Treatment Effect (ATE).

Definition:
ATE = E[Y(1)] - E[Y(0)]

Secondary Objective:
Estimate the Average Treatment Effect on the Treated (ATT).

Definition:
ATT = E[Y(1) - Y(0) | A = 1]

Sensitivity Objectives:
- Compare estimates across PSM, IPTW, DR, TMLE, Bayesian
- Check robustness and covariate balance

------------------------------------------------------------
2. Analysis Populations
------------------------------------------------------------

Full Analysis Set (FAS):
All observations with non-missing treatment, outcome, and covariates.

Matched Set:
Units retained after 1:1 nearest-neighbor matching.

Weighted Set:
Units with valid IPTW weights (after optional trimming).

------------------------------------------------------------
3. Variables
------------------------------------------------------------

Treatment:
A (1 = treated, 0 = control)

Outcome:
Y (re78)

Confounders:
age, educ, black, hispan, married, nodegree, re74, re75  
(dummy variables generated from race)

------------------------------------------------------------
4. Methods
------------------------------------------------------------

4.1 Propensity Score Estimation  
PS = P(A = 1 | X), estimated via logistic regression.  
Used for matching, weighting, DR, and TMLE.

4.2 Propensity Score Matching (PSM)
- Nearest neighbor 1:1  
- Caliper 0.2  
- ATT estimated as mean(Y_treated - Y_matched_control)  
Outputs: matched dataset, balance tables, love plot

4.3 IPTW (Inverse Probability of Treatment Weighting)
Weights:
w = 1/PS for treated  
w = 1/(1 - PS) for control  

ATE estimated as weighted mean difference.  
Outputs: weighted balance, IPTW estimates

4.4 Doubly Robust Estimator (DR)
Outcome regression plus IPTW weights.  
Consistent if either PS model OR outcome model correct.  
Output: DR estimate

4.5 TMLE
Combines outcome model (Q) and PS model (g).  
Outputs: ATE, CI, p-value, TMLE plot

4.6 Bayesian ATE (brms)
Model:
Y = beta0 + betaA * A + beta1 * W1 + beta2 * W2  

Outputs:
- posterior samples  
- posterior summary  
- posterior distribution plot  

------------------------------------------------------------
5. Output Specifications
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
6. Software
------------------------------------------------------------

R packages:
MatchIt, WeightIt, survey, tmle, SuperLearner, brms, bayesplot, ggplot2, dplyr

Reproducibility:
[causal_analysis.R](/code/demo code.R)

------------------------------------------------------------
7. Notes
------------------------------------------------------------

This Mini SAP is designed for documentation, reproducibility, and interview demonstration.  
Its structure mirrors analysis plans used in real-world biostatistics and RWE workflows.
