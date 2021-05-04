#update_grid.R
#
#Seferin James, BA, MLitt, PhD
#
#2021/05/04
#
#grid_update is an R script that checks for the latest release of the GRID database of institutional data by Digital Science (https://www.grid.ac/). Details about the most recent update are retrieved via the figshare api. The most recent data is downloaded as a zip file if it is not already available locally and extracted. A log file is created and the zip file tidied up.

#Scrip depends on base, curl and jsonlite packages.

update_grid <- function (path_data = "./data/") {
  required_packages <- c("curl", "jsonlite")
  lapply(required_packages, require, character.only = TRUE)
  
  #Check for valid path_data value
  if(!is.na(path_data)){
    if(path_data != ""){
      
      if(!grepl("/$", path_data)){
        path_data <- paste0(path_data, "/")
      }
      
    }else{
      warning("path_data is NULL in grid_update call")
      return(NULL)
    }
  }else{
    
    warning("path_data is NA in grid_update call")
    return(NULL)
    
  }
  
  #Ensure path_data exists
  if(!dir.exists(path_data)){
    dir.create(path_data)
    if(!dir.exists(path_data)){
      warning("path_data does not exist and an attempt to create it has failed")
      return(NULL)
    }
  }
  
  #Function to get information on GRID releases, returns url and date of most recent release
  #The two web get functions could possibly be consoidated into one that returns json res
  web_get_update_details <- function () {
    res <- curl_fetch_memory("https://api.figshare.com/v2/collections/3812929/articles")
    res <- fromJSON(rawToChar(res$content))[,c("url", "published_date")]
    res <- res[which(res$published_date == max(res$published_date)),]
    return(res)
    }
  
  #Function to retrieve the most recent filename and download link
  web_get_file_details <- function (url) {
    res <- curl_fetch_memory(url)
    res <- fromJSON(rawToChar(res$content))
    res <- as.data.frame(res[['files']])
    res <- res[,c("name","download_url")]
    return(res)
  }
  
  web_get_file_download <- function(file_details, path_data){
    download.file(file_details$download_url, 
                  paste0(path_data, file_details$name), mode="wb")
    
    #Strip trailing slash from path_data prior to unzip method
    safe_path_data <- gsub("/$", "", path_data)
    
    #Unzip the latest release
    unzip(paste0(path_data, file_details$name), overwrite = T, exdir = safe_path_data)
    
    # Create log record
    fileConn <- file(paste0(path_data, "download_log.txt"))
    writeLines(file_details$name, fileConn)
    close(fileConn)
    
    # Tidy up
    if (file.exists(paste0(path_data, file_details$name))){
      result <- file.remove(paste0(path_data, file_details$name))
    }
  }
  
  update_details <- web_get_update_details()
  
  file_details <- web_get_file_details(update_details$url)
  
  #Test whether local data is already latest release
  if (file.exists(paste0(path_data, "download_log.txt"))){
    
    # Read log record value
    rec <- read.table(paste0(path_data, "download_log.txt"), 
               colClasses = "character")[1, 1]
    
    # Download if log is not the most recent release
    if(rec==file_details$name){
      cat("Local GRID data cache already latest release\n")
    } else {
      web_get_file_download(file_details, path_data)
    }
    
  } else {
    # Download if no log found
    web_get_file_download(file_details, path_data)
  }
}
