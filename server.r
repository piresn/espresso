shinyServer(function(input, output, session) {
  
  values <- reactiveValues(plot = NULL,
                           ensembl = NULL,
                           # experiment has to be initial input$species
                           experiment = list_projects_sp('mouse'),
                           genes = NULL,
                           df = NULL,
                           gmeans = NULL)
  
  
  # limit number characters identifiers input
  shinyjs::runjs("$('#identif').attr('maxlength', 200)")
  
  #############################################
  
  output$filter <- renderUI({
    
    shinyjs::hidden(
      wellPanel(id = "filt_panel",
                checkboxGroupInput('experiment', NULL,
                                   choices = list_projects_sp(input$species),
                                   selected = list_projects_sp(input$species)
                )
      )
    )
  })
  
  observeEvent(input$showfilter, {
    shinyjs::toggle(id = "filt_panel")
  })
  
  #############################################
  
  observeEvent(input$species, {
    values$experiment <- list_projects_sp(input$species)
  })
  
  # observeEvent(input$experiment, {
  #   values$experiment <- input$experiment
  # })
  
  observe({
    values$experiment <- input$experiment
  })
  
  #############################################
  
  observeEvent(input$go, {
    
    values$plot <- NULL
    
    # ensembl mart
    if(!offline){
      values$ensembl <- switch(input$species,
                               'human' = ensembl_human,
                               'mouse' = ensembl_mouse)
    }
    
    # store Ensembl IDs
    values$genes <- process_ids(input$identif,
                                input$idtype,
                                values$ensembl,
                                max = 8)
    
    # data for plotting
    values$df <- create_df(input$species,
                           values$genes,
                           values$ensembl,
                           values$experiment)
    
    # geometric means
    values$gmeans <- calc_gmeans(values$df)
    
  })
  
  
  #########################################
  
  output$geneinfo <- renderTable({
    infoTable(values$genes, values$ensembl)
  })
  

  output$plot <- renderPlot({
    values$plot <- express_plot(values$df, values$gmeans, showmeans = input$showmeans)
    print(values$plot)
  }, width = 600, height = exprToFunction(calc_height()))
  

  output$sampleTable <- renderDataTable({
    meta[,-1]
  })

  calc_height <- reactive({
    if(length(values$plot$data$sample) > 0) return(length(values$plot$data$sample) + 1000)
    if(length(values$plot$data$gene) > 0) return(length(values$plot$data$gene) + 400)
    else return(100)
  })
  
  output$debug <- renderPrint({
    length(values$plot$data$sample)
  })
  
})