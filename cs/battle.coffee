bloon_image = (fill, stroke = "%238aa4ff") ->
	"data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 180 220'><defs><radialGradient id='g' cx='60%25' cy='25%25' r='70%25'><stop offset='0%25' stop-color='%23ffffff' stop-opacity='.75'/><stop offset='40%25' stop-color='#{fill}'/><stop offset='100%25' stop-color='#{fill}' stop-opacity='.82'/></radialGradient></defs><ellipse cx='90' cy='84' rx='68' ry='76' fill='url(%23g)' stroke='#{stroke}' stroke-width='8'/><path d='M78 155h24l-12 40z' fill='#{fill}' stroke='#{stroke}' stroke-width='6' stroke-linejoin='round'/></svg>"

ETERNAL_BLOON_IMAGE = "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 240 260'><defs><radialGradient id='g' cx='60%25' cy='28%25' r='72%25'><stop offset='0%25' stop-color='%23ffffff' stop-opacity='.8'/><stop offset='38%25' stop-color='%233be5d0'/><stop offset='100%25' stop-color='%23008391'/></radialGradient><filter id='glow'><feGaussianBlur stdDeviation='4' result='b'/><feMerge><feMergeNode in='b'/><feMergeNode in='SourceGraphic'/></feMerge></filter></defs><ellipse cx='120' cy='96' rx='82' ry='88' fill='url(%23g)' stroke='%23f8ff77' stroke-width='10'/><path d='M102 180h36l-18 54z' fill='%23008391' stroke='%23f8ff77' stroke-width='8' stroke-linejoin='round'/><path d='M60 100c22-42 56-42 60 0 4 42 38 42 60 0M60 100c22 42 56 42 60 0 4-42 38-42 60 0' fill='none' stroke='%23fff36b' stroke-width='13' stroke-linecap='round' filter='url(%23glow)'/></svg>"

