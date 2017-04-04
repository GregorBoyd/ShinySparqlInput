library(shiny)
library(SPARQL) 
library(DT)
library(leaflet)
library(geojsonio)
require(stringr)

# Step 1 - Set up preliminaries and define query
# Define the statistics.gov.scot endpoint
endpoint <- "http://statistics.gov.scot/sparql"

function(input, output, session) {
  #only run when submit button clicked
  observeEvent(input$submit, {
  output$mymap <- renderLeaflet({ 

  withProgress(min = 0, max = 1, message = 'Fetching Data and Displaying Results',
                 detail = 'This may take a few seconds...', value = 0, {

# create query statement
query2 <-
  # use isolate so query isn't rerun when input postcode changes
  isolate(
  # paste the postcode into the sparql query
  paste(
    "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#> 
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> 
    PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
    PREFIX qb: <http://purl.org/linked-data/cube#> 
    PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
    SELECT ?DataZone ?Decile 
    WHERE {
    ?s rdf:type <http://data.ordnancesurvey.co.uk/ontology/postcode/PostcodeUnit>.
    ?s rdfs:label ", "'",  input$postcode   ,"'", ".
    ?s <http://statistics.gov.scot/def/postcode/dataZone2011> ?DZuri.
    ?DZuri skos:notation ?DataZone. 
    ?r <http://purl.org/linked-data/sdmx/2009/dimension#refArea>  ?DZuri.
    ?r qb:dataSet <http://statistics.gov.scot/data/scottish-index-of-multiple-deprivation-2016>.
    ?r <http://statistics.gov.scot/def/dimension/simdDomain> <http://statistics.gov.scot/def/concept/simd-domain/simd>.
    ?r <http://purl.org/linked-data/sdmx/2009/dimension#refPeriod> <http://reference.data.gov.uk/id/year/2016>.
    ?r <http://purl.org/linked-data/cube#measureType> <http://statistics.gov.scot/def/measure-properties/decile>. 
    ?r <http://statistics.gov.scot/def/measure-properties/decile> ?Decile
    }",sep="")
)

querydata2 <- SPARQL(endpoint,query2)
SIMDdata <- querydata2$results
incProgress(2/10)
SIMDdata["DataZone"] = substr(SIMDdata["DataZone"], 2,10)
SIMDdata["DataZone"] = str_trim(SIMDdata["DataZone"])
datatable(SIMDdata)
incProgress(1/10)
url <- paste("http://statistics.gov.scot/boundaries/",SIMDdata["DataZone"],".json",sep="")
incProgress(1/10)
out <- geojson_read(url,what = "sp")
datatable(head(iris), options = list(dom = 't'))
output$tbl = DT::renderDataTable(
SIMDdata, options = list(dom = 't'))
incProgress(1/10)

leaflet(out) %>%
  addProviderTiles(providers$CartoDB.Positron,
                   options = providerTileOptions(noWrap = TRUE)
  ) %>%
  addPolygons(stroke = TRUE, smoothFactor = 0.3, fillOpacity = 0.3
  )
  })
  })
  })
}
 
  


