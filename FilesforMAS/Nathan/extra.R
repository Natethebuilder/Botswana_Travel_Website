# Visualization of cooperation vs defection rates
ggplot(summary_stats,
       aes(x = intervention_intensity)) +
    geom_line(aes(y = mean_coop_other, color = "Cooperation")) +
    geom_line(aes(y = mean_def_other, color = "Defection")) +
    facet_grid(intervention_type ~ environmentType) +
    theme_minimal() +
    labs(title = "Cooperation vs Defection Rates by Environment and Intervention",
         x = "Intervention Intensity",
         y = "Count",
         color = "Interaction Type") +
    theme(axis.text = element_text(size = 10),
          axis.title = element_text(size = 12),
          strip.text = element_text(size = 10))
ggsave("cooperation_defection_comparison.png", width = 15, height = 12)

# Box plots showing prejudice distribution
ggplot(all_data,
       aes(x = factor(intervention_intensity),
           y = `mean [prejudice] of people`,
           fill = intervention_type)) +
    geom_boxplot(alpha = 0.7) +
    facet_wrap(~environmentType) +
    theme_minimal() +
    labs(title = "Distribution of Prejudice Levels by Intervention and Environment",
         x = "Intervention Intensity",
         y = "Prejudice Level",
         fill = "Intervention Type") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave("prejudice_distribution.png", width = 12, height = 8)

# Individual group prejudice levels
group_prejudice <- all_data %>%
    pivot_longer(
        cols = matches("group = "),
        names_to = "group",
        values_to = "prejudice"
    ) %>%
    mutate(group = str_extract(group, '"[A-E]"'))

ggplot(group_prejudice,
       aes(x = intervention_intensity,
           y = prejudice,
           color = group)) +
    geom_smooth(se = FALSE) +
    facet_grid(intervention_type ~ environmentType) +
    theme_minimal() +
    labs(title = "Group-Specific Prejudice Levels",
         x = "Intervention Intensity",
         y = "Prejudice Level",
         color = "Group") +
    theme(strip.text = element_text(size = 10))
ggsave("group_specific_prejudice.png", width = 15, height = 12)

# Visualization of intervention effectiveness over time
time_analysis <- all_data %>%
    group_by(intervention_type, environmentType, `[step]`, intervention_intensity) %>%
    summarise(mean_prejudice = mean(`mean [prejudice] of people`),
              .groups = 'drop')

ggplot(time_analysis,
       aes(x = `[step]`,
           y = mean_prejudice,
           color = factor(intervention_intensity))) +
    geom_line(alpha = 0.7) +
    facet_grid(intervention_type ~ environmentType) +
    theme_minimal() +
    labs(title = "Intervention Effects Over Time",
         x = "Time Step",
         y = "Mean Prejudice",
         color = "Intervention\nIntensity") +
    theme(legend.title = element_text(size = 10))
ggsave("time_series_analysis.png", width = 15, height = 12)

# Heatmap of intervention effectiveness
summary_stats %>%
    ggplot(aes(x = factor(environmentType),
               y = intervention_type,
               fill = mean_prejudice)) +
    geom_tile() +
    facet_wrap(~intervention_intensity) +
    scale_fill_gradient2(low = "blue", mid = "white", high = "red",
                        midpoint = mean(summary_stats$mean_prejudice)) +
    theme_minimal() +
    labs(title = "Heatmap of Intervention Effectiveness",
         x = "Environment Type",
         y = "Intervention Type",
         fill = "Mean\nPrejudice") +
    theme(axis.text.x = element_text(angle = 0))
ggsave("intervention_heatmap.png", width = 15, height = 8)

# Interaction effect plot
ggplot(summary_stats,
       aes(x = intervention_intensity,
           y = mean_prejudice,
           color = factor(environmentType))) +
    geom_line() +
    geom_point() +
    facet_wrap(~intervention_type) +
    theme_minimal() +
    labs(title = "Environment-Intervention Interaction Effects",
         x = "Intervention Intensity",
         y = "Mean Prejudice",
         color = "Environment\nType")
ggsave("interaction_effects.png", width = 12, height = 8)