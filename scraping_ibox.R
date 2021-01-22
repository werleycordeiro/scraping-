suppressMessages(library(httr))
library(rvest)

sierra = c("ELET6","PETR4","USIM5","CCRO3","GGBR4","BRDT3","MRVE3","BRML3","BBDC4","BTOW3")
for(i in 1:length(sierra)){
	sh = GET(url = paste0("https://www.ibovx.com.br/historico-papeis-bovespa.aspx?papel=",sierra[i]))
	data = read_html(sh) %>% html_nodes("div") %>% html_nodes("table") %>% html_nodes("tr") %>% html_nodes("td") %>% html_text()
	if(i==1){
		aux = as.numeric(gsub(",",".",noquote(head(matrix(data[13:length(data)],ncol=9,byrow=TRUE))[2,4])))
	}else{
		if(i>1){
			aux = c(aux,aux = as.numeric(gsub(",",".",noquote(head(matrix(data[13:length(data)],ncol=9,byrow=TRUE))[2,4]))))
		}
	}
	pb = txtProgressBar(min = (1/length(sierra)), max = length(sierra), style = 3)
	setTxtProgressBar(pb,i)
}

