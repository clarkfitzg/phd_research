# Wed Jun 13 21:32:43 PDT 2018

# I want to create objects of class B from objects of class A. 
# A has subclasses A1 and A2, and the conversion of these objects to class
# B is pretty complex, resulting in objects B1 and B2. I can't use
# coercion, ie. for an object a1 of class A1 call as(a1, "B") because I
# don't want to convert it to an object of class B- it needs to become an
# object of class B2. A second reason is that I think it's more natural to
# call B(a1).
#
# A way around this is to make the class name B also a generic function. Is
# this reasonable? The idea is that the generic function B will always
# return an object that contains the class B.

# The idea seems to work out fine below.


# Classes

A = setClass("A", slots = c(Afoo = "numeric"))
A1 = setClass("A1", contains = "A")

setClass("B", slots = c(a = "A", Bbar = "numeric"))
setClass("B1", contains = "B")


setGeneric("B", function(a)
{
    message("default")
    new("B", a = a, Bbar = a@Afoo + 1)
})
setAs(from = "A", to = "B", function(from) B(from))


setMethod("B", "A1", function(a)
{
    message("A1 to B1")
    new("B1", a = a, Bbar = a@Afoo + 2)
})
setAs(from = "A1", to = "B1", function(from) B(from))


# Expect default message:

a = A(Afoo = 100)
b = B(a)

# Same
as(a, "B")


# Expect message A1 to B1:

a1 = A1(Afoo = 100)
b1 = B(a1)

# Same
as(a1, "B1")
