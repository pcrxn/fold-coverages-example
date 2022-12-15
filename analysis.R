library(tidyverse)

# Obtain a list of alignment stats files
stats_files = list.files("stats/", pattern = "stats.tsv", full.names = TRUE)

# Read in the alignment stats files as a single dataframe
stats = read_tsv(stats_files, id = 'filename') %>% 
  mutate(sampleid = gsub(".*/(.*)_S[0-9]+_stats.tsv", "\\1", filename)) %>% 
  select(-filename) %>% 
  relocate(sampleid, .before = target)

# Create an adjacency matrix (heatmap) of positives (1) and negatives (0)
prop_cov_threshold = 0.9
fold_cov_threshold = 0.9

stats_filtered_adjmat = stats %>%
  filter(sampleid != 'Undetermined') %>% 
  filter(prop_cov >= prop_cov_threshold) %>% 
  filter(fold_cov >= fold_cov_threshold) %>%
  mutate(positive = 1) %>% 
  pivot_wider(id_cols = sampleid, names_from = target, values_from = positive, values_fill = 0) 

write_tsv(stats_filtered_adjmat, "stats-filtered-adjmat.tsv")

# Create a heatmap of fold-coverages
stats_foldcov_heatmap = stats %>%
  pivot_wider(id_cols = sampleid, names_from = target, values_from = fold_cov, values_fill = 0)

write_tsv(stats_foldcov_heatmap, "stats_foldcov_heatmap.tsv")
