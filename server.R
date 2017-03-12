library(shiny)
source("asunto.R")

input_to_asunto <- function(input)
{
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
    res
}

shinyServer(function(input, output) {

  output$text <- renderText({
    res <- input_to_asunto(input)
    paste0("Osaketuotto: ", round(res$osake,0), ", asuntotuotto: ", round(res$asunto,0))
  })
  output$kustannusplot <- renderPlot({
        res <- input_to_asunto(input)
        print(plot_kk_maksut( res$asunto_df ))
    })
})


