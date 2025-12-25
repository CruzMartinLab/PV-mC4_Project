############################################################
# STEP 3: Subset scRNA-seq reference dataset to match
#         cell-type populations present in bulk RNA-seq
#
# Goal:
#   Restrict the single-cell reference dataset to cortical
#   cell populations that are biologically relevant to the
#   bulk-tissue RNA-seq experiment, then preprocess and
#   visualize the resulting dataset.
############################################################


# ----------------------------------------------------------
# 1. Inspect metadata distributions
# ----------------------------------------------------------
# Explore anatomical and cell-type annotations to guide
# biologically informed subsetting decisions.
table(sc_data$region_label)
table(sc_data$subclass_label)


# ----------------------------------------------------------
# 2. Define cortical (neocortical/isocortical) regions
# ----------------------------------------------------------
# These region labels correspond to neocortical areas
# present in the Allen Brain Atlas taxonomy.
cortex_regions <- c(
  "ACA", "AI", "ALM", "AUD", "GU",
  "MOp", "ORB", "PL-ILA", "PTLp",
  "RSP", "RSPv", "SSp", "SSs",
  "VIS", "VISp", "TEa-PERI-ECT"
)

# Strict anatomical subsetting:
# Retain only cells whose region annotation corresponds
# to neocortex.
sc_data <- subset(
  x = sc_data,
  subset = region_label %in% cortex_regions
)


# ----------------------------------------------------------
# 3. Remove non-cortical / hippocampal-related subclasses
# ----------------------------------------------------------
# This secondary safeguard removes hippocampal,
# parahippocampal, and other non-isocortical populations
# that may persist due to annotation overlap.
exclude_patterns <- c(
  "ENT",   # entorhinal / allocortex
  "PPP",   # parasubiculum / postsubiculum
  "RHP",   # retrohippocampal
  "SUB",   # subiculum
  "CA",    # hippocampal CA fields
  "DG",    # dentate gyrus
  "CLA",   # claustrum
  "^NP"    # non-projecting / non-cortical
)

keep_cells <- !Reduce(
  `|`,
  lapply(
    exclude_patterns,
    function(p) grepl(p, sc_data$subclass_label)
  )
)

sc_data <- subset(
  x = sc_data,
  cells = colnames(sc_data)[keep_cells]
)


# ----------------------------------------------------------
# 4. Set and clean cell identity labels
# ----------------------------------------------------------
# Convert subclass labels to factors and drop unused levels.
Idents(sc_data) <- factor(sc_data$subclass_label)
Idents(sc_data) <- droplevels(Idents(sc_data))

# Reorder identity levels alphabetically for consistency
# across plots and reproducibility across sessions.
Idents(sc_data) <- factor(
  Idents(sc_data),
  levels = sort(levels(Idents(sc_data)))
)

# Keep metadata synchronized with identities
sc_data$subclass_label <- Idents(sc_data)


# ----------------------------------------------------------
# 5. Normalize and preprocess gene expression data
# ----------------------------------------------------------
# Normalize raw counts using log normalization.
sc_data <- NormalizeData(
  sc_data,
  normalization.method = "LogNormalize",
  scale.factor = 10000
)

# Identify highly variable genes using variance-stabilizing
# transformation (VST).
sc_data <- FindVariableFeatures(
  sc_data,
  selection.method = "vst",
  nfeatures = 2000
)

# Scale and center gene expression values prior to PCA.
sc_data <- ScaleData(sc_data)


# ----------------------------------------------------------
# 6. Linear dimensionality reduction (PCA)
# ----------------------------------------------------------
# Perform PCA using the previously identified variable genes.
sc_data <- RunPCA(sc_data)

# Quantify variance explained by each principal component.
pct  <- sc_data[["pca"]]@stdev / sum(sc_data[["pca"]]@stdev) * 100
cumu <- cumsum(pct)

# Criterion 1:
# First PC where cumulative variance > 90% AND individual
# PC contributes < 5% variance.
co1 <- which(cumu > 90 & pct < 5)[1]

# Criterion 2:
# Last PC where change in variance between consecutive PCs
# is greater than 0.1%.
co2 <- sort(
  which((pct[1:(length(pct) - 1)] - pct[2:length(pct)]) > 0.1),
  decreasing = TRUE
)[1] + 1

# Final number of informative PCs:
# Conservative choice using the minimum of both criteria.
pcs <- min(co1, co2)
pcs

# Optional visualization of PC variance distribution.
ElbowPlot(sc_data, ndims = 50)


# ----------------------------------------------------------
# 7. Non-linear dimensionality reduction (t-SNE and UMAP)
# ----------------------------------------------------------
# Compute t-SNE and UMAP embeddings using biologically
# informative principal components.
sc_data <- RunTSNE(sc_data, dims = 1:pcs)
sc_data <- RunUMAP(sc_data, dims = 1:pcs)


# ----------------------------------------------------------
# 8. Visualization setup
# ----------------------------------------------------------
library(cowplot)
library(patchwork)
library(ggplot2)


# ----------------------------------------------------------
# 9. Dynamic color assignment for cell types
# ----------------------------------------------------------
cell_types <- levels(Idents(sc_data))

cols_use <- Seurat::DiscretePalette(
  length(cell_types),
  palette = "polychrome"
)
names(cols_use) <- cell_types


# ----------------------------------------------------------
# 10. Generate and save dimensionality reduction plots
# ----------------------------------------------------------

# PCA plot
pca_plot <- DimPlot(
  sc_data,
  reduction = "pca",
  pt.size = 0.1,
  label = TRUE,
  cols = cols_use
)

ggsave(
  filename = "pca_plot.png",
  plot = pca_plot,
  width = 13,
  height = 3.75,
  dpi = 300
)

# t-SNE plot
tsne_plot <- DimPlot(
  sc_data,
  reduction = "tsne",
  pt.size = 0.1,
  label = TRUE,
  cols = cols_use
)

ggsave(
  filename = "tsne_plot.png",
  plot = tsne_plot,
  width = 13,
  height = 3.75,
  dpi = 300
)

# UMAP plot
umap_plot <- DimPlot(
  sc_data,
  reduction = "umap",
  pt.size = 0.1,
  label = TRUE,
  cols = cols_use
)

ggsave(
  filename = "umap_plot.png",
  plot = umap_plot,
  width = 13,
  height = 3.75,
  dpi = 300
)

# Extract legend
legend <- get_legend(umap_plot)
ggsave(
  filename = "legend.png",
  plot = legend,
  width = 3,
  height = 4,
  dpi = 300
)