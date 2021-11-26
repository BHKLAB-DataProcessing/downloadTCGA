library(MultiAssayExperiment)
library(curatedTCGAData)
library(TCGAutils)

#'Script to download TCGA data into MultiAssayExperiment objects grouped by each disease code.
#'Generates data_list.csv which contains a list of datasets, and filename for each MultiAssayExperiment objects.
#'Used in TCGADataPipelines.

#'Uses curatedTCGAData library to download MultiAssayExperiment object for 
#'each disease type.
download <- function(outDir, diseaseCodes){
  filenames <- c()
  for(disease in diseaseCodes){
    obj <- curatedTCGAData(
      diseaseCode = disease, assays = "*", version = "2.0.1", dry.run = FALSE
    )
    filename <- paste0("TCGA_", disease, ".rds")
    saveRDS(obj, paste0(outDir, filename))
    filenames <- c(filenames, filename)
    if(disease == "BLCA"){
      break
    }
  }
  return(filenames)
}

# out_dir <- "~/Documents/pfs/"
out_dir <- "/pfs/out/"

data('diseaseCodes', package = "TCGAutils")
colnames(diseaseCodes) <- c("study", "available", "subtype_data", "study_name")
diseaseCodes <- diseaseCodes[(diseaseCodes$available != "No" & diseaseCodes$study %in% c("ACC", "BLCA")), ]

filenames <- download(out_dir, diseaseCodes$study)

diseaseCodes["filename"] <- filenames
diseaseCodes[c("doi", "download_link")] <- NA
write.csv(diseaseCodes, paste0(out_dir, "data_list.csv"), row.names=FALSE)
