shinyServer(function(input, output, session) {
  
  values <- reactiveValues(plot = NULL,
                           dict = NULL,
                           table = NULL,
                           species = 'mouse',
                           # experiment has to be initial input$species
                           experiment = list_projects_sp('mouse'),
                           metric = 'TPM',
                           genes = NULL,
                           df = NULL,
                           gmeans = NULL)
  
  
  # limit number characters identifiers input
  shinyjs::runjs("$('#identif').attr('maxlength', 200)")
  
  #############################################
  
  output$filter <- renderUI({
    
    shinyjs::hidden(
      wellPanel(id = "filt_panel",
                div(checkboxGroupInput('experiment', 'Include projects:',
                                       choices = list_projects_sp(input$species),
                                       selected = list_projects_sp(input$species)),
                    style = 'color: grey; font-size: 90%'),
                
                tags$hr(),
                
                div(selectizeInput('outliers_list', 'Remove outlier samples:',
                                   choices = meta$sample, selected = outliers, multiple = TRUE),
                    actionLink('reset_outliers', 'Preset'),
                    style = 'color: grey; font-size: 90%')
      )
    )
  })
  
  observeEvent(input$showfilter, {
    shinyjs::toggle(id = "filt_panel")
  })
  
  
  observeEvent(input$reset_outliers, {
    updateSelectizeInput(session, 'outliers_list', selected = outliers)
  })
  
  
  #############################################
  
  observeEvent(input$species, {
    values$experiment <- list_projects_sp(input$species)
  })
  
  
  observe({
    values$experiment <- input$experiment
  })
  
  #############################################
  
  observeEvent(input$go, {
    
    values$species <- input$species
    
    values$plot <- NULL
    
    values$dict <- switch(input$species,
                          'human' = human_dict,
                          'mouse' = mouse_dict)
    
    values$metric <- switch(input$metric,
                            'TPM (recommended)' = 'TPM',
                            'RPKM' = 'RPKM')
    
    # store Ensembl IDs
    values$genes <- process_ids(input$identif,
                                input$idtype,
                                values$dict,
                                max = 8)
    
    # data for plotting
    values$df <- create_df(values$species,
                           values$metric,
                           values$genes,
                           values$dict,
                           values$experiment,
                           input$outliers_list)
    
    # geometric means
    values$gmeans <- calc_gmeans(values$df)
    
    #########################
    
    if(input$showmeans){
      
      values$table <- data.frame(Sample = values$gmeans$group,
                                 Gene = values$gmeans$gene,
                                 count = round(values$gmeans$gmean, 2))
      
      
    }else{
      
      values$table <- data.frame(Project = values$df$project,
                                 Group = values$df$group,
                                 Sample = values$df$sample,
                                 Gene = values$df$gene,
                                 count = round(values$df$counts, 2))
    }
    
    try(colnames(values$table)[colnames(values$table) == 'count'] <- values$metric)
    
  })
  
  
  
  #########################################
  #########################################
  
  output$geneinfo <- DT::renderDataTable({
    infoTable(values$genes, values$dict, values$species)
  },
  rownames = FALSE,
  escape = FALSE,
  options = list(dom = 't',
                 ordering = FALSE))
  
  #########################################
  
  output$plot <- renderPlot({
    
    values$plot <- express_plot(values$df, values$gmeans, showmeans = input$showmeans, metric = values$metric)
    values$plot
    
  },
  width = exprToFunction(calc_width()),
  height = exprToFunction(calc_height())
  )
  
  
  calc_width <- reactive({
    if(input$showmeans) return(600)
    else return(800)
  })
  
  calc_height <- reactive({
    if(input$showmeans) return(18 * length(unique(values$plot$data$group)) + 150)
    else return(18 * length(unique(values$plot$data$sample)) + 100)
  })
  
  
  #########################################
  
  output$rawdata <- DT::renderDataTable({
    
    out <- values$table
    #colnames(out)[colnames(out) == 'Group'] <- 'Name'
    cbind(out,
          Info = as.character(meta[match(out$Sample, meta$sample), 'sample_info']))
    
    
  },
  rownames = FALSE,
  options = list(
    autoWidth = FALSE,
    pageLength = 25,
    columnDefs = list(list(width = '20px', targets = "_all"))))  
  
  
  output$download <- downloadHandler(
    filename = function(){paste0(values$metric, "s.csv")},
    content = function(file){
      write.csv(values$table, file, quote = FALSE, row.names = FALSE)
    }
  )
  
  
  #########################################
  
  output$sampleTable <- renderDataTable({
    out <- meta
    colnames(out)[colnames(out) == 'group'] <- 'name'
    colnames(out)[colnames(out) == 'total_mapped'] <- 'assigned reads'
    out['source'] <- paste0('<a target = "_blank" href=',
                            out$data_source, '>', out$source, '</a>')
    out$data_source <- NULL
    out
  },
  escape = FALSE,
  options = list(bfilter = 'top',
                 autoWidth = FALSE,
                 pageLength = 25,
                 lengthMenu = c(25, 50, 100, 200)))
  
  
  ###############################
  
  output$debug <- renderPrint({
  })
  
})