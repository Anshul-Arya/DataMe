library(readr)
library(ggplot2)
library(shinydashboard)
# read data

recommendation <-
  read_csv(
    "https://raw.githubusercontent.com/amrrs/sample_revenue_dashboard_shiny/master/recommendation.csv"
  )

#app.R#
header <- dashboardHeader(title = "Basic Dashboard")
sidebar <- dashboardSidebar(sidebarMenu(
  menuItem(
    "Dashboard",
    tabName = "dashboard",
    icon = icon("dashboard")
  ),
  menuItem(
    "Visit-us",
    icon = icon("send", lib = "glyphicon"),
    href = "https://www.salesforce.com"
  )
))

frow1 <- fluidRow(valueBoxOutput("value1"),
                  valueBoxOutput("value2"),
                  valueBoxOutput("value3"))
frow2 <- fluidRow(
  box(
    title = "Revenue per Account",
    status = "primary",
    solidHeader = TRUE,
    collapsible = TRUE,
    plotOutput("revenuebyPrd", height = "300px")
  ),
  box(
    title = "Revenue per Product",
    status = "primary",
    solidHeader = TRUE,
    collapsible = TRUE,
    plotOutput("revenuebyRegion", height = "300px")
  )
)

body <- dashboardBody(frow1, frow2)
ui <- dashboardPage(title = "This is my Page Title",
                    header,
                    sidebar,
                    body)
# Create the server function for the Dashboard
server <- function(input, output) {
  # Some data manipulation to derive the values of KPI boxes
  total.revenue <- sum(recommendation$Revenue)
  sales.account <- recommendation %>% group_by(Account) %>%
    summarise(value = sum(Revenue)) %>% filter(value == max(value))
  prof.prod <- recommendation %>% group_by(Product) %>%
    summarise(value = sum(Revenue)) %>%  filter(value == max(value))
  # Creating the Value box  output content
  output$value1 <- renderValueBox({
    valueBox(
      formatC(
        sales.account$value,
        format = "d",
        big.mark = ","
      ),
      paste('Top Account:', sales.account$Account),
      icon = icon("stats", lib = "glyphicon"),
      color = "purple"
    )
  })
  output$value2 <- renderValueBox({
    valueBox(
      formatC(total.revenue, format = "d", big.mark = ',')
      ,
      'Total Expected Revenue'
      ,
      icon = icon("gbp", lib = 'glyphicon')
      ,
      color = "green"
    )
    
  })
  output$value3 <- renderValueBox({
    valueBox(
      formatC(prof.prod$value, format = "d", big.mark = ',')
      ,
      paste('Top Product:', prof.prod$Product)
      ,
      icon = icon("menu-hamburger", lib = 'glyphicon')
      ,
      color = "yellow"
    )
  })
  # Creating the Plotoutput content
  output$revenuebyPrd <- renderPlot({
    ggplot(data = recommendation,
           aes(
             x = Product,
             y = Revenue,
             fill = factor(Region)
           )) +
      geom_bar(position = position_dodge(), stat = "identity") +
      ylab("Revenue(in Euros)") +
      xlab("Product") + theme(legend.position = "bottom",
                              plot.title = element_text(size = 15,
                                                        face = "bold")) +
      ggtitle("Revenue by Product") + labs(fill = "Region")
  })
  output$revenuebyRegion <- renderPlot({
    ggplot(data = recommendation,
           aes(
             x = Account,
             y = Revenue,
             fill = factor(Region)
           )) +
      geom_bar(position = position_dodge(), stat = "identity") +
      ylab("Revenue (in Euros)") +
      xlab("Account") + theme(legend.position = "bottom",
                              plot.title = element_text(size = 15,
                                                        face = "bold")) +
      ggtitle("Revenue by Region") + labs(fill = "Region")
    
  })
}
shinyApp(ui, server)
