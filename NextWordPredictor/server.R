library(shinydashboard)

source("main.R")

function(input, output, session){
    result <- reactive ({
        predict_next_word(freq.table, input$text, input$numberWords)[1:input$numberWords,]
    })
    
    output$plot <- renderPlot({
        ggplot(result(), aes(predicted, freq)) + 
            geom_bar(stat="identity", color='blue',fill = '#0073C2FF') + 
            scale_x_discrete(limits= result()$predicted) +
            xlab("Predicted Word") + 
            ylab("Probability") +             
            coord_flip() +
            theme_bw() +
            theme(plot.title = element_text(size=22)) +
            theme(axis.text.y=element_blank(),
                  axis.text=element_text(size=12),
                  axis.title=element_text(size=14,face="bold")) +
            geom_text(aes(label=predicted), hjust="inward", color="black", size=7)  
    })
    

    independent_Words <- reactive( { 
        if(length(result()$predicted)<5) {
            c(result()$predicted, rep("", 5-length(result()$predicted)))
        } else { result()$predicted 
        } 
    })
    
    output$buttons <- renderUI( {
        div(class="btn-group btn-group-justified",
            actionLink(inputId = "action1", class="btn btn-default", label = independent_Words()[1]),
            actionLink(inputId = "action2", class="btn btn-default", label = independent_Words()[2]),
            actionLink(inputId = "action3", class="btn btn-default", label = independent_Words()[3]),
            actionLink(inputId = "action4", class="btn btn-default", label = independent_Words()[4]),
            actionLink(inputId = "action5", class="btn btn-default", label = independent_Words()[5])
        )
    })
    
    # Output word cloud ####
    wordcloud_rep = repeatable(wordcloud)
    output$wordcloud <- renderPlot({
            wordcloud_rep(
                    result()$predicted,
                    result()$freq,
                    colors = brewer.pal(8, 'Dark2'),
                    scale=c(4, 0.5),
                    max.words = 300
            )
        
    })
    
    # Generate updated text when one of the predicted words is clicked, or
    # random choice button is clicked
    my_clicks <- reactiveValues(data = NULL)
    
    observeEvent(input$action1, {
        my_clicks$data <- paste(input$text, independent_Words()[1])
    })
    
    observeEvent(input$action2, {
        my_clicks$data <- paste(input$text, independent_Words()[2])
    })
    
    observeEvent(input$action3, {
        my_clicks$data <- paste(input$text, independent_Words()[3])
    })
    
    observeEvent(input$action4, {
        my_clicks$data <- paste(input$text, independent_Words()[4])
    })
    
    observeEvent(input$action5, {
        my_clicks$data <- paste(input$text, independent_Words()[5])
    })
 
    observe({
        updateTextInput(session, "text",
                        value = str_trim(my_clicks$data))
    })
    
} 