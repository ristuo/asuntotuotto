library(shiny)
library(magrittr)

hinta_slider <- sliderInput( "hinta"
                           , "Asunnon hinta:"
                           , min = 0
                           , max = 300000
                           , value = 175000 )

maksuosuus_slider <- sliderInput( "maksuosuus"
                                , "Käsiraha"
                                , min = 0
                                , max = 300000
                                , value = 20000 )

hoitovastike_slider <- sliderInput( "hoitovastike"
                                  , "Ostettavan asunnon vastike"
                                  , min = 0
                                  , max = 800
                                  , value = 150 )

euribor_slider <- sliderInput( "euribor"
                             , "Euribor"
                             , min = 0
                             , max = 0.15
                             , value = 0.01 )

marginaali_slider <- sliderInput( "marginaali"
                                , "Pankin marginaali:"
                                , min = 0
                                , max = 0.03
                                , value = 0.0135 )

verovahennys_slider <- sliderInput( "verovahennys"
                                  , "Korkovähennys"
                                  , min = 0
                                  , max = 0.35
                                  , value = 0 )

alijaamahyvitys_slider = sliderInput( "alijaamahyvitys"
                                    , "Alijäämähyvitys"
                                    , min = 0
                                    , max = 1
                                    , value = 0.3 )

osaketuotto_slider = sliderInput( "osaketuotto"
                                , "Osaketuotto"
                                , min = 0
                                , max = 0.1
                                , value = 0.045 )

arvonnousu_slider = sliderInput( "arvonnousu"
                               , "Asunnon arvonnousu maksuaikana"
                               , min = 0
                               , max = 2
                               , value = 0.05 )

vuokra_slider = sliderInput( "vuokra"
                           , "Vuokra"
                           , min = 0
                           , max = 1200
                           , value = 700 )

menetelma_radio = radioButtons( "menetelma"
                              , "Maksumenetelmä"
                              , c("Annuiteetti", "Tasaerä")
                              , "Annuiteetti" )

laina_aika_slider <- sliderInput( "laina_aika"
                           , "Laina-aika vuosissa:"
                           , min = 1
                           , max = 30
                           , step = 1
                           , value = 20 )

fluidPage( titlePanel("Asuntotuottolaskuri")
         , sidebarLayout( sidebarPanel( hinta_slider
                                      , maksuosuus_slider
                                      , laina_aika_slider
                                      , hoitovastike_slider
                                      , euribor_slider
                                      , marginaali_slider 
                                      , verovahennys_slider
                                      , alijaamahyvitys_slider
                                      , osaketuotto_slider
                                      , arvonnousu_slider
                                      , vuokra_slider
                                      , menetelma_radio )
                        , mainPanel( textOutput("text")))) %>% 
shinyUI
