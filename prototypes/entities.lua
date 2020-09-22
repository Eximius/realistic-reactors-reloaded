local debug_core = false
REACTOR_SHIFT = {0.03, -0.38375}
REACTOR_GLOW = {intensity = 0.6, size = 9.9, shift = REACTOR_SHIFT, color = {r = 0.07, g = 0.63, b = 0.55}}
BREEDER_GLOW = {intensity = 0.4, size = 9.9, shift = REACTOR_SHIFT, color = {r = 0.8, g = 0.4, b = 0.15}}
RUIN_GLOW = {intensity = 0.22, size = 6.5, shift = {0.0, 0.0}, color = {r = 0.35, g = 0.8, b = 1.0}}
-- entity parts
resistances_immune=		
		{
		{
			type = "physical",
			percent = 100
		},
		{
			type = "impact",
			percent = 100
		},
		{
			type = "fire",
			percent = 100
		},
		{
			type = "acid",
			percent = 100
		},
		{
			type = "poison",
			percent = 100
		},
		{
			type = "explosion",
			percent = 100
		},
		{
			type = "laser",
			percent = 99
		},
		}
		
empty_sprite =
{
  filename = "__core__/graphics/empty.png",
  priority = "extra-high",
  frame_count = 1,
  width = 1,
  height = 1
}

interface_led =
{
  filename = "__base__/graphics/entity/combinator/activity-leds/decider-combinator-LED-S.png",
  width = 8,
  height = 8,
  frame_count = 1,
  --shift = {-0.28125, -0.34375}
  shift = {-0.15, -0.24},
  scale = 0.3
}
--{
--      shadow =
--      {
--        red = util.by_pixel(25, 20),
--        green = util.by_pixel(9, 20)
--      },
--      wire =
--      {
--        red = util.by_pixel(9, 7.5),
--        green = util.by_pixel(-6.5, 7.5) unten
--      }
--    },
local red_point = {x=6.9,y=10.8}
local green_point = {x=-6.1,y=10.8}

interface_connection =
{
  shadow =
  {
    red =   util.by_pixel(red_point.x+16, red_point.y+12.5),--{0.796875, 0.5},
    green = util.by_pixel(green_point.x+16, green_point.y+12.5)--{0.203125, 0.5},
  },
  wire =
  {
    red =   util.by_pixel(red_point.x, red_point.y),--{0.296875, 0.0625},
    green = util.by_pixel(green_point.x, green_point.y)--{-0.296875, 0.0625},
  }
}

