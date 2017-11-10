shinyUI(
  navbarPage(
    "v0.1", theme = shinytheme("yeti"),
    
    tabPanel(
      "Gene expression",
      fluidPage(
        
        # includeCSS("www/styles.css"),
        useShinyjs(),
        
        fluidRow(
          #shinythemes::themeSelector(),
          verbatimTextOutput('debug'),
          
          column(3,
                 fluidRow(
                   
                   helpText('Enter up to 8 genes:'),
                   textAreaInput('identif', NULL, rows = 2, resize = 'vertical',
                                 value = initial_sel_genes,
                                 width = '85%'),
                   
                   radioButtons('idtype', NULL, c('EnsemblID', 'GeneSymbol'),
                                inline = TRUE),
                   
                   radioButtons('species', 'Species', c('mouse', 'human'),
                                inline = TRUE),
                   
                   actionButton('go', 'GO'),
                   
                   tags$p(),
                   
                   uiOutput('modal_experiments'),
                   
                   tags$hr(),
                   
                   tableOutput('geneinfo')
                 )
          ),
          
          column(9,
                 fluidRow(
                   #actionLink('sort', "sort"),
                   checkboxInput("reps", "Calculate replicate means"),
                   plotOutput('plot')
                 )
          )
        )
      )
    ),
    tabPanel("Samples",
             dataTableOutput("sampleTable"),
             helpText(paste(c('database', database_version),
                            collapse = ' ')
             )
    )
  )
)
