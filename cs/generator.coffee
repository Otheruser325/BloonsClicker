gens = {}
generators = []

class Generator

	constructor: (name) ->
		@name = name
		@display_name = name
		@description = ""
		@image = name
		@legacy_names = []

		@base_gps = 0.0
		@premult_gps = 0.0
		@gps = 0.0

		@level = 1
		@level_mult = 1.0

		@base_cost = 15
		@cost = @base_cost
		@lvup_cost = @base_cost * 100
		@count = 0

		@cost_f = (n) -> Math.floor(@base_cost * Math.pow(n + 10, Math.log(n + 10) / Math.log(10)) / 10)

		gens[name] = this
		generators.push(this)

	buy: (n) ->
		for i in [1..n]
			if basedata.bloons < @cost
				recalc()
				return i-1
			basedata.bloons -= @cost
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
			basedata.bloons += @cost * 0.25
		recalc()
		return n

	levelup: () ->
		if basedata.bloons < @lvup_cost
			return false
		basedata.bloons -= @lvup_cost
		@level += 1
		@lvup_cost = @base_cost * 100 * Math.pow(1.35, @level - 1)
		recalc()
		return true

	show_tooltip: () ->
		$("##{@name}").qtip("lol")

	set_base_cost: (cost) ->
		@base_cost = cost
		@lvup_cost = @base_cost * 100

	set_theme: (display_name, description, image, legacy_names = []) ->
		@display_name = display_name
		@description = description
		@image = image
		@legacy_names = legacy_names
		for legacy_name in legacy_names
			gens[legacy_name] = this


# actual generator data

cursor = new Generator("cursor")
cursor.base_gps = 0.2
cursor.set_base_cost(15)
cursor.set_theme("Cursor", "A helping cursor that pops a tiny trickle of Bloons.", "cursor")
# repl. time: 100 s

monkey = new Generator("monkey")
monkey.base_gps = 1.0
monkey.set_base_cost(100)
monkey.set_theme("Dart Monkey", "A lil' Dart Monkey who is trained to pop and capture Bloons.", "monkey")
# repl. time: 100 s

tackshooter = new Generator("tackshooter")
tackshooter.base_gps = 5.0
tackshooter.set_base_cost(500)
tackshooter.set_theme("Tack Shooter", "A tower which shoots eight tacks in adjacent volleys to pop numerous Bloons.", "TackShooter", ["daycare"])
# repl. time: 120 s

snipermonkey = new Generator("snipermonkey")
snipermonkey.base_gps = 20.0
snipermonkey.set_base_cost(2500)
snipermonkey.set_theme("Sniper Monkey", "A sniper monkey that can snipe bloons anywhere even if they try to attack.", "SniperMonkey", ["reserve"])
# repl. time: 150 s

bombshooter = new Generator("bombshooter")
bombshooter.base_gps = 80.0
bombshooter.set_base_cost(15000)
bombshooter.set_theme("Bomb Shooter", "A cannon which shoots bombs that detonate on contact, destroying Bloon layers open.", "BombShooter", ["farm"])
# repl. time: 200 s

boomerangthrower = new Generator("boomerangthrower")
boomerangthrower.base_gps = 250.0
boomerangthrower.set_base_cost(50000)
boomerangthrower.set_theme("Boomerang Thrower", "A jungle monkey who throws curving boomerangs that pop any Bloons they touch.", "BoomerangThrower", ["fountain"])
# repl. time: 280 s

gluegunner = new Generator("gluegunner")
gluegunner.base_gps = 1000.0
gluegunner.set_base_cost(350000)
gluegunner.set_theme("Glue Gunner", "A monkey who glues Bloons in place, then corrodes their layers with ease.", "GlueGunner", ["cave"])
# repl. time: 400 s

icetower = new Generator("icetower")
icetower.base_gps = 4000.0
icetower.set_base_cost(2000000)
icetower.set_theme("Ice Tower", "A monkey with the powers of ice, stalling Bloons in freezing blocks.", "IceTower", ["trench"])
# repl. time: 600 s

ninjamonkey = new Generator("ninjamonkey")
ninjamonkey.base_gps = 18000
ninjamonkey.set_base_cost(18000000)
ninjamonkey.set_theme("Ninja Monkey", "A ninja trained to assassinate Bloons with shurikens and advanced Camo detection.", "NinjaMonkey", ["arceus"])
# repl. time: 1111 s

monkeybuccaneer = new Generator("monkeybuccaneer")
monkeybuccaneer.base_gps = 75000
monkeybuccaneer.set_base_cost(100000000)
monkeybuccaneer.set_theme("Monkey Buccaneer", "A boat monkey ready to plunder Bloons with cannons, darts, and piracy.", "MonkeyBuccaneer.svg", ["rngabuser"])
# repl. time: 1024 s

monkeyapprentice = new Generator("monkeyapprentice")
monkeyapprentice.base_gps = 275000
monkeyapprentice.set_base_cost(1000000000)
monkeyapprentice.set_theme("Monkey Apprentice", "A wizard monkey whose fire and power magic bewitch and destroy Bloons.", "MonkeyApprentice", ["cloninglab"])
# repl. time: 1260 s

monkeysub = new Generator("monkeysub")
monkeysub.base_gps = 1350000
monkeysub.set_base_cost(15000000000)
monkeysub.set_theme("Monkey Sub", "A submarine monkey that fires homing barbed torpedarts at Bloons.", "MonkeySub.svg", ["church"])
# repl. time: 1600 s

monkeyace = new Generator("monkeyace")
monkeyace.base_gps = 86500000
monkeyace.set_base_cost(300000000000)
monkeyace.set_theme("Monkey Ace", "A monkey pilot who throws out powerful dart volleys from above.", "MonkeyAce.svg", ["gcminer"])
# repl. time: 32768 s

spikefactory = new Generator("spikefactory")
spikefactory.base_gps = 750000000
spikefactory.set_base_cost(5000000000000)
spikefactory.set_theme("Spike Factory", "A mechanical tower that lays spikes to shred Bloons that pass through.", "SpikeFactory.svg", ["photoncollider"])
# repl. time: 86400 s

monkeyengineer = new Generator("monkeyengineer")
monkeyengineer.base_gps = 40000000000
monkeyengineer.set_base_cost(30e15)
monkeyengineer.set_theme("Monkey Engineer", "An ingenious monkey who invents sentry turrets and attacks with a nail gun.", "MonkeyEngineer.svg")

supermonkey = new Generator("supermonkey")
supermonkey.base_gps = 800000000000
supermonkey.set_base_cost(860e15)
supermonkey.set_theme("Super Monkey", "A powerful monkey who throws darts hypersonically fast to destroy MOAB-class Bloons.", "SuperMonkey")

# create a list of the above generators
ngens = [tackshooter, snipermonkey, bombshooter, boomerangthrower, gluegunner, icetower, ninjamonkey, monkeybuccaneer, monkeyapprentice, monkeysub, monkeyace, spikefactory, monkeyengineer, supermonkey]

# create a dictionary by name so they're more easily searchable
for gen in generators
	gen.cost = gen.base_cost
