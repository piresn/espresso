shinyUI(
  navbarPage(
    "v0.1", theme = shinytheme("united"),
    
    tabPanel(
      "Gene expression",
      fluidPage(
        
        # includeCSS("www/styles.css"),
        useShinyjs(),
        
        fluidRow(
          # shinythemes::themeSelector(),
          verbatimTextOutput('debug'),
          
          column(3,
                 fluidRow(
                   
                   helpText('Enter up to 8 genes:'),
                   textAreaInput('identif', NULL, rows = 2, resize = 'vertical',
                                 value = initial_sel_genes,
                                 width = '85%'),
                   
                   radioButtons('idtype', NULL, c('GeneSymbol', 'EnsemblID'),
                                inline = TRUE),
                   
                   radioButtons('species', 'Species', c('mouse', 'human'),
                                inline = TRUE),
                   
                   actionLink('showfilter', 'Filter datasets',
                              icon = icon('sort-down')),
                   
                   uiOutput('filter'),
                   
                   tags$p(),
                   
                   actionButton('go', 'GO'),
                   
                   tags$hr(),
                   
                   tableOutput('geneinfo')
                 )
          ),
          
          column(9,
                 tabsetPanel(id = 'tabs1',
                             tabPanel('Plot',
                                      fluidRow(
                                        
                                        checkboxInput("showmeans", "Show means only", value = FALSE),
                                        
                                        withSpinner(plotOutput('plot'), type = 1)
                                      )
                             ),
                             tabPanel('Raw',
                                      DT::dataTableOutput("rawdata")
                             )
                 )
          )
        )
      )
    ),
    
    tabPanel("Samples info",
             dataTableOutput("sampleTable"),
             helpText(paste(c('Database created:', timestamp),
                            collapse = ' ')
             )
    ),
    
    tabPanel("Help",
             includeMarkdown("scripts/help.md")
    )
  )
)
