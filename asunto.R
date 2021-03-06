library(ggplot2)
library(dplyr)
library(magrittr)
library(reshape2)

vuosikorko_to_compounding <- function(vuosikorko, m)
{
    if (vuosikorko < 1)
    {
        vuosikorko <- vuosikorko + 1
    }
    vuosikorko^(1/m) - 1
}


annuiteetin_kk_era <- function(r, n, s)
{
    a <- g(r, n, s, 0 )
    f_x2 <- g(r, n, s, 150)
    b <- (f_x2 - a) / 150
    (-a)/b 
}

g <- function(r, n, s, x)
{
    s + r * sum( ci_( s, n, r, x) ) - n*x
}

ci_ <- function( s, i, r, x )
{
    ci_memo <- c(s, rep(NA, i-1))
    ci_compute <- function(s, i, r, x)
    {
        if (!is.na(ci_memo[i]))
        {
            return(ci_memo[i])   
        }
        if (i == 1)
        {
            return(s)
        }
        sum <- 0
        for (j in 1:(i-1))
        {
            sum <- sum + ci_compute( s, j, r, x) 
        }
        res <- s - (i-1) * x + sum * r
        ci_memo[i] <<- res
        res
    }
    ci_compute( s, i, r, x )
    ci_memo
}

annuiteetti <- function( hinta
                       , maksuosuus
                       , laina_aika
                       , euribor
                       , marginaali )
{
    s <- hinta - maksuosuus
    kk_eria <- laina_aika * 12
    r <- vuosikorko_to_compounding(euribor + marginaali, 12)
    kk_era <- annuiteetin_kk_era( r, kk_eria, s )
    jaljella <- ci_( s, kk_eria, r, kk_era )
    res <- data.frame( kuukausi = 1:kk_eria
                     , maksu = kk_era
                     , jaljella = jaljella
                     , maksettava_korko = r * jaljella
                     , maksettava_paaoma = kk_era - (r*jaljella) )
    res
}

tasalyhennys <- function( hinta
                        , maksuosuus
                        , laina_aika 
                        , euribor
                        , marginaali )
{
    velka <- hinta - maksuosuus
    kk_korko <- vuosikorko_to_compounding( euribor + marginaali, 12 )
    kk_eria <- laina_aika * 12
    kiintea_era <- velka / kk_eria
    res <- data.frame( kuukausi = 1:kk_eria
                     , maksu = vector("numeric", kk_eria)
                     , jaljella = vector("numeric", kk_eria)
                     , maksettava_korko = vector("numeric", kk_eria)
                     , maksettava_paaoma = vector("numeric", kk_eria) )
    res$maksettava_paaoma <- kiintea_era
    for (i in 1:kk_eria)
    {
        res$jaljella[i] <- velka 
        maksettava_korko <- velka * kk_korko
        maksu <- kiintea_era + maksettava_korko
        velka <- velka - kiintea_era 
        res$maksu[i] <- maksu
        res$maksettava_korko[i] <- maksettava_korko
    }
    res
}

asunto <- function( hinta = 175000
                  , maksuosuus = 20000
                  , laina_aika = 20
                  , hoitovastike = 150
                  , euribor = 0.01
                  , marginaali = 0.0135
                  , verovahennys = 0.25
                  , alijaamahyvitys = 0.3
                  , osaketuotto = 0.03
                  , arvonnousu = 0
                  , vuokra = 750
                  , menetelma = "annuiteetti" )
{
    f <- switch( menetelma
               , annuiteetti = annuiteetti
               , tasalyhennys = tasalyhennys 
               , NULL )
    if (is.null(f))
    {
        msg <- paste0( "Sallittuja maksuaikatauluja ovat "
                     , "annuiteetti ja tasalyhennys, ei esim. "
                     , menetelma
                     , "\n")
        stop(msg)
    }
    res <- f( hinta = hinta
            , maksuosuus = maksuosuus
            , laina_aika
            , euribor
            , marginaali )
    res$korkovahennys <- res$maksettava_korko * verovahennys * alijaamahyvitys
    res$vastike <- hoitovastike
    res$kokonaiskustannus <- res$vastike + res$maksu - res$korkovahennys 
      
    osaketuotto_kk <- osaketuotto/12
    korot <- (1 + osaketuotto_kk ) ^ ((laina_aika*12):1)
    osakerahat <- sum(( res$kokonaiskustannus - vuokra ) * korot) + 
                  maksuosuus * ( (1 + osaketuotto_kk) ^ (laina_aika*12) )
    asuntorahat <- (1 + arvonnousu) * hinta - 
                   ( sum(res$kokonaiskustannus) + maksuosuus ) + 
                   vuokra * (laina_aika * 12)
    list( osake = osakerahat, asunto = asuntorahat, asunto_df = res )
}

plot_kk_maksut <- function(asunto_df)
{
    maksimi <- max(asunto_df$kokonaiskustannus) + 1
    tmp <- select( asunto_df
                 , kuukausi
                 , maksettava_paaoma
                 , maksettava_korko
                 , vastike ) %>%
           melt(id.vars = "kuukausi")
    ggplot(data = tmp, aes(y = value, fill = variable, x = kuukausi)) +
    geom_bar(stat="identity", width=1) + 
    theme_bw() +
    scale_fill_manual( labels = c("Korko", "Velan pääoma", "Hoitovastike")
                      , values = c( "#b3e2cd"
                                  , "#fdcdac"
                                  , "#cbd5e8" )) +
    ylab("Euroa") +
    xlab("Kuukausi") +
    ggtitle("Kuukausikustannuksen jakautuminen") +
    theme( panel.grid = element_blank()
         , legend.title = element_blank()
         , legend.position = "bottom"
         , plot.title = element_text(hjust = 0.5)
         , axis.ticks = element_blank()
         , panel.border = element_blank() ) +
    scale_y_continuous( breaks = c(seq(0, maksimi, by = 100), round(maksimi)))
}
