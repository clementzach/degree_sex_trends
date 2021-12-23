


load("app_data.Rdata") #get the data


library(shiny)
library(ggplot2)


ui <- fluidPage(tabsetPanel(
    tabPanel(
        "Percent Female",
        
        h3("Proportion of Female Degrees over Time"),
        
        sidebarLayout(
            sidebarPanel(
                selectInput(
                    "degree_level",
                    label = "Degree Level",
                    choices = c("Bachelor's", "Master's", "Doctor's"),
                    selected = "Bachelor's"
                ),
                
                checkboxGroupInput(
                    "fields",
                    "Field of Study",
                    choices = sort(unique(fields_by_sex$field)),
                    selected = "Business"
                )
            ),
            mainPanel(plotOutput("percent_by_field"))
            
        )
    ),
    #end tabpanelbody1
    tabPanel(
        "Total Female vs Male",
        h3("Total Female and Male Degrees in a Field"),
        sidebarLayout(
            sidebarPanel(
                selectInput(
                    "degree_level_t",
                    label = "Degree Level",
                    choices = c("Bachelor's", "Master's", "Doctor's"),
                    selected = "Bachelor's"
                ),
                
                selectInput(
                    "field_t",
                    "Field of Study",
                    choices = sort(unique(fields_by_sex$field)),
                    selected = "Business"
                )
            ),
            mainPanel(plotOutput("total_by_field"))
            
            
        )
    )
))


server <- function(input, output) {
    fields <- reactive({
        input$fields
    })
    
    degree_level <- reactive({
        input$degree_level
    })
    
    
    output$total_by_field <- renderPlot({
        short_level = tolower(input$degree_level_t) |> substr(start = 0, stop = 4)
        only_field <-
            fields_by_sex[fields_by_sex$field == input$field_t, ]
        
        pct_female <-
            only_field[, paste0(short_level, "_f")] / only_field[, paste0(short_level, "_t")]
        
        
        #using the aes_ forces eager evaluation
        ggplot() +
            geom_line(aes(
                x = only_field$year,
                y = only_field[, paste0(short_level, "_f")],
                col = paste0(input$field_t, " (Women)")
            )) +
            geom_line(aes(
                x = only_field$year,
                y = only_field[, paste0(short_level, "_m")],
                col = paste0(input$field_t, " (Men)")
            )) +
            scale_color_discrete(type = c("steelblue", "mediumvioletred")) +
            labs(
                title = paste0("Total degrees granted at ", degree_level(), " level"),
                col = "",
                x = "Year",
                y = "Number of Degrees Granted",
                caption = "Data Provided by NCES"
            ) +
            theme_light() +
            theme(legend.position = "bottom") +
            guides(color = guide_legend(ncol = 2,
                                        byrow = TRUE))
        
        
    })
    
    
    
    
    output$percent_by_field <- renderPlot({
        short_level = tolower(degree_level()) |> substr(start = 0, stop = 4)
        x_min = 1968 #initial values should look okay with the overall
        x_max = 2016.5
        y_min = .2 #don't want to be restricting the range of our visualization
        y_max = .8
        
        p <- ggplot() + geom_line(aes(
            x = sex_overall$year,
            y = sex_overall[, paste0(short_level, "_pct_f")] / 100,
            col = "Overall"
        ))
        
        for (field in fields()) {
            only_field <- fields_by_sex[fields_by_sex$field == field, ]
            
            only_field <-
                only_field[order(only_field$year), ] #should already be ordered but just in case
            
            pct_female <-
                only_field[, paste0(short_level, "_f")] / only_field[, paste0(short_level, "_t")]
            #check if we need to update the mins/maaxes
            y_min = min(y_min, pct_female)
            y_max = max(y_max, pct_female)
            x_min = min(x_min, min(only_field$year))
            
            
            #using the aes_ forces eager evaluation
            p <- p + geom_line(aes_(
                x = only_field$year,
                y = pct_female,
                col = field
            ))
        }
        
        
        p +
            scale_size_continuous(guide = "none") +
            labs(
                title = paste0("Percent Female Degrees at ", degree_level(), " level"),
                col = "",
                x = "Year",
                y = "Percent Female",
                caption = "Data Provided by NCES"
            ) +
            xlim(x_min, x_max) +
            theme_light() +
            ylim(y_min, y_max) +
            theme(legend.position = "bottom") +
            guides(color = guide_legend(ncol = 2,
                                        byrow = TRUE))
    })
}

# Run the application
shinyApp(ui = ui, server = server)
