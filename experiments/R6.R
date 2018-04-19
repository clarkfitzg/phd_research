# Thu Apr 19 10:26:34 PDT 2018
#
# Understanding a bit about R6

library(R6)

Person <- R6Class("Person",
  public = list(
    name = NULL,
    hair = NULL,
    planet = "Earth",
    initialize = function(name = NA, hair = NA) {
      self$name <- name
      self$hair <- hair
      self$greet()
    },
    set_hair = function(val) {
      self$hair <- val
    },
    greet = function() {
      cat(paste0("Hello, my name is ", self$name, ".\n"))
    }
  )
)


p1 = Person$new("Joe", "grey")
p2 = Person$new("May", "blond")

# Object method
p1$greet()

p2$planet = "Mars"
p1$planet
