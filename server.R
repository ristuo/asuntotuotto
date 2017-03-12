library(shiny)
source("asunto.R")


# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  output$text <- renderText({
    menetelma <- switch( input$menetelma
                       , Tasaerä = "tasalyhennys"
                       , Annuiteetti = "annuiteetti" )
    res <- asunto( hinta = input$hinta
                 , maksuosuus = input$maksuosuus
                 , laina_aika = input$laina_aika
                 , hoitovastike = input$hoitovastike
                 , euribor = input$euribor
                 , marginaali = input$marginaali
                 , verovahennys = input$verovahennys
                 , alijaamahyvitys = input$alijaamahyvitys
                 , osaketuotto = input$osaketuotto
                 , arvonnousu = input$arvonnousu
                 , vuokra = input$vuokra
                 , menetelma = menetelma )
    paste0("Osaketuotto: ", round(res$osake,0), ", asuntotuotto: ", round(res$asunto,0))
  })
})


