start_if_loaded = ->
	init_input()
	change_language(lang)
	load_save_from_local_storage()
	battle.render()
	setInterval(update, 20)
	setInterval(save_to_local_storage, 10000)

startup = ->
	start_if_loaded()

$(document).ready(startup)
