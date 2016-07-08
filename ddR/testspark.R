library(sparkapi)
spark_home = "/Users/clark/Library/Caches/spark/spark-2.0.0-preview-bin-hadoop2.6"

sc <- start_shell(master = "local", spark_home = spark_home)

billion <- sc %>% 
  invoke_new("java.math.BigInteger", "1000000000") %>%
    invoke("longValue")

data(Orange)

ls("package:sparkapi")

hive_context(sc)

