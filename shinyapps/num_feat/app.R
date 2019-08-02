###
### THIS APP ALLOW TO DISPLAY PLOTS FOR THE DATASET
###


# Load Packages
library('ggthemes')
library('ggplot2')
library('plyr')
library('grid')
library('gridExtra')
library('shiny')
library('shinyjs')

# Load Data
hp_train <- readRDS('data/hp_train.rds')

shinyApp(
  ui = fluidPage(fluidRow(
    selectInput(
      inputId = 'feature',
      label = 'Numerical Feature',
      choices = sort(names(hp_train[, names(hp_train) != 'price'])[sapply(hp_train[, names(hp_train) != 'price'], is.numeric)]),
      selected = 'sqft_living'
    )
  ),
  fluidRow(plotOutput('plot'))),
  
  server = function(input, output) {
    output$plot <- renderPlot({
      g1 <- ggplot(hp_train,
                   aes(x = hp_train[, input$feature])) +
        geom_density(color = 'darkcyan', fill = 'darkcyan') +
        theme_minimal() +
        theme(
          legend.position = 'none',
          plot.title = element_text(
            hjust = 0.5,
            size = 12,
            face = 'bold'
          )
        ) +
        labs(x = '',
             y = 'Density',
             title = paste0(toupper(substr(
               input$feature, 1, 1
             )), tolower(substr(
               input$feature, 2, nchar(input$feature)
             ))))
      
      g2 <- ggplot(hp_train,
                   aes(x = hp_train[, input$feature], y = price)) +
        geom_point(color = 'darkcyan', size = 0.5) +
        theme_minimal() +
        theme(legend.position = 'none') +
        labs(x = '', y = 'House Price')
      
      grobs <- list()
      grobs[[1]] <- g1
      grobs[[2]] <- g2
      grid.arrange(grobs = grobs)
    })
  },
  
  options = list(height = 500)
)

