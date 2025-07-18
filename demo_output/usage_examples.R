#!/usr/bin/env Rscript
# Usage examples for ggdiceplot package
# This script demonstrates various ways to use the geom_dice function

library(ggplot2)

# Load the ggdiceplot functions
source("../R/utils.R")
source("../R/geom_dice.R")

# Already in demo_output directory
cat("Working from demo_output directory...\n")

cat("Creating ggdiceplot usage examples...\n")

# Example 1: Gene expression data
cat("1. Creating gene expression example...\n")
gene_data <- data.frame(
  gene = rep(c("GENE1", "GENE2", "GENE3", "GENE4"), each = 3),
  condition = rep(c("Control", "Treatment1", "Treatment2"), times = 4),
  pathways = c(
    "Pathway1", "Pathway1,Pathway2", "Pathway1,Pathway2,Pathway3",
    "Pathway2", "Pathway2,Pathway3", "Pathway3,Pathway4",
    "Pathway1,Pathway4", "Pathway4,Pathway5", "Pathway5,Pathway6",
    "Pathway1,Pathway6", "Pathway2,Pathway6", "Pathway3,Pathway5,Pathway6"
  )
)

pathway_positions <- c(
  "Pathway1" = 1, "Pathway2" = 2, "Pathway3" = 3,
  "Pathway4" = 4, "Pathway5" = 5, "Pathway6" = 6
)

p_gene <- ggplot(gene_data, aes(x = gene, y = condition, categories = pathways)) +
  geom_dice(category_positions = pathway_positions) +
  labs(title = "Gene Expression Analysis", 
       subtitle = "Pathway activation patterns across genes and conditions",
       x = "Gene", y = "Condition") +
  theme_minimal() +
  theme(panel.grid.minor = element_blank())

ggsave("gene_expression_example.png", p_gene, width = 10, height = 6, dpi = 300)

# Example 2: Survey data
cat("2. Creating survey data example...\n")
survey_data <- data.frame(
  respondent = rep(1:5, each = 4),
  question = rep(paste("Q", 1:4, sep = ""), times = 5),
  responses = c(
    "A", "A,B", "A,B,C", "B,C",
    "A", "B", "A,C", "A,B,C",
    "B", "A,B", "C", "A,B,C",
    "A,C", "B,C", "A,B", "A,B,C",
    "C", "A,C", "B,C", "A,B,C"
  )
)

response_positions <- c("A" = 1, "B" = 2, "C" = 3)

p_survey <- ggplot(survey_data, aes(x = respondent, y = question, categories = responses)) +
  geom_dice(category_positions = response_positions) +
  scale_x_continuous(breaks = 1:5) +
  labs(title = "Survey Response Analysis", 
       subtitle = "Multiple choice responses (A, B, C) per respondent and question",
       x = "Respondent", y = "Question") +
  theme_minimal() +
  theme(panel.grid.minor = element_blank())

ggsave("survey_analysis_example.png", p_survey, width = 8, height = 6, dpi = 300)

# Example 3: Clinical trial data
cat("3. Creating clinical trial example...\n")
clinical_data <- data.frame(
  patient = rep(1:6, each = 4),
  timepoint = rep(c("Baseline", "Week 4", "Week 8", "Week 12"), times = 6),
  symptoms = c(
    "Fever", "Fever,Cough", "Cough,Fatigue", "Fatigue",
    "Fever,Headache", "Headache", "Cough", "Fatigue,Nausea",
    "Fever,Cough,Headache", "Cough,Headache", "Headache,Fatigue", "Fatigue",
    "Fever,Nausea", "Cough,Nausea", "Headache,Nausea", "Nausea",
    "Fever,Cough,Fatigue", "Fever,Fatigue", "Fatigue", "",
    "Fever,Headache,Nausea", "Headache,Nausea", "Nausea", ""
  )
)

symptom_positions <- c("Fever" = 1, "Cough" = 2, "Headache" = 3, "Fatigue" = 4, "Nausea" = 5)

p_clinical <- ggplot(clinical_data, aes(x = patient, y = timepoint, categories = symptoms)) +
  geom_dice(category_positions = symptom_positions) +
  scale_x_continuous(breaks = 1:6) +
  scale_y_discrete(limits = c("Baseline", "Week 4", "Week 8", "Week 12")) +
  labs(title = "Clinical Trial: Symptom Tracking", 
       subtitle = "Patient symptoms over time (Fever, Cough, Headache, Fatigue, Nausea)",
       x = "Patient ID", y = "Timepoint") +
  theme_minimal() +
  theme(panel.grid.minor = element_blank())

ggsave("clinical_trial_example.png", p_clinical, width = 10, height = 6, dpi = 300)

# Example 4: Market research
cat("4. Creating market research example...\n")
market_data <- data.frame(
  segment = rep(c("Young", "Middle", "Senior"), each = 5),
  product = rep(c("Product A", "Product B", "Product C", "Product D", "Product E"), times = 3),
  features = c(
    "Price", "Price,Quality", "Quality,Design", "Design,Support", "Support,Innovation",
    "Price,Innovation", "Quality", "Design", "Support,Quality", "Innovation,Design",
    "Price,Support", "Quality,Innovation", "Design,Price", "Support", "Innovation"
  )
)

feature_positions <- c("Price" = 1, "Quality" = 2, "Design" = 3, "Support" = 4, "Innovation" = 5)

p_market <- ggplot(market_data, aes(x = segment, y = product, categories = features)) +
  geom_dice(category_positions = feature_positions) +
  labs(title = "Market Research: Feature Preferences", 
       subtitle = "Important features by customer segment and product",
       x = "Customer Segment", y = "Product") +
  theme_minimal() +
  theme(panel.grid.minor = element_blank())

ggsave("market_research_example.png", p_market, width = 8, height = 8, dpi = 300)

cat("All usage examples created successfully!\n")
cat("Generated files in demo_output/:\n")
cat("- gene_expression_example.png\n")
cat("- survey_analysis_example.png\n")
cat("- clinical_trial_example.png\n")
cat("- market_research_example.png\n")