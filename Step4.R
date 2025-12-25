############################################################
# STEP 4: Deconvolution of cell-type–specific signals
#         in bulk RNA-seq DEGs using scRNA-seq reference
#
# Goal:
#   Use a single-cell RNA-seq reference to interpret
#   bulk-tissue RNA-seq differential expression results
#   by identifying cell-type–specific gene signatures
#   among the top DEGs.
############################################################


# ----------------------------------------------------------
# 1. Extract gene names from the scRNA-seq reference object
# ----------------------------------------------------------
# These genes define the universe of genes measurable
# in the single-cell dataset.
gene_names <- rownames(sc_data)


# ----------------------------------------------------------
# 2. Intersect bulk DEGs with scRNA-seq gene universe
# ----------------------------------------------------------
# Retain only DEGs that are also present in the scRNA-seq
# reference, preserving the original ordering by fold change.
ctrl_DEGs <- ctrl_DEGs[ctrl_DEGs %in% gene_names]
c4_DEGs   <- c4_DEGs[c4_DEGs %in% gene_names]


# ----------------------------------------------------------
# 3. Select equally sized DEG signatures for comparison
# ----------------------------------------------------------
# To ensure comparability between experimental conditions,
# restrict analysis to the top N DEGs ranked by magnitude
# of differential expression.
ctrl_DEGs <- head(ctrl_DEGs, 250)
c4_DEGs   <- head(c4_DEGs, 250)


# ----------------------------------------------------------
# 4. Select DEG list for current iteration
# ----------------------------------------------------------
# The following steps are repeated independently for each
# DEG list (e.g., ctrl_DEGs and c4_DEGs). Output filenames
# should be renamed accordingly to avoid overwriting results.
topDEGs_list <- ctrl_DEGs   # Repeat Steps 5–8 for c4_DEGs


# ----------------------------------------------------------
# 5. Scale scRNA-seq expression for selected DEGs
# ----------------------------------------------------------
# Scaling is performed only on the genes in topDEGs_list
# to focus downstream dimensionality reduction on the
# bulk-derived gene signature.
sc_data <- ScaleData(sc_data, features = topDEGs_list)


# ----------------------------------------------------------
# 6. Dimensionality reduction of DEG-based expression
# ----------------------------------------------------------

# i. Perform PCA using only the selected DEGs.
sc_data <- RunPCA(sc_data, features = topDEGs_list)

# ii. Retain genes with non-zero loadings in PCA.
# These genes contribute to variance and will be used
# for downstream correlation analyses.
topDEGs_list <- rownames(
  sc_data@reductions[["pca"]]@feature.loadings
)


# ----------------------------------------------------------
# 7. Visualize PCA of DEG-driven expression patterns
# ----------------------------------------------------------
# Generate PCA plot to visualize how DEG expression
# separates cell populations in the scRNA-seq reference.
pca_plot <- DimPlot(
  sc_data,
  reduction = "pca",
  pt.size = 0.1,
  label = FALSE,
  cols = cols
)

# Extract legend for separate export (useful for figure panels)
legend <- get_legend(pca_plot)

# Remove legend from main PCA plot
pca_plot <- pca_plot & NoLegend()

# Save PCA plot
ggsave(
  filename = "Fig_2_pca_plot.png",
  plot = pca_plot,
  width = 3.75,
  height = 3.75,
  dpi = 300
)

# Save legend separately
ggsave(
  filename = "Fig_2_legend.png",
  plot = legend,
  width = 2,
  height = 3.75,
  dpi = 300
)


# ----------------------------------------------------------
# 8. Correlation-based clustering of DEG signatures
# ----------------------------------------------------------
# This step identifies cell-type–specific gene expression
# patterns by computing pairwise Pearson correlations
# among DEGs across all single cells.

# i. Define correlation heatmap color palette
# a. Generate a random matrix to empirically estimate
#    correlation value distribution.
random.matrix <- matrix(
  runif(500, min = -1, max = 1),
  nrow = 50
)

# b. Compute quantiles of the simulated distribution.
quantile.range <- quantile(random.matrix, probs = seq(0, 1, 0.01))

# c. Define correlation range used for color scaling.
#    Lower and upper bounds are chosen empirically to
#    maximize visual contrast.
palette.breaks <- seq(
  quantile.range["35%"],
  quantile.range["83%"],
  0.06
)

# d. Create diverging color palette for correlations.
color.palette <- colorRampPalette(
  c("#0571b0", "#f7f7f7", "#ca0020")
)(length(palette.breaks) - 1)


# ----------------------------------------------------------
# 9. Hierarchical clustering and heatmap functions
# ----------------------------------------------------------

# Load gplots for enhanced heatmap functionality
library(gplots)

# Define clustering function:
# Uses Pearson correlation distance and average linkage.
clustFunction <- function(x) {
  hclust(
    as.dist(1 - cor(t(as.matrix(x)), method = "pearson")),
    method = "average"
  )
}

# Define correlation heatmap function
heatmapPearson <- function(correlations) {
  heatmap.2(
    x = correlations,
    col = color.palette,
    breaks = palette.breaks,
    trace = "none",
    symm = TRUE,
    hclustfun = clustFunction
  )
}


# ----------------------------------------------------------
# 10. Compute gene–gene correlation matrix
# ----------------------------------------------------------
# Calculate Pearson correlation coefficients on log2-
# transformed normalized expression values for selected DEGs.
expr <- GetAssayData(
  sc_data,
  assay = "RNA",
  layer = "data"
)[topDEGs_list, ]

correlations_DEGs_log <- cor(
  log2(t(as.matrix(expr)) + 1),
  method = "pearson"
)


# ----------------------------------------------------------
# 11. Generate and save correlation heatmap
# ----------------------------------------------------------
pdf(
  file = "Fig_2_corr_plot.pdf",
  width = 25,
  height = 25
)
heatmapPearson(correlations_DEGs_log)
dev.off()


# ----------------------------------------------------------
# NOTE:
# Repeat Steps 4–11 for the c4_DEGs list, updating
# output filenames to avoid overwriting results.
############################################################
