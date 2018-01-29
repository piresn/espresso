shinyUI(
  navbarPage(
    "v0.1", theme = shinytheme("flatly"),
    
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
                 fluidRow(
                   
                   checkboxInput("showmeans", "Plot means", value = TRUE),
                   
                   withSpinner(plotOutput('plot'), type = 1)
                 )
          )
        )
      )
    ),
    tabPanel("Samples",
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
