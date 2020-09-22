data:extend({
  {
    type = "technology",
    name = "breeder-reactors",
    icon = "__RealisticReactorsReloaded__/graphics/technology/breeder-reactors.png",
    icon_size = 128,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "breeder-reactor"
      }
    },
    prerequisites = {"nuclear-power", "productivity-module-3"},
    unit =
    {
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
		{"military-science-pack", 1},
		{"production-science-pack", 1},
		{"utility-science-pack", 1}
      },
      time = 30,
      count = 800
    },
    order = "a-h-d"
  }
})

-- insert recipes in technology
table.insert(data.raw["technology"]["nuclear-power"].effects, {type = "unlock-recipe", recipe = "realistic-reactor"})
table.insert(data.raw["technology"]["nuclear-power"].effects, {type = "unlock-recipe", recipe = "rr-cooling-tower"})
if settings.startup["meltdown-mode"].value == "meltdown with ruin + sarcophagus" then
  table.insert(data.raw["technology"]["nuclear-power"].effects, {type = "unlock-recipe", recipe = "reactor-sarcophagus"})
end