-- default reactor (running reactor)
reactor_template =
{
    type = "reactor",
    name = "realistic-reactor",
	icon = "__RealisticReactors__/graphics/icons/nuclear-reactor.png",
    icon_size = 32,
	order = "f[nuclear-energy]-a[reactor]",
    flags = {"placeable-neutral", "player-creation", "placeable-off-grid", "not-on-map","not-deconstructable","not-blueprintable"},
	--placeable_by = { item="iron-plate", count = 1},
    --minable = {mining_time = 1.5, result = "realistic-reactor"},
    max_health = 500,
    corpse = "big-remnants",
    consumption = "40MW",
    neighbour_bonus = 1,
	selectable_in_game = false,
	energy_source =
    {
      type = "burner",
      fuel_categories = {"nuclear"},
      effectivity = 1,
      fuel_inventory_size = 1,
      burnt_inventory_size = 1,
	  light_flicker = {
	  minimum_intensity=0,
	  maximum_intensity = 0,
	  minimum_light_size=0,
	  light_intensity_to_size_coefficient=0,
	  }
    },
	light = {intensity = 0, size = 0, shift = REACTOR_SHIFT, color = {r = 0.07, g = 0.63, b = 0.55}},
    --burner = --replaced by energy_source
    --{
    --  fuel_category = "nuclear",
    --  effectivity = 1,
    --  fuel_inventory_size = 1,
    --  burnt_inventory_size = 1
    --},
    --collision_box = {{-2.2, -2.2}, {2.2, 2.2}},
    --selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
	--collision_box = {{-1.4, -1.4}, {1.4, 0.7}},
    --selection_box = {{-1.5, -3}, {1.5, 0.5}},
	collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
	--selection_box = {{-1.4, -3}, {1.4, 1.4}},
	working_sound =
	{
		sound = { filename = "__RealisticReactors__/sound/reactor-active.ogg", volume = 0.6 },
		idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
		apparent_volume = 1.5
	},
    --picture =
    --{
    --  layers =
    --  {
    --    --{
	--	--  filename = "__RealisticReactors__/graphics/entity/nuclear-reactor.png",
    --    --  width = 140,
    --    --  height = 160,
    --    --  shift = {0.6875, -0.59375}
    --    --}
    --  }
    --},
    working_light_picture =
    {
    --  filename = "__RealisticReactors__/graphics/entity/workinglight-yellow.png",
    --  width = 140,
    --  height = 160,
    --  shift = {0.6875, -0.59375},
	--  priority = "extra-high",
    --  blend_mode = "additive"
	  filename = "__RealisticReactors__/graphics/transparent32.png",
      width = 32,
      height = 32,
    },
    --light = {intensity = 2, size = 9.9, shift = {0.0, 0.0}, color = {r = 1.0, g = 0.5, b = 0.0}},
    heat_buffer =
    {
      max_temperature = 1005,
      specific_heat = "5MJ",
      max_transfer = "10GW",
	  minimum_glow_temperature = 350,
      glow_alpha_modifier = 0.6,
      connections =
      {
        {
          position = {1, -1.5},
          direction = defines.direction.north
        },
        {
          position = {0, -1.5},
          direction = defines.direction.north
        },
        {
          position = {-1, -1.5},
          direction = defines.direction.north
        },
        {
          position = {1.3, -1},
          direction = defines.direction.east
        },
        {
          position = {1.3, 0},
          direction = defines.direction.east
        },
        {
          position = {-1.3, 0},
          direction = defines.direction.west
        },
        {
          position = {-1.3, -1},
          direction = defines.direction.west
        }
      }
    },
    connection_patches_connected =
    {
      sheet =
      {
        filename = "__RealisticReactors__/graphics/entity/reactor-connect-patches-empty.png",
        width = 32,
        height = 32,
        variation_count = 12
      }
    },
    connection_patches_disconnected =
    {
      sheet =
      {
        filename = "__RealisticReactors__/graphics/entity/reactor-connect-patches-empty.png",
        width = 32,
        height = 32,
        variation_count = 12,
        y = 32
      }
    },
	--pipe_covers = pipecoverspictures(),
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    meltdown_action = nil
   
  }
  
if data.raw["fuel-category"]["MOX"] then
	table.insert(reactor_template.energy_source.fuel_categories,"MOX")
end

if data.raw["fuel-category"]["PE-MOX"] then
	table.insert(reactor_template.energy_source.fuel_categories,"PE-MOX")
end





-- display dummy for normal reactor
reactor_normal=table.deepcopy(reactor_template)
reactor_normal.name = "realistic-reactor-normal"
reactor_normal.flags = {"placeable-neutral", "player-creation"}
reactor_normal.placeable_by = { item="realistic-reactor", count = 1}
reactor_normal.minable = {mining_time = 1.5, result = "realistic-reactor"}
reactor_normal.consumption = 0.00001 .."W"
reactor_normal.collision_box = {{-1.3, -1.3}, {1.3, 1.4}}
--reactor_normal.selection_box = {{-1.4, -1.9}, {1.4, 0.5}}
reactor_normal.selection_box = {{-1.4, -1.8}, {1.4, 1.35}} --eccs would not be selectable, but interface would.
reactor_normal.selectable_in_game = true
reactor_normal.heat_buffer.connections={}
reactor_normal.light = REACTOR_GLOW
reactor_normal.energy_source.light_flicker ={
											minimum_intensity=0.4,
											maximum_intensity = 0.7,
											minimum_light_size=0.6,
											derivation_change_frequency=0.05,
											derivation_change_deviation=0.001,
											border_fix_speed=0.008,
											light_intensity_to_size_coefficient=0.05,
											color = {r = 0.07, g = 0.63, b = 0.55}
											}
