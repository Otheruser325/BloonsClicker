# GCM = generator click multiplier, I think?

gcm1 = new Item("gcm1", 1)
gcm1.unlock_condition = -> bloon.level >= 5
gcm1.cost = 1e4

gcm2 = new Item("gcm2", 2)
gcm2.unlock_condition = -> bloon.level >= 10
gcm2.cost = 1e5

gcm3 = new Item("gcm3", 3)
gcm3.unlock_condition = -> bloon.level >= 20
gcm3.cost = 1e7

gcm4 = new Item("gcm4", 4)
gcm4.unlock_condition = -> bloon.level >= 40
gcm4.cost = 1e10

gcm5 = new Item("gcm5", 5)
gcm5.unlock_condition = -> bloon.level >= 80
gcm5.cost = 1e14

click1 = new Item("click1", 6)
click1.unlock_condition = -> bloon.level >= 100
click1.cost = 1e16

# dart monkey base upgrades
ball01 = new Item("ball01", 8)
ball01.unlock_condition = -> bloon.level >= 10 && gens["monkey"].count >= 10
ball01.cost = 1e4

ball02 = new Item("ball02", 9)
ball02.unlock_condition = -> bloon.level >= 30 && gens["monkey"].count >= 50
ball02.cost = 1e8

ball99 = new Item("ball99", 10)
ball99.unlock_condition = -> bloon.level >= 100
ball99.cost = 1e15

# 11 tiered BpS upgrades for every non-cursor monkey/tower type.
generator_upgrade_defs = [
	{tier: 1, bps: 2, cost_mult: 20, count: 10, type: "Minor", suffix: "Focused Training"}
	{tier: 2, bps: 2, cost_mult: 300, count: 25, type: "Minor", suffix: "Sharper Instincts"}
	{tier: 3, bps: 2, cost_mult: 4000, count: 50, type: "Minor", suffix: "Veteran Drills"}
	{tier: 4, bps: 2, cost_mult: 60000, count: 75, type: "Minor", suffix: "Elite Discipline"}
	{tier: 5, bps: 4, cost_mult: 900000, count: 100, type: "Major", suffix: "Mastery"}
	{tier: 6, bps: 2, cost_mult: 12500000, count: 150, type: "Minor", suffix: "Expert Coordination"}
	{tier: 7, bps: 2, cost_mult: 175000000, count: 200, type: "Minor", suffix: "Hyper Practice"}
	{tier: 8, bps: 5, cost_mult: 2500000000, count: 250, type: "Major", suffix: "Paragon Assault"}
	{tier: 9, bps: 2, cost_mult: 35000000000, count: 300, type: "Minor", suffix: "Relentless Output"}
	{tier: 10, bps: 4, cost_mult: 500000000000, count: 350, type: "Major", suffix: "Ascended Arsenal"}
	{tier: 11, bps: 2, cost_mult: 7500000000000, count: 400, type: "Minor", suffix: "Endless Barrage"}
]

for gen in generators when gen.name != "cursor"
	for def in generator_upgrade_defs
		do (gen, def) ->
			item = new Item("#{gen.name}_tier#{def.tier}", 51 + (generators.indexOf(gen) - 1) * 11 + def.tier)
			item.generator_name = gen.name
			item.bps_mult = def.bps
			item.display_name = "#{gen.display_name} #{def.suffix}"
			item.description = "Tier #{def.tier} (#{def.type}): #{gen.display_name} BpS is multiplied by <b>#{def.bps}x</b>. Requires owning #{def.count} #{gen.display_name}."
			item.caption = "#{def.type} upgrade for #{gen.display_name}."
			item.unlock_condition = -> gen.count >= def.count
			item.cost = gen.base_cost * def.cost_mult
