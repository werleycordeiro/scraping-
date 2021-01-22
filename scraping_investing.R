
# data

#---
# Packages
 packages = c("RSelenium","tidyverse","XML","xts")
 new.packages = packages[!(packages %in% installed.packages()[,"Package"])]
 if(length(new.packages)) install.packages(new.packages)

suppressMessages(library(RSelenium))
suppressMessages(library(tidyverse))
suppressMessages(library(XML))
suppressMessages(library(xts))


#rm(list=ls())
#remote_driver$close()
#rm(driver)
#rm(list=ls())
#rm(remote_driver)

#available.versions<-binman::list_versions("chromedriver")
#latest.version = available.versions$win32[length(available.versions)]

#driver <- RSelenium::rsDriver(browser = "chrome",chromever = "81.0.4044.138")
driver <- rsDriver(browser = "firefox") # if brokerUFSC
# driver <- rsDriver() # Local
remote_driver = driver[["client"]] 

ticker = "PETR4"
indate = "01/01/2017" # mm/dd/yyyy
findate = "05/25/2020" # mm/dd/yyyy
fqc = "daily" # daily, weekly, monthly 
setwd("C:\\Users\\xxxxxxxxxxx\\Documents\\Carteira")

robot = function(ticker,indate,findate,fqc){
	# Google
	#remote_driver$navigate("http://www.google.com/?hl=en")
	#address_element = remote_driver$findElement(using = 'class', value = 'gLFyf')
	#address_element$sendKeysToElement(list(paste0("investing+",ticker), key = "enter"))
	#button_element = remote_driver$findElement(using = 'xpath', "//*[@id='tsf']/div[2]/div[1]/div[3]/center/input[2]")
	#button_element$clickElement()
	#Sys.sleep(2)
	#srch = remote_driver$findElement(using ='xpath',"//*[@id='rso']/div[1]/div/div[1]/a/h3")
	#srch$clickElement()
	
	# Investing
	remote_driver$navigate(paste0("https://www.investing.com/search/?q=",ticker))
	button_element = remote_driver$findElement(using = 'xpath', "//*[@id='fullColumn']/div/div[2]/div[2]/div[1]/a[1]/span[2]")
	button_element$clickElement()
	Sys.sleep(5)
	webElem <- remote_driver$findElement("css", "body")
	i=1
	while(i<4){
		webElem$sendKeysToElement(list(key = "down_arrow"))
		i=i+1
	}
	# historical
	url = remote_driver$getCurrentUrl()
	remote_driver$navigate(paste0(url,"-historical-data")) 
	#srch1 = remote_driver$findElement(using ='xpath',"//*[@id='pairSublinksLevel2']/li[3]")
	#srch1$clickElement()
	Sys.sleep(5)
	webElem <- remote_driver$findElement("css", "body")
	i=1
	while(i<9){
		webElem$sendKeysToElement(list(key = "down_arrow"))
		i=i+1
	}
	Sys.sleep(7)
	#fq = remote_driver$findElement(using = 'xpath', "//*[@id='data_interval']")
	#fq$clickElement()
	if(fqc=="daily"){
		fq = remote_driver$findElement(using = 'xpath', "//*[@id='data_interval']/option[1]")
		fq$clickElement()
	}else{
		if(fqc=="weekly"){
			fq = remote_driver$findElement(using = 'xpath', "//*[@id='data_interval']/option[2]")
			fq$clickElement()
		}else{
			if(fqc=="monthly"){
				fq = remote_driver$findElement(using = 'xpath', "//*[@id='data_interval']/option[3]")
				fq$clickElement()	
			}
		}
	}
	fq = remote_driver$findElement(using = 'xpath', "//*[@id='data_interval']/option[1]")
	fq$clickElement()
	element = remote_driver$findElement(using = 'id', "widgetFieldDateRange")
	element$clickElement()
	startDate = remote_driver$findElement(using = 'id', "startDate")
	startDate$clearElement()
	startDate$sendKeysToElement(list(indate))
	endDate = remote_driver$findElement(using = 'id', "endDate")
	endDate$clearElement()
	endDate$sendKeysToElement(list(findate))
	remote_driver$findElement(using = 'xpath', "//*[@id='applyBtn']")$clickElement()
	Sys.sleep(7)
	# Table
	tab = htmlParse(remote_driver$getPageSource()[[1]])
	tab = readHTMLTable(tab)$curr_table
	date = gsub(" ","/",tab[,1]) 
	date = gsub(",","",date)
	date = readr::parse_date(date,"%b/%d/%Y",locale=locale("en"))
	tab[,6] = gsub("M","",tab[,6])
	tab[,7] = gsub("%","",tab[,7])
	tab = apply(tab[2:7],2,as.numeric)
	tab = xts::xts(tab,order.by=date)
	write.zoo(tab,file=paste0(ticker,".csv"),sep=",")
	# return(tab)
}

for(i in 1:length(paste0(unlist(tick)))){
	robot(ticker=paste0(unlist(tick)[i]),indate="01/01/2017",findate="05/25/2020",fqc="daily")
	pb = txtProgressBar(min = (1/length(paste0(unlist(tick)))), max = length(paste0(unlist(tick))), style = 3)
	setTxtProgressBar(pb,i)
}




remote_driver$close()
system("taskkill /im java.exe /f", intern=FALSE, ignore.stdout=FALSE)
