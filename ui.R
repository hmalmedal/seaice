library(shiny)
library(ggvis)

shinyUI(fluidPage(

  titlePanel("Arctic sea ice extent"),

  ggvisOutput("ggvis"),

  hr(),

  fluidRow(
    column(width = 3,
           sliderInput(inputId = "percentage",
                       label = "Inter-percentile range",
                       value = 50, min = 0, max = 100, step = 1)),
    column(width = 3,
           sliderInput(inputId = "years", label = "Years plotted",
                       value = 2, min = 1, max = 10, step = 1))),

  a(href = "https://github.com/hmalmedal/seaice", "GitHub")

))
