library("rquery")

d <- data.frame(
  subjectID = c(1,                   
                1,
                2,                   
                2),
  surveyCategory = c(
    'withdrawal behavior',
    'positive re-framing',
    'withdrawal behavior',
    'positive re-framing'
  ),
  assessmentTotal = c(5,                 
                      2,
                      3,                  
                      4),
  stringsAsFactors = FALSE
)
  
print(d)

scale <- 0.237

dq <- d %.>%
  extend_nse(.,
             probability :=
               exp(assessmentTotal * scale)/
               sum(exp(assessmentTotal * scale)),
             count := count(1),
             partitionby = 'subjectID') %.>%
  extend_nse(.,
             rank := rank(),
             partitionby = 'subjectID',
             orderby = c('probability', 'surveyCategory'))  %.>%
  rename_columns(., 'diagnosis' := 'surveyCategory') %.>%
  select_rows_nse(., rank == count) %.>%
  select_columns(., c('subjectID', 
                      'diagnosis', 
                      'probability')) %.>%
  orderby(., 'subjectID')


methods(class = class(dq))

tables_used(dq)

columns_used(dq)


# I'd like to manipulate the operators without any physical data.
# Here's an imaginary table called 'flights' with three columns.
ts = table_source("flights", columns = c("month", "day", "number"))

ts2 = ts %.>%
    select_rows_nse(., month == 1 & day == 1) %.>%
    select_columns(., "month")

# knows that it doesn't need the "number" column, good.
columns_used(ts2)

db = DBI::dbConnect(RSQLite::SQLite(), ":memory:")

ts2 %.>% to_sql(., db) %.>% writeLines(.)


