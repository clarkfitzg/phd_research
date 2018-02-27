Tue Feb 27 08:48:27 PST 2018

Reading http://ieeexplore.ieee.org/abstract/document/6816765/

[@viglas2014just] discusses how databases generally go from SQL into an
intermediate representation of a physical query plan which can then be
directly optimized.

Databases have compiled queries, or portions of queries, with various
levels of success since COBOL and SEQUEL, the predecessor to SQL.

Some systems translate SQL into LLVM or C, which is compiled to run
efficiently. Compilation can be a bottleneck for small queries.

Parallel processing in compiled SQL technologies is an open research area
as of 2014.

[@shi2014towards] describe a new language for ad hoc data processing that
creates an intermediate representation they call UniQL. The intermediate
representation is optimized for efficient execution. Databases already do
this, so the research contribution is how their new language includes and
optimizes both procedural and declarative aspects of the language.
