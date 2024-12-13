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

# Calculate intervention effectiveness rates
effectiveness_data <- all_data %>%
  group_by(intervention_type, environmentType, intervention_intensity) %>%
  summarise(
    initial_prejudice = mean(`mean [prejudice] of people`[`[step]` == 0]),
    final_prejudice = mean(`mean [prejudice] of people`[`[step]` == max(`[step]`)]),
    reduction_rate = ((initial_prejudice - final_prejudice) / initial_prejudice) * 100,
    .groups = 'drop'
  )

# Visualization of intervention effectiveness rates
ggplot(effectiveness_data,
       aes(x = intervention_intensity,
           y = reduction_rate,
           color = intervention_type)) +
    geom_line(size = 1) +
    geom_point(size = 3) +
    facet_wrap(~environmentType) +
    theme_minimal() +
    labs(title = "Intervention Effectiveness: Prejudice Reduction Rate",
         subtitle = "Higher percentage indicates more effective intervention",
         x = "Intervention Intensity",
         y = "Prejudice Reduction Rate (%)",
         color = "Intervention Type") +
    theme(text = element_text(size = 12))
ggsave("intervention_effectiveness_rate.png", width = 12, height = 8)

# Cooperation to Defection Ratio Analysis
cooperation_ratio <- all_data %>%
  group_by(intervention_type, environmentType, intervention_intensity) %>%
  summarise(
    coop_ratio = sum(`coopother-agg`) / (sum(`coopother-agg`) + sum(`defother-agg`)) * 100,
    .groups = 'drop'
  )

ggplot(cooperation_ratio,
       aes(x = intervention_intensity,
           y = coop_ratio,
           color = intervention_type)) +
    geom_line(size = 1) +
    geom_point(size = 3) +
    facet_wrap(~environmentType) +
    theme_minimal() +
    labs(title = "Cooperation Rate by Intervention and Environment",
         subtitle = "Percentage of cooperative interactions vs total interactions",
         x = "Intervention Intensity",
         y = "Cooperation Rate (%)",
         color = "Intervention Type") +
    theme(text = element_text(size = 12))
ggsave("cooperation_ratio.png", width = 12, height = 8)

# Intervention Speed Analysis
speed_analysis <- all_data %>%
  group_by(intervention_type, environmentType, intervention_intensity) %>%
  summarise(
    steps_to_50_reduction = min(which(`mean [prejudice] of people` <= 50)),
    .groups = 'drop'
  )

ggplot(speed_analysis,
       aes(x = intervention_intensity,
           y = steps_to_50_reduction,
           color = intervention_type)) +
    geom_line(size = 1) +
    geom_point(size = 3) +
    facet_wrap(~environmentType) +
    theme_minimal() +
    labs(title = "Speed of Intervention Effect",
         subtitle = "Number of steps needed to reach 50% prejudice reduction",
         x = "Intervention Intensity",
         y = "Steps to 50% Reduction",
         color = "Intervention Type") +
    theme(text = element_text(size = 12))
ggsave("intervention_speed.png", width = 12, height = 8)

# Relative Effectiveness Heatmap
relative_effectiveness <- effectiveness_data %>%
  group_by(intervention_type) %>%
  mutate(relative_reduction = reduction_rate / max(reduction_rate) * 100)

ggplot(relative_effectiveness,
       aes(x = factor(environmentType),
           y = intervention_type,
           fill = relative_reduction)) +
    geom_tile() +
    facet_wrap(~intervention_intensity) +
    scale_fill_gradient2(low = "white", mid = "yellow", high = "red",
                        midpoint = 50,
                        name = "Relative\nEffectiveness (%)") +
    theme_minimal() +
    labs(title = "Relative Effectiveness of Interventions",
         subtitle = "Percentage of maximum possible reduction for each intervention type",
         x = "Environment Type",
         y = "Intervention Type") +
    theme(text = element_text(size = 12))
ggsave("relative_effectiveness_heatmap.png", width = 15, height = 8)

# Group Polarization Analysis
polarization_data <- all_data %>%
  group_by(intervention_type, environmentType, intervention_intensity, `[step]`) %>%
  summarise(
    prejudice_std = sd(c(
      `mean [prejudice] of people with [group = "A"]`,
      `mean [prejudice] of people with [group = "B"]`,
      `mean [prejudice] of people with [group = "C"]`,
      `mean [prejudice] of people with [group = "D"]`,
      `mean [prejudice] of people with [group = "E"]`
    )),
    .groups = 'drop'
  )

ggplot(polarization_data,
       aes(x = `[step]`,
           y = prejudice_std,
           color = factor(intervention_intensity))) +
    geom_line() +
    facet_grid(intervention_type ~ environmentType) +
    theme_minimal() +
    labs(title = "Group Polarization Over Time",
         subtitle = "Standard deviation of prejudice levels between groups",
         x = "Time Step",
         y = "Prejudice Standard Deviation",
         color = "Intervention\nIntensity") +
    theme(text = element_text(size = 12))
ggsave("group_polarization.png", width = 15, height = 12)