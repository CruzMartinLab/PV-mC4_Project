############################################################
# STEP 2: Load the single-cell expression dataset and
#         construct the Seurat single-cell object
############################################################

# ----------------------------------------------------------
# 1. Load the single-cell gene expression matrix and metadata
# ----------------------------------------------------------

# Set the working directory to the folder containing the
# single-cell RNA-seq data files (metadata and count matrix)
path <- "~/AllenBrainMap_MouseCortexAndHippo_SMART-seq/"
setwd(path)

# Read the single-cell metadata table
# Rows correspond to cells; row names are cell barcodes
metadata <- read.csv("metadata.csv", row.names = 1)

# Load the data.table package to access fread(),
# a fast and memory-efficient function for reading large files
library(data.table)

# Read the raw gene expression count matrix from disk
# The table is expected to contain a column named 'sample_name'
# corresponding to cell barcodes
counts <- fread("matrix.csv", data.table = FALSE)

# Set cell barcodes as row names of the count matrix
rownames(counts) <- counts$sample_name

# Remove the 'sample_name' column so that only gene counts remain
counts <- counts[, !names(counts) %in% c("sample_name")]

# Convert the count table to a numeric matrix
counts <- as.matrix(counts)

# Transpose the count matrix so that:
#   - Rows represent genes
#   - Columns represent cells
# This format is required by Seurat
transposed_counts <- t(counts)

# Remove the original counts object to reduce memory usage
rm(counts)

# Trigger garbage collection to free unused memory
gc()

# ----------------------------------------------------------
# 2. Build the Seurat single-cell dataset object
# ----------------------------------------------------------

# Load the Seurat library
library(Seurat)

# Create the Seurat object using raw (unfiltered) counts
# and associated cell metadata
# min.cells = 0     -> keep all genes
# min.features = 0 -> keep all cells
sc_data <- CreateSeuratObject(
  counts = transposed_counts,
  meta.data = metadata,
  min.cells = 0,
  min.features = 0,
  project = "AllenBrainMap_MouseCortex_SMART-seq_2019_with_10x_SMART-seq_2020_taxonomy"
)

# Remove intermediate objects to free memory
rm(transposed_counts)
rm(metadata)

# Final garbage collection
gc()
