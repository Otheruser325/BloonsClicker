asset_url = (path, default_ext = "png") ->
	return path if /^(https?:|data:|blob:)/.test(path)
	path = "#{path}"
	path = path.replace(/^img\//, "")
	if !/\.[a-z0-9]+$/i.test(path)
		path = "#{path}.#{default_ext}"
	"img/#{path}"

bloon_asset = (name) -> asset_url("Bloons/#{name}")
monkey_asset = (name) -> asset_url("Monkeys/#{name}")
audio_asset = (name) -> "audio/#{name}"

@asset_url = asset_url
@bloon_asset = bloon_asset
@monkey_asset = monkey_asset
@audio_asset = audio_asset
