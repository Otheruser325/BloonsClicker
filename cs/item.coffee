items = {}
itemlist = []
item_ids = {}

class Item

	constructor: (name, id) ->

		@name = name

		@display_name = ""
		@description = ""
		@caption = ""

		@id = id

		@cost = 0
		@bought = false

		@locked = true
		@unlock_condition = ->

		@buy = ->
			if @locked or basedata.bloons < @cost
				return false
			basedata.bloons -= @cost
			@bought = true
			recalc() # everything you buy has recalculatory effects.

		items[name] = this
		item_ids[id] = this
		itemlist.push(this)
