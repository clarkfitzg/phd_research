Thu Mar  1 15:06:16 PST 2018

Following `notes/flatten.md` I wonder if I can use this flattened code to
create SQL out of R code.

Here's the R code:

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

One thing I need to be able to do is test a condition and branch.
How can I do that in SQL and bash?

```{sql}

DROP TABLE scalar_integers;

CREATE TABLE scalar_integers (
    name CHAR
    , value INTEGER
);

INSERT INTO scalar_integers
VALUES ("n", 50);

INSERT INTO scalar_integers
VALUES ("n_i", 10);

-- This tests if n_i < n. Returns 1 if true, 0 if false.
SELECT COUNT(*) FROM scalar_integers WHERE name = "n_i" AND
value < (SELECT value FROM scalar_integers WHERE name = "n");

SELECT * FROM scalar_integers;

```
