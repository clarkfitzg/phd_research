# Wed Jun 13 21:32:43 PDT 2018

# 
# I want to create objects of class B from objects of class A. 
# Class A1 contains A and 
# B is pretty complex, resulting in objects PastaMeal and B2. I can't use
# coercion, ie. for an object a1 of class A1 call as(a1, "B") because I
# don't want to convert it to an object of class B- it needs to become an
# object of class B2. A second reason is that I think it's more natural to
# call B(a1).
#
# A way around this is to make the class name B also a generic function. Is
# this reasonable? The idea is that the generic function B will always
# return an object that contains the class B.
#
# The strange thing to me is that "A" and "B" are __both__ classes and
# generic functions. 

# The idea seems to work out fine below.

# Classes

setClass("Ingredient", slots = c(main = "character"))
setClass("PastaIngredient", slots = c("weight" = "numeric"), contains = "Ingredient")

setClass("Meal", slots = c(ingredient = "Ingredient", which = "character"))
setClass("PastaMeal", contains = "Meal")


# We define a default method to convert the argument to the proper class
# and build the Ingredient object. This acts similar to the class generator
# function that setClass returns, but is slightly more convenient because
# we don't need to specify the arguments.

setGeneric("Ingredient", function(x, ...)
{
    message("default")
    new("Ingredient", main = as(x, "character"))
})


# When we pass in a numeric argument it must mean the weight of the pasta.

setMethod("Ingredient", "numeric", function(x, main = "noodle")
{
    message("Oh, this must be pasta.")
    new("PastaIngredient", main = main, weight = x)
})


# What was the ingredient in this meal?

setMethod("Ingredient", "Meal", function(x)
{
    message("These are the ingredients in the meal.")
    x@ingredient
})


setGeneric("Meal", function(a, ...)
{
    message("default")
    new("Meal", a = a, Bbar = a@main + 1)
})
setAs(from = "Ingredient", to = "Meal", function(from) B(from))


setMethod("Meal", "PastaIngredient", function(a)
{
    message("A1 to PastaMeal")
    new("PastaMeal", a = a, Bbar = a@main + 2)
})
setAs(from = "PastaIngredient", to = "PastaMeal", function(from) B(from))


# Expect default message:

a = A(100)
b = B(a)

# Same
as(a, "Meal")

A(b)


# Expect message A1 to PastaMeal:

a1 = A("dispatch!")

b1 = B(a1)

# Same
as(a1, "PastaMeal")

A(b1)

