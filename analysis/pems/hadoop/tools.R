plotfd = function(row, ...)
{
    with(row, lines(c(0, leftx, rightx, 1)
                    , c(0, lefty, righty, 0), ...))
}
