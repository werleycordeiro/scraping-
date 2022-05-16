suppressMessages(library(httr))
suppressMessages(library(rvest))

ticker <- c("TAEE11","ITSA4")

data_inicial <- "14/04/2018"
data_final <- "08/05/2021"

for(i in 1:length(ticker)){

    url <- paste0("https://www.ibovx.com.br/historico-papeis-bovespa.aspx?papel=",ticker[i],"&dtini=",data_inicial,"&dtfim=",data_final)
    sh <- GET(url = url)
    data <- read_html(sh) %>% html_nodes("div") %>% html_nodes("table") %>% html_nodes("tr") %>% html_nodes("td") %>% html_text()
    data <- data[-grep("\r\n.ibovx_bannerresponsivoabaixomenu",data)] # remover banner entre as linhas da tabela
    
    if(! length(data) == 0){
    
    	data <- matrix(data[13:length(data)], ncol = 9, byrow = TRUE)
    	nomes_coluna <- c(data[1,], "Ticker")
        data <- cbind(data, rep(ticker[i], nrow(data)))
        data <- data[-1,]

        if(i == 1){

            dataset <- data

        }else{

        	dataset <- rbind(dataset,data)
        }

    }

    pb = txtProgressBar(min = (1 / length(ticker)), max = length(ticker), style = 3)
    setTxtProgressBar(pb,i)

}

colnames(dataset) <- nomes_coluna
head(dataset)
tail(dataset)
