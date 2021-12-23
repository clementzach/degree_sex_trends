colnames_sex_df = c(
  "year",
  "bach_t",
  "bach_annual_pct_change",
  "bach_m",
  "bach_f",
  "bach_f_pct",
  "mast_t",
  "mast_m",
  'mast_f',
  'doct_t',
  'doct_m',
  'doct_f'
)

rm("fields_by_sex") #remove before starting so we can re-run the chunk
for (file in list.files('gender_excel_files')) {
  current_sex_df = readxl::read_xls(paste0('gender_excel_files/', file))
  id_string = colnames(current_sex_df)[1]
  current_sex_df = current_sex_df[-(1:4), 1:12] #remove 13th col if exists, remove first 4 rows because they're just column descriptions
  # get field name
  colnames(current_sex_df) = colnames_sex_df
  start_removed = gsub(pattern = ".{1,} Degrees in ",
                       x = id_string,
                       replacement = '')
  end_removed = gsub(pattern = " conferred .{1,}" ,
                     x = start_removed,
                     replacement = '')
  
  
  ## remove any useless rows from each df
  keep_rows = grep(pattern = "^\\d{4}-\\d{2,} \\.{5,}$", current_sex_df$year)
  
  current_sex_df = current_sex_df[keep_rows, ]
  
  #add the field to each row
  current_sex_df$field = end_removed
  
  current_sex_df$year = substr(current_sex_df$year, start = 1, stop = 4) |> as.numeric()
  
  
  if (exists("fields_by_sex")) {
    fields_by_sex = rbind(current_sex_df, fields_by_sex)
  }
  else {
    fields_by_sex = current_sex_df
  }
}

sex_overall <-
  readxl::read_xls('/Users/zacharyclement/degree_sex_trends/all_degrees_by_sex.xls',
                   skip = 4)

sex_overall <- sex_overall[, -c(7, 9, 11)]

cols_overall <-
  c(
    "year",
    "assoc_t",
    "assoc_m",
    "assoc_f",
    "assoc_pct_f",
    "bach_t",
    "bach_m",
    "bach_f",
    "bach_pct_f",
    "mast_t",
    "mast_m",
    'mast_f',
    'mast_pct_f',
    'doct_t',
    'doct_m',
    'doct_f',
    'doct_pct_f'
  )

colnames(sex_overall) <- cols_overall

keep_rows <-
  grep(pattern = "^\\d{4}-\\d{2,}$", sex_overall$year) #this gets rid of the projected years, but that's okay



sex_overall <- sex_overall[keep_rows, ]

sex_overall$year = substr(sex_overall$year, start = 0, stop = 4)



sex_overall <- lapply(sex_overall, as.numeric) |> data.frame()

temp_field <-
  fields_by_sex$field #the only one we want as non-numeric
fields_by_sex <- lapply(fields_by_sex, as.numeric) |> data.frame()
fields_by_sex$field <- temp_field

fields_by_sex$field <- fields_by_sex$field |>
  gsub(pattern = '^\\s|\n|the ', replacement = '') |>
  stringr::str_to_title() |>
  gsub(pattern = " And In Communications\\s{1,}Technologies", replacement = '')


save(list = c("fields_by_sex", "sex_overall"),
     file = "degree_sex_trends_app/app_data.Rdata")
