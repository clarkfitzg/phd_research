params = read.csv('params.csv')
data = read.csv('data.csv')
sim = simulate(params, 1000000)
joined = merge(data, sim)
