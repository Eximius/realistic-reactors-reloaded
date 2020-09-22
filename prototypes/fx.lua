-- ENTITIES FOR CLOUDS AND FALLOUT AND ATOMIC EXPLOSION
function make_action(radius, effect_id)
return {
			type = "direct",
			action_delivery =
			{
				type = "instant",
				target_effects =
				{
					type = "nested-result",
					action =
					{
						type = "area",
						radius = radius,
						entity_flags = {"placeable-off-grid"},
						action_delivery =
						{
							type = "instant",
							target_effects =
							{
								type = "script",
								effect_id = effect_id,
								--probability = 0.5,
							}
						}
					}
				}
			}
		}
end

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

-- fallout cloud for meltdown
	data:extend({
	trivial_smoke
  {
    name = "RR-nuclear-smoke",
    spread_duration = 0,
    duration = 60,
    fade_away_duration = 40,
    start_scale = 0.5,
    end_scale = 1,
    affected_by_wind = false
  },
  trivial_smoke
  {
    name = "RR-staying-smoke",
    spread_duration = 0,
    duration = 60,
    fade_away_duration = 60,
    start_scale = 3,
    end_scale = 2.5,
    affected_by_wind = false
  },
	-- fallout cloud
	{
		type = "smoke-with-trigger",
		name = "fallout-cloud",
		flags = {"not-on-map","placeable-off-grid"},
		render_layer = "entity-info-icon-above",
		show_when_smoke_off = true,
		animation =
		{
			filename = "__RealisticReactorsReloaded__/graphics/fallout/cloud-45-frames.png",
			flags = { "compressed" },
			priority = "low",
			width = 256,
			height = 256,
			frame_count = 45,
			animation_speed = 0.2,
			line_length = 7,
			scale = 6,
		},
		slow_down_factor = 0,
		affected_by_wind = true,
		cyclic = true,
		duration = settings.startup["rr-clouds-duration"].value * 60,
		--fade_in_duration =  math.min(20,settings.startup["rr-clouds-duration"].value/3) * 60, --doesnt work
		fade_away_duration = math.min(20,settings.startup["rr-clouds-duration"].value/3) * 60,
		--spread_duration = 50,
		spread_duration = 300,
		movement_slow_down_factor = 1,
		color = { r = 1, g = 1, b = 1},
		action = make_action(20,"radiation-damage-strong"),
		action_cooldown = 30
	},
	
})

-- fallout radiation 
perma_radiation = {
		type = "smoke-with-trigger",
		name = "permanent-radiation",
		flags = {"not-on-map"},
		render_layer = "item-in-inserter-hand",
		show_when_smoke_off = true,
		random_animation_offset = true,
		animation =
		{
			filename = "__RealisticReactorsReloaded__/graphics/fallout/fallout_spritesheet.png",
			random_animation_offset = true,
			
			priority = "low",
			width = 249,
			height = 211,
			frame_count = 14,
			animation_speed = 0.15,
			line_length = 7,
			scale = 2,
			blend_mode = "additive-soft",
			apply_runtime_tint=true,
		},
		slow_down_factor = 0,
		affected_by_wind = false,
		cyclic = true,
		duration = settings.startup["rr-fallout-duration"].value * 60,
		fade_away_duration = math.min(180,settings.startup["rr-fallout-duration"].value/3) * 60,
		--fade_in_duration = math.min(5,settings.startup["rr-fallout-duration"].value/3) * 60, --doesn't work
		spread_duration = math.min(5,settings.startup["rr-fallout-duration"].value/3) * 60,
		movement_slow_down_factor = 0,
		color = { r = 1, g = 1, b = 1},
		action = make_action(7,"radiation-damage"),
		action_cooldown = 30
	}

	-- fallout appearance 
	if settings.startup["fallout-appearance"].value == "invisible" then
		perma_radiation.animation = 
		{
			filename = "__RealisticReactorsReloaded__/graphics/transparent32.png",
			random_animation_offset = true,
			flags = { "compressed" },
			priority = "low",
			width = 32,
			height = 32,
			frame_count = 1,
			animation_speed = 0.2,
			line_length = 1,
			scale = 1,
		}
		perma_radiation.action =make_action(14,"radiation-damage")
			
	elseif settings.startup["fallout-appearance"].value == "half-transparent" then
		perma_radiation.animation =	
		{
			filename = "__RealisticReactorsReloaded__/graphics/fallout/fallout_spritesheet_half.png",
			random_animation_offset = true,
			priority = "low",
			width = 249,
			height = 211,
			frame_count = 14,
			animation_speed = 0.15,
			line_length = 7,
			scale = 2,
			blend_mode = "additive-soft",
			apply_runtime_tint=true,
		}
		
