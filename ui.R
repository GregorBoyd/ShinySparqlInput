library(leaflet)

ui <- fluidPage(

  textInput("postcode", "Enter Postcode", "EH1 3DG"),
  verbatimTextOutput("value"),
  
  actionButton("submit","Search"),
  br(),
  DT::dataTableOutput('tbl'),
  br(),
  leafletOutput("mymap")
  
)