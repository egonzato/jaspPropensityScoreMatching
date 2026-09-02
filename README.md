# jaspPropensityScoreMethods

This module was developed during the first JASP hackathon, in February 2026.

## Introduction

To make use of observational data, causal inference methods are often employed to make two groups comparable. Several approaches are used to recreate clinical-trial like settings from data gathered during daily clinical practice. Among these, propensity score matching (psm) and inverse propability of treatment weighting (iptw), which can both be labelled under the same umbrella as propensity score methods.

## What are Propensity Score Methods

Propensity score methods like psm and iptw aim to predict how likely a unit is to receive the treatment, based on a certain set of characteristics, also called confounders. Once the probability of receiving the treatment is predicted for each unit, this can be used to:

* Pair treated and untreated units that are closest in probability of treatment, for psm, in order to recreate a dataset in which confounders are balanced between the two arms.
* Use the inverse of this probability of treatment as weights in the analysis of interest, to regulate the impact that units have on parameter estimation.

## Options currently available

For psm, the following options are available:

* Treatment model specification: linear and/or non-linear form for confounders.
* Distance measure: Probability, Logit, Mahalanobis distance
* Method: matching can be performed starting from treated units with the highest probability of treatment ('nearest') or minimizing the distance in the distance chosen ('optimal')
* Ratio: number of untreated units to look for each treated unit.
* Caliper: available only when the selected distance measure is either "Probability" or "Logit", specifies the maximum distance in distance measure between treated and untreated units for matching.
* Replacement: untreated units can be used multiple times in matching with replacement, or only once if without replacement.

For inverse probability of treatment weighting, the following options are available:

* Treatment model specification: linear and/or non-linear form for confounders.
* Stabilize weights: whether weights should be stabilizing by using mean probability of treatment as numerator of treatment weights or 1 (unstabilized weights)
* Truncate weights: whether tails of the distributions of weights should be truncated, given certain percentiles.

## To do

* Sum up and ask for help

### Need help

* For psm:

  * Gray-out "caliper" when: i) distance is set to "Mahalanobis", ii) method is set to "Optimal"
  * Save selected dataset
  
* For iptw:

  * Bootstrapping analysis for iptw standard errors or save dataset

#### Other

* Change label of module (draw confounding)
