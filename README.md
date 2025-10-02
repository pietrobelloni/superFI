# superFI

## Frailty indicator based on a super-classifier

The Super-Classifier_Indicator.R code can be used to reproduce the results presented in the article _Measuring frailty in older adults: an indicator based on a super-classifier_ by S. Rebottini and P. Belloni (2025). Current preprint: https://arxiv.org/abs/2506.22349.

For privacy reasons, sharing the original raw data is not possible. Therefore, in the prediction.RData file, we only provide the values predicted by the logistic models mentioned in the article, which we aggregate to obtain the final frailty indicator. The variable selection and model estimation steps are thus not included in this code. Nevertheless, the code can be used to aggregate the predicted values from any set of models, provided that their sensitivities and specificities are known and the aggregation assumptions are met.
