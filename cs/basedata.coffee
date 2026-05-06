basedata =

	version: "0.354 (pre-alpha)",

	game_started: false,

	bloons: 0,

	total_bloons: 0,   # total bloons, counting ones used in purchases
	total_total_bloons: 0,   # total bloons, counting ones used in reset

	play_time: 0,   # play time in seconds of current session
	total_play_time: 0,   # total play time over all sessions

	last_save_time: new Date()	# date and time of last save, for perfect idle calc

	gps: 0,
	expps: 0,
	gpc: 1,

	sliggoo_gpsmult: 1.0,

	raindance_mult: 1.0,
	frenzy_clickmult: 1.0,

	clicks: 0,   # number of times the Great Bloon was clicked
	total_clicks: 0,

	earn: (n) ->
		@bloons += n
		@total_bloons += n
		@total_total_bloons += n

	click: ->

		if !@game_started
			@game_started = true

		gain = @gpc

		@earn(gain)
		@clicks += 1
		@total_clicks += 1
		bloon.gain_exp(bloon.level)
		return gain

	update: (ms) ->

		gain = @gps * ms / 1000
		@earn(gain)

		exp_gain = @expps * ms / 1000
		bloon.gain_exp (exp_gain)

		if @game_started
			@play_time += ms
			@total_play_time += ms

	reset: ->
		# calculate prestige bonuses
		sliggoo.gain_exp (@total_bloons / 1e12)
		goodra.gain_exp (bloon.exp / 1e4)

		# Sliggoo gives a GPS multiplier boost.
		@sliggoo_gpsmult = 1.0 + 0.1 * (sliggoo.level)
		# Goodra raises the level cap.
		bloon.level_cap = 1000 + (goodra.level)

		@bloons = 0
		@total_bloons = 0
		# @total_total_bloons is untouched.

		bloon.exp = 0
		bloon.level = 1
		bloon.next_lv_exp = 100
		bloon.lv_total_exp = 0

		@game_started = false
		@play_time = 0

		@clicks = 0
		for generator in generators
			generator.count = 0
			generator.cost = generator.base_cost
			generator.level = 1
			generator.upgrades = []

		for name, item of items
			item.bought = false
			item.locked = true

		battle.reset_progress()
		recalc()
		update_all_numbers()
		regenerate_tooltips()

# DEBUG: expose basedata to access variables.

@basedata = basedata

settings =
	audio: true
	music: true
	number_format: "full"

@settings = settings
