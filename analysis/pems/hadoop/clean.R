col.names = c("station"
, "n_total"
, "n_middle"
, "n_high"
, "left_slope"
, "left_slope_se"
, "mid_intercept"
, "mid_intercept_se"
, "mid_slope"
, "mid_slope_se"
, "right_slope"
, "right_slope_se"
)

colClasses = c("integer"
, "integer"
, "integer"
, "integer"
, "numeric"
, "numeric"
, "numeric"
, "numeric"
, "numeric"
, "numeric"
, "numeric"
, "numeric"
)

fd = read.table("~/data/pems/fd.tsv", na.strings = "NULL"
    , col.names = col.names, colClasses = colClasses)


n_original = nrow(fd)
 
length(unique(fd$station)) == length(fd$station)

sapply(fd, function(x) mean(is.na(x)))

# These points define the fd
fd$leftx = fd$mid_intercept / (fd$left_slope - fd$mid_slope)
fd$lefty = fd$left_slope * fd$leftx

fd$rightx = (fd$mid_intercept + fd$right_slope) /
                    (fd$right_slope - fd$mid_slope)
fd$righty = fd$mid_intercept + fd$mid_slope * fd$rightx

ordered = with(fd, (0 <= leftx) & (leftx <= rightx) & (rightx <= 1))
ordered[is.na(ordered)] = FALSE

# 0.87 have the right order. Good!
mean(ordered)

fd = fd[ordered, ]

fd$mid_slope_se = as.numeric(fd$mid_slope_se)
fd$right_slope_se = as.numeric(fd$right_slope_se)

par(mfrow = c(2, 2))

lapply(fd[, c("left_slope_se", "mid_slope_se", "right_slope_se")], hist)

lapply(fd[, c("left_slope", "mid_slope", "right_slope")], quantile)

# Apply some reasonable cutoffs
reasonable = (fd$left_slope < 300) &
    (-100 < fd$right_slope) &
    (fd$left_slope_se < 1)

mean(reasonable)

fd = fd[reasonable, ]

par(mfrow = c(1, 1))

nrow(fd)

fd$right_convex = fd$mid_slope < fd$right_slope

# This is an interesting find
mean(fd$right_convex)

write.table(fd, "~/data/pems/fdclean.tsv", sep = "\t"
            , row.names = FALSE)
