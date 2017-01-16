


define R_INT_MAX  INT_MAX
define R_INT_MIN -INT_MAX
// .. relying on fact that NA_INTEGER is outside of these

static R_INLINE int R_integer_plus(int x, int y, Rboolean *pnaflag)

   if (x == NA_INTEGER || y == NA_INTEGER)
   return NA_INTEGER;

   if (((y > 0) && (x > (R_INT_MAX - y))) ||
   ((y < 0) && (x < (R_INT_MIN - y)))) {
   if (pnaflag != NULL)
       *pnaflag = TRUE;
   return NA_INTEGER;
   }
   return x + y;
