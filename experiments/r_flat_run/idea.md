I'm considering an alternative execution model for R code based on this
flattened task graph.

The execution starts out with the following state:

- __R process__, a single R process that runs an event loop
- __statement store__, a mapping from `1, 2, ...` to data structure with
  the following elements:
    - __variable__ name of the variable to update in store
    - __code__ to evaluate which updates the variable
    - __control flow__ integer vector of statements to execute
- __variable store__, an empty key value store to contain the variables
- __current statement__ is initialized to 1.

A single unit of work consists of these steps:

1. R looks up the (variable, function call, control flow) corresponding to
   the value of the current statement.
2. R identifies all symbols used in the call.
3. For each symbol, R checks the variable store to see if it contains the
   value, and loads it into the workspace if found.
4. R evaluates the function call.
5. R saves the result of the function call into the variable in the
   variable store.
6. R updates the current statement
    - If the control flow is of length 1, then that becomes the current
      statement
    - If the control flow is a vector of length > 1, then the current
      statement switches based on the value of the evaluated code.
6. R checks if the current statement matches a sentinel value
   indicating the end of the program. If so, then the program is complete.
6. R removes all variables that it loaded in step 3.

This approach has many disadvantages. The two that come to mind first are
that it will slow R down and make it more difficult to debug.
Critics claim R is slow, and this will make R much slower.

The only advantage I see is that R will use less memory than it would
otherwise.

## Refinements

(Easy) R can locally cache the symbols so it doesn't have to hit the variable
store every time.

(More Difficult) The control flow can be refined into a tree that allows
multiple R processes to do task parallelism.

## Example

```{R}
# Compute n!
n = 3
ans = 1L
for(i in 2:n){
    ans = ans * i
}
print(ans)
```

When flattened out it becomes:

```
id  | var               | code                          | goto  | if_false
--------------------------------------------------------------------------
1   | n                 | identity(3)                   | 2     | NA
2   | ans               | identity(1)                   | 3     | NA
3   | tmp_iter_over     | 2:n                           | 4     | NA
4   | tmp_last          | length(tmp_iter_over)         | 5     | NA
5   | tmp_i_index       | identity(1)                   | 6     | NA
6   | i                 | tmp_iter_over[[tmp_i_index]]  | 7     | NA
7   | ans               | ans * i                       | 8     | NA
8   | tmp_i_index       | tmp_i_index + 1L              | 9     | NA
9   | tmp_test_end_for  | tmp_i_index > tmp_last        | 10    | 6
10  | tmp_print         | print(ans)                    | Inf   | NA
```
