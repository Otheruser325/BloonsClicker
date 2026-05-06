load_save_from_local_storage = () ->

	if window.localStorage.hasOwnProperty("gc2.savefile") and window.localStorage["gc2.savefile"] != ""

		save_data = import_save(b64_to_sstr(window.localStorage["gc2.savefile"]))

		last_update_time.setTime(save_data["save_time"].getTime())

		if save_data["play_time"] != -1
			basedata.game_started = true
			basedata.play_time = save_data["play_time"]

		basedata.total_play_time = save_data["total_play_time"]
		basedata.bloons = save_data["bloons"]
		basedata.total_bloons = save_data["total_bloons"]
		basedata.total_total_bloons = save_data["total_total_bloons"]
		basedata.clicks = save_data["clicks"]
		basedata.total_clicks = save_data["total_clicks"]

		goomy.gain_exp(save_data["goomy_exp"])
		sliggoo.gain_exp(save_data["sliggoo_exp"])
		goodra.gain_exp(save_data["goodra_exp"])

		basedata.sliggoo_gpsmult = 1.0 + 0.1 * (sliggoo.level)
		goomy.level_cap = 1000 + (goodra.level)

		for generator in generators
			if save_data.generators[generator.name]
				generator.count = save_data.generators[generator.name].count
				generator.level = save_data.generators[generator.name].level
			else
				generator.count = 0
				generator.level = 1
			generator.cost = generator.cost_f(generator.count)
			generator.lvup_cost = generator.base_cost * 100 * Math.pow(1.35, generator.level - 1)

		recalc()
		$("#settings_audio").prop("checked", settings.audio)
		$("#settings_music").prop("checked", settings.music)
		$("#settings_number_format").val(settings.number_format)
		battle.render()
		update_all_numbers()


import_save = (str) ->

	version = str.split("||", 1)[0]  # first instance of a number

	if version == "0.12"
		return _import_save_0_10(str)
	else if version == "0.11"
		return _import_save_0_10(str)
	else if version == "0.10"
		return _import_save_0_10(str)
	else if version == "0.05"
		return _import_save_0_05(str)




##########
# actual import methods
##########





# save file version 0.10
_import_save_0_10 = (str) ->

	save = {}

	data = str.split("||")

	save_time = new Date()
	save_time.setTime(parseInt(data[1]))
	save["save_time"] = save_time

	d02_basedata = data[2].split("|")
	save["play_time"] = parseFloat(d02_basedata[0])
	save["total_play_time"] = parseFloat(d02_basedata[1])
	save["bloons"] = parseFloat(d02_basedata[2])
	save["total_bloons"] = parseFloat(d02_basedata[3])
	save["total_total_bloons"] = parseFloat(d02_basedata[4])
	save["clicks"] = parseFloat(d02_basedata[5])
	save["total_clicks"] = parseFloat(d02_basedata[6])

	d03_goomystats = data[3].split("|")
	save["goomy_exp"] = parseInt(d03_goomystats[0])
	save["sliggoo_exp"] = parseInt(d03_goomystats[1])
	save["goodra_exp"] = parseInt(d03_goomystats[2])

	generator_names = [
		"cursor",
		"monkey",
		"tackshooter",
		"snipermonkey",
		"bombshooter",
		"boomerangthrower",
		"gluegunner",
		"icetower",
		"ninjamonkey",
		"monkeybuccaneer",
		"monkeyapprentice",
		"monkeysub",
		"monkeyace",
		"spikefactory",
		"monkeyengineer",
		"supermonkey"
	]
	legacy_generator_names = [
		"cursor",
		"monkey",
		"daycare",
		"reserve",
		"farm",
		"fountain",
		"cave",
		"trench",
		"arceus",
		"rngabuser",
		"cloninglab",
		"church",
		"gcminer",
		"photoncollider",
		"monkeyengineer",
		"supermonkey"
	]

	gen_data = {}
	d04_generators = data[4].split("|")
	for i in [0..Math.min(generator_names.length, d04_generators.length)-1]
		datum = d04_generators[i].split(",")
		gen_data[generator_names[i]] = {
			count: parseInt(datum[0])
			level: parseInt(datum[1])
		}
		if legacy_generator_names[i] != generator_names[i]
			gen_data[legacy_generator_names[i]] = gen_data[generator_names[i]]
	save["generators"] = gen_data

	d05_upgrades = data[5].split("|")
	d05_upgrades_bought = sstr_to_bitfield(d05_upgrades[0])
	d05_upgrades_unlocked = sstr_to_bitfield(d05_upgrades[1])
	for id in [1..250]
		if item_ids[id]
			if d05_upgrades_unlocked[id-1] == "1"
				item_ids[id].locked = false
				if d05_upgrades_bought[id-1] == "1"
					item_ids[id].bought = true

	if data[6]
		d07_settings = data[6].split("|")
		settings.audio = d07_settings[0] != "0"
		settings.music = d07_settings[1] != "0"
		settings.number_format = d07_settings[2] || "full"
	if data[7]
		d08_battle = data[7].split("|")
		battle.defeated = parseInt(d08_battle[0]) || 0
		battle.current_index = parseInt(d08_battle[1]) || battle.defeated || 0
		if battle.defeated >= battle.bloons.length
			battle.current_index = battle.bloons.length
		else
			battle.current_index = Math.min(battle.current_index, battle.bloons.length)
		battle.eternal_stage = parseInt(d08_battle[2]) || Math.max(0, battle.defeated - battle.bloons.length)
		battle.active = false
		battle.recalculate_rewards()

	return save







