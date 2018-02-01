shinyServer(function(input, output, session) {
  
  values <- reactiveValues(plot = NULL,
                           dict = NULL,
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
    
    values$dict <- switch(input$species,
                          'human' = human_dict,
                          'mouse' = mouse_dict)
    
    # store Ensembl IDs
    values$genes <- process_ids(input$identif,
                                input$idtype,
                                values$dict,
                                max = 8)
    
    # data for plotting
    values$df <- create_df(input$species,
                           values$genes,
                           values$dict,
                           values$experiment)
    
    # geometric means
    values$gmeans <- calc_gmeans(values$df)
    
  })
  
  
  
  #########################################
  
  output$geneinfo <- renderTable({
    infoTable(values$genes, values$dict)
  })
  
  
  output$plot <- renderPlot({
    values$plot <- express_plot(values$df, values$gmeans, showmeans = input$showmeans)
    print(values$plot)
  }, width = exprToFunction(calc_width()),
  height = exprToFunction(calc_height())
  )
  
  #########################################
  
  calc_width <- reactive({
    if(input$showmeans) return(600)
    else return(800)
  })
  
  calc_height <- reactive({
    if(input$showmeans) return(18 * length(unique(values$plot$data$group)) + 150)
    else return(18 * length(unique(values$plot$data$sample)) + 100)
  })
  
  #########################################
  
  output$sampleTable <- renderDataTable({
    meta[,-1]
  })
  
  output$rawdata <- DT::renderDataTable({
    try(data.frame(gene = values$df$gene,
               sample = values$df$sample,
               TPM = round(values$df$counts, 2)))},
    options = list(
      autoWidth = TRUE,
      pageLength = 100,
      columnDefs = list(list(width = '20px', targets = "_all"))))
    
    output$debug <- renderPrint({
      head(values$df)
    })
    
})