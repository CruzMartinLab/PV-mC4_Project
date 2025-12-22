############################################################
# STEP 1: Load and filter differentially expressed genes
# Description:
#   This script loads DESeq2 differential expression results,
#   filters significant genes, and separates them by direction
#   of change for downstream analyses.
############################################################

# ----------------------------
# Input file
# ----------------------------
DEGs_file <- "S1_Table_DESeq.csv"   # DESeq2 results table (CSV)

# ----------------------------
# Load data
# ----------------------------
degs <- read.csv(DEGs_file, stringsAsFactors = FALSE)

# ----------------------------
# Basic filtering
# ----------------------------
# Remove rows with missing gene symbols
# Keep only statistically significant genes
degs <- degs[!is.na(degs$gene) & degs$padj < 0.1, ]

# ----------------------------
# Rank by fold change
# ----------------------------
# Order genes by log fold change (descending)
degs <- degs[order(-degs$logFC), ]

# ----------------------------
# Subset by direction of change
# ----------------------------
# Genes downregulated in C4 vs Control
ctrl_DEGs <- degs[degs$logFC < 0, ]

# Genes upregulated in C4 vs Control
c4_DEGs <- degs[degs$logFC > 0, ]

# ----------------------------
# Extract gene symbol vectors
# ----------------------------
ctrl_genes <- ctrl_DEGs$gene
c4_genes   <- c4_DEGs$gene
