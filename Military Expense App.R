library(shiny)
library(plotly)
library(dplyr)
library(ggplot2)
library(tidyr)
library(stringr)

# READ THE DATA
options(scipen=999)
#setwd("C:/Users/Anshul Arya/Desktop/Sem 2/Data Visualisation/Assignment3")
percapita <- read.csv("File2.csv", header = T, na.strings = c(c("xxx","",". .",
                                                            ". ."),"NA"))
head(percapita)

# Convert the data to long format
percapita = gather(percapita, "Year", "per_capita", X1949:X2017)
percapita$Year <- as.numeric(str_replace(percapita$Year, "\\w",""))
percapita[is.na(percapita)] <- 0
percapita$per_capita <- as.numeric(percapita$per_capita)

percapita[is.na(percapita)] <- 0
percapita <- percapita[order(percapita$Country),]
#percapita$per_capita <- format(percapita$per_capita)
percapita <- percapita %>% filter(Country != "Kuwait")
percapita <- percapita %>% filter(Country != "USA")
head(percapita)

# Read the Share per GDP data
share_GDP <- read.csv("SIPRI-Milex-data-1949-2017.csv", header = T, 
                      na.strings = c(c("xxx","",". ."),"NA"))
head(share_GDP)

# Convert the data to long format
share_GDP_long <- gather(share_GDP, "Year", "Perc_of_GDP", X1949:X2017)
share_GDP_long$Year <- as.numeric(str_replace(share_GDP_long$Year, "\\w",""))
share_GDP_long[is.na(share_GDP_long)] <- 0
share_GDP_long$Perc_of_GDP <- gsub("%","",share_GDP_long$Perc_of_GDP)
share_GDP_long$Perc_of_GDP <- as.numeric(share_GDP_long$Perc_of_GDP)
share_GDP_long <- share_GDP_long[order(share_GDP_long$Country),]
share_GDP_long <- share_GDP_long %>% filter(Country != "Kuwait")
share_GDP_long <- share_GDP_long %>% filter(Country != "USA")
head(share_GDP_long)

share_GDP_capita <- merge(share_GDP_long, percapita)
head(share_GDP_capita)

# Define the server for Military Expense Shiny App
server_ans <- function(input, output) {
  output$assignment3 <- renderPlotly({
    share_GDP_capita$highlight <- ifelse(share_GDP_capita$Country == input$highlight,
                                       input$highlight, "Other")
    share_GDP_capita$highlight <- share_GDP_capita$highlight %>% 
      factor(levels = c(input$highlight, "other"))
    
    col <- ifelse(input$highlight == "Continent", "Continent",
                  "highlight")
    plot_ly(share_GDP_capita, x = ~per_capita, y = ~Perc_of_GDP, color = ~get(col),
            colors = "Set1", frame = ~Year, alpha = 1, type = "scatter", mode = "markers") %>%
      layout(title = "Military expense as % of GDP",
             yaxis = list(zeroline = FALSE, title = "% of GDP"),
             xaxis = list(zeroline = FALSE, title = "Military Expense in US$ million"))
  })
}

# Define the UI for Military Expense App
ui_ans <- fluidPage(
  titlePanel("Military expense by"),
  sidebarLayout(
    sidebarPanel(
      selectInput("highlight", "Select Country",
                  choices = c("Continent", levels(share_GDP_capita$Country)),
                  selected = "Continent")
    ),
    mainPanel(plotlyOutput("assignment3"))
  )
)

# Deploy the App
shinyApp(ui = ui_ans, server = server_ans)

# Visualisation URL
# https://anshul-arya27.shinyapps.io/MATH2270-Assignment/
