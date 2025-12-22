# Deconvolution of Bulk RNA-seq DEGs Using scRNA-seq Reference

This repository contains the analysis pipeline used to **deconvolve bulk-tissue RNA-seq differential expression results** using a **single-cell RNA-seq (scRNA-seq) reference dataset**, enabling identification of **cell-type–specific gene expression signatures** underlying bulk transcriptomic changes.

The workflow integrates:
- Bulk RNA-seq DESeq2 results  
- A curated scRNA-seq reference from mouse cortex  
- Dimensionality reduction and correlation-based analyses  

---

## Overview of the Analysis Pipeline

The analysis is organized into four main steps:

1. **Identification and filtering of bulk RNA-seq DEGs**
2. **Construction of the scRNA-seq reference object**
3. **Subsetting and preprocessing of the scRNA-seq reference to match bulk tissue composition**
4. **Deconvolution of bulk DEGs using the scRNA-seq reference**

Each step is implemented as a standalone, reproducible script.

---

## Step 1: Load and Filter Bulk RNA-seq Differentially Expressed Genes (DEGs)

**Purpose:**  
Identify statistically significant DEGs from bulk RNA-seq and prepare ranked gene lists for downstream integration with scRNA-seq data.

**Key operations:**
- Load DESeq2 results table  
- Remove genes without valid gene symbols  
- Filter by adjusted p-value (`padj < 0.1`)  
- Rank genes by log fold change  
- Split genes by direction of regulation (control vs experimental)  
- Select the top 250 DEGs per condition  

**Inputs:**
- `S1_Table_DESeq.csv` (DESeq2 results)

**Outputs:**
- `ctrl_DEGs`: top downregulated genes  
- `c4_DEGs`: top upregulated genes  

---

## Step 2: Build the scRNA-seq Reference Dataset

**Purpose:**  
Load raw single-cell gene expression data and metadata, and construct a Seurat object for downstream analysis.

**Key operations:**
- Load cell metadata and gene expression matrix  
- Convert data into Seurat-compatible format  
- Create a Seurat object without initial filtering  
- Retain all genes and cells to preserve reference completeness  

**Inputs:**
- `matrix.csv` (gene expression counts)  
- `metadata.csv` (cell annotations)  

**Outputs:**
- `sc_data`: Seurat object containing the scRNA-seq reference dataset  

---

## Step 3: Subset scRNA-seq Reference to Match Bulk Tissue Composition

**Purpose:**  
Restrict the scRNA-seq reference dataset to **cortical cell populations** that are biologically relevant to the bulk-tissue RNA-seq experiment.

**Key operations:**
- Inspect region and subclass metadata distributions  
- Subset cells based on neocortical region labels  
- Remove hippocampal and non-isocortical subclasses  
- Set cell-type subclass labels as active identities  
- Normalize, scale, and identify variable genes  
- Perform PCA, t-SNE, and UMAP  
- Dynamically generate cell-type–adaptive color palettes  
- Save dimensionality reduction plots  

**Inputs:**
- `sc_data` from Step 2  

**Outputs:**
- Filtered and normalized scRNA-seq reference  
- PCA, t-SNE, and UMAP plots (`.png`)  
- Extracted plot legends for figure assembly  

---

## Step 4: Deconvolution of Bulk DEGs Using scRNA-seq Reference

**Purpose:**  
Interpret bulk RNA-seq DEGs by identifying **cell-type–specific gene expression patterns** using the scRNA-seq reference.

**Key operations:**
- Intersect bulk DEGs with scRNA-seq gene universe  
- Use equally sized DEG sets for comparability  
- Scale scRNA-seq expression for DEG genes only  
- Perform PCA using DEG-driven expression  
- Identify genes contributing to DEG-associated variance  
- Compute gene–gene Pearson correlation matrices  
- Perform hierarchical clustering  
- Visualize correlation structure using heatmaps  

**Inputs:**
- `ctrl_DEGs` / `c4_DEGs` from Step 1  
- `sc_data` from Step 3  

**Outputs:**
- DEG-driven PCA plots  
- Correlation heatmaps (`.pdf`)  
- Cell-type–specific gene signature visualizations  

---

## Software and R Packages

This pipeline was developed and tested using:

- **R** (≥ 4.2)  
- **Seurat**  
- **data.table**  
- **ggplot2**  
- **cowplot**  
- **patchwork**  
- **gplots**  

Install required packages using:

```r
install.packages(c("data.table", "ggplot2", "cowplot", "patchwork", "gplots"))
install.packages("Seurat")
