Wed Oct 19 10:10:07 PDT 2016

## Visualization

Creating animated data visualizations is typically painful- it requires
a large investment in learning the library and then many lines of code to
implement them. Yet I'm coming to appreciate data visualization more as a
useful tool for understanding and communicating patterns in data,
particularly to a nontechnical audience.

What are the computational considerations when attempting to visualize
large data sets? There seem to be tools that could aid in this like webGL.

Most of the viz techniques we have seem to have been developed from a time
when data was in short supply. The other issue is a shift in medium- paper
was the old medium, and web browsers are essentially the new medium. Web
browsers allow one to interact with data, asking more specific questions.
They can also produce animations. 

Interactivity and animations could probably be used for educational
purposes when teaching statistics and practical data science. They could
increase intuition around things like the central limit theorem. Is there
room to do research around this?

If my long term goal is to teach then this would be a valuable area of
expertise to build up. This applies to teaching both at community college
or industry. If my long term goal is to contribute something useful to
society then again this activity could benefit people across the
world, because it's open and it scales.

What if you could use technology to teach R? Suppose you give a beginner a
task, and then programmatically analyze their solution code to determine if
it's correct or how it could be better? Is it possible to look beyond the
syntax to verify conceptual understanding? This is something like Acuitus
tried to do. Could we say something more with several submitted solutions?

Mostly this is done by learning along with a more experienced person.

I've observed that starting out in a new technology or field is the hardest
part. It's like the sine curve of productivity, when they start off slow.

### Article

Even back in 2007 people had great apps to learn statistics. So making more
of these interactive apps wouldn't be anything new.
https://escholarship.org/uc/item/8sd2t4rr#page-1

### Article

By Nolan, Temple Lang in 2012.
http://amstat.tandfonline.com/doi/abs/10.1198/tast.2010.09132

Talks about the need for statistical computing. The key concepts and the
"computational reasoning" are more
important than the syntax or the favorite technology of the day.
Figure 1 is interesting in how it defines "statistical computing".
Considers the curriculum of statistical computing in detail.

### Article

2015 - Data Science in Statistics Curricula: Preparing Students to “Think with
Data”

> One key aspect of the course is helping students recognize that while each
> language may have its own syntax, the underlying operation that is being
> performed on the data is the same.

In Peng's Coursera sequence:

> The Data Science Specialization is taught entirely online; all assignments
> are graded by peers or machines.

I can remember being peer reviewed in Duncan's 242 class by someone less
experienced than me- their comments weren't helpful.

Programming assignments graded by unit tests- those are probably not able
to detect conceptual errors.

http://swirlstats.com/ Interacts with users by asking for input line by
line. Looks basic from what I see. Probably quite useful though.
