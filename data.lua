require("prototypes.entities")
require("prototypes.items")
require("prototypes.recipes")
require("prototypes.signals")
require("prototypes.technology")
require("prototypes.sprites_font")
require("prototypes.lamps")
require("prototypes.fx")

if settings.startup["disable-vanilla-reactor"].value then
	--if data.raw.technology["nuclear-power"].effects[1].recipe == "nuclear-reactor" then
	--	data.raw.technology["nuclear-power"].effects[1]=nil
	--end
	data.raw.recipe["nuclear-reactor"].hidden=true
	data.raw.reactor["nuclear-reactor"].minable = {mining_time = 1.5, result = "realistic-reactor"}
	table.insert(data.raw.technology["nuclear-power"].prerequisites, "effectivity-module-2")
end

data.raw["heat-pipe"]["heat-pipe"].heat_buffer.specific_heat = "1MJ"
data.raw["boiler"]["heat-exchanger"].energy_source.specific_heat = "1MJ"