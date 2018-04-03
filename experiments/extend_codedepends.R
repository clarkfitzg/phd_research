library(CodeDepends)

getInputs(quote(
    iris %>%
      select(Petal.Width, Species)
))@inputs


# Here's how to extend it.

getInputs(quote(
    iris %>%
      select(Petal.Width, Species) %>%
      gather(key = "var", value = "value", Petal.Width)
), collector = inputCollector(functionHandlers = list(gather = nseafterfirst))
)@inputs

