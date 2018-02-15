Thu Feb 15 14:54:56 PST 2018

The last week I've been working through these `reduce` and `join` ideas and
examples. This is too much focus on "plumbing", ie. programming and
implementation. I need to focus less on plumbing and more on the new ideas.

Problem: I seem to be always straying away from the central idea of my
thesis, which is taking (code, data, platform) and describing or possibly
producing a strategy to execute it, with a focus on acceleration through
parallelism. This is a problem because if it continues I won't finish in a
timely manner.

Possible Solution (Clark's notes after): Short term milestones, say tasks
that I might be able to do in around 1 month. I'll propose a milestone,
then Duncan and I can discuss it and agree on what it means, flesh it out.
I'll focus primarily on that until I finish it or get completely stuck.

Possible first milestones are:

- Systematically examine a more extensive corpus of R code to detect and
  quantify patterns in how programmers in the wild use implicitly parallel
  idioms, ie. Map, tapply, vectorization.
- Precisely define what a data description consists of, which I'll
  focus on, and how they can be extended. This makes the starting point of
  my research much more concrete.
- Represent R code as a data structure that reveals the ideal parallelism,
  ie. both statements that can run in parallel and map type code.


For next meeting:

- Be much more specific with ideas and problems- too general is not helpful.
- Before sending notes for meeting check that they are self contained, ie. give context
  for the motivating problems and focus on core research ideas.
- Send notes farther in advance, say 48 hours.
