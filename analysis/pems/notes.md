Mon Jun 26 09:04:01 PDT 2017

Looking again at the PEMS site. They have interesting metadata for each
station:

```
Roadway Information (from TSN)
Road Width  36 ft
Lane Width  12.0 ft
Inner Shoulder Width    5 ft
Inner Shoulder Treated Width    5 ft
Outer Shoulder Width    5 ft
Outer Shoulder Treated Width    5 ft
Design Speed Limit  70 mph
Functional Class    Principal Arterial W/ C/L Prin Arterial
Inner Median Type   Unpaved
Inner Median Width  32 ft
Terrain Flat
Population  Urbanized
Barrier Three Beam Barrier
Surface Base & Surface >= 7" Thick
Roadway Use No Special Features 
```

This could be used as the input for regression that predicts
the characteristics of the fundamental diagram as the output. For example,
flat `Terrain` should be different than a 6% grade because trucks will be
slower.

Another interesting task would be to validate the highway flow models based
on real data. The highway flow models are tables which let one look up most
of the above characteristics and then output an hourly flow.

# One station

```
scp clarkf@poisson.ucdavis.edu:/scratch/clarkf/pems/stationID/400400.csv ~/data/station_400400.csv
```

First focus on just station 400400. This is North bound 101 in San Jose
just North of I680.


```{R}

# Row names are a problem
station = read.csv("~/data/station_400400.csv", row.names = NULL)[, -1]

fd = traffic::fd_rlm(station$flow2, station$occupancy2)

```

Are these reasonable values? Since flow is in vehicles per 30 seconds this
can be converted to hourly flows by multiplying by 120.

For congested the flow drops to 0 around when the occupancy = 1, which is
good. This constraint could also be enforced, for a more parsimonious /
reasonable model.

```{R}

# For freeflow the max flow is 2628 - seems reasonable
146 * 120 * 0.15

# For congested the max flow is 1718 - not bad
120 * (16.6 - 15.2 * 0.15)

```
