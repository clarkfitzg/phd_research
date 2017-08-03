
------------------------------------------------------------

What is the meaning of `const` after a function or method signature in the
documentation?

```
const value_type* arrow::NumericArray< TYPE >::raw_data (       )   const
```

_ANSWER_:

The `const` keyword after means that the `raw_data()` method will not modify the
object, the implicit `this`
[src](https://stackoverflow.com/a/15999170/2681019).

------------------------------------------------------------


