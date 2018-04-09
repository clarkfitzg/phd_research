Mon Apr  9 13:52:27 PDT 2018

Brainstorming ideas for talking at JSM this summer. Abstracts are finalized
on Apr 18th. My current abstract looks decent- it's general, high level and
doesn't commit me to much.

Duncan suggests that I use the user narrative as my talk. After all, I only
have 20-30 minutes. This seems like it explains the general ideas pretty
well. It's similar to my QE.

I would like to show the Hive code generator on the PEMS example as
something that worked well. To that end I would like to make that code a
little more complete and possibly release it on CRAN before I give the
talk. All I want is a function like `by_to_hive()`. Some features I had in
mind were:

- Querying hive to get the input column data types
- Type inference on R code
- More customization

## Points to make

- The best abstractions are the ones you already know.
- The best thing that can happen with parallelism is for other systems to
  deal with the details for you.
- Metaprogramming allows some interesting possibilities.

## Graphics to present

- highlight chunks of code, separate them into threads
- take the three simple example statements and show all different
  models for execution.

## Questions to anticipate

- When is this useful?
    - General data analysis scripts
- What kind of speedups do you hope for?
    - For task parallelism we'd be thrilled with a factor of 2
    - The Hive one makes things possible that weren't possible before
- When can I use this?
    - This is still very much in the prototype stage
    - If you have a specific use case I'd like to talk with you afterwards
    - If you're looking to do this today consider `parallel::mcparallel()`
      or Henrik Bengtson's `futures` package.
