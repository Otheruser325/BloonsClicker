update_numbers = ->

	goomy_str = reprnum(Math.floor(basedata.bloons), "long")
	$(".goomies").html(goomy_str)

	$("#stats_playtime").html(reprtime(basedata.play_time))

	$("#stats_goomies").html(reprnum(Math.floor(basedata.bloons), "long"))
	$("#stats_total_goomies").html(reprnum(Math.floor(basedata.total_bloons), "long"))
	$("#stats_exp").html(reprnum(Math.floor(goomy.exp)))
	$("#stats_exp_to_next_level").html(reprnum(goomy.next_lv_exp + goomy.lv_total_exp - Math.floor(goomy.exp)))

	if shiny_goomy.time_left > 0
		if shiny_goomy.effect == "raindance"
			$("#rain_dance_time_left").html(reprsecs(shiny_goomy.time_left))
		else if shiny_goomy.effect == "clickmult"
			$("#click_frenzy_time_left").html(reprsecs(shiny_goomy.time_left))

	$("#level_progress").attr("value", goomy.exp - goomy.lv_total_exp)


update_all_numbers = ->
	# updates numbers other than just Goomy count and related stats.
	update_numbers()

	gps_str = reprnum(Math.round(basedata.gps * 10) / 10, "medium")
	$(".gps").html(gps_str)
	$("#stats_gps").html(gps_str)

	for generator in generators
		$("#" + generator.name + "_cost").html(reprnum(Math.floor(generator.cost), "short"))
		if generator in ngens
			if generator.count > 0
				$("#" + generator.name + "_count").html("x" + reprnum(generator.count, "short"))
			else
				$("#" + generator.name + "_count").html("")
		else
			$("#" + generator.name + "_count").html(reprnum(generator.count, "short"))
		$("##{generator.name}_gps").html(reprnum(Math.round(generator.gps * 100) / 100, "medium"))
		$("##{generator.name}_owned").html(reprnum(generator.count, "short"))
		$("##{generator.name}_tooltip_cost").html(reprnum(Math.floor(generator.cost), "long"))
		$("##{generator.name}_level").html(reprnum(generator.level, "short"))
		$("##{generator.name}_levelup_cost").html(reprnum(generator.lvup_cost, "short"))

	# special abbreviation code for cursors and monkeys
	if ("" + gens["cursor"].count).length >= langs[lang].cursor_abbrev_length + 2
		$("#cursor_counter").html("")
	else if ("" + gens["cursor"].count).length >= langs[lang].cursor_abbrev_length
		$("#cursor_counter").html(langs[lang].cursor_counter_short)
	else
		$("#cursor_counter").html(langs[lang].cursor_counter)

	if ("" + gens["monkey"].count).length >= langs[lang].monkey_abbrev_length + 2
		$("#monkey_counter").html("")
	else if ("" + gens["monkey"].count).length >= langs[lang].monkey_abbrev_length
		$("#monkey_counter").html(langs[lang].monkey_counter_short)
	else
		$("#monkey_counter").html(langs[lang].monkey_counter)

	for item in itemlist
		if item.locked && item.unlock_condition()
			item.locked = false
			# create the item in HTML.
			$("#items").append("
				<div class='item' id='#{item.name}'>
					#{item.display_name || item.name}
				</div>
			")

			# create the tooltip
			$("#tooltips").append("<div class='item-tooltip' id='#{item.name}_tooltip'></div>")
			$("##{item.name}_tooltip").append(
				"<p id='#{item.name}_description'>" + (langs[lang]["#{item.name}_description"] || item.description) + "</p>" + "
				<br />
				Cost: <span class='tooltip-gps' id='#{item.name}_tooltip_cost'></span> Bloons
				<hr />" +
				"<span id='#{item.name}_flavourtext'>" + (langs[lang]["#{item.name}_caption"] || item.caption) + "</span>"
			)
			$("##{item.name}_tooltip_cost").html(reprnum(Math.floor(item.cost), "long"))
			$("##{item.name}").qtip({
				content: {
					title: item.display_name || langs[lang]["#{item.name}_name"] || item.name,
					text: $($("##{item.name}_tooltip")[0])
				},
				style: {
					classes: "qtip-dark",
					width: 300
				},
				position: {
					my: if $(window).width() > 1024 then "right center" else "bottom left",
					at: if $(window).width() > 1024 then "left center" else "top left",
					viewport: $(window)
				},
				show: { delay: 0 },
				hide: { delay: 100 },
			})
			$("##{item.name}").click ((name) -> ( ->
				if items[name].buy()
					$("##{name}").hide()
			))(item.name)

	if goomy.level == goomy.level_cap
		$("#stats_next_level_row").hide()
	else
		$("#stats_next_level_row").show()
	$(".level").html(reprnum(goomy.level, "short"))
	$("#level_progress").attr("max", goomy.next_lv_exp)

	$("#stats_next_level").html(reprnum(goomy.level + 1, "short"))


update_language = ->

	regenerate_tooltips()
	update_all_numbers()


regenerate_tooltips = ->

	for generator in generators
		$("##{generator.name}").unbind()
		if $(window).width() >= 1024
			$("##{generator.name}").click(((name) -> (() -> gens[name].buy(1)))(generator.name))
	# if on a mobile platform, clicking to show tooltips shouldn't autobuy.

	$("#tooltips").empty()
	$(".qtip").empty()
	for generator in generators

		# tooltips are annoying because of this. >_>

		$("##{generator.name}_description").html((langs[lang]["#{generator.name}_description"] || generator.description))
		$("#tooltips").append("<div class='generator-tooltip' id='#{generator.name}_tooltip'></div>")
		$("##{generator.name}_tooltip").append("<span id='#{generator.name}_description'>" + (langs[lang]["#{generator.name}_description"] || generator.description) + "</span>" + "
			<hr />
			<span class='lang_tooltip_gps_pre'>Each one produces </span>
			<span class='tooltip-gps' id='#{generator.name}_gps'></span>
			<span class='lang_tooltip_gps_post'> Bloons per second</span>
			<br />
			<span class='lang_tooltip_owned_pre'>You own </span>
			<span class='tooltip-gps' id='#{generator.name}_owned'></span>
			<span class='lang_tooltip_owned_post'></span>
			<br />
			<span class='lang_tooltip_cost_pre'>To buy one costs </span>
			<span class='tooltip-gps' id='#{generator.name}_tooltip_cost'></span>
			<span class='lang_tooltip_cost_post'> Bloons</span>
			<br />
			<button class='tooltip-buy-button lang_tooltip_buy1' id='#{generator.name}_buy1'>Buy 1</button>
			<button class='tooltip-buy-button lang_tooltip_buy10' id='#{generator.name}_buy10'>Buy 10</button>
			<button class='tooltip-buy-button lang_tooltip_buy100' id='#{generator.name}_buy100'>Buy 100</button>
			<button class='tooltip-buy-button lang_tooltip_sell1' id='#{generator.name}_sell1'>Sell 1</button>
			<hr />
			<span class='lang_tooltip_level_pre'>Level </span>
			<span class='tooltip-gps' id='#{generator.name}_level'></span>
			<span class='lang_tooltip_level_post'></span>
			<button id='#{generator.name}_levelup' class='tooltip-buy-button'>Level up for <span id='#{generator.name}_levelup_cost'></span></button>
		")

		$("##{generator.name}").qtip({
			content: {
				title: langs[lang]["#{generator.name}_name"] || generator.display_name || generator.name,
				text: $($("##{generator.name}_tooltip")[0])
			},
			style: {
				classes: "qtip-dark",
				width: 300
			},
			position: {
				my: if $(window).width() > 1024 then "right center" else "bottom left",
				at: if $(window).width() > 1024 then "left center" else "top left",
				viewport: $(window)
			},
			show: { delay: 0 },
			hide: { fixed: true, delay: 100 },
		})

		$("##{generator.name}_buy1").click(((name) -> (() -> gens[name].buy(1)))(generator.name))
		$("##{generator.name}_buy10").click(((name) -> (() -> gens[name].buy(10)))(generator.name))
		$("##{generator.name}_buy100").click(((name) -> (() -> gens[name].buy(100)))(generator.name))
		$("##{generator.name}_sell1").click(((name) -> (() -> gens[name].sell(1)))(generator.name))
		$("##{generator.name}_levelup").click(((name) -> (() -> gens[name].levelup()))(generator.name))

	$(".lang_tooltip_gps_pre").html(langs[lang]["tooltip_gps_pre"])
	$(".lang_tooltip_gps_post").html(langs[lang]["tooltip_gps_post"])
	$(".lang_tooltip_owned_pre").html(langs[lang]["tooltip_owned_pre"])
	$(".lang_tooltip_owned_post").html(langs[lang]["tooltip_owned_post"])
	$(".lang_tooltip_cost_pre").html(langs[lang]["tooltip_cost_pre"])
	$(".lang_tooltip_cost_post").html(langs[lang]["tooltip_cost_post"])

	$(".lang_tooltip_buy1").html(langs[lang]["tooltip_buy1"])
	$(".lang_tooltip_buy10").html(langs[lang]["tooltip_buy10"])
	$(".lang_tooltip_buy100").html(langs[lang]["tooltip_buy100"])
	$(".lang_tooltip_sell1").html(langs[lang]["tooltip_sell1"])


$(window).resize( ->
	regenerate_tooltips()
	update_all_numbers()
)

# main game loop

last_update_time = new Date()

updateF = (ms) ->
	basedata.update(ms)
	shiny_goomy.update(ms)
	update_numbers(ms)
	animate_plus_markers(ms)

update = ->
	new_update_time = new Date()
	ms = new_update_time.getTime() - last_update_time.getTime()
	last_update_time.setTime(new_update_time.getTime())
	updateF(ms)
