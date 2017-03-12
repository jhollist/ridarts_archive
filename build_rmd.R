build_rmd <- function(){
  library(dplyr)
  image_url <- "http://ridarts.com/Rosters,%20Achievements,%20Schedules/Schedules/Central%20%20South%20Roster_files/image002.gif"
  filename <- paste0(format(Sys.time(), "%Y-%m-%d"),".gif")
  months_txt <- c("January", "February", "March", "April","May","June","July","August",
                  "September","October","November","December")
  httr::GET(image_url,httr::write_disk(filename,TRUE))
  files <- data.frame(file = list.files(pattern = ".gif"),stringsAsFactors = FALSE) %>%
    arrange(desc(file)) %>%
    mutate(year = stringr::str_split(file,"-",simplify = T)[,1],
           month = stringr::str_split(file,"-",simplify = T)[,2])
  con <- file("index.Rmd","w")
  yaml <- "---
title: 'Rhode Island Dart League Archive'
output:
  html_document:
    toc: yes
    toc_float: yes
    toc_depth: 2
---\n"
  writeLines(yaml, con)
  for(yr in unique(files$year)){
    yr_md <- paste0("\n", "# ", yr, "\n")
    writeLines(yr_md,con)
    files_yr <- files %>%
      filter(year == yr)
    for(mn in unique(files_yr$month)){
      mn_md <- paste0("\n", "## ", months_txt[as.numeric(mn)], "\n")
      writeLines(mn_md, con)
      files_mn <- files_yr %>%
        filter(month == mn)
      for(im in unique(files_mn$file)){
        im_md <- paste0("- [", stringr::str_replace(im, ".gif", ""), "](", im, ")")
        writeLines(im_md, con)
      }
    }
  }
  close(con)
  rmarkdown::render("index.Rmd")
}
