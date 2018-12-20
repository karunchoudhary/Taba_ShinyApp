#################################################
#               Udpipe Text Analysis             #
#################################################

options(spinner.color.background="#F5F5F5")

shinyUI(fluidPage(
  
  
 titlePanel("Udpipe Text Analysis"),
  
  # Input in sidepanel:
  sidebarPanel(
    
    fileInput("file", "Upload text file",accept = c("text",
                                                    "text,text/plain",
                                                    ".txt"),multiple = FALSE),
    selectInput("model", h3("Select language model"),
                choices = list("english" =  "english","hindi" = "hindi","afrikaans" = "afrikaans", "ancient_greek-proiel" = "ancient_greek-proiel",
                               "ancient_greek" = "ancient_greek", "arabic" = "arabic", "basque" = "basque", "belarusian" = "belarusian", "bulgarian" = "bulgarian", "catalan" = "catalan",
                               "chinese" = "chinese", "coptic" = "coptic", "croatian" = "croatian", "czech-cac" = "czech-cac", "czech-cltt" = "czech-cltt", "czech" = "czech", "danish" = "danish",
                               "dutch-lassysmall" = "dutch-lassysmall", "dutch"= "dutch", "english-lines" = "english-lines", "english-partut" = "english-partut",
                               "estonian" = "estonian", "finnish-ftb" = "finnish-ftb", "finnish" = "finnish", "french-partut" = "french-partut", "french-sequoia" = "french-sequoia",
                               "french" = "french", "galician-treegal" = "galician-treegal", "galician" = "galician", "german" = "german", "gothic" = "gothic", "greek" = "greek")),
               # selected = c("english","NOUN","PROPN")),
    checkboxGroupInput("checkGroup", 
                       h3("Select UPOS"), 
                       choices = list("Adjective (JJ)" = "ADJ", 
                                      "Noun (NN)" = "NOUN", 
                                      "Proper Noun (NNP)" = "PROPN",
                                      "Adverb (RB)" = "ADV",
                                      "Verb (VB)" = "VERB"),
                       selected = c("ADJ","NOUN","PROPN")),
    
    sliderInput("freq", "Minimum Frequency of a word in Wordcloud:", min = 0,  max = 100, value = 3),
    sliderInput("maxi",  "Maximum Number of Words in Wordcloud:", min = 1,  max = 500,  value = 150),  
    numericInput("nodes", "Number of Central Nodes in co-occurrence graph", 4),
   # numericInput("connection", "Number of Max Connection with Central Node", 5),
    submitButton(text = "Apply Changes", icon("refresh"))
    
  ),
  
  # Main Panel:
  mainPanel(
        tabsetPanel(type = "tabs",
                #
          tabPanel("Overview",h4(p("How to use this App")),
  
         tags$li("To use this app you need a document corpus in txt file format.", align = "justify"),
         
         tags$li("To do Text Analysis on your corpus, click on Browse in left-sidebar panel and upload the txt file.
                 
                 Once the file is uploaded it will do the computations in
                 
                 back-end with default inputs and accordingly results will be displayed in various tabs.", align = "justify"),
         
         tags$li("If you wish to modify the input,make changes on parameters in left side-bar panel and hit Apply changes.
                 
                 Accordingly results in respective tab will be refreshed", align = "Justify"),
         
         tags$li("The App uses UDPipe and hence supports 52 language Models , you can find details here:" , a(href="https://www.rdocumentation.org/packages/udpipe/versions/0.7/topics/udpipe_download_model","udpipe Models") , align = "justify"),
         
         tags$li("NOTE:You might see a lag after clicking 'Apply Changes' depending on the size of your corpus and computations involved.
                 
                 Sip a coffee meanwhile ! As soon as all the computations are over in back-end results will be refreshed", align = "justify"),
         tags$li("NOTE: Please store the text file in UTF-8 encoding before uploading the file into App", align = "justify"),

         tags$li("Here is a simple workflow for you to quick start : "),
         
         img(src = "Workflow.jpg"),

         tags$li("If plots are not working then please install dependencies (from dependencies.R) before you start using the app.", align = "justify"),
 
         h4(tags$li("Download Sample text file")),
         
         downloadButton("downloadData1", "Download Nokia Lumia reviews txt file (works only in browser)"),br(),br(),
     
         tags$li("Please note that download will not work with RStudio interface. Download will work only in web-browsers. So open this app in a web-browser and then download the example file. For opening this app in web-browser click on \"Open in Browser\" as shown below -")

         ),
                
                tabPanel("Frequency Plot of UPOS",
                         wellPanel(withSpinner(plotOutput("table")))
                        # verbatimTextOutput("start")
                        ),
                tabPanel("Co-locations",wellPanel(withSpinner( tableOutput("table1")))
                        # verbatimTextOutput("event")
                        ), 
              
                tabPanel("Word Cloud",h4("Word Cloud"),
                              plotOutput("wordcloud",width = "100%" ,height= "800px")),

                tabPanel("Co-occurrence plot of seleted XPOS's",
                         wellPanel(withSpinner( plotOutput("wordcoocc"))))
                 )
           )
)

)
