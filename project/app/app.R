library(shiny)
library(h2o)

ui <- dashboardPage(
  dashboardHeader(title = "Loan dashboard 2022"),
  dashboardSidebar(fileInput("file", "Ikelti csv faila")),
  dashboardBody(
  fluidRow(
    column(4,
           #titlePanel("Finance history"),
           h3("Finance history"),
           numericInput("yearly_income", "Yearly income", value = 0, min = 0),
           selectInput("home_ownership", "Home ownership", c("Mortgage"= "mortgage", "Own"="own", "Rent"="rent"), multiple = FALSE),
           sliderInput("bankruptcies", "Bankruptcies", value = 0, min = 0, max = 15),
           numericInput("years_current_job", "Years current job", value = "", min = 0, max=100),
           numericInput("monthly_debt", "Monthly debt", value = 0, min = 0),
    ),
    column(4,
           #titlePanel("Credit history"),
           h3("Credit history"),
           numericInput("years_credit_history", "Years credit history", value = 0, min = 0),
           numericInput("months_since_last_delinquent", "Months since last delinquent", value = 0, min = 0),
           numericInput("open_accounts", "Open accounts", value = 0, min = 0),
           sliderInput("credit_problems", "Credit problems", value = 0, min = 0, max = 100),
           numericInput("credit_balance", "Credit balance", value = 0, min = 0),
           numericInput("max_open_credit", "max_open_credit", value = 0, min = 0),
    ),
    column(4,
           #titlePanel("About loan"),
           h3("About loan"),
           numericInput("amount_current_loan", "Loan size", value = 0, min = 0),
           selectInput("term", "Term", c("Long"= "long", "Short"="short"), multiple = FALSE),
           selectInput("credit_score", "Credit score", c("Fair"= "fair", "Good"="good", "Very good"="very_good", "NA"=""), multiple = FALSE),
           selectInput("loan_purpose", "Loan purpose", 
                       c("Business loan"="business_loan",
                         "Buy a car"="buy_a_car",
                         "Buy house"="buy_house",
                         "Debt consolidation"= "debt_consolidation",
                         "Educational expenses"="educational_expenses",
                         "Home improvements"="home_improvements",
                         "Major purchase"="major_purchase",
                         "Medical bills"="medical_bills",
                         "Moving"="moving",
                         "Renewable energy"="renewable_energy",
                         "Take a trip"="take_a_trip",
                         "Small business"="small_business",
                         "Vacation"="vacation",
                         "Wedding"="wedding",
                         "Other"="other"), multiple = FALSE),
    )
  ),
  
  fluidRow(
    column(12, align="center",
           h3("Check the probability that a loan will be granted:"),
           
           actionButton("check", "Check", class = "btn-lg btn-success"),
           "",
           h3(strong({textOutput("text")})),
           textOutput("tableCaption"),
           tableOutput("table"),
    )
  ),
  
  dataTableOutput("predictions")
  )
)

server <- function(input, output) {
  h2o.init()
  model <- h2o.loadModel("../4-model/my_model")
  
  output$predictions <- renderDataTable({
    req(input$file)
    df_test <- h2o.importFile(input$file$datapath)
    p <- h2o.predict(model, df_test)
    p %>%
      as_tibble() %>%
      mutate(y = predict) %>%
      select(y) %>%
      rownames_to_column("id") %>%
      head(20)
  })
  
  observeEvent(input$check,{
    data <- data.frame(                               
      yearly_income = input$yearly_income,
      home_ownership = input$home_ownership,
      bankruptcies = input$bankruptcies,
      years_current_job = input$years_current_job,
      monthly_debt = input$monthly_debt,
      years_credit_history = input$years_credit_history,
      months_since_last_delinquent = input$months_since_last_delinquent,
      open_accounts = input$open_accounts,
      credit_problems = input$credit_problems,
      credit_balance = input$credit_balance,
      max_open_credit = input$max_open_credit,
      amount_current_loan = input$amount_current_loan,
      term = input$term,
      credit_score = input$credit_score,
      loan_purpose = input$loan_purpose)
    
    datah <- as.h2o(data)
    
    prediction <- h2o.predict(model, datah)
    
    output$text <- renderText({
      if(prediction[1,1] == 1){
        paste("The loan request may be approved.\n\n")
      }
      else{
        paste("The loan request may be denied.\n\n")
      }
    })
    
    output$tableCaption <- renderText({"Probabilities (p1 - to approve, p0 - to deny):"})
    output$table <- renderTable({prediction})
    
  })
  
}
shinyApp(ui = ui, server = server)