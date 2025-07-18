#!/usr/bin/env Rscript
# Multi-face dice plot example with artificial data
# Shows 4-face, 5-face, and 6-face dice with pathway coloring and continuous fold change

library(ggplot2)

# Load the ggdiceplot functions
source("../R/utils.R")
source("../R/geom_dice.R")

# No additional dependencies needed - using base R

cat("Creating multi-face dice plot examples...\n")

# Set seed for reproducible results
set.seed(42)

# Create artificial gene expression data
genes <- paste0("Gene_", 1:8)
conditions <- c("Control", "Treatment_A", "Treatment_B", "Treatment_C")

# Generate artificial data with different numbers of active pathways
create_pathway_combinations <- function(n_pathways, n_observations) {
  pathways <- c("Apoptosis", "Inflammation", "Metabolism", "DNA_Repair", "Cell_Cycle", "Immune_Response")
  
  combinations <- replicate(n_observations, {
    # Randomly select 1 to n_pathways pathways
    n_active <- sample(1:n_pathways, 1)
    active_pathways <- sample(pathways[1:n_pathways], n_active)
    paste(active_pathways, collapse = ",")
  })
  
  return(combinations)
}

# Create datasets for 4, 5, and 6 pathway analyses
data_4_pathways <- expand.grid(
  gene = genes,
  condition = conditions,
  stringsAsFactors = FALSE
)
data_4_pathways$pathways <- create_pathway_combinations(4, nrow(data_4_pathways))
data_4_pathways$fold_change <- rnorm(nrow(data_4_pathways), mean = 0, sd = 1.5)
data_4_pathways$pathway_category <- sample(c("Stress Response", "Cell Death", "Signaling", "Housekeeping"), 
                                          nrow(data_4_pathways), replace = TRUE)

data_5_pathways <- expand.grid(
  gene = genes,
  condition = conditions,
  stringsAsFactors = FALSE
)
data_5_pathways$pathways <- create_pathway_combinations(5, nrow(data_5_pathways))
data_5_pathways$fold_change <- rnorm(nrow(data_5_pathways), mean = 0, sd = 1.5)
data_5_pathways$pathway_category <- sample(c("Stress Response", "Cell Death", "Signaling", "Housekeeping", "Development"), 
                                          nrow(data_5_pathways), replace = TRUE)

data_6_pathways <- expand.grid(
  gene = genes,
  condition = conditions,
  stringsAsFactors = FALSE
)
data_6_pathways$pathways <- create_pathway_combinations(6, nrow(data_6_pathways))
data_6_pathways$fold_change <- rnorm(nrow(data_6_pathways), mean = 0, sd = 1.5)
data_6_pathways$pathway_category <- sample(c("Stress Response", "Cell Death", "Signaling", "Housekeeping", "Development", "Immune"), 
                                          nrow(data_6_pathways), replace = TRUE)

# Define pathway positions
pathway_positions_4 <- c("Apoptosis" = 1, "Inflammation" = 2, "Metabolism" = 3, "DNA_Repair" = 4)
pathway_positions_5 <- c("Apoptosis" = 1, "Inflammation" = 2, "Metabolism" = 3, "DNA_Repair" = 4, "Cell_Cycle" = 5)
pathway_positions_6 <- c("Apoptosis" = 1, "Inflammation" = 2, "Metabolism" = 3, "DNA_Repair" = 4, "Cell_Cycle" = 5, "Immune_Response" = 6)