reactor_normal.working_light_picture =
    {
      filename = "__RealisticReactors__/graphics/entity/reactor-lights-color.png",
      width = 288,
      height = 348,
      shift = REACTOR_SHIFT,
	  scale=0.3542,
      blend_mode = "additive",
      --hr_version =
      --{
      --  filename = "__base__/graphics/entity/nuclear-reactor/hr-reactor-lights-color.png",
      --  width = 320,
      --  height = 320,
      --  scale = 0.5,
      --  shift = REACTOR_SHIFT
      --  blend_mode = "additive"
      --}
    }
	
reactor_normal.picture =
    {
      layers =
      {
        {

		  filename = "__RealisticReactors__/graphics/entity/reactor_hr.png",
          width = 288,
          height = 348,
		  scale=0.3542,
          shift = REACTOR_SHIFT
        },
		{
		filename = "__RealisticReactors__/graphics/entity/reactor-shadow.png",
		width = 174,
		height = 160,
		shift = {1.2185, -0.59375},
		draw_as_shadow = true,
		}
      }
    }
reactor_normal.heat_buffer.heat_picture =
      {
        filename = "__RealisticReactors__/graphics/entity/reactor-heated.png",
        width = 288,
        height = 348,
        shift = REACTOR_SHIFT,
		scale=0.3542,
        --hr_version =
        --{
        --  filename = "__base__/graphics/entity/nuclear-reactor/hr-reactor-heated.png",
        --  width = 216,
        --  height = 256,
        --  scale = 0.5,
        --  shift = REACTOR_SHIFT,
        --}
      }
reactor_normal.heat_buffer.heat_glow =
      {
        filename = "__RealisticReactors__/graphics/entity/reactor-heat-glow.png",
        priority = "extra-high",
        width = 288,
        height = 348,
        tint = heat_glow_tint,
        shift = REACTOR_SHIFT,
		scale=0.3542,
      }

 -- display dummy for breeder reactor
reactor_breeder = table.deepcopy(reactor_normal)
reactor_breeder.name = "realistic-reactor-breeder"
reactor_breeder.icon = "__RealisticReactors__/graphics/icons/breeder-reactor.png"
reactor_breeder.minable = {mining_time = 1.5, result = "breeder-reactor"}
reactor_breeder.placeable_by = { item="breeder-reactor", count = 1}
reactor_breeder.picture.layers[1].filename = "__RealisticReactors__/graphics/entity/breeder_hr.png"
reactor_breeder.heat_buffer.heat_glow.filename = "__RealisticReactors__/graphics/entity/breeder-heat-glow.png"
reactor_breeder.heat_buffer.heat_picture.filename = "__RealisticReactors__/graphics/entity/breeder-heated.png"
reactor_breeder.working_light_picture.filename = "__RealisticReactors__/graphics/entity/breeder-lights-color.png"
reactor_breeder.light = BREEDER_GLOW
reactor_breeder.energy_source.light_flicker ={
											minimum_intensity=0.4,
											maximum_intensity = 0.7,
											minimum_light_size=0.6,
											derivation_change_frequency=0.05,
											derivation_change_deviation=0.001,
											border_fix_speed=0.008,
											light_intensity_to_size_coefficient=0.05,
											color = {r = 0.59, g = 0.35, b = 0.04}
											}
--reactor_breeder.picture.layers[1].width = 174
--reactor_breeder.picture.layers[1].height = 160
--reactor_breeder.picture.layers[1].scale = 1


      
reactor_default =  table.deepcopy(reactor_template)
reactor_default.collision_mask = {"item-layer"}
reactor_default.resistances = resistances_immune
table.insert(reactor_template.flags,  "no-automated-item-insertion")
table.insert(reactor_template.flags,  "no-automated-item-removal")

reactor_template.lower_layer_picture = table.deepcopy(reactor_normal.picture.layers[1])
reactor_template.lower_layer_picture.filename = "__RealisticReactors__/graphics/entity/reactor-pipes.png"

