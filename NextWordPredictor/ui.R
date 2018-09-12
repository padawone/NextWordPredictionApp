library(shinydashboard)
library(stringr)

header <- dashboardHeader(
    title = "Next Word Predictor App"
)

sidebar <- dashboardSidebar(
    disable = FALSE,
    sidebarMenu(
        menuItem("Next Word Prediction", tabName = "dashboard", icon = icon("dashboard")),
        menuItem("Help", tabName = "help", icon = icon("question")),
        menuItem("About", tabName = "about", icon = icon("info")),
        menuItem("Source code", icon = icon("file-code-o"),href = "https://github.com/padawone/NextWordPredictionApp")
    )
)

body <- dashboardBody(
     tags$head(
          tags$link(rel = "stylesheet", type = "text/css", href = "bootstrap.min.css")
     ),
    tabItems(
        tabItem(tabName = "dashboard",
                fluidRow(
                    column(width = 7,
                           box(width = NULL, solidHeader = TRUE,collapsible = TRUE,title = "Inputs",
                               status = "info",
                               h3("Type some text or words here to begin."),
                               tags$textarea(id="text", rows=6, cols=70,autofocus=TRUE,resize=FALSE, placeholder="Type text / words here")
                           ),
                           box(width = NULL, status = "success",solidHeader = TRUE,collapsible = TRUE,title = "Predictions",
                               uiOutput("buttons")
                           ),
                           p(
                               "Click one of the above predicted words to add it on input text area."
                           ),
                           box(width =NULL, status = "success",collapsible = TRUE,solidHeader = TRUE,title = "WordCloud",
                               h3("Predicted words cloud", align="center"),
                               plotOutput('wordcloud')
                           )
                    ),
                    column(width = 5,
                           box(width = NULL, status = "warning",solidHeader = TRUE,collapsible = TRUE,title = "Options",
                               h3("Number of Predictions to create"),
                               sliderInput("numberWords", "",
                                           min = 1, max = 5, value = 3
                               )
                               
                           ),
                           box(width = NULL, status = "success",collapsible = TRUE,solidHeader = TRUE,title = "Plot",
                               h3("Probabilities of the predicted words", align="center"),
                               plotOutput("plot")
                           )
                           
                    )
                )
        ),
        tabItem(tabName = "help",
                h2("Instructions to use this app"),
                p("Type words in text area,meanwhile app will use typed words to create and show next words predictions with highest probabilities and in number especified by user."),
                p("Then you can continue typing more words, or click and select one of the predicted words that will be inserted in to the text area."),
                p("The number of predictions are set to 3 as default. User can change it to any number from 1 to 5 before or during typing in the text area using slider input provided.")
        ),
        tabItem(tabName = "about",
                h2("About this Shiny app"),
                p("This Shiny app is developed as a capstone project to complete Coursera Data Science Specialization offered by John Hopkins University in collaboration with Swiftkey. The main goal is build a predictive text model from unstructured text documents (blogs, news and twitter) and to develop it into a Shiny app for end users."),
                p("The predictive model is uses a simple Stupid Backoff algorithm to make a prediction for next word, based on typed previous words by user.")
        )
    )
    
)

dashboardPage(
    header,
    sidebar,
    body,
    skin="blue"
)

