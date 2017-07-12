
Tue Jul 11 17:14:33 PDT 2017

Verify my understanding of this. Found in the R source for covariance
calculation, ie. under `src/library/stats/src/cor.c`

- What's the `##` mean? A single `#` is for a preprocessor macro.

1. Loop through `_X_`. If the 

```
/* This uses two passes for better accuracy */
#define MEAN(_X_)				\
    /* variable means */			\
    for (i = 0 ; i < nc##_X_ ; i++) {		\
	xx = &_X_[i * n];			\
	sum = 0.;				\
	for (k = 0 ; k < n ; k++)		\
	    if(ind[k] != 0)			\
		sum += xx[k];			\
	tmp = sum / nobs;			\
	if(R_FINITE((double)tmp)) {		\
	    sum = 0.;				\
	    for (k = 0 ; k < n ; k++)		\
		if(ind[k] != 0)			\
		    sum += (xx[k] - tmp);	\
	     tmp = tmp + sum / nobs;		\
	}					\
	_X_##m [i] = (double)tmp;		\
    }
```