reactor_template.heat_lower_layer_picture = table.deepcopy(reactor_normal.picture.layers[1])
reactor_template.heat_lower_layer_picture.filename = "__RealisticReactors__/graphics/entity/reactor-pipes-heated.png"
if mods["heat_glow"] then
	reactor_template.heat_lower_layer_picture.filename = "__RealisticReactors__/graphics/entity/reactor-pipes-heated-mod.png"
	reactor_normal.heat_buffer.heat_picture.filename = "__RealisticReactors__/graphics/entity/reactor-heated-mod.png"
	reactor_breeder.heat_buffer.heat_picture.filename = "__RealisticReactors__/graphics/entity/breeder-heated-mod.png"
end
-- Nuclear reactor x, running phase
for i=1, 250 do

	local temp_reactor = table.deepcopy(reactor_template)
	temp_reactor.name = "realistic-reactor-"..i
	temp_reactor.resistances = resistances_immune
	temp_reactor.collision_mask = {"item-layer"}
	temp_reactor.consumption = i.."MW"
	
	if debug_core then
		temp_reactor.selection_box = {{-1.4, -2.5}, {1.4, 1.35}}
		temp_reactor.selectable_in_game = true
		temp_reactor.selectable_in_game = true
	end
		
	--temp_reactor.light = {intensity = 0.3, size = 9.9, shift = {0.0, 0.0}, color = {r = 0.0, g = 0.5, b = 0.0}}
	--temp_reactor.light = {intensity = 0.7, size = 9.9, shift = {0.0, 0.0}, color = {r = 0.35, g = 0.8, b = 1.0}}
	
	data:extend({temp_reactor})

end
 
-- Circuit interface entity for nuclear reactor
reactor_interface =
{
  type = "constant-combinator",
  name = "realistic-reactor-interface",
  collision_mask = {"layer-11"},
  icon = reactor_template.icon,
  icon_size = reactor_template.icon_size,
  order = "f[nuclear-energy]-a[reactor]",
  flags = {"placeable-neutral","placeable-player", "player-creation"},
  resistances = resistances_immune,
  minable = {hardness = 0.2, mining_time = 0.5, result = "constant-combinator"},
  placeable_by = {item="constant-combinator", count = 1},
  max_health = reactor_template.max_health,
  collision_box = {{-1.4, -0.25}, {1.4, 0.4}},
  selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
  item_slot_count = 14,

  sprites =
  {
    north =
    {
      filename = "__RealisticReactors__/graphics/entity/nuclear-reactor-interface.png",
      priority = "high",
      frame_count = 1,
      width = 32,
      height = 32,
	  shift = util.by_pixel(1,0)
    },
    east =
    {
      filename = "__RealisticReactors__/graphics/entity/nuclear-reactor-interface.png",
      priority = "high",
      frame_count = 1,
      width = 32,
      height = 32,
	  shift = util.by_pixel(1,0)
    },
    south =
    {
      filename = "__RealisticReactors__/graphics/entity/nuclear-reactor-interface.png",
      priority = "high",
      frame_count = 1,
      width = 32,
      height = 32,
	  shift = util.by_pixel(1,0)
    },
    west =
    {
      filename = "__RealisticReactors__/graphics/entity/nuclear-reactor-interface.png",
      priority = "high",
      frame_count = 1,
      width = 32,
      height = 32,
	  shift = util.by_pixel(1,0)
    }
  },
  activity_led_sprites =
  {
    north = interface_led,
    east = interface_led,
    south = interface_led,
    west = interface_led
  },
  activity_led_light =
  {
    intensity = 0.4,
    size = 0.3,
	color = {r = 0.02, g = 0.05, b = 0.55}
  },
  activity_led_light_offsets =
  {
    interface_led.shift,
    interface_led.shift,
    interface_led.shift,
    interface_led.shift
  },
  circuit_wire_connection_points =
  {
    interface_connection,
    interface_connection,
    interface_connection,
    interface_connection
  },
  circuit_wire_max_distance = 7.5,
  order = "z"
}

local breeder_interface = table.deepcopy(reactor_interface)
breeder_interface.name = "realistic-breeder-interface"
breeder_interface.sprites.north.filename = "__RealisticReactors__/graphics/entity/breeder-interface.png"
breeder_interface.sprites.east.filename = "__RealisticReactors__/graphics/entity/breeder-interface.png"
breeder_interface.sprites.south.filename = "__RealisticReactors__/graphics/entity/breeder-interface.png"
breeder_interface.sprites.west.filename = "__RealisticReactors__/graphics/entity/breeder-interface.png"


