# SpatialRegressionBSPS2023

[BSPS Annual Conference 2023](https://www.lse.ac.uk/international-development/research/british-society-for-population-studies/annual-conference)

# Spatial Bayesian Statistics Tutorial for Social Researchers

This tutorial provides an introduction to Spatial Bayesian Statistics for Social Researchers, focusing on practical methods and applications using Indian labour force data. It is a valuable resource for those looking to incorporate spatial analysis into their social research projects.

**Introduction**

Spatial Bayesian statistics is a powerful tool for social researchers to analyse and model spatial relationships in their data. This tutorial will provide you with an introduction to spatial Bayesian statistics, focusing on methods relevant to social researchers. The tutorial assumes that you have some basic knowledge of statistics and data analysis. The tutorial is structured in the following way: 

## Table of Contents

1. **Getting Started**
    - **Downloading the Tutorial Materials**
    - **Software Requirements**
      
2. **Understanding Spatial Bayesian Statistics**
    - **What is Spatial Bayesian Statistics?**
    - **Why Use Bayesian Methods for Spatial Analysis?**
      
3. **Data Preparation**
    - **Data Sources**
    - **Data Cleaning**
      
4. **Spatial Regression with Bayesian Estimation**
    - **Introduction to STAN**
    - **Spatial Models**
  
5. **Hands-on Tutorial**
    - **Running Spatial Bayesian Models**
    - **Interpreting Results**
  
6. **Additional Resources**
    - **References**
    - **Acknowledgement of Funding**

---

### 1. Getting Started

#### Downloading the Tutorial Materials

To get started with this tutorial, you will need to download the tutorial materials:

1. Visit the GitHub repository: 
2. Click the green "CODE" button.
3. Choose the 'Download ZIP' option.
4. Save the ZIP file to your computer.

Next, extract the contents of the ZIP file using your preferred unzip software, such as 7ZIP or Win-ZIP.

The files include: -- three PowerPoint slides -- one Tutorial guide, providing some sketchy answers to the set tasks@ --  Full code for cleaning the India data yourself to study any other aspect of Indian society using 'Periodic Labour-Force Survey' 2017/8 or 2018/9. Use all these for self-managed learning. 

During the workshop, if you have a question, please raise your hand, and someone will assist you.

If you encounter any difficulties or have questions, please contact Diego Perez Ruiz at diego.perezruiz@manchester.ac.uk for assistance.

---

### 2. Understanding Spatial Bayesian Statistics

#### What is Spatial Bayesian Statistics?

Spatial Bayesian statistics is a branch of statistics that deals with modelling and analyzing data that has a spatial or geographic component. It allows researchers to account for spatial dependencies and patterns in their data. Spatial Bayesian models use Bayesian estimation techniques to make probabilistic inferences about spatial relationships.

#### Why Use Bayesian Methods for Spatial Analysis?

Bayesian methods are particularly well-suited for spatial analysis because they provide a flexible framework for modelling complex relationships and incorporating prior information. Some advantages of using Bayesian methods for spatial analysis include:

- Ability to handle uncertainty: Bayesian methods allow you to quantify and propagate uncertainty through your analysis.
- Integration of prior knowledge: You can incorporate prior information into your models, which is especially useful when dealing with limited data.
- Flexibility: Bayesian models can be adapted to various types of spatial data and research questions.

---

### 3. Data Preparation

#### Data Sources

The tutorial materials provided are based on the Indian Periodic Labour Force Survey for the years 2017/8 and 2018/9. These datasets are open access and can be obtained from the following website: [Indian Periodic Labour Force Survey](https://mospi.gov.in/) (accessed September 2023).

The website provides tabular data, and you may need to use a dictionary to code the labels onto the data.

#### Data Cleaning

Data cleaning is a crucial step in any data analysis. The tutorial materials include full code for cleaning the Indian data to prepare it for spatial Bayesian analysis. This code can serve as a reference for cleaning data for other aspects of Indian society or different research questions.

---

### 4. Spatial Regression with Bayesian Estimation

#### Introduction to STAN (https://mc-stan.org/users/documentation/)

STAN is an open-source probabilistic programming language that is commonly used for Bayesian statistical modelling and data analysis. Some key points about STAN:

1. Provides a language for specifying statistical models, especially Bayesian models which represent probability distributions.
2. Integrates the modelling language with sampling algorithms so users don't have to code them separately.
3. Allows users to specify models using familiar statistical notation like matrices and distributions. The STAN program then handles the algorithms internally.
4. Written in C++ but provides interfaces for Python, R, MATLAB, Julia and other languages.
5. Allows computation of posterior inferences after conditioning models on observed data.

In the tutorial materials, you will find examples of spatial regression models implemented in STAN. You will learn how to write and run Bayesian models for spatial analysis using STAN.

#### How to install STAN?

Instructions for downloading, installing, and getting started with RStan on all platforms. See:


https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started


#### Spatial Models

Spatial regression models allow you to investigate how spatial relationships affect the variables of interest. These models can be used to analyze spatial patterns, identify clusters, and make predictions while accounting for spatial dependencies.

---

### 5. Hands-on Tutorial

#### Running Spatial Bayesian Models

The tutorial materials include codes, figures, and datasets related to labour force participation in India for specific age groups. You will learn how to run Bayesian spatial regression models using this data. The tutorial guide provides answers to set tasks, helping you understand the practical implementation of these models.

#### Interpreting Results

Interpreting the results of Bayesian spatial models is a crucial step. You will learn how to interpret the output of your models, including posterior distributions, credible intervals, and spatial effects. Understanding these results is essential for drawing meaningful conclusions from your analysis.

---

### 6. Additional Resources

#### References

In the tutorial materials, you will find references to relevant research papers and sources that can provide further insights into spatial Bayesian statistics and its applications in social research. These references include:

- Research papers (Case Study) by Arkadiusz Wiśniowski, Diego Perez Ruiz, Madhu Chauhan, and Wendy Olsen.
  
- Papers related to Child Labour Risks in India.


** Kim J, Olsen W, Wiśniowski A. (2022) Predicting Child-Labour Risks by Norms in India. Work, Employment and Society. doi:10.1177/09500170221091886
(Free, open source)

** Kim, Jihye, Wendy Olsen, and Arkadiusz Wiśniowski (2022), Extremely Harmful Child Labour in India from a Time-Use Perspective, to Development in Practice.  Revise & Resubmit, accepted with minor changes. (Please await full article link)

** Kim, Jihye, Olsen, W.K. and Arkadiusz Wiśniowski (mimeo), “Girl Children’s Labour Participation, “Child Labour” and Decent Work: Results from India”, sent to Canadian Journal of Development Studies, 2021; please await the publication; 

** Anita Hammer, Wendy Olsen and Janroj Keles, “Working Lives in India: Past insights and future directions”, lead article for India e-special issue, Work, Employment and Society, accepted, DOI 10.1177/09500170221083511. 2022

** Kim, Jihye, Olsen, W.K. and Arkadiusz Wiśniowski (2020), A Bayesian Estimation of Child Labour in India, Child Indicators Research, DOI https://doi.org/10.1007/s12187-020-09740-w. Online 8 June. ** 


#### Acknowledgement of Funding

We would like to acknowledge the contributions of Madhu Chauhan, who served as the research assistant during the 2021/22 academic year. And Dr Arkadiusz Wiśniowski for his invaluable guidance and support as the advisor for all the materials

This research was supported by Research Support Funds 2021-22 at the School of Social Sciences at the University of Manchester.

Part of this research has been disrupted by the effects of the COVID-19 pandemic.

---
 
For further questions or assistance, you can contact the tutorial creators via email. Happy learning and exploring the world of spatial Bayesian statistics!
