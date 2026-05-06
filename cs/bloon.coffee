bloon =
	exp: 0,
	level: 1,
	next_lv_exp: 100,
	lv_total_exp: 0,
	level_cap: 100,

	level_up: ->
		@level += 1
		@lv_total_exp += @next_lv_exp
		@next_lv_exp = @level * @level * 100
		recalc_gpc()
		update_all_numbers()

	gain_exp: (exp) ->
		@exp += exp
		if @level >= @level_cap and @exp > @lv_total_exp
			@exp = @lv_total_exp
		while @exp >= @lv_total_exp + @next_lv_exp and @level < @level_cap
			do @level_up


sliggoo =
	exp: 0,
	level: 0,
	next_lv_exp: 25,
	lv_total_exp: 0,

	level_up: ->
		@level += 1
		@lv_total_exp += @next_lv_exp
		@next_lv_exp = (@level + 5) * (@level + 5)

	gain_exp: (exp) ->
		@exp += exp
		while @exp >= @lv_total_exp + @next_lv_exp
			do @level_up


goodra =
	exp: 0,
	level: 0,
	next_lv_exp: 1000,
	lv_total_exp: 0,

	level_up: ->
		@level += 1
		@lv_total_exp += @next_lv_exp
		@next_lv_exp = @level * 30 + 1000

	gain_exp: (exp) ->
		@exp += exp
		while @exp >= @lv_total_exp + @next_lv_exp
			do @level_up

@bloon = bloon
@sliggoo = sliggoo
@goodra = goodra