-- ECCS entity for nuclear reactor
reactor_eccs =
{
  type = "storage-tank",
  name = "realistic-reactor-eccs",
  collision_mask = {"item-layer"},
  icon = reactor_template.icon,
  icon_size = reactor_template.icon_size,
  order = "f[nuclear-energy]-a[reactor]",
  flags = {"player-creation", "not-deconstructable","not-blueprintable","not-rotatable"},
  resistances = resistances_immune,
  --placeable_by = {item="iron-plate", count = 1},
  max_health = reactor_template.max_health,
  collision_mask = {"ghost-layer"},
  collision_box = {{-1.3, -1.3}, {1.3, 1.3}},
  selection_box = {{-1.4,0.5},{1.4,1.7}},
  --drawing_box = {{-1.4,-1.4},{-1,-1}}, --doesnt affect alt-info-overlay
  fluid_box =
  {
    base_area = 50,
    pipe_covers = pipecoverspictures(),
    pipe_connections =
    {
      --{position = {-2, -1}},
      {position = {-2, 1}},
      --{position = {-1, -2}},
      {position = {-1, 2}},
      --{position = {1, -2}},
      {position = {1, 2}},
      --{position = {2, -1}},
      {position = {2, 1}}
    }
  },
  window_bounding_box = {{-0.1,-0.1}, {0.1,0.1}},
  pictures =
  {
    picture =
    {
      north = empty_sprite,
      east = empty_sprite,
      south = empty_sprite,
      west = empty_sprite
    },
    fluid_background = empty_sprite,
    window_background = empty_sprite,
    flow_sprite = empty_sprite,
	gas_flow = empty_sprite
  },
  flow_length_in_ticks = 360,
  --circuit_wire_connection_points = reactor_interface.circuit_wire_connection_points,
  circuit_wire_connection_points = {
{
  shadow =
  {
    red = {-0.896875, 1.5},
    green = {-1.403125, 1.5},
  },
  wire =
  {
    red = {-1.296875, 1.0625},
    green = {-1.696875, 1.0625},
  }
},
{
  shadow =
  {
    red = {-0.896875, 1.5},
    green = {-1.403125, 1.5},
  },
  wire =
  {
    red = {-1.296875, 1.0625},
    green = {-1.696875, 1.0625},
  }
},
{
  shadow =
  {
    red = {-0.896875, 1.5},
    green = {-1.403125, 1.5},
  },
  wire =
  {
    red = {-1.296875, 1.0625},
    green = {-1.696875, 1.0625},
  }
},
{
  shadow =
  {
    red = {-0.896875, 1.5},
    green = {-1.403125, 1.5},
  },
  wire =
  {
    red = {-1.296875, 1.0625},
    green = {-1.696875, 1.0625},
  }
},

},
  circuit_wire_max_distance = 5,
  order = "z",
  --circuit_wire_connection_points = circuit_connector_definitions["storage-tank"].points,
  circuit_connector_sprites = circuit_connector_definitions["storage-tank"].sprites,
  --  circuit_wire_max_distance = default_circuit_wire_max_distance,
}

-- Power draining entity for normal reactor
reactor_power_normal =
  {
    type = "electric-energy-interface",
    name = "realistic-reactor-power-normal",
	icon = reactor_normal.icon,
	icon_size = reactor_normal.icon_size,
    flags = {"player-creation", "not-deconstructable","not-blueprintable"},
	order = "f[nuclear-energy]-a[reactor]",
    max_health = 150,
	resistances = resistances_immune,
	collision_mask = {"ghost-layer"},
    collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
    selection_box = {{-1.4, -1.4}, {1.4, 1.4}},
    drawing_box = {{-0.5, -2.5}, {0.5, 0.3}},
	selectable_in_game = false,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
	  input_flow_limit= "17MW",
	  buffer_capacity = "17MJ"
    },
	energy_production = "0kW",
	energy_usage = "0kW",
  }

