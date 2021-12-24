# degree_sex_trends
Dashboard of trends in education by gender over time

This project creates a shiny dashboard displaying the proportion of college degrees awarded to women over time. 
A web version of the dashboard can be found [here](https://zachary-clement.shinyapps.io/degree_sex_trends_app)

The files in this repo are: 

data_exploration.Rmd: an R markdown document I usued to explore and develop a cleaning strategy for the data

clean_data.R: An R script which reads files in the gender_excel_files folder and the all_degrees_by_sex.xls folders 
to create an .Rdata file for the shiny app. 

degree_sex_trends_app/app.R: the shiny app displaying results. 

all_degrees_by_sex.xls, and excel files in gender_excel_files folder: downloaded from [here](https://nces.ed.gov/programs/digest/2019menu_tables.asp)



