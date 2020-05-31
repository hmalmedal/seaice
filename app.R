library(shiny)

ui <- fluidPage(
  titlePanel("Arctic sea ice extent"),
  sidebarLayout(
    sidebarPanel(
      sliderInput(inputId = "percentage",
                  label = "Inter-percentile range",
                  value = 50, min = 0, max = 100, step = 1),
      sliderInput(inputId = "years", label = "Years plotted",
                  value = 1, min = 1, max = 10, step = 1),
      textOutput("explanation"),
      a(href = "https://github.com/hmalmedal/seaice", "GitHub")
    ),
    mainPanel(
      plotOutput("plot")
    )
  )
)

server <- function(input, output) {
  source("seaice_approx.R")

  plot_df <- seaice_approx %>%
    mutate(Year = year(Date))

  year(plot_df$Date) <- 2001

  maxYear <- max(plot_df$Year)

  ribbon_df <- reactive(
    plot_df %>%
      na.omit() %>%
      filter(Year <= maxYear - input$years) %>%
      group_by(Date) %>%
      summarise(max = max(Extent),
                min = min(Extent),
                median = median(Extent),
                upperquantile = quantile(Extent, 0.5 + input$percentage / 200,
                                         type = 8),
                lowerquantile = quantile(Extent, 0.5 - input$percentage / 200,
                                         type = 8),
                .groups = "drop"))

  output$plot <- renderPlot(
    plot_df %>%
      na.omit() %>%
      filter(Year > maxYear - input$years) %>%
      mutate(Year = fct_rev(factor(Year))) %>%
      ggplot(aes(Date)) +
      geom_ribbon(data = ribbon_df(),
                  aes(ymin = min,
                      ymax = max), alpha = 0.2) +
      geom_ribbon(data = ribbon_df(),
                  aes(ymin = lowerquantile,
                      ymax = upperquantile), alpha = 0.2) +
      geom_line(aes(y = Extent, col = Year)) +
      geom_line(data = ribbon_df(), aes(y = median)) +
      scale_x_date(
        breaks = seq(make_date(2001), make_date(2002), by = "month"),
        labels = c("J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D",
                   "J"),
        minor_breaks = NULL) +
      labs(x = NULL, y = "Extent (mill. km²)")
  )

  output$explanation <- renderText(paste0(
    "The lightest band shows the range between the maximum and the minimum ",
    "daily extents for the period from ", min(plot_df$Year), " to ",
    maxYear - input$years, ". ",
    "The darkest band shows the central ", input$percentage,
    " percent range for the same period. ",
    "The black line is the median."))
}

shinyApp(ui = ui, server = server)
