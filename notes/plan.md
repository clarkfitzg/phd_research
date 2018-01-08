Mon Jan  8 08:57:24 PST 2018

Winding down last year I wrote a summary of what I've been up to. In
retrospect I was too hard on R.

Now let's plan for next year. Following Norm's advice, Duncan and I need to
be on the same page about what will make a thesis.  Hmmm, I wonder if I
could have a draft completed in a year.

I just looked over Gabe Becker's thesis. The rough, high level structure
is:

1. 2 substantial motivating case studies
2. Computational model, object model
3. Proof of concept software / integration with existing software

This is about what I expected. I could follow a similar format.

# Outline

## Case studies

1. PEMS data
    - Several different analyses, ie. nonparametric, or robust
    - Generate and run on several different systems, Hive, single server
      (sufficient and limited memory) (SLURM probably too hard).
2. More numerical
    - Ethan's Vecchia approximation calculation
    - Computing sample correlation matrix (probably too simple)
3. Complete script
    - Find or make one that actually benefits from task parallelism

## Concepts / Software

1. Directed task graph in R
    - Review substantial CS literature
    - Details on generation, peculiarities to R

2. Automatically identifying and using Map-Reduce parallelism in R
    - Covers simple case of `lapply()` to `mclapply`.
    - Group by also common, can come from finding the use of `split()` in
      code

3. Pipeline parallelism 
    - Avoids R's memory limits
    - Generate shell commands to efficiently preprocess
    - Integrate with cursors in another type of database
