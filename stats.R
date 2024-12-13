# Required packages
library(tidyverse)
library(lme4)
library(ggplot2)
library(car)
library(effectsize)
library(emmeans)

# Set working directory (change this to your folder location)
setwd("C:/Users/user/PycharmProjects/untitled1/Nathan")

# Function to read and process each intervention file
process_intervention_data <- function(file_path, intervention_name) {
    # Read the CSV file, skipping the first 6 rows
    data <- read.csv(file_path, skip = 6, header = TRUE, check.names = FALSE)

    # Explicitly set column names to match your dataset
    colnames(data) <- c(
        '[run number]',
        'environmentType',
        'slider_sharedResourceIntensity',
        'slider_legalPolicyIntensity',
        'slider_communityEventIntensity',
        'slider_youthSocializationIntensity',
        'slider_trainingIntensity',
        'slider_economicIncentiveIntensity',
        '[step]',
        'coopother-agg',
        'defother-agg',
        'coopown-agg',
        'mean [prejudice] of people',
        'mean [prejudice] of people with [group = "A"]',
        'mean [prejudice] of people with [group = "B"]',
        'mean [prejudice] of people with [group = "C"]',
        'mean [prejudice] of people with [group = "D"]',
        'mean [prejudice] of people with [group = "E"]'
    )

    # Select relevant columns and rename for easier handling
    data_clean <- data %>%
        select(
            `[run number]`,
            environmentType,
            intervention_intensity = matches(paste0("slider_", intervention_name, "Intensity")),
            `[step]`,
            `coopother-agg`,
            `defother-agg`,
            `coopown-agg`,
            `mean [prejudice] of people`,
            `mean [prejudice] of people with [group = "A"]`,
            `mean [prejudice] of people with [group = "B"]`,
            `mean [prejudice] of people with [group = "C"]`,
            `mean [prejudice] of people with [group = "D"]`,
            `mean [prejudice] of people with [group = "E"]`
        ) %>%
        mutate(intervention_type = intervention_name)

    return(data_clean)
}

# Process each intervention file
legal_policy <- process_intervention_data("legal_policy.csv", "legalPolicy")
training <- process_intervention_data("training.csv", "training")
community_events <- process_intervention_data("community_events.csv", "communityEvent")
youth_social <- process_intervention_data("youth_social.csv", "youthSocialization")
economic <- process_intervention_data("economic.csv", "economicIncentive")
shared_resource <- process_intervention_data("shared_resource.csv", "sharedResource")

# Combine all processed data into one dataframe
all_data <- bind_rows(
    legal_policy, training, community_events,
    youth_social, economic, shared_resource
)

# Sort by `[step]` to ensure rows remain properly ordered
all_data <- all_data %>% arrange(`[step]`)

# Summary statistics for each intervention
summary_stats <- all_data %>%
    group_by(intervention_type, environmentType, intervention_intensity) %>%
    summarise(
        mean_prejudice = mean(`mean [prejudice] of people`, na.rm = TRUE),
        sd_prejudice = sd(`mean [prejudice] of people`, na.rm = TRUE),
        mean_coop_other = mean(`coopother-agg`, na.rm = TRUE),
        mean_def_other = mean(`defother-agg`, na.rm = TRUE),
        n_obs = n(),
        .groups = 'drop'
    )

# Save summary statistics to CSV
write.csv(summary_stats, "all_interventions_summary.csv")

# Visualization comparing all interventions
ggplot(summary_stats,
       aes(x = intervention_intensity,
           y = mean_prejudice,
           color = intervention_type)) +
    geom_line() +
    facet_wrap(~environmentType) +
    theme_minimal() +
    labs(title = "Comparison of Intervention Effects on Prejudice",
         x = "Intervention Intensity",
         y = "Mean Prejudice",
         color = "Intervention Type") +
    theme(axis.text = element_text(size = 12), axis.title = element_text(size = 14))
ggsave("intervention_comparison.png", width = 12, height = 8)

# Create a comprehensive visualization of prejudice reduction by intervention
ggplot(summary_stats %>% group_by(intervention_type, intervention_intensity) %>%
           summarise(mean_prejudice = mean(mean_prejudice)),
       aes(x = intervention_intensity,
           y = mean_prejudice,
           color = intervention_type)) +
    geom_line() +
    geom_point() +
    theme_minimal() +
    labs(title = "Effectiveness of Different Interventions",
         x = "Intervention Intensity",
         y = "Mean Prejudice Level",
         color = "Intervention Type") +
    theme(axis.text = element_text(size = 12), axis.title = element_text(size = 14))
ggsave("intervention_effectiveness.png", width = 10, height = 6)

# Statistical comparison of interventions using lmer
model_prejudice <- lmer(`mean [prejudice] of people` ~
                            intervention_type * intervention_intensity *
                            factor(environmentType) +
                            (1|`[run number]`),
                        data = all_data)

# ANOVA results
anova_results <- anova(model_prejudice)
write.csv(anova_results, "intervention_comparison_anova.csv")
print("ANOVA Results for Prejudice Reduction:")
print(anova_results)

# Effect sizes
effects <- eta_squared(model_prejudice)
write.csv(effects, "intervention_effect_sizes.csv")
print("\nEffect Sizes for Prejudice Reduction:")
print(effects)

# Post-hoc comparisons for interventions
posthoc <- emmeans(model_prejudice, pairwise ~ intervention_type | environmentType)
write.csv(summary(posthoc), "posthoc_comparisons.csv")
print("\nPost-hoc Comparisons:")
print(posthoc)

# Additional analysis for cooperation and defection
model_cooperation <- lmer(`coopother-agg` ~
                          intervention_type * intervention_intensity *
                          factor(environmentType) + (1 | `[run number]`),
                          data = all_data)
anova_cooperation <- anova(model_cooperation)
print("ANOVA Results for Cooperation:")
print(anova_cooperation)

model_defection <- lmer(`defother-agg` ~
                        intervention_type * intervention_intensity *
                        factor(environmentType) + (1 | `[run number]`),
                        data = all_data)
anova_defection <- anova(model_defection)
print("ANOVA Results for Defection:")
print(anova_defection)

# Effect sizes for cooperation and defection
effects_cooperation <- eta_squared(model_cooperation)
effects_defection <- eta_squared(model_defection)
write.csv(effects_cooperation, "cooperation_effect_sizes.csv")
write.csv(effects_defection, "defection_effect_sizes.csv")

print("\nEffect Sizes for Cooperation:")
print(effects_cooperation)
print("\nEffect Sizes for Defection:")
print(effects_defection)


# Redirect console output to a text file
sink("console_output.txt")

# ANOVA results
print("ANOVA Results for Prejudice Reduction:")
print(anova_results)

# Effect sizes
print("\nEffect Sizes for Prejudice Reduction:")
print(effects)

# Post-hoc comparisons
print("\nPost-hoc Comparisons:")
print(posthoc)

# ANOVA results for cooperation and defection
print("\nANOVA Results for Cooperation:")
print(anova_cooperation)

print("\nANOVA Results for Defection:")
print(anova_defection)

# Effect sizes for cooperation and defection
print("\nEffect Sizes for Cooperation:")
print(effects_cooperation)

print("\nEffect Sizes for Defection:")
print(effects_defection)

# Stop redirecting console output
sink()

# Optional message to indicate completion
cat("Console output saved to console_output.txt\n")