# save file version 0.05
_import_save_0_05 = (str) ->

	save = {}

	data = str.split("||", 5)

	save_time = new Date()
	save_time.setTime(parseInt(data[1]))
	save["save_time"] = save_time

	d02_basedata = data[2].split("|")
	save["play_time"] = parseFloat(d02_basedata[0])
	save["total_play_time"] = parseFloat(d02_basedata[1])
	save["bloons"] = parseFloat(d02_basedata[2])
	save["total_bloons"] = parseFloat(d02_basedata[3])
	save["total_total_bloons"] = parseFloat(d02_basedata[4])
	save["clicks"] = parseFloat(d02_basedata[5])
	save["total_clicks"] = parseFloat(d02_basedata[6])

	d03_goomystats = data[3].split("|")
	save["goomy_exp"] = parseInt(d03_goomystats[0])
	save["sliggoo_exp"] = parseInt(d03_goomystats[1])
	save["goodra_exp"] = parseInt(d03_goomystats[2])

	generator_names = [
		"cursor",
		"monkey",
		"tackshooter",
		"snipermonkey",
		"bombshooter",
		"boomerangthrower",
		"gluegunner",
		"icetower",
		"ninjamonkey",
		"monkeybuccaneer",
		"monkeyapprentice",
		"monkeysub",
		"monkeyace",
		"spikefactory",
		"monkeyengineer",
		"supermonkey"
	]
	legacy_generator_names = [
		"cursor",
		"monkey",
		"daycare",
		"reserve",
		"farm",
		"fountain",
		"cave",
		"trench",
		"arceus",
		"rngabuser",
		"cloninglab",
		"church",
		"gcminer",
		"photoncollider",
		"monkeyengineer",
		"supermonkey"
	]

	gen_data = {}
	d04_generators = data[4].split("|")
	for i in [0..Math.min(generator_names.length, d04_generators.length)-1]
		datum = d04_generators[i].split(",")
		gen_data[generator_names[i]] = {
			count: parseInt(datum[0])
			level: parseInt(datum[1])
		}
		if legacy_generator_names[i] != generator_names[i]
			gen_data[legacy_generator_names[i]] = gen_data[generator_names[i]]
	save["generators"] = gen_data


	return save
