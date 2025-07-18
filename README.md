# Data Analysis with R📊

---

## 📚 Table of Contents
- [Overview](#overview)
- [Datasets](#datasets)
- [Analysis Workflow](#analysis-workflow)
- [Key Findings](#key-findings)
- [Discussion](#discussion)
- [Conclusion](#conclusion)
- [Authors](#authors)

---

## Overview

The project focuses on **exploratory data analysis** and **statistical testing** in R for two real‑world datasets. We walk through data cleaning, visualization, hypothesis testing, and summary insights—no predictive modeling is included.

---

## Datasets

1. **Fetal Health Classification**  
   - 2,126 records of cardiotocogram (CTG) measurements  
   - 3 outcome classes: Normal, Suspect, Pathological  

2. **Garment Worker Productivity**  
   - 1,197 records of factory worker metrics (e.g., department, overtime, incentives)  
   - Continuous target: actual productivity

---

## Analysis Workflow

1. **Data Cleaning & Preprocessing**  
   - Imputed missing values with column means or modes  
   - Standardized column names and types  
   - Balanced class counts for CTG (oversampling)  
   - Removed extreme outliers in productivity (>1.1)  

2. **Exploratory Data Analysis (EDA)**  
   - **Univariate**: Histograms & boxplots for each feature  
   - **Bivariate**: Correlation heatmaps, scatterplots  
   - **Group comparisons**:  
     - CTG class distributions (%)  
     - Productivity by department & overtime status  

3. **Statistical Testing**  
   - Two‑sample t‑tests to compare mean productivity between departments  
   - ANOVA to assess differences across CTG classes for key measurements  
   - Chi‑square tests for associations between categorical factors

4. **Visualization & Reporting**  
   - Plotted distributions and group means with error bars  
   - Summarized key statistics in tables  
   - Annotated significant p‑values on plots  

---

## Key Findings

- **CTG Classes**  
  - Normal: ~78% of records  
  - Suspect: ~14%  
  - Pathological: ~8%  
  - Significant differences (ANOVA p < 0.001) in baseline heart rate and variability across all three groups.

- **Worker Productivity**  
  - Mean productivity—Finishing: 0.75 vs. Sewing: 0.72  
  - T‑test (Finishing vs. Sewing): p = 0.02 → statistically higher productivity in Finishing.  
  - Overtime effect: small negative correlation (r = –0.10) between hours of overtime and productivity.

- **Feature Relationships**  
  - Moderate positive correlation (r = 0.45) between `mean_value_of_long_term_variability` and fetal health class.  
  - Incentives show a weak positive association (χ² p = 0.04) with productivity levels.

---

## Discussion

- **Data Quality:** Imputation and outlier removal were essential—~8% of CTG records had at least one missing value; ~5% of productivity records were outliers.  
- **Group Differences:** Clear statistical separation in CTG metrics supports clinical relevance of suspect/pathological labels.  
- **Operational Insights:** Finishing department consistently outperforms sewing; excessive overtime may slightly reduce productivity.

---

## Conclusion

Through systematic cleaning, visualization, and hypothesis testing, we extracted actionable insights from both clinical and operational datasets—demonstrating the power of R for end‑to‑end data analysis without any predictive modeling.

---


## Authors
| Member                 |
|------------------------|
| Sidy Yaya Toure        | 
| Ali Sena Danishwer     | 
| Md Rashidul Islam      | 
