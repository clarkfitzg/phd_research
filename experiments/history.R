    history_lines <- function()
    {
      f <- tempfile()
      on.exit(unlink(f))
      savehistory(f)
      readLines(f, encoding = "UTF-8")
    }
