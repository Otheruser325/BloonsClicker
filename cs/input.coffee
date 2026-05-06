generator_image_url = (image) -> asset_url(image)

init_input = ->

	$(".nano").nanoScroller()
	$(document).one("mousedown touchstart keydown", -> audio.unlock())

	# populate the generator pane
	for generator in ngens
		$("#generators").append("<div class='generator' id='#{generator.name}'></div>")
		$("##{generator.name}").append('<div class="generator-info"></div>')
		$("##{generator.name}").css("background-image", "url('#{generator_image_url(generator.image)}')")
		$("##{generator.name} .generator-info").append("<span class='generator-count' id='#{generator.name}_count'></span><br />
			Next: <span class='generator-cost' id='#{generator.name}_cost'>#{reprnum(generator.base_cost, "short")}</span>")

	if $(window).width() >= 1024
		for generator in generators
			$("##{generator.name}").click(((name) -> (() -> gens[name].buy(1)))(generator.name))
	# if on a mobile platform, clicking on tooltips shouldn't autobuy.

	$("#bloon_container").mousedown (e) ->
		audio.unlock()
		gain = basedata.click()
		play_sound("tap")
		plus_marker = new PlusMarker("+#{reprnum(Math.floor(gain))}", e.clientX - 10 + Math.random() * 20, e.clientY - 10 + Math.random() * 20)

	$("#bloon_container").contextmenu( -> return false)

	$("#bloon_container").mousedown ->
		$("#great_bloon").css("width", "96%")
		$("#great_bloon").css("top", "2%")

	$("#bloon_container").mouseup ->
		$("#great_bloon").css("width", "100%")
		$("#great_bloon").css("top", "0%")

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
		play_sound("tap") if settings.audio
		save_to_local_storage()
	$("#settings_music").change ->
		settings.music = $(this).is(":checked")
		audio.refresh_music()
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