-- Power draining entity 2 for nuclear reactor
reactor_power_breeder = table.deepcopy(reactor_power_normal)
reactor_power_breeder.name = "realistic-reactor-power-breeder"
reactor_power_breeder.icon = reactor_breeder.icon
reactor_power_breeder.icon_size = reactor_breeder.icon_size


reactor_ruin = {
    type = "simple-entity-with-owner",
    name = "reactor-ruin",
	icon = "__RealisticReactors__/graphics/icons/nuclear-reactor.png",
    icon_size = 32,
	max_health = 1000,
	order = "f[nuclear-energy]-a[reactor]",
    flags = {"player-creation", "not-deconstructable","not-blueprintable", "not-repairable"},
	--flags = {"placeable-neutral", "placeable-player", "player-creation"},
	--resistances=resistances_immune,
	placeable_by = { item="reactor-sarcophagus", count = 1},
    collision_box = {{-1.5, -1.5}, {1.5, 1.5}},	
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},	
	minable = {hardness=1, mining_time = 4, result = nil},
	fast_replaceable_group = "reactor-ruins",	
	picture =
	{ 
		filename = "__RealisticReactors__/graphics/entity/reactor_ruin.png",
		width = 174,
		height = 160,
		shift = {1.2185, -0.59375},
		frame_count=1
	},	
}
if settings.startup["meltdown-mode"].value == "meltdown with ruin + sarcophagus" then
	reactor_ruin.selection_box = {{-2.5, -2.5}, {2.5, 2.5}}
	reactor_ruin.selection_priority = 0
	reactor_ruin.minable = {hardness=999999, mining_time = 999999, result = nil}
elseif settings.startup["meltdown-mode"].value == "meltdown with ruin" then
	--reactor_ruin.minable = {hardness=1, mining_time = 4, result = nil} --already set
end

breeder_ruin = table.deepcopy(reactor_ruin)
breeder_ruin.name = "breeder-ruin"
breeder_ruin.icon = "__RealisticReactors__/graphics/icons/breeder-reactor.png"
--breeder_ruin.minable = {hardness=999999, mining_time = 999999, result = "breeder-reactor"}
--if settings.startup["meltdown-mode"].value == "meltdown with ruin" then
--	breeder_ruin.minable = {hardness=1, mining_time = 4, result = nil}
--end
breeder_ruin.pictures ={layers={
{
	filename = "__RealisticReactors__/graphics/entity/breeder_ruin.png",
	width = 174,
	height = 160,
	shift = {1.2185, -0.59375},
	frame_count=1
},
{
	filename = "__RealisticReactors__/graphics/entity/breeder_ruin.png",
	width = 174,
	height = 160,
	shift = {1.8185, -0.19375},
	frame_count=1,
	draw_as_shadow = true
},
}}

sarcophagus = table.deepcopy(reactor_ruin)
sarcophagus.name = "reactor-sarcophagus"
sarcophagus.icon = "__RealisticReactors__/graphics/icons/sarcophagus2.png"
sarcophagus.flags = {"player-creation", "not-blueprintable", "not-repairable"}
sarcophagus.minable = {mining_time = 1, result = "reactor-sarcophagus"}
sarcophagus.collision_box = {{-2.2, -2.1}, {2.2, 2.1}}
sarcophagus.selection_box = {{-2.3, -2.4}, {2.1, 2.0}}
sarcophagus.picture ={layers={
{
	filename = "__RealisticReactors__/graphics/entity/sarcophagus2.png",
	width = 1024,
	height = 768,
	shift = {-0.1, -0.4},
	frame_count=1,
	scale=0.19
},
{
	filename = "__RealisticReactors__/graphics/entity/sarcophagus2-shadow.png",
	width = 1024,
	height = 768,
	shift = {0.8, -0.07},
	frame_count=1,
	scale=0.18,
	draw_as_shadow = true
},
}}


