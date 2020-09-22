data:extend({
  {
    type = "item",
    name = "rr-dummy-fuel-cell",
	  flags = {"hidden","hide-from-bonus-gui","hide-from-fuel-tooltip"},
    icon = "__base__/graphics/icons/uranium-fuel-cell.png",
    icon_size = 32,
    subgroup = "intermediate-product",
    order = "r[uranium-processing]-a[uranium-fuel-cell]",
    fuel_category = "nuclear",
    burnt_result = "used-up-uranium-fuel-cell",
    fuel_value = "9223372035GJ",
    stack_size = 50
  },
  --Nuclear Reactor
  {
    type = "item",
    name = "realistic-reactor",
    icon = "__RealisticReactorsReloaded__/graphics/icons/nuclear-reactor.png",
	  icon_size = 32,
    subgroup = "energy",
    order = "f[nuclear-energy]-a[reactor]",
    place_result = "realistic-reactor-normal",
    stack_size = 10
  },
  --Breeder Reactor
    {
    type = "item",
    name = "breeder-reactor",
    icon = "__RealisticReactorsReloaded__/graphics/icons/breeder-reactor.png",
	  icon_size = 32,
    subgroup = "energy",
    order = "f[nuclear-energy]-a[reactor]z",
    place_result = "realistic-reactor-breeder",
    stack_size = 10
  },
  -- Cooling Tower
  {
    type = "item",
    name = "rr-cooling-tower",
    icon = "__RealisticReactorsReloaded__/graphics/icons/cooling-tower.png",
	  icon_size = 32,
    subgroup = "energy",
    order = "b[steam-power]-d[cooling-tower]",
    place_result = "rr-cooling-tower",
    stack_size = 10
  },
    -- sarcophagus
  {
    type = "item",
    name = "reactor-sarcophagus",
    icon = "__RealisticReactorsReloaded__/graphics/icons/sarcophagus2.png",
	  icon_size = 32,
    subgroup = "energy",
    order = "f[nuclear-energy]-a[reactor]z",
    place_result = "reactor-sarcophagus",
    stack_size = 1
  }
 })