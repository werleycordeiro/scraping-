suppressMessages(library(ggplot2))
suppressMessages(library(httr))
suppressMessages(library(rvest))
suppressMessages(library(reshape2))

ticker <- read.csv("https://www.dropbox.com/s/2nfnj13jhnpk6na/IBOV.csv?dl=1",header=FALSE,sep=",")

data_inicial <- "14/04/2018"
data_final <- "08/05/2021"

# Web scraping
for(i in 1:nrow(ticker)){

    url <- paste0("https://www.ibovx.com.br/historico-papeis-bovespa.aspx?papel=",unlist(ticker)[i],"&dtini=",data_inicial,"&dtfim=",data_final)
    sh <- GET(url = url)
    data <- read_html(sh) %>% html_nodes("div") %>% html_nodes("table") %>% html_nodes("tr") %>% html_nodes("td") %>% html_text()
    data <- data[-grep("\r\n.ibovx_bannerresponsivoabaixomenu",data)] # remover banner entre as linhas da tabela
    if(! length(data) == 0){
        data <- matrix(data[13:length(data)],ncol=9,byrow=TRUE)
        ret <- gsub("%","", data[-1,2]) 
        ret <- na.omit(as.numeric(gsub(",",".",ret)))
        ret <- matrix(ret, byrow = TRUE)
        colnames(ret) <- unlist(ticker)[i]
        attributes(ret)$na.action <- NULL

        if(i == 1){
            returnsT <- ret
        }else{
            if(nrow(ret) == nrow(returnsT)){
                returnsT <- cbind(returnsT,ret)
            }
        }
    }

    pb = txtProgressBar(min = (1 / nrow(ticker)), max = nrow(ticker), style = 3)
    setTxtProgressBar(pb,i)

}

cormat <- cor(returnsT)
head(cormat)
