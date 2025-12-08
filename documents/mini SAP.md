# Mini Statistical Analysis Plan (SAP)
## Causal Inference: Treatment Effect Estimation

## 1. Study Overview
This Statistical Analysis Plan (SAP) describes methods used to estimate the causal effect of a binary treatment using observational data. 
The primary dataset is the Lalonde dataset from the MatchIt package, with simulated data used for Bayesian estimation. 
Causal inference methods included in this analysis are:
- Propensity Score Matching (PSM)
- Inverse Probability of Treatment Weighting (IPTW)
- Doubly Robust Estimator (DR)
- Targeted Maximum Likelihood Estimation (TMLE)
- Bayesian ATE estimation (via brms)

---

## 2. Objectives

### Primary Objective
Estimate the Average Treatment Effect (ATE), defined as:
ATE = E[Y(1)] - E[Y(0)]

### Secondary Objective
Estimate the Average Treatment Effect on the Treated (ATT):
ATT = E[Y(1) - Y(0) | A = 1]

### Sensitivity Objectives
- Compare estimates across all methods  
- Assess covariate balance before and after adjustments  
- Evaluate robustness of causal conclusions  

---

## 3. Analysis Populations
- Full Analysis Set (FAS): all observations with complete data  
- Matched Set: observations retained after PSM  
- Weighted Population: observations with positive IPTW weights  

---

## 4. Variables

### Treatment
A (1 = treated, 0 = control)

### Outcome
Y = re78 (post-treatment income)

### Confounders
age, educ, black, hispan, married, nodegree, re74, re75  
Dummy variables constructed from race.

---

## 5. Methods

### 5.1 Propensity Score Estimation
Propensity score estimated via logistic regression:
PS = P(A = 1 | X)

---

### 5.2 Propensity Score Matching (PSM)
- 1:1 nearest neighbor matching  
- Caliper = 0.2  
- ATT estimator computed as mean(Y_treated - Y_matched_control)

Outputs:
- Matched dataset  
- PSM balance summary  
- Love plot  

---

### 5.3 Inverse Probability of Treatment Weighting (IPTW)
Weights:
w = 1/PS for treated  
w = 1/(1 - PS) for control  

ATE estimated as weighted difference in mean Y.

Outputs:
- Weighted balance summary  
- IPTW ATE estimate  

---

### 5.4 Doubly Robust Estimator (DR)
Outcome regression model combined with PS weighting.  
Estimator remains consistent if either the PS model OR the outcome model is correctly specified.

Output:
- DR treatment effect estimate  

---

### 5.5 Targeted Maximum Likelihood Estimation (TMLE)
TMLE procedure uses:
- Initial Q model (outcome regression)
- g model (propensity score)
- A targeting step to update Q  

Outputs include:
- TMLE ATE estimate  
- 95% confidence interval  
- p-value  
- TMLE visualization  

---

### 5.6 Bayesian ATE Estimation
Bayesian regression model:
Y = beta0 + betaA * A + beta1 * W1 + beta2 * W2 + error  

Outputs:
- Posterior samples  
- Posterior mean and SD  
- Credible intervals  
- Posterior distribution plot  

---

## 6. Output Specifications

#  Key Figures (Visual Outputs)

### **1. Love Plot — Covariate Balance (PSM)**
<img src="figures/love_plot.png" width="450">

---

### **2. TMLE ATE Estimate (with 95% CI)**
<img src="figures/tmle_results.png" width="450">

---

### **3. Bayesian Posterior Distribution (ATE)**
<img src="figures/bayes_posterior.png" width="450">

---

#  Detailed CSV Results (Click to view)

GitHub automatically renders CSV files in interactive table view.

| Description | File |
|------------|------|
| PSM Balance Table | [balance_psm.csv](tables/balance_psm.csv) |
| Matched Dataset (PSM) | [matched_data_psm.csv](tables/matched_data_psm.csv) |
| PSM ATT Result | [psm_result.csv](tables/psm_result.csv) |
| IPTW Balance Table | [balance_iptw.csv](tables/balance_iptw.csv) |
| IPTW ATE Result | [iptw_result.csv](tables/iptw_result.csv) |
| Doubly Robust Result | [dr_result.csv](tables/dr_result.csv) |
| TMLE ATE Result | [tmle_result.csv](tables/tmle_result.csv) |
| Bayesian Posterior Samples | [bayes_posterior_samples.csv](tables/bayes_posterior_samples.csv) |
| Bayesian Summary | [bayes_A_summary.csv](tables/bayes_A_summary.csv) |
| Combined Summary | [causal_results_summary.csv](tables/causal_results_summary.csv) |

---

## 7. Software
Analyses conducted in R, using:
MatchIt, WeightIt, survey, tmle, SuperLearner, brms, bayesplot, ggplot2, dplyr

Reproducible via:
source("code/demo code.R")

---

## 8. Notes
This Mini SAP is a simplified demonstration of causal inference procedures used in RWE and biostatistics.
It is intended for analysis documentation, portfolio presentation, and interview discussion.
