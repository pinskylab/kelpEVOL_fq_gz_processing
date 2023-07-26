#### Plot Read Length Distribution ####
## Take the output of read-length_counter.sh and visualize in a barplot.
## Kevin Labrador
#######################################

#### INITIALIZATION ####

# Delete all 
rm(list=ls())

# Set working directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Load Libraries
pacman::p_load (
  tidyverse, 
  janitor
)


#### USER DEFINED VARIABLES ####

inFilePath <- "./read-length-distribution_fp1.txt"
outFilePath <- "./barplot_read-length-distribution.png"

#### READ IN DATA AND CURATE ####
df <- 
  read.table(inFilePath, 
             sep = "\t",
             header = T
  ) %>% 
  mutate (filename = File,
          library_id =  str_extract(filename, "([^/]+)-[^-.]+"),
          read = str_extract(filename, "r\\d")
  ) %>% 
  select (- File
  ) %>% 
  clean_names

#### VISUALIZE ####
(p1 <- 
   ggplot (df,
           aes (x=read_length, 
                y = frequency,
                fill=read)
   ) +
   geom_col(alpha=0.5,
            col="black") +
   facet_grid(read~library_id) +
   guides (fill = "none") +
   xlim (100, 151) +
   theme_bw() +
   theme (axis.text.x = element_text(angle=45,
                                     hjust=1, 
                                     vjust=1)
   )
)

# Save output
ggsave (p1,
        filename = outFilePath,
        width = 7,
        height = 5,
        units = "in"
)


#### END ####
