shinyUI(
  navbarPage(
    "v0.1", theme = shinytheme("united"),
    
    tabPanel(
      "Gene expression",
      fluidPage(
        
        useShinyjs(),
        
        includeCSS("www/styles.css"),
        
        fluidRow(
          # shinythemes::themeSelector(),
          verbatimTextOutput('debug'),
          
          column(2,
                 fluidRow(
                   
                   wellPanel(
                     
                     helpText('Enter up to 8 genes:'),
                     textAreaInput('identif', NULL, rows = 2, resize = 'vertical',
                                   value = initial_sel_genes,
                                   width = '85%'),
                     
                     radioButtons('idtype', NULL, c('GeneSymbol', 'EnsemblID'),
                                  inline = TRUE),
                     
                     
                     radioButtons('species', 'Species', c('mouse', 'human'),
                                  inline = TRUE)
                   ),
                   
                   

                   actionButton('go', 'GO', width = '100%'),

                   div(checkboxInput("showmeans", "Calculate means", value = FALSE),
                       style = 'font-weight: bold; padding-top: 10px'),
                   
                   radioButtons('metric', 'Metric', c('TPM (recommended)', 'RPKM'),
                                inline = FALSE),
                   
                   actionLink('showfilter', 'Filter samples',
                              icon = icon('wrench')),
                   
                   uiOutput('filter'),
                   
                   tags$p(),
                   
                   tags$hr(),
                   
                   DT::dataTableOutput('geneinfo')
                 )
          ),
          
          column(10,

                 tabsetPanel(id = 'tabs1',
                             tabPanel('Plot',
                                      fluidRow(
                                        withSpinner(plotOutput('plot'), type = 1)
                                      )
                             ),
                             
                             tabPanel('Table',
                                      DT::dataTableOutput("rawdata"),
                                      
                                      downloadLink('download',"Download")
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
