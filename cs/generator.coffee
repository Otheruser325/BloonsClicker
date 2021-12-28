gens = {}
generators = []

class Generator

	constructor: (name) ->
		@name = name

		@base_gps = 0.0
		@premult_gps = 0.0
		@gps = 0.0

		@level = 1
		@level_mult = 1.0

		@base_cost = 20
		@cost = @base_cost
		@lvup_cost = @base_cost * 100
		@count = 0

		@cost_f = (n) -> Math.floor(@base_cost * Math.pow(n + 10, Math.log(n + 10) / Math.log(10)) / 10)

		gens[name] = this
		generators.push(this)

	buy: (n) ->
		for i in [1..n]
			if basedata.goomies < @cost
				recalc()
				return i-1
			basedata.goomies -= @cost
			@count += 1
			@cost = @cost_f(@count)
		recalc()
		return n

	sell: (n) ->
		for i in [1..n]
			if @count <= 0
				recalc()
				return i-1
			@count -= 1
			@cost = @cost_f(@count)
			basedata.goomies += @cost * 0.25
		recalc()
		return n

	levelup: () ->
		if basedata.goomies < @lvup_cost
			return false
		basedata.goomies -= @lvup_cost
		@level += 1
		@lvup_cost = @base_cost * 100 * Math.pow(1.3, @level - 1)
		recalc()
		return true

	show_tooltip: () ->
		$("##{@name}").qtip("lol")

	set_base_cost: (cost) ->
		@base_cost = cost
		@lvup_cost = @base_cost * 100


# actual generator data

cursor = new Generator("cursor")
cursor.base_gps = 0.2
cursor.set_base_cost(15)
# repl. time: 100 s

youngster = new Generator("youngster")
youngster.base_gps = 1.0
youngster.set_base_cost(100)
# repl. time: 100 s

daycare = new Generator("daycare")
daycare.base_gps = 5.0
daycare.set_base_cost(600)
# repl. time: 120 s

reserve = new Generator("reserve")
reserve.base_gps = 20.0
reserve.set_base_cost(3000)
# repl. time: 150 s

farm = new Generator("farm")
farm.base_gps = 75.0
farm.set_base_cost(15000)
# repl. time: 200 s

fountain = new Generator("fountain")
fountain.base_gps = 250.0
fountain.set_base_cost(70000)
# repl. time: 280 s

cave = new Generator("cave")
cave.base_gps = 1000.0
cave.set_base_cost(400000)
# repl. time: 400 s

trench = new Generator("trench")
trench.base_gps = 4000.0
trench.set_base_cost(2400000)
# repl. time: 600 s

arceus = new Generator("arceus")
arceus.base_gps = 18000
arceus.set_base_cost(20000000)
# repl. time: 1111 s

rngabuser = new Generator("rngabuser")
rngabuser.base_gps = 65536
rngabuser.set_base_cost(134217728)
# repl. time: 1024 s

cloninglab = new Generator("cloninglab")
cloninglab.base_gps = 288000
cloninglab.set_base_cost(1440000000)
# repl. time: 1260 s

church = new Generator("church")
church.base_gps = 1920000
church.set_base_cost(24.192e9)
# repl. time: 1600 s

gcminer = new Generator("gcminer")
gcminer.base_gps = 16777216
gcminer.set_base_cost(549755813888)
# repl. time: 32768 s

photoncollider = new Generator("photoncollider")
photoncollider.base_gps = 299792458
photoncollider.set_base_cost(25902068371200)
# repl. time: 86400 s

# create a list of the above generators
ngens = [daycare, reserve, farm, fountain, cave, trench, arceus, rngabuser, cloninglab, church, gcminer, photoncollider]

# create a dictionary by name so they're more easily searchable
for gen in generators
	gen.cost = gen.base_cost
