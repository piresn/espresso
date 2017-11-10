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
  
  # NOT in use yet
  # later use to create vector sample names for subsetting
  
  output$modal_experiments <- renderUI({
    
    if(!is.null(values$df)){
      
      tagList(
        
        actionLink('sel_experiment', 'Filter datasets'),
        
        bsModal('mod_exps', 'Filter datasets',
                'sel_experiment', size = 'small',
                fluidRow(
                  checkboxGroupInput('experiment', NULL,
                                     choices = unique(meta[
                                       meta$species == input$species,
                                       'project']),
                                     selected = unique(meta[
                                       meta$species == input$species,
                                       'project'])
                                     )
                )
        )
      )
    }
  })
  
  #############################################
  
  observeEvent(input$species, {
    values$experiment <- list_projects_sp(input$species)
  })
  
  observeEvent(input$experiment, {
    values$experiment <- input$experiment
  })
  
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
    values$plot <- express_plot(values$df, values$gmeans, reps = input$reps)
    print(values$plot)
  })
  
  output$sampleTable <- renderDataTable({
    meta[,1]
  })
  
  output$debug <- renderPrint({
    values$experiment
  })
  
})