battle =
	active: false
	timer: 0
	duration: 30000
	hp: 0
	max_hp: 0
	tap_mult: 1
	bps_mult: 1
	defeated: 0
	current_index: 0
	eternal_stage: 0
	bloons: [
		{name: "Blue Bloon", hp: 1000, tap_reward: 0.01, bps_reward: 0.005, image: bloon_image("%233e7bff", "%238aa4ff")}
		{name: "Green Bloon", hp: 7500, tap_reward: 0.015, bps_reward: 0.0075, image: bloon_image("%2337d45f", "%2382f59a")}
		{name: "Yellow Bloon", hp: 50000, tap_reward: 0.02, bps_reward: 0.01, image: bloon_image("%23ffd83f", "%23fff187")}
		{name: "Pink Bloon", hp: 350000, tap_reward: 0.025, bps_reward: 0.0125, image: bloon_image("%23ff5fb7", "%23ff9fd4")}
		{name: "Black Bloon", hp: 2500000, tap_reward: 0.03, bps_reward: 0.015, image: bloon_image("%2324242a", "%23757582")}
		{name: "White Bloon", hp: 15000000, tap_reward: 0.035, bps_reward: 0.0175, image: bloon_image("%23f7f7f7", "%23c9d8ff")}
		{name: "Lead Bloon", hp: 100000000, tap_reward: 0.04, bps_reward: 0.02, image: bloon_image("%23838383", "%23c8c8c8")}
		{name: "Zebra Bloon", hp: 750000000, tap_reward: 0.045, bps_reward: 0.0225, image: bloon_image("%23ffffff", "%23161616")}
		{name: "Rainbow Bloon", hp: 5000000000, tap_reward: 0.05, bps_reward: 0.025, image: bloon_image("%23ff4646", "%23864cff")}
		{name: "Ceramic Bloon", hp: 40000000000, tap_reward: 0.06, bps_reward: 0.03, image: bloon_image("%23c7803c", "%23ffd17d")}
		{name: "MOAB", hp: 250000000000, tap_reward: 0.075, bps_reward: 0.04, image: "https://static.wikia.nocookie.net/b__/images/b/ba/BTD6MOAB.png/revision/latest?cb=20180809063308&path-prefix=bloons"}
		{name: "BFB", hp: 2500000000000, tap_reward: 0.1, bps_reward: 0.055, image: "https://bloons.fandom.com/wiki/Special:Redirect/file/BTD6BFB.png"}
		{name: "ZOMG", hp: 25000000000000, tap_reward: 0.13, bps_reward: 0.07, image: "https://bloons.fandom.com/wiki/Special:Redirect/file/BTD6ZOMG.png"}
		{name: "B.A.D", hp: 250000000000000, tap_reward: 0.18, bps_reward: 0.1, image: "https://static.wikia.nocookie.net/b__/images/4/41/BTD63DBAD.png/revision/latest?cb=20190620201902&path-prefix=bloons"}
	]
	eternal_base_hp: 250000000000000 * 21
	eternal_hp_scale: 7.5
	eternal_tap_reward: 0.10
	eternal_bps_reward: 0.05
	current_bloon: ->
		if @current_index >= @bloons.length
			stage = @eternal_stage + 1
			return {
				name: "Eternal Bloon Stage #{stage}"
				hp: @eternal_base_hp * Math.pow(@eternal_hp_scale, @eternal_stage)
				tap_reward: @eternal_tap_reward + @eternal_stage * 0.01
				bps_reward: @eternal_bps_reward + @eternal_stage * 0.005
				image: ETERNAL_BLOON_IMAGE
				eternal: true
			}
		@bloons[Math.min(@current_index, @bloons.length - 1)]
	recalculate_rewards: ->
		@tap_mult = 1
		@bps_mult = 1
		for i in [0...Math.min(@defeated, @bloons.length)]
			@tap_mult += @bloons[i].tap_reward
			@bps_mult += @bloons[i].bps_reward
		if @eternal_stage > 0
			for stage in [1..@eternal_stage]
				@tap_mult += @eternal_tap_reward + (stage - 1) * 0.01
				@bps_mult += @eternal_bps_reward + (stage - 1) * 0.005
	start: ->
		if @active
			return @render_status("Already fighting #{@current_bloon().name}!")
		bloon = @current_bloon()
		@active = true
		@timer = @duration
		@max_hp = bloon.hp
		@hp = @max_hp
		@render_status("Fight started: #{bloon.name}. Pop it before time runs out.")
		@render()
	tap: ->
		return unless @active
		@damage(Math.max(1, basedata.gpc))
	damage: (n) ->
		@hp -= n
		if @hp <= 0 then @win() else @render()
	win: ->
		bloon = @current_bloon()
		name = bloon.name
		@active = false
		@defeated += 1
		if bloon.eternal
			@eternal_stage += 1
		else
			@current_index = Math.min(@current_index + 1, @bloons.length)
		@tap_mult += bloon.tap_reward
		@bps_mult += bloon.bps_reward
		$("#battle_trophies").append("<div class='battle-trophy'>#{name}<br/>+#{(bloon.tap_reward * 100).toFixed(1)}% Tap, +#{(bloon.bps_reward * 100).toFixed(1)}% BPS</div>")
		@render_status("Victory! #{name} defeated. Next up: #{@current_bloon().name}.")
		@render()
		recalc()
	lose: ->
		@active = false
		@render_status("Time up! #{@current_bloon().name} escaped.")
		@render()
	update: (ms) ->
		return unless @active
		@timer -= ms
		@damage(basedata.gps * ms / 1000)
		if @timer <= 0 && @active then @lose()
	render_status: (message) -> $("#battle_status").html(message)
	render: ->
		bloon = @current_bloon()
		$("#battle_target").html(bloon.name)
		$("#battle_bloon_img").attr("src", bloon.image)
		$("#great_goomy").attr("src", if @defeated > 0 then bloon.image else "img/Bloon.png")
		$("#battle_timer").html((Math.max(0, @timer) / 1000).toFixed(1) + "s")
		$("#battle_hp").attr("max", @max_hp || bloon.hp)
		$("#battle_hp").attr("value", Math.max(0, @hp || bloon.hp))
		$("#battle_hp_value").html(reprnum(Math.ceil(Math.max(0, @hp || bloon.hp))) + " / " + reprnum(@max_hp || bloon.hp) + " HP")

@battle = battle