elseif settings.startup["fallout-appearance"].value == "green veil" then
		perma_radiation.animation =
		{
			filename = "__RealisticReactorsReloaded__/graphics/fallout/fallout-green.png",
			random_animation_offset = true,
			flags = { "compressed" },
			priority = "low",
			width = 256,
			height = 256,
			frame_count = 1,
			animation_speed = 0.2,
			line_length = 1,
			scale = 4,
			blend_mode = "additive-soft",
			apply_runtime_tint=true,
			--premul_alpha= false,
			tint =  {r=0, g=1, b=0, a=0.01},
		}
		perma_radiation.action =make_action(15,"radiation-damage")
end
--if settings.startup["fallout-mode"].value == "radioactivity" then
--	perma_radiation.affected_by_wind = true --müll
--	perma_radiation.slow_down_factor = 0.99
--	perma_radiation.movement_slow_down_factor = 0.01
--	perma_radiation.spread_duration  = 600
--
--end

data:extend({
	perma_radiation,
	
	-- fallout-explosion (aka atomic meltdown explosion)
	{
		type = "smoke-with-trigger",
		name = "fallout-explosion",
		flags = {"not-on-map"},
		show_when_smoke_off = true,
		animation =
		{
			filename = "__base__/graphics/entity/cloud/cloud-45-frames.png",
			flags = { "compressed" },
			priority = "low",
			width = 256,
			height = 256,
			frame_count = 45,
			animation_speed = 0.1,
			line_length = 7,
			scale = 6,
		},
		slow_down_factor = 0,
		affected_by_wind = true,
		cyclic = true,
		--duration = 60 * 80,
		duration = 1,
		--fade_away_duration = 4 * 60,
		spread_duration = 50,
		color = { r = 1, g = 1, b = 1},
		action = {
			type = "direct",
			action_delivery =
			{
				type = "instant",
				source_effects =
				{
					{
						repeat_count = 250,
						type = "create-trivial-smoke",
						smoke_name = "RR-nuclear-smoke",
						offset_deviation = {{-1, -1}, {1, 1}},
						slow_down_factor = 1,
						starting_frame = 3,
						starting_frame_deviation = 5,
						starting_frame_speed = 0,
						starting_frame_speed_deviation = 5,
						speed_from_center = 0.5,
						speed_deviation = 0.2
					},
					{
						type = "create-entity",
						entity_name = "explosion"
					},
					{
						type = "damage",
						damage = {amount = 400, type = "explosion"}
					},
					{
						type = "create-entity",
						entity_name = "RR-uranium-explosion-LUQ",
						trigger_created_entity = "true"               
					},
					{
						type = "create-entity",
						entity_name = "RR-uranium-explosion-RUQ"
					},
					{
						type = "create-entity",
						entity_name = "RR-uranium-explosion-LLQ"
					},
					{
						type = "create-entity",
						entity_name = "RR-uranium-explosion-RLQ"
					},
				{
						type = "create-entity",
						entity_name = "RR-nuclear-scorchmark",
						check_buildability = true
					},
					{
						type = "nested-result",
						action =
						{
							type = "area",
							target_entities = false,
							repeat_count = 1000,
							radius = 20,
							action_delivery =
							{
								type = "projectile",
								projectile = "RR-atomic-bomb-wave",
								starting_speed = 0.5
							}
						}
					},
					{
						type = "nested-result",
						action =
						{
							type = "area",
							target_entities = false,
							repeat_count = 1000,
							radius = 22,
							action_delivery =
							{
								type = "projectile",
								projectile = "RR-atomic-bomb-wave-smoke",
								starting_speed = 0.48
							}
						}
					}
				}
			}
		},
		action_cooldown = 30
	},
	  {
		type = "sound",
		name = "RR-geiger-0",
		filename = "__RealisticReactorsReloaded__/sound/geiger0.ogg",
	},
	{
		type = "sound",
		name = "RR-geiger-1",
		filename = "__RealisticReactorsReloaded__/sound/geiger1.ogg",
	},
	-- RR-geiger-0
	--{
	--		type = "explosion",
	--		name = "RR-geiger-0",
	--		flags = {"not-on-map"},
	--		animations =
	--		{
	--			{
	--				filename = "__RealisticReactorsReloaded__/graphics/transparent32.png",
	--				priority = "low",
	--				width = 32,
	--				height = 32,
	--				frame_count = 1,
	--				line_length = 1,
	--				animation_speed = 1
	--			},
	--		},
	--		light = {intensity = 0, size = 0},
	--		sound =
	--		{
	--			{
	--				filename = "__RealisticReactorsReloaded__/sound/geiger0.ogg",
	--				volume = 0.5,
	--				audible_distance_modifier = 0.3
	--			},       
	--		},
	--	},
	--	
	--	-- RR-geiger-1
	--	{
	--		type = "explosion",
	--		name = "RR-geiger-1",
	--		flags = {"not-on-map"},
	--		animations =
	--		{
	--			{
	--				filename = "__RealisticReactorsReloaded__/graphics/transparent32.png",
	--				priority = "low",
	--				width = 32,
	--				height = 32,
	--				frame_count = 1,
	--				line_length = 1,
	--				animation_speed = 1
	--			},
	--		},
	--		light = {intensity = 0, size = 0},
	--		sound =
	--		{
	--			{
	--				filename = "__RealisticReactorsReloaded__/sound/geiger1.ogg",
	--				volume = 0.5,
	--				audible_distance_modifier = 0.3
	--			},       
	--		},
	--	},
		
	-- RR-nuclear-detonation-sound
	{
			type = "sound",
			name = "RR-nuclear-detonation-sound",
			--flags = {"not-on-map"},
			--animations =
			--{
			--	{
			--		filename = "__RealisticReactorsReloaded__/graphics/transparent32.png",
			--		priority = "low",
			--		width = 32,
			--		height = 32,
			--		frame_count = 1,
			--		line_length = 1,
			--		animation_speed = 1
			--	},
			--},
			--light = {intensity = 0, size = 0},
			--sound = 
			--{
				filename = "__RealisticReactorsReloaded__/sound/nuclear_detonation_in_vincinity_2.ogg",
				volume = 1,
				audible_distance_modifier = 10000     
			--},
		},
	
	-- RR-explosion"
	--{
	--	type = "explosion",
	--	name = "RR-explosion",
	--	flags = {"not-on-map"},
	--	animations =
	--	{
	--		{
	--			width = 152,
	--			height = 120,
	--			line_length = 5,
	--			frame_count = 60,
	--			shift = {-0.53125, -0.4375},
	--			priority = "high",
	--			animation_speed = 0.25,
	--			filename = "__base__/graphics/entity/smoke/smoke.png",
	--			flags = { "smoke" }
	--		},
	--	--  {
	--	--	filename = "__RealisticReactorsReloaded__/graphics/transparent32.png",
	--	--	priority = "high",
	--	--	width = 32,
	--	--	height = 32,
	--	--	frame_count = 1,
	--	--	animation_speed = 0.5
	--	--  },
	--	  --{
	--	  --  filename = "__base__/graphics/entity/explosion/explosion-2.png",
	--	  --  priority = "high",
	--	  --  width = 64,
	--	  --  height = 57,
	--	  --  frame_count = 16,
	--	  --  animation_speed = 0.5
	--	  --},
	--	  --{
	--	  --  filename = "__base__/graphics/entity/explosion/explosion-3.png",
	--	  --  priority = "high",
	--	  --  width = 64,
	--	  --  height = 49,
	--	  --  frame_count = 16,
	--	  --  animation_speed = 0.5
	--	  --},
	--	  --{
	--	  --  filename = "__base__/graphics/entity/explosion/explosion-4.png",
	--	  --  priority = "high",
	--	  --  width = 64,
	--	  --  height = 51,
	--	  --  frame_count = 16,
	--	  --  animation_speed = 0.5
	--	  --}
	--	},
	--	light = {intensity = 1, size = 20, color = {r=1.0, g=1.0, b=1.0}},
	--	smoke = "smoke-fast",
	--	smoke_count = 2,
	--	smoke_slow_down_factor = 1,
	--	sound =
	--	{
	--	  aggregation =
	--	  {
	--		max_count = 1,
	--		remove = true
	--	  },
	--	  variations =
	--	  {
	--		{
	--		  filename = "__base__/sound/fight/small-explosion-1.ogg",
	--		  volume = 0.75
	--		},
	--		{
	--		  filename = "__base__/sound/fight/small-explosion-2.ogg",
	--		  volume = 0.75
	--		}
	--	  }
	--	}
	--  },
	  
	  -- RR-atomic-bomb-wave
	  {
		type = "projectile",
		name = "RR-atomic-bomb-wave-smoke",
		flags = {"not-on-map"},
		acceleration = 0,
		action =
		{
		  {
			type = "direct",
			action_delivery =
			{
			  type = "instant",
			  target_effects =
			  {
				{
				  type = "create-trivial-smoke",
				  smoke_name = "RR-staying-smoke"
				},
			  }
			}
		  },
		--  {
		--	type = "area",
		--	radius = 3,
		--	action_delivery =
		--	{
		--	  type = "instant",
		--	  target_effects =
		--	  {
		--		type = "damage",
		--		damage = {amount = 400, type = "explosion"}
		--	  }
		--	}
		--  }
		},
		animation =
		{
		  filename = "__core__/graphics/empty.png",
		  frame_count = 1,
		  width = 1,
		  height = 1,
		  priority = "high"
		},
		shadow =
		{
		  filename = "__core__/graphics/empty.png",
		  frame_count = 1,
		  width = 1,
		  height = 1,
		  priority = "high"
		}
	  },
	  {
		type = "projectile",
		name = "RR-atomic-bomb-wave",
		flags = {"not-on-map"},
		acceleration = 0,
		action =
		{
		--  {
		--	type = "direct",
		--	action_delivery =
		--	{
		--	  type = "instant",
		--	  target_effects =
		--	  {
		--		
		--		{
		--		  type = "create-trivial-smoke",
		--		  smoke_name = "RR-staying-smoke"
		--		}
		--	  }
		--	}
		--  },
		  {
			type = "area",
			radius = 3,
			action_delivery =
			{
			  type = "instant",
			  target_effects =
			  {
				{
					type = "damage",
					damage = {amount = 400, type = "explosion"}
				}
			  },
			}
		  },
		  {
			type = "direct",
			action_delivery =
			{
				type = "instant",
				target_effects =
				{
					{
					type = "destroy-cliffs",
					radius = 1.5,
					--explosion = "explosion"
					}
				}
			}
      }
		},
		animation =
		{
		  filename = "__core__/graphics/empty.png",
		  frame_count = 1,
		  width = 1,
		  height = 1,
		  priority = "high"
		},
		shadow =
		{
		  filename = "__core__/graphics/empty.png",
		  frame_count = 1,
		  width = 1,
		  height = 1,
		  priority = "high"
		}
	  },
	  -- RR-uranium-explosion-LUQ
	  {
			type = "explosion",
			name = "RR-uranium-explosion-LUQ",
			flags = {"not-on-map"},
			render_layer = "air-object",
			animations =
			{
				{
					filename = "__RealisticReactorsReloaded__/graphics/explosion/LUQ.png",
					priority = "extra-high",
					width = 256,
					height = 256,
					frame_count = 64,
					line_length = 8,
					scale = 4,
					shift = {-16, -16},
					animation_speed = 0.25
				},
			},
			light = {intensity = 10, size = 120},
			smoke = "smoke-fast",
			smoke_count = 2,
			smoke_slow_down_factor = 1,
			sound =
			{

				filename = "__RealisticReactorsReloaded__/sound/nuclear_detonation_close_proximity.ogg",
				volume = 1.2,
				audible_distance_modifier = 10
				
			},
		},
		
		-- RR-uranium-explosion-RUQ
		{
			type = "explosion",
			name = "RR-uranium-explosion-RUQ",
			flags = {"not-on-map"},
			render_layer = "air-object",
			animations =
			{
				{
					filename = "__RealisticReactorsReloaded__/graphics/explosion/RUQ.png",
					priority = "extra-high",
					width = 256,
					height = 256,
					frame_count = 64,
					line_length = 8,
					scale = 4,
					shift = {16, -16},
					animation_speed = 0.25
				},
			},
			light = {intensity = 10, size = 120},
			smoke = "smoke-fast",
			smoke_count = 2,
			smoke_slow_down_factor = 1,
			sound = nil
			--{
			--	filename = "__RealisticReactorsReloaded__/sound/nuclear_detonation_in_vincinity_2.ogg",
			--	volume = 1,
			--	audible_distance_modifier = -100
			--},
		},
		
		-- RR-uranium-explosion-LLQ
		{
			type = "explosion",
			name = "RR-uranium-explosion-LLQ",
			flags = {"not-on-map"},
			render_layer = "air-object",
			animations =
			{
				{
					filename = "__RealisticReactorsReloaded__/graphics/explosion/LLQ.png",
					priority = "extra-high",
					width = 256,
					height = 256,
					frame_count = 64,
					line_length = 8,
					scale = 4,
					shift = {-16, 16},
					animation_speed = 0.25
				},
			},
			light = {intensity = 10, size = 120},
			smoke = "smoke-fast",
			smoke_count = 2,
			smoke_slow_down_factor = 1,
			sound =nil,
			--{
			--	aggregation =
			--	{
			--		max_count = 1,
			--		remove = false
			--	},
			--	variations =
			--	{	
			--		{
			--			filename = "__RealisticReactorsReloaded__/sound/nuclear_detonation_close_proximity.ogg",
			--			volume = 0.5,
			--		},
			--	}
			--},
		},
		
		-- RR-uranium-explosion-RLQ
		{
			type = "explosion",
			name = "RR-uranium-explosion-RLQ",
			flags = {"not-on-map"},
			render_layer = "air-object",
			animations =
			{
				{
					filename = "__RealisticReactorsReloaded__/graphics/explosion/RLQ.png",
					priority = "extra-high",
					width = 256,
					height = 256,
					frame_count = 64,
					line_length = 8,
					scale = 4,
					shift = {16, 16},
					animation_speed = 0.25
				},
			},
			light = {intensity = 10, size = 120},
			smoke = "smoke-fast",
			smoke_count = 2,
			smoke_slow_down_factor = 1,
			sound = nil,
			--{
			--	aggregation =
			--	{
			--		max_count = 1,
			--		remove = false
			--	},
			--	variations =
			--	{
			--		{
			--			filename = "__RealisticReactorsReloaded__/sound/nuclear_detonation_close_proximity.ogg",
			--			volume = 0.5
			--		},
			--	}
			--},
		},
		
		-- RR-nuclear-scorchmark
		{
		type = "corpse",
		name = "RR-nuclear-scorchmark",
		icon = "__base__/graphics/icons/small-scorchmark.png",
		icon_size = 32,
		flags = {"placeable-neutral", "not-on-map", "placeable-off-grid"},
		collision_box = {{-12,-12}, {12,12}},
		collision_mask = {},
		selection_box = {{-1, -1}, {1, 1}},
		selectable_in_game = false,
		remove_on_entity_placement = false,
		time_before_removed = 60 * 60 * 10, -- 10 minutes
		final_render_layer = "ground-patch-higher2",
		subgroup = "remnants",
		order="d[remnants]-b[scorchmark]-b[nuclear]",
		animation =
		{
		  width = 440,
		  height = 360,
		  frame_count = 1,
		  direction_count = 1,
		  filename = "__RealisticReactorsReloaded__/graphics/explosion/scorchmark-low.png",
		  variation_count = 3,
		  scale=4,
		  hr_version=   {
			width = 880,
			height = 720,
			frame_count = 1,
			direction_count = 1,
			filename = "__RealisticReactorsReloaded__/graphics/explosion/scorchmark.png",
			variation_count = 3,
			scale = 2
			}
		},
		ground_patch =
		{
		  sheet =
		  {
			width = 440,
			height = 360,
			frame_count = 1,
			direction_count = 1,
			x = 880,
			filename = "__RealisticReactorsReloaded__/graphics/explosion/scorchmark-low.png",
			variation_count = 3,
			scale=4,
			hr_version={
				width = 880,
				height = 720,
				frame_count = 1,
				direction_count = 1,
				x = 880 * 2,
				filename = "__RealisticReactorsReloaded__/graphics/explosion/scorchmark.png",
				variation_count = 3,
				scale = 2
				}
		  }
		},
		ground_patch_higher =
		{
		  sheet =
		  {
			width = 440,
			height = 360,
			frame_count = 1,
			direction_count = 1,
			x = 440,
			filename = "__RealisticReactorsReloaded__/graphics/explosion/scorchmark-low.png",
			variation_count = 3,
			scale = 4,
			hr_version={
				width = 880,
				height = 720,
				frame_count = 1,
				direction_count = 1,
				x = 880,
				filename = "__RealisticReactorsReloaded__/graphics/explosion/scorchmark.png",
				variation_count = 3,
				scale = 2
			  }
		  }
		}
	  }
	})

--end

