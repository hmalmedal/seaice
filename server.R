source("seaice_approx.R")

library(lubridate)
plot_df <- seaice_approx %>%
  mutate(Year = year(Date))
year(plot_df$Date) <- 2001

maxYear <- max(plot_df$Year)

library(shiny)
library(ggvis)

shinyServer(function(input, output) {

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
                                         type = 8)))

  reactive(
    plot_df %>%
      na.omit() %>%
      filter(Year > maxYear - input$years) %>%
      mutate(Year = forcats::fct_rev(factor(Year)))) %>%
    ggvis(~Date, ~Extent, stroke = ~Year) %>%
    layer_lines() %>%
    add_data(ribbon_df) %>%
    layer_ribbons(y = ~max, y2 = ~min, stroke := "black",
                  opacity := 0.2, strokeOpacity := 0) %>%
    layer_ribbons(y = ~upperquantile, y2 = ~lowerquantile, stroke := "black",
                  opacity := 0.2, strokeOpacity := 0) %>%
    layer_paths(y = ~median, stroke := "black") %>%
    add_axis("x", title = "", format = "%b") %>%
    add_axis("y", title = "Extent (mill. km²)") %>%
    bind_shiny("ggvis")

  output$explanation <- renderText(paste0(
    "The lightest band shows the range between the maximum and the minimum ",
    "daily extents for the period from ", min(plot_df$Year), " to ",
    maxYear - input$years, ". ",
    "The darkest band shows the central ", input$percentage,
    " percent range for the same period. ",
    "The black line is the median."))

})
