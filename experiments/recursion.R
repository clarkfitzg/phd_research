
factorial = function(x)
{
    if(x == 1L){
        x
    } else {
        x * Recall(x - 1L)
    }
}

f5 = factorial(5)

# Simulating iteration between two functions
f1 = function(x) f2(x - 1)
f2 = function(x) f1(x - 2)
