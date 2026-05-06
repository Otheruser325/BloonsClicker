init_input = ->

	$(".nano").nanoScroller()

	# populate the generator pane
	for generator in ngens
		$("#generators").append("<div class='generator' id='#{generator.name}'></div>")
		$("##{generator.name}").append('<div class="generator-info"></div>')
		$("##{generator.name}").css("background-image", "url('img/#{generator.image}.png')")
		$("##{generator.name} .generator-info").append("<span class='generator-count' id='#{generator.name}_count'></span><br />
			Next: <span class='generator-cost' id='#{generator.name}_cost'>#{reprnum(generator.base_cost, "short")}</span>")

	if $(window).width() >= 1024
		for generator in generators
			$("##{generator.name}").click(((name) -> (() -> gens[name].buy(1)))(generator.name))
	# if on a mobile platform, clicking on tooltips shouldn't autobuy.

	$("#goomy_container").mousedown (e) ->
		plus_marker = new PlusMarker("+#{reprnum(Math.floor(basedata.click()))}", e.clientX - 10 + Math.random() * 20, e.clientY - 10 + Math.random() * 20)

	$("#goomy_container").contextmenu( -> return false)

	$("#goomy_container").mousedown ->
		$("#great_goomy").css("width", "96%")
		$("#great_goomy").css("top", "2%")

	$("#goomy_container").mouseup ->
		$("#great_goomy").css("width", "100%")
		$("#great_goomy").css("top", "0%")

	$("#export_save_button").click ->
		a = export_save()
		$("#export_save").show()
		$("#export_save_string").val(a)
		$("#export_qr_code")[0].getContext("2d").clearRect(0, 0, 200, 200)
		$("#export_qr_code").qrcode({ text: a })

	$(".menu-tab").click ->
		target = $(this).attr("data-tab")
		$(".menu-tab").removeClass("active")
		$(this).addClass("active")
		$(".menu-panel").removeClass("active")
		$("##{target}").addClass("active")

	$("#battle_start").click -> battle.start()
	$("#battle_tap").click -> battle.tap()

	# settings tab
	$("#settings_audio").change ->
		settings.audio = $(this).is(":checked")
		save_to_local_storage()
	$("#settings_music").change ->
		settings.music = $(this).is(":checked")
		save_to_local_storage()
	$("#settings_number_format").change ->
		settings.number_format = $(this).val()
		update_all_numbers()
		battle.render()
		save_to_local_storage()
	$("#settings_reset_progress").click ->
		if window.confirm && !window.confirm("Reset all progress? This cannot be undone.")
			return false
		window.localStorage["gc2.savefile"] = ""
		window.location.reload()

	$("#about_close").click -> $("#about").hide()
	$("#export_close").click -> $("#export_save").hide()
