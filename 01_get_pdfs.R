# install.packages("tidyverse") # Uncomment if you need to install.
library(tidyverse)
library(rvest)
library(glue)

rm(list = ls())

# 1. Get List of PDFs ----
cls_url <- "https://cls.ucl.ac.uk/cls-studies"

get_study_page <- function(study_stub){
  glue("{cls_url}/{study_stub}") %>% 
    read_html()
}

get_sweep_urls <- function(study_page){
  study_page %>% 
    html_nodes("a") %>% 
    html_attr("href") %>%
    str_subset("-sweep\\/$")
}

get_doc_items <- function(sweep_url){
  read_html(sweep_url) %>%
    html_nodes(".item")
}

get_pdf_urls <- function(doc_items){
  change_to_na <- function(x){
    if (length(x) == 0){
      y <- NA
    } else{
      y <- x
    }
    return(y)
  }
  
  pdf_urls <- map_chr(doc_items,
                      ~ .x %>%
                        html_nodes(".btn_download") %>%
                        html_attr("href") %>%
                        change_to_na())
  h3_text <- map_chr(doc_items,
                     ~ .x %>% 
                       html_nodes("h3") %>%
                       html_text() %>%
                       change_to_na())
  
  tibble(title = h3_text, pdf_url = pdf_urls) %>%
    drop_na()
}

clean_sweep <- function(sweep_urls){
  start <- str_locate(sweep_urls, "age")[, 1]
  end <- str_locate(sweep_urls, "sweep")[, 1] - 2
  
  str_sub(sweep_urls, start, end)
}

df_pdf <- c(ncds = "1958-national-child-development-study",
  bcs70 = "1970-british-cohort-study",
  next_steps = "next-steps",
  mcs = "millennium-cohort-study") %>%
  enframe(name = "study", value = "study_stub") %>%
  mutate(study_clean = ifelse(study == "next_steps", "Next Steps", str_to_upper(study)),
         study_page = map(study_stub, get_study_page),
         sweep_url = map(study_page, get_sweep_urls)) %>%
  select(-study_page) %>%
  unchop(sweep_url) %>%
  filter(str_detect(sweep_url, study_stub)) %>%
  distinct() %>%
  mutate(doc_items = map(sweep_url, get_doc_items),
         pdf_info = map(doc_items, get_pdf_urls)) %>%
  select(-doc_items) %>%
  unnest(pdf_info) %>%
  mutate(sweep = str_remove(sweep_url, cls_url) %>%
           str_remove(study_stub) %>%
           str_remove_all("\\/") %>%
           str_remove("^(ncds|bcs70|mcs|next-steps)") %>%
           str_remove("sweep$") %>%
           str_remove("age") %>%
           str_replace_all("\\-", " ") %>%
           str_squish() %>%
           str_to_title() %>%
           str_replace("(\\d+)", "\\1y") %>%
           str_replace("y Months", "m") %>%
           str_replace("Birth", "0y"),
         sweep = ifelse(str_count(sweep, "\\d") == 1,
                        str_replace(sweep, "(\\d+)", "0\\1"),
                        sweep)) %>%
  group_by(title, pdf_url) %>%
  mutate(n_cohorts = unique(study) %>% length()) %>%
  group_by(study, title, pdf_url) %>%
  mutate(n_sweeps = n()) %>%
  ungroup() %>%
  mutate(folder = case_when(n_cohorts > 1 ~ "All",
                            n_sweeps > 1 ~ glue("{study_clean}/xwave"),
                            TRUE ~ glue("{study_clean}/{sweep}")),
         file = glue("{folder}/{title}.pdf")) %>%
  distinct(folder, file, pdf_url)

# 2. Create Directories ----
df_pdf %>%
  distinct(folder) %>%
  pull(folder) %>%
  walk(~ dir.create(.x, recursive = TRUE, showWarnings = FALSE))

# 3. Download PDFs ----
walk2(df_pdf$pdf_url, df_pdf$file, ~ download.file(.x, destfile = .y, mode = "wb"))