-- Cooling tower
cooling_tower =
{
  type = "furnace",
  name = "rr-cooling-tower",
  icon = "__RealisticReactors__/graphics/icons/cooling-tower.png",
  icon_size = 32,
  flags = {"placeable-neutral", "placeable-player", "player-creation"},
  minable = {hardness = 0.2, mining_time = 0.5, result = "rr-cooling-tower"},
  max_health = 500,
  corpse = "medium-remnants",
  resistances =
  {
    {
      type = "fire",
      percent = 70
    }
  },
  collision_box = {{-1.3, -1.3}, {1.3, 1.3}},
  selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
  drawing_box = {{-1.5, -3}, {1.5, 1.5}},
  fluid_boxes =
  {
    {
      production_type = "input",
      base_area = 25,
      base_level = -1,
      pipe_covers = pipecoverspictures(),
      pipe_connections =
      {
        {position = {-2, -1},type = "input"},
        {position = {-2, 1},type = "input"},
        {position = {-1, -2},type = "input"},
        {position = {-1, 2},type = "input"}
      }
    },
    {
      production_type = "output",
      base_area = 25,
      base_level = 1,
      pipe_covers = pipecoverspictures(),
      pipe_connections =
      {
        {position = {1, -2},type = "output"},
        {position = {1, 2},type = "output"},
        {position = {2, -1},type = "output"},
        {position = {2, 1},type = "output"}
      }
    }
  },
  source_inventory_size = 0,
  result_inventory_size = 0,
  crafting_categories = {"water-cooling"},
  energy_usage = "120kW",
  crafting_speed = 1,
  energy_source =
  {
    type = "electric",
    usage_priority = "primary-input",
    emissions = 0,
  },
  animation =
  { 
	  layers=
	  {
		{
			filename = "__RealisticReactors__/graphics/entity/cooling-tower.png",
			width = 140,
			height = 160,
			frame_count = 1,
			shift = {0.6875, -0.59375},
			hr_version =
			{
				filename = "__RealisticReactors__/graphics/entity/cooling-tower-hr.png",
				width = 308,
				height = 310,
				frame_count = 1,
				shift = {0.695, -0.66},
				scale = 0.505
			}
		},
		{
			filename = "__RealisticReactors__/graphics/entity/cooling-tower-hr-shadow.png",
			width = 308,
			height = 310,
			frame_count = 1,
			shift = {0.695, -0.66},
			scale = 0.505,
			draw_as_shadow = true,
		}
	  }
  }
}

-- Steam creator for cooling tower
cooling_tower_smoke =
{
  type = "furnace",
  name = "rr-cooling-tower-steam",
  icon = cooling_tower.icon,
  icon_size = 32,
  order = "f[nuclear-energy]-a[reactor]",
  flags = {"not-blueprintable", "not-deconstructable","placeable-off-grid","hide-alt-info"},
  max_health = cooling_tower.max_health,
  collision_mask = {"ghost-layer"},
  collision_box = {{-0.5,-0.5},{0.5,0.5}},
  selection_box = {{-0.5,-0.5},{0.5,0.5}},
  fluid_boxes =
  {
    {
      production_type = "input",
      base_area = 0.1,
      pipe_connections = { }
    },
    {
      production_type = "output",
      base_area = 0.1,
      pipe_connections = { }
    }
  },
  source_inventory_size = 0,
  result_inventory_size = 0,
  crafting_categories = {"steaming"},
  energy_usage = "1W",
  crafting_speed = 1,
  energy_source =
  {
    type = "burner",
    effectivity = 1,
    fuel_inventory_size = 1,
    emissions = 0,
    light_flicker =
    {
      minimum_intensity = 0,
      maximum_intensity = 0
    },
    smoke =
    {
      {
        name = "cooling-tower-smoke-type",
		type = "trivial-smoke",
        deviation = {0.05, 0.05},
		frequency = 10,
        position = {0.15, -1.95},
        starting_vertical_speed = 0.011,
		starting_vertical_speed_deviation = 0.004,
        starting_frame_deviation = 60,
      }
    }
  },
  animation = empty_sprite
}

ruin_smoke = table.deepcopy(cooling_tower_smoke)
ruin_smoke.name = "ruin-smoke"
ruin_smoke.energy_source.smoke[1].name = "ruin-smoke-type"
ruin_smoke.energy_source.smoke[1].position = {0.0, -1.8}

