shinyUI(
  navbarPage(
    "v0.9", theme = shinytheme("yeti"),
    
    tabPanel(
      "Gene expression",
      fluidPage(
        
        useShinyjs(),
        
        includeCSS("www/styles.css"),
        
        fluidRow(
          #verbatimTextOutput('debug'),
          
          column(3,
                 fluidRow(
                   
                   wellPanel(
                     
                     helpText('Enter up to 8 genes:'),
                    
                     textAreaInput('identif', NULL, rows = 2, resize = 'vertical',
                                   value = initial_sel_genes,
                                   width = '85%'),
                     
                     radioButtons('idtype', NULL, c('GeneSymbol', 'EnsemblID'),
                                  inline = TRUE),
                     
                     
                     radioButtons('species', 'Species', levels(meta$species),
                                  inline = TRUE)
                   ),
                   
                   actionButton('go', 'GO'),
                   
                   div(checkboxInput("showmeans", 'Show means only', value = FALSE),
                       style = 'padding-top: 10px; padding-bottom: 10px'),
                   
                   
                   radioButtons('metric', 'Expression units', c('TPM (recommended)', 'RPKM'),
                                inline = FALSE),
                   
                   actionLink('showfilter', 'Filter samples',
                              icon = icon('tasks')),
                   
                   uiOutput('filter'),
                   
                   tags$p(),
                   
                   tags$hr(),
                   
                   DT::dataTableOutput('geneinfo')
                 )
          ),
          
          column(9,
                 
                 tabsetPanel(id = 'tabs1',
                             tabPanel('Plot',
                                      fluidRow(align="center",
                                               withSpinner(plotOutput('plot'), type = 8, color = '#D9D9D9')
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
             helpText(paste(c('Database created:', format(timestamp, '%F')),
                            collapse = ' ')
             )
    ),
    
    tabPanel("Help",
             div(includeMarkdown("help.md"), class='markdw')
    )
  )
)