# Example 1: 4-face dice colored by pathway category
cat("1. Creating 4-face dice plot with pathway categories...\n")
p1_categorical <- ggplot(data_4_pathways, aes(x = gene, y = condition, categories = pathways, color = pathway_category)) +
  geom_dice(category_positions = pathway_positions_4, dice_size = 0.8) +
  scale_color_manual(values = c("Stress Response" = "#E74C3C", "Cell Death" = "#3498DB", 
                               "Signaling" = "#2ECC71", "Housekeeping" = "#F39C12"),
                    name = "Pathway Category") +
  labs(title = "4-Face Dice Plot: Pathway Categories",
       subtitle = "Gene expression pathways colored by functional category",
       x = "Gene", y = "Condition") +
  theme_minimal() +
  theme(panel.grid.minor = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("4_face_dice_categorical.png", p1_categorical, width = 12, height = 8, dpi = 300)

# Example 2: 4-face dice colored by continuous fold change
cat("2. Creating 4-face dice plot with continuous fold change...\n")
p1_continuous <- ggplot(data_4_pathways, aes(x = gene, y = condition, categories = pathways, color = fold_change)) +
  geom_dice(category_positions = pathway_positions_4, dice_size = 0.8) +
  scale_color_gradient2(low = "#3498DB", mid = "white", high = "#E74C3C", 
                       midpoint = 0, name = "Fold Change") +
  labs(title = "4-Face Dice Plot: Continuous Fold Change",
       subtitle = "Gene expression pathways colored by fold change values",
       x = "Gene", y = "Condition") +
  theme_minimal() +
  theme(panel.grid.minor = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("4_face_dice_continuous.png", p1_continuous, width = 12, height = 8, dpi = 300)

# Example 3: 5-face dice colored by pathway category
cat("3. Creating 5-face dice plot with pathway categories...\n")
p2_categorical <- ggplot(data_5_pathways, aes(x = gene, y = condition, categories = pathways, color = pathway_category)) +
  geom_dice(category_positions = pathway_positions_5, dice_size = 0.8) +
  scale_color_manual(values = c("Stress Response" = "#E74C3C", "Cell Death" = "#3498DB", 
                               "Signaling" = "#2ECC71", "Housekeeping" = "#F39C12",
                               "Development" = "#9B59B6"),
                    name = "Pathway Category") +
  labs(title = "5-Face Dice Plot: Pathway Categories",
       subtitle = "Gene expression pathways (5 pathways) colored by functional category",
       x = "Gene", y = "Condition") +
  theme_minimal() +
  theme(panel.grid.minor = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("5_face_dice_categorical.png", p2_categorical, width = 12, height = 8, dpi = 300)

# Example 4: 5-face dice colored by continuous fold change
cat("4. Creating 5-face dice plot with continuous fold change...\n")
p2_continuous <- ggplot(data_5_pathways, aes(x = gene, y = condition, categories = pathways, color = fold_change)) +
  geom_dice(category_positions = pathway_positions_5, dice_size = 0.8) +
  scale_color_gradient2(low = "#3498DB", mid = "white", high = "#E74C3C", 
                       midpoint = 0, name = "Fold Change") +
  labs(title = "5-Face Dice Plot: Continuous Fold Change",
       subtitle = "Gene expression pathways (5 pathways) colored by fold change values",
       x = "Gene", y = "Condition") +
  theme_minimal() +
  theme(panel.grid.minor = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("5_face_dice_continuous.png", p2_continuous, width = 12, height = 8, dpi = 300)

# Example 5: 6-face dice colored by pathway category
cat("5. Creating 6-face dice plot with pathway categories...\n")
p3_categorical <- ggplot(data_6_pathways, aes(x = gene, y = condition, categories = pathways, color = pathway_category)) +
  geom_dice(category_positions = pathway_positions_6, dice_size = 0.8) +
  scale_color_manual(values = c("Stress Response" = "#E74C3C", "Cell Death" = "#3498DB", 
                               "Signaling" = "#2ECC71", "Housekeeping" = "#F39C12",
                               "Development" = "#9B59B6", "Immune" = "#1ABC9C"),
                    name = "Pathway Category") +
  labs(title = "6-Face Dice Plot: Pathway Categories",
       subtitle = "Gene expression pathways (6 pathways) colored by functional category",
       x = "Gene", y = "Condition") +
  theme_minimal() +
  theme(panel.grid.minor = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("6_face_dice_categorical.png", p3_categorical, width = 12, height = 8, dpi = 300)

# Example 6: 6-face dice colored by continuous fold change
cat("6. Creating 6-face dice plot with continuous fold change...\n")
p3_continuous <- ggplot(data_6_pathways, aes(x = gene, y = condition, categories = pathways, color = fold_change)) +
  geom_dice(category_positions = pathway_positions_6, dice_size = 0.8) +
  scale_color_gradient2(low = "#3498DB", mid = "white", high = "#E74C3C", 
                       midpoint = 0, name = "Fold Change") +
  labs(title = "6-Face Dice Plot: Continuous Fold Change",
       subtitle = "Gene expression pathways (6 pathways) colored by fold change values",
       x = "Gene", y = "Condition") +
  theme_minimal() +
  theme(panel.grid.minor = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("6_face_dice_continuous.png", p3_continuous, width = 12, height = 8, dpi = 300)

# Create a reference plot showing the pathway positions
cat("7. Creating pathway position reference...\n")
ref_data <- data.frame(
  pathway = c("Apoptosis", "Inflammation", "Metabolism", "DNA_Repair", "Cell_Cycle", "Immune_Response"),
  position = 1:6,
  categories = c("Apoptosis", "Inflammation", "Metabolism", "DNA_Repair", "Cell_Cycle", "Immune_Response"),
  type = "Reference"
)

p_reference <- ggplot(ref_data, aes(x = position, y = 1, categories = categories)) +
  geom_dice(category_positions = pathway_positions_6, dice_size = 0.8) +
  scale_x_continuous(breaks = 1:6, labels = c("Apoptosis", "Inflammation", "Metabolism", 
                                              "DNA_Repair", "Cell_Cycle", "Immune_Response")) +
  labs(title = "Pathway Position Reference",
       subtitle = "Dice positions 1-6 corresponding to biological pathways",
       x = "Pathway (Dice Position)", y = "") +
  theme_minimal() +
  theme(panel.grid.minor = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("pathway_position_reference.png", p_reference, width = 12, height = 4, dpi = 300)

cat("All multi-face dice plot examples created successfully!\n")
cat("Generated files:\n")
cat("- 4_face_dice_categorical.png\n")
cat("- 4_face_dice_continuous.png\n")
cat("- 5_face_dice_categorical.png\n")
cat("- 5_face_dice_continuous.png\n")
cat("- 6_face_dice_categorical.png\n")
cat("- 6_face_dice_continuous.png\n")
cat("- pathway_position_reference.png\n")

# Print data summary
cat("\nData Summary:\n")
cat("4-pathway analysis: ", nrow(data_4_pathways), " observations\n")
cat("5-pathway analysis: ", nrow(data_5_pathways), " observations\n")
cat("6-pathway analysis: ", nrow(data_6_pathways), " observations\n")
cat("Genes: ", length(genes), " (", paste(genes[1:3], collapse = ", "), "...)\n")
cat("Conditions: ", length(conditions), " (", paste(conditions, collapse = ", "), ")\n")