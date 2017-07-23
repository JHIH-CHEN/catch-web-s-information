library(readr)
ALLTRENO_P <- read_csv("C:/Users/JHIH-CHEN/Downloads/ALLTRENO_P.csv", 
                       col_names = FALSE)
#View(ALLTRENO_P)

library(reshape2)
for (a in ALLTRENO_P){
  ALLTRENO_P1<-data.frame(strsplit (a," "))#將依據空格來做分割
}

#分割後，僅留下最前面那段，並透過melt將其轉長表，再刪除第一行，留下需要的部分。最後，透過unique將重複值刪除
ALLTRENO_P2<-unique(melt((ALLTRENO_P1[1,]),id.vars = c())[2])

#網址
urlHeader<-"http://cghasp.cgmh.org.tw/query/income/income010.asp?mid="
for (code in ALLTRENO_P2){
  html<-paste0(urlHeader,code)
}

library(rvest)
#library(RCurl)
library(httr)
df0<-NULL#儲存的資料框
df_e<-NULL
df_w<-NULL

#透過迴圈抓取資料，以第1~100筆資料為例
for (ul in html[1:100]){
  #透過trycatch跳過警告與錯誤的網址，以便其他筆資料的蒐集
  tryCatch({
    html0<-read_html(GET(ul,user_agent("myagent")),encoding="big5" ) 
    NO <- html_nodes(html0,xpath="//tr/td[1]")%>%html_text()
    Item <- html_nodes(html0,xpath="//tr/td[2]")%>%html_text()
    Eng <-html_nodes(html0,xpath="//tr/td[3]")%>%html_text()
    ItemPrice <- html_nodes(html0,xpath="//tr/td[4]")%>%html_text()
    Des<- html_nodes(html0,xpath="//tr/td[5]")%>%html_text()
    dif<- html_nodes(html0,xpath="//tr/td[6]")%>%html_text()
    Lic<- html_nodes(html0,xpath="//tr/td[7]")%>%html_text()
    HINum<- html_nodes(html0,xpath="//tr/td[8]")%>%html_text()
    Q<- html_nodes(html0,xpath="//tr/td[9]")%>%html_text()
    Name<- html_nodes(html0,xpath="//tr/td[10]")%>%html_text()
    Point<- html_nodes(html0,xpath="//tr/td[11]")%>%html_text()
    df0<- rbind(df0,data.frame( "本院編號"=NO,"項目名稱"=Item,"英文名稱"=Eng ,
                                "項目金額"=ItemPrice, "管制說明"=Des,"差額"=dif, "許可證字號"=Lic,
                                "健保編號"=HINum,"數量"=Q, "健保名稱"=Name,"健保點數"=Point,
                                stringsAsFactors=FALSE))
  }, warning = function(w) {
    warn <- conditionMessage(w)
    warn<<-print(ul)
    # 警告處理
  }, error = function(e) {
    err <- conditionMessage(e)
    err <<-print(ul)
    # 錯誤處理
  })
  #try((NO <- html_nodes(html0,xpath="//tr/td[1]")%>%html_text()), silent=TRUE)
  
}
#以下為error、warning的ul
err<-data.frame(err)
warn<-data.frame(warn)

#擷取後刪除重複的資料
df0<-unique(df0)
df0<-df0[-1,]

#寫入名為df0的csv檔中(記得要事先設定好存檔位置)
write.csv(df0, "df0.csv", row.names = FALSE)
#以下儲存error、warning的ul
write.csv(err, "err.csv", row.names = FALSE)
write.csv(warn, "warn.csv", row.names = FALSE)


