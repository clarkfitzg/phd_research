params = read.csv('params.csv')
sim = simulate(params, 1000000)
data = read.csv('data.csv')
joined = merge(data, sim)
