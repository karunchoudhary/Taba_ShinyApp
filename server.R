#################################################
#               Udpipe Text Analysis            #
#################################################

shinyServer(function(input, output,session) {
  set.seed=0000000   
  options(shiny.maxRequestSize=30*1024^2)
  
  tryCatch(windowsFonts(devanew=windowsFont("Devanagari new normal")),error=function(e)print("windowsFonts not supporting in MAC"))
  
  dataset <- reactive({
    if (is.null(input$file)) {return(NULL)}
      else {
        Document = readLines(input$file$datapath)
            x  =  gsub("<.*?>", " ", Document)               # regex for removing HTML tags
        #   x  =  iconv(x, "latin1", "ASCII", sub="") # Keep only ASCII characters
         #   x  =  gsub("[^[:alnum:]]", " ", x)        # keep only alpha numeric
        #    x  =  tolower(x)                          # convert to lower case characters
        #   x  =  removeNumbers(x)                    # removing numbers
        #   x  =  stripWhitespace(x)                  # removing white space
       # x  =  gsub("^\\s+|\\s+$", "", x)          # remove leading and trailing white space
        return(x)}
      })
  
  u_model <- reactive({
    if (is.null(input$model)) {
      # User has not uploaded a file yet
      return(NULL)
    }
   # file = readLines(input$model$datapath) 
    udpipe_m<- udpipe_download_model(input$model)  
    udpipe_model <- udpipe_load_model(udpipe_m)
    return(udpipe_model)
  })
  

# input_from_checkboxgroup <- function(){
#   
#      data <- input$checkGroup
#   #  print(data)
#    return(data)
# }

doc_annotate <- reactive({
  
  doc <- dataset()
  x_annotated <- udpipe_annotate(u_model(), x = doc) #%>% as.data.frame() %>% head()
  view_data <- as.data.frame(x_annotated)
  
  return(view_data)
})

output$table <- renderPlot({
  
  stats <- txt_freq(doc_annotate()$upos)
  stats$key <- factor(stats$key, levels = rev(stats$key))
  barchart(key ~ freq, data = stats, col = "cadetblue", 
           main = "UPOS (Universal Parts of Speech)\n frequency of occurrence", 
           xlab = "Freq")
  # all_nouns = doc_annotate() %>% subset(., upos %in% input_from_checkboxgroup()[2]) 
  # top_nouns = txt_freq(all_nouns$lemma)  # txt_freq() calcs noun freqs in desc order
  # top_nouns1 <- head(top_nouns, 10)
 # return(top_nouns1)
  
})

# Collocation (words following one another)
text_colloc =  reactive({
  textb = doc_annotate()
  colloc <- keywords_collocation(x = textb,   # try ?keywords_collocation
                                 term = "token", 
                                 group = c("doc_id", "paragraph_id", "sentence_id"),
                                 ngram_max = 3)
    return(colloc)
  })


output$table1 <- renderTable({

  top_colloc <- head(text_colloc(), 10)
  return(top_colloc)
})

# Sentence Co-occurrences for selected xpos
text_cooc =  reactive({
  texta = doc_annotate()
  n_cooc <- cooccurrence(     # try `?cooccurrence` for parm options
            x = subset(texta, upos %in% input$checkGroup), 
            term = "lemma", 
            group = c("doc_id", "paragraph_id", "sentence_id"))

  return(n_cooc)
})

# Co-occurrences plot for selected xpos
output$wordcoocc <- renderPlot({
  wordnetwork <- head(text_cooc(), 100)
  wordnetwork <- igraph::graph_from_data_frame(wordnetwork)
  
  x_plot <- ggraph(wordnetwork, layout = "fr") +  geom_edge_link(aes(width = cooc, edge_alpha = cooc), edge_colour = "orange") +  
    geom_node_text(aes(label = name), col = "darkgreen", size = input$nodes) + theme_graph(base_family = "Arial Narrow") + 
    theme(legend.position = "none") + labs(title = "Cooccurrences within 3 words distance", subtitle = "selected Upos")
  
  return(x_plot)
})

# Nouns Word Cloud
output$wordcloud <- renderPlot({
all_nouns = doc_annotate() %>% subset(., upos %in% input$checkGroup)
top_nouns = txt_freq(all_nouns$lemma)
w_plot <- wordcloud(words = top_nouns$key,freq = top_nouns$freq,scale=c(7,.5),min.freq =input$freq,max.words = input$maxi,
                     random.order = FALSE,colors = brewer.pal(6, "Dark2"),title = 'Term Frequency Wordcloud')
  return(w_plot)
    })

output$downloadData1 <- downloadHandler(
  
  filename = function() { "Nokia_Lumia_reviews.txt" },
  
  content = function(file) {
    
    writeLines(readLines("data/amazon_nokia_lumia_reviews.txt"), file)
    
  }
  
)


})