local function trivial_smoke(opts)
  return
  {
    type = "trivial-smoke",
    name = opts.name,
	render_layer = "entity-info-icon-above",
    duration = opts.duration or 600,
    fade_in_duration = opts.fade_in_duration or 0,
    fade_away_duration = opts.fade_away_duration or ((opts.duration or 600) - (opts.fade_in_duration or 0)),
    spread_duration = opts.spread_duration or 600,
    start_scale = opts.start_scale or 0.20,
    end_scale = opts.end_scale or 1.0,
    color = opts.color,
    cyclic = true,
    affected_by_wind = opts.affected_by_wind or true,
    animation =
    {
      width = 152,
      height = 120,
      line_length = 5,
      frame_count = 60,
      shift = {-0.53125, -0.4375},
      priority = "high",
      animation_speed = 0.25,
      filename = "__base__/graphics/entity/smoke/smoke.png",
      flags = { "smoke" },
	  --scale = opts.scale or 1
    }
  }
end
data:extend({
  -- electricity warning
  {
    type = "simple-entity",
    name = "rr-electricity-warning",
	flags = {"placeable-off-grid"},
    picture =
    {
      filename = "__core__/graphics/icons/alerts/electricity-icon-red.png",
      priority = "high",
      width = 64,
      height = 64,
      frame_count = 1,
      animation_speed = 1,
	  scale = 0.44,
    },
	duration = 60,
	fade_in_duration = 3,
	fade_away_duration = 3,
	spread_duration = 0,
	start_scale = 1,
	end_scale = 1,
	cyclic = true,
	affected_by_wind = false,
	movement_slow_down_factor = 0.5,
	show_when_smoke_off = true,
	render_layer = "entity-info-icon-above",
    --duration = 60,
    --fade_away_duration = 1,
	--affected_by_wind = false,
	--show_when_smoke_off = true,
	--render_layer = "smoke",
	--cyclic = true,
	--spread_duration = 6,

    --fade_in_duration = opts.fade_in_duration or 0,
    --spread_duration = opts.spread_duration or 600,
    --start_scale = opts.start_scale or 0.20,
    --end_scale = opts.end_scale or 1.0,
    --color = opts.color,

  },
   
   -- smoke for cooling tower
   trivial_smoke{
	name = "cooling-tower-smoke-type", 
	flags = {"placeable-off-grid","not-on-map"},
	color = {r = 0.65, g = 0.65, b = 0.65, a = 0.3}, 
	start_scale = 0.77,
	end_scale = 1.3,
	duration = 260,
	spread_duration = 260,
	fade_away_duration = 100,
	affected_by_wind = true,
	fade_in_duration = 20,
    starting_frame_deviation = 60,
	deviation = {0.1, 0.1},
    frequency = 10,
    position = {0.0, -2.25},
    starting_vertical_speed = 0.00,
		
	},
	
	-- smoke for reactor ruin
   {
	name = "ruin-smoke-type",
	type = "trivial-smoke",
	flags = {"placeable-off-grid","not-on-map"},
	blend_mode = "additive-soft",
	--color = {r = 0.9, g = 0.9, b = 0.9, a = 0.3}, 
	start_scale = 0.4,
	end_scale = 6.0,
	duration = 1000,
	spread_duration = 1000,
	fade_away_duration = 990,
	affected_by_wind = true,
	fade_in_duration = 10,
    starting_frame_deviation = 60,
	deviation = {0.1, 0.1},
    --frequency = 10,
    position = {0.0, -2.25},
    starting_vertical_speed = 0.00,
	cyclic = true,
	animation =
    {
      width = 152,
      height = 120,
      line_length = 5,
      frame_count = 60,
      axially_symmetrical = false,
      direction_count = 1,
      shift = {-0.53125, -0.4375},
      priority = "high",
      animation_speed = 0.25,
      filename = "__RealisticReactors__/graphics/smoke.png",
      --flags = { "smoke" }
    }
	},
	
  
 })

data:extend({ 
  reactor_default,
  reactor_interface,
  breeder_interface,
  reactor_eccs,
  reactor_power_normal,
  reactor_power_breeder,
  reactor_normal,
  reactor_breeder,
  cooling_tower,
  cooling_tower_smoke,
  ruin_smoke,
  reactor_ruin,
  breeder_ruin,
  sarcophagus
})

