# Wed Nov  8 16:02:31 PST 2017
#
# Was reading the docs for dbplyr and seeing if it can help with SQL
# generation to make queries run on Hive.

# https://cran.r-project.org/web/packages/dbplyr/vignettes/dbplyr.html

library(dplyr)
library(dbplyr)


lahman_s <- lahman_sqlite()

batting <- tbl(lahman_s, "Batting")

tailnum_delay_db <- batting %>% 
  group_by(yearID) %>%
  summarise(
    delay = mean(G),
    n = n()
  ) %>% 
  arrange(desc(delay)) %>%
  filter(n > 100)


tailnum_delay_db %>% show_query()

# Looks reasonable:

# <SQL>
# SELECT *
# FROM (SELECT *
# FROM (SELECT `yearID`, AVG(`G`) AS `delay`, COUNT() AS `n`
# FROM `Batting`
# GROUP BY `yearID`)
# ORDER BY `delay` DESC)
# WHERE (`n` > 100.0)

# But suppose we use a user defined R function:

udf = function(x) pi

tailnum_delay_db2 <- batting %>% 
  group_by(yearID) %>%
  summarise(
    delay = udf(G),
    n = n()
  ) %>% 
  arrange(desc(delay)) %>%
  filter(n > 100) %>%
  show_query()

# Then it translates to UDF(`G`) in the SQL, which has no meaning unless it's
# implemented in the database.

