script.on_event(defines.events.on_pre_ghost_deconstructed, function(event)
	if event.ghost.type == "item-request-proxy" then return end
	if event.ghost.ghost_name == INTERFACE_ENTITY_NAME or event.ghost.ghost_name == BREEDER_INTERFACE_ENTITY_NAME then --interface ghost has been mined via deconstruction planner
		-- look for a reactor
		local reactor_entity = event.ghost.surface.find_entity(REACTOR_ENTITY_NAME,{event.ghost.position.x,event.ghost.position.y})
		local breeder_entity = event.ghost.surface.find_entity(BREEDER_ENTITY_NAME,{event.ghost.position.x,event.ghost.position.y})
		if reactor_entity then --reactor found, recreate interface for free and register the reactor
			local interface = event.ghost.surface.create_entity
				{
					name = INTERFACE_ENTITY_NAME,
					position = event.ghost.position,
					force = event.ghost.force
				}	
			add_reactor(reactor_entity,interface)
		elseif breeder_entity then
			local interface = event.ghost.surface.create_entity
			{
				name = BREEDER_INTERFACE_ENTITY_NAME,
				position = event.ghost.position,
				force = event.ghost.force
			}
			add_reactor(breeder_entity,interface)
		end
	elseif event.ghost.ghost_name == REACTOR_ENTITY_NAME or event.ghost.ghost_name == BREEDER_ENTITY_NAME then
	
		local interface = {}
		interface[1] = event.ghost.surface.find_entity(INTERFACE_ENTITY_NAME,{event.ghost.position.x,event.ghost.position.y+1})
		interface[2] = event.ghost.surface.find_entity(BREEDER_INTERFACE_ENTITY_NAME,{event.ghost.position.x,event.ghost.position.y+1})
		interface[3] = event.ghost.surface.find_entities_filtered{ghost_name=INTERFACE_ENTITY_NAME,position={event.ghost.position.x,event.ghost.position.y+1}}
		interface[3] = interface[3][1]
		interface[4] = event.ghost.surface.find_entities_filtered{ghost_name=BREEDER_INTERFACE_ENTITY_NAME,position={event.ghost.position.x,event.ghost.position.y+1}}
		interface[4] = interface[4][1]
		for _,int in pairs(interface) do
			int.destroy()
		end
	
	
	end
end)

script.on_event({defines.events.on_pre_player_mined_item, defines.events.on_robot_pre_mined, defines.events.on_entity_died}, function(event)
	if event.entity.name=="entity-ghost" then
		if event.entity.ghost_name == INTERFACE_ENTITY_NAME or event.entity.ghost_name == BREEDER_INTERFACE_ENTITY_NAME then --interface ghost has been mined manually
			-- look for a reactor
			local reactor_entity = event.entity.surface.find_entity(REACTOR_ENTITY_NAME,{event.entity.position.x,event.entity.position.y})
			local breeder_entity = event.entity.surface.find_entity(BREEDER_ENTITY_NAME,{event.entity.position.x,event.entity.position.y})
			if reactor_entity then --reactor found, recreate interface for free and register the reactor
				local interface = event.entity.surface.create_entity
					{
						name = INTERFACE_ENTITY_NAME,
						position = event.entity.position,
						force = event.entity.force
					}	
				add_reactor(reactor_entity,interface)
			elseif breeder_entity then

				local interface = event.entity.surface.create_entity
				{
					name = BREEDER_INTERFACE_ENTITY_NAME,
					position = event.entity.position,
					force = event.entity.force
				}
				add_reactor(breeder_entity,interface)
			end
		elseif event.entity.ghost_name == REACTOR_ENTITY_NAME or event.entity.ghost_name == BREEDER_ENTITY_NAME then
		--remove interface on reactor ghost removal
			local interface = {}
			interface[1] = event.entity.surface.find_entity(INTERFACE_ENTITY_NAME,{event.entity.position.x,event.entity.position.y+1})
			interface[2] = event.entity.surface.find_entity(BREEDER_INTERFACE_ENTITY_NAME,{event.entity.position.x,event.entity.position.y+1})
			interface[3] = event.entity.surface.find_entities_filtered{ghost_name=INTERFACE_ENTITY_NAME,position={event.entity.position.x,event.entity.position.y+1}}
			interface[3] = interface[3][1]
			interface[4] = event.entity.surface.find_entities_filtered{ghost_name=BREEDER_INTERFACE_ENTITY_NAME,position = {event.entity.position.x,event.entity.position.y+1}}
			interface[4] = interface[4][1]
			for _,int in pairs(interface) do
				int.destroy()
			end
		end
	elseif event.entity.name == REACTOR_ENTITY_NAME or event.entity.name == BREEDER_ENTITY_NAME then
		local interface = {}
		interface[1] = event.entity.surface.find_entities_filtered{ghost_name=INTERFACE_ENTITY_NAME,position={event.entity.position.x,event.entity.position.y+1}}
		interface[1] = interface[1][1]
		interface[2] = event.entity.surface.find_entities_filtered{ghost_name=BREEDER_INTERFACE_ENTITY_NAME,position = {event.entity.position.x,event.entity.position.y+1}}
		interface[2] = interface[2][1]
		if interface[1] then
			interface[1].destroy()
		elseif interface[2] then
			interface[2].destroy()
		else
			remove_reactor(event)
		end
	elseif event.entity.name == TOWER_ENTITY_NAME then
		remove_cooling_tower(event.entity)
	elseif event.entity.name == REACTOR_RUIN_NAME or event.entity.name == BREEDER_RUIN_NAME then
		remove_reactor_ruin(event.entity)
	elseif event.entity.type == "heat-pipe" then
		if event.entity.name == "rr-underground-heat-pipe" then
			for key, hp in pairs(global.underground_heat_pipes) do
				if hp == event.entity then
					table.remove(global.underground_heat_pipes, key)
				end
			end
		end
		local surroundings = event.entity.surface.find_entities_filtered{area = {{event.entity.position.x-1,event.entity.position.y},{event.entity.position.x+1,event.entity.position.y}}, type='heat-pipe'}
		local surroundings2 = event.entity.surface.find_entities_filtered{area = {{event.entity.position.x,event.entity.position.y-1},{event.entity.position.x,event.entity.position.y+1}}, type='heat-pipe'}
		surroundings = union_tables(surroundings,surroundings2)
		for _, ent in pairs (surroundings) do
			if ent ~= event.entity and global.all_heat_pipes[event.entity.surface.name][ent.unit_number] then
				for key, connected_pipe in pairs(global.all_heat_pipes[event.entity.surface.name][ent.unit_number][2]) do
					if connected_pipe == event.entity then
						global.all_heat_pipes[event.entity.surface.name][ent.unit_number][2][key]=nil
					end
				end
			end
		end
		global.all_heat_pipes[event.entity.surface.name][event.entity.unit_number]=nil
		
		-- register event for updating list of connected reactors
		register_update_connected_reactors_event(event.tick)	
	end
end)

script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity}, function(event)
	if event.created_entity.name == "reactor-sarcophagus" then
		event.created_entity.health = 0.1
		event.created_entity.destructible = false
		event.created_entity.minable = false
		table.insert(global.sarcophagus, event.created_entity)
		
		local fallout = event.created_entity.surface.find_entities_filtered{name="permanent-radiation",area={{event.created_entity.position.x-5,event.created_entity.position.y-5},{event.created_entity.position.x+5,event.created_entity.position.y+5}}}
		for i, entity in pairs (fallout) do
			if i%20 ~=1 then
				entity.destroy()
			end
		end
	--build event: reactors
	elseif event.created_entity.name == REACTOR_ENTITY_NAME or event.created_entity.name == BREEDER_ENTITY_NAME then
		register_update_connected_reactors_event(event.tick)
		event.created_entity.active=false
		event.created_entity.minable = true
		--look for interface
		local interface_entity = event.created_entity.surface.find_entity(INTERFACE_ENTITY_NAME,{event.created_entity.position.x,event.created_entity.position.y+1})
		if not interface_entity then
			interface_entity = event.created_entity.surface.find_entity(BREEDER_INTERFACE_ENTITY_NAME,{event.created_entity.position.x,event.created_entity.position.y+1})
		end
		--look for interface ghost
		local interface_ghost
		if not interface_entity then
			interface_ghost = event.created_entity.surface.find_entities_filtered{ghost_name=INTERFACE_ENTITY_NAME,position={event.created_entity.position.x,event.created_entity.position.y+1}}
			if #interface_ghost == 0 then
				interface_ghost = event.created_entity.surface.find_entities_filtered{ghost_name=BREEDER_INTERFACE_ENTITY_NAME,position={event.created_entity.position.x,event.created_entity.position.y+1}}
			end
		end
		
		if interface_entity == nil and #interface_ghost == 0 then --no interface found
			--logging("Building new circuit interface")
			--add new circuit interface
			local interface
			if event.created_entity.name == REACTOR_ENTITY_NAME then --different interfaces for different reactors
				interface = event.created_entity.surface.create_entity
				{
					name = INTERFACE_ENTITY_NAME,
					position = {event.created_entity.position.x, event.created_entity.position.y + 1},
					force = event.created_entity.force
				}
			else
				interface = event.created_entity.surface.create_entity
				{
					name = BREEDER_INTERFACE_ENTITY_NAME,
					position = {event.created_entity.position.x, event.created_entity.position.y + 1},
					force = event.created_entity.force
				}
			end
			add_reactor(event.created_entity,interface)
			
		elseif interface_entity ~= nil then -- interface found
			--logging("Found existing circuit interface")
			add_reactor(event.created_entity,interface_entity)
			
		else --interface ghost found
			event.created_entity.destructible = true
			event.created_entity.minable = true
			
		end
		
	elseif event.created_entity.name == INTERFACE_ENTITY_NAME or event.created_entity.name == BREEDER_INTERFACE_ENTITY_NAME then --build event: interfaces
		--look for reactors
		local reactor_entity = event.created_entity.surface.find_entity(REACTOR_ENTITY_NAME,{event.created_entity.position.x,event.created_entity.position.y})
		if not reactor_entity then
			reactor_entity = event.created_entity.surface.find_entity(BREEDER_ENTITY_NAME,{event.created_entity.position.x,event.created_entity.position.y})
		end
		
		if reactor_entity and reactor_entity.position.x == event.created_entity.position.x and reactor_entity.position.y == event.created_entity.position.y-1 then --reactor found and location is correct
			add_reactor(reactor_entity,event.created_entity)
		else
			event.created_entity.destructible = true
			event.created_entity.minable = true
		end
		
	elseif event.created_entity.name == TOWER_ENTITY_NAME then --build event: cooling tower
		add_cooling_tower(event.created_entity)
		
	elseif event.created_entity.type == "heat-pipe" then
		if event.created_entity.name == "rr-underground-heat-pipe" then
			table.insert(global.underground_heat_pipes, event.created_entity)
		end
		local surroundings = event.created_entity.surface.find_entities_filtered{area = {{event.created_entity.position.x-1,event.created_entity.position.y},{event.created_entity.position.x+1,event.created_entity.position.y}}, type='heat-pipe'}
		local surroundings2 = event.created_entity.surface.find_entities_filtered{area = {{event.created_entity.position.x,event.created_entity.position.y-1},{event.created_entity.position.x,event.created_entity.position.y+1}}, type='heat-pipe'}
		surroundings = union_tables(surroundings,surroundings2)
		for key, ent in pairs (surroundings) do
			if ent == event.created_entity then
				surroundings[key] = nil
			end
		end
		if not global.all_heat_pipes[event.created_entity.surface.name] then
			global.all_heat_pipes[event.created_entity.surface.name] = {}
		end
		global.all_heat_pipes[event.created_entity.surface.name][event.created_entity.unit_number]={event.created_entity,surroundings,get_connected_reactors(event.created_entity)}
		
		for key, ent in pairs (surroundings) do
			if not global.all_heat_pipes[event.created_entity.surface.name][ent.unit_number] then 
				global.all_heat_pipes[event.created_entity.surface.name][ent.unit_number] = {hp,{},{}}
			end
			table.insert(global.all_heat_pipes[event.created_entity.surface.name][ent.unit_number][2],event.created_entity)
		end
		-- register event for updating list of connected reactors
		register_update_connected_reactors_event(event.tick)
		
	elseif event.created_entity.name=="constant-combinator" then --build event: constant combinator (manually built)
		--check if there is an interface ghost under the constant combinator
		local interface_ghost = event.created_entity.surface.find_entities_filtered{ghost_name=INTERFACE_ENTITY_NAME,position=event.created_entity.position}
		if #interface_ghost == 0 then
			interface_ghost = event.created_entity.surface.find_entities_filtered{ghost_name=BREEDER_INTERFACE_ENTITY_NAME,position=event.created_entity.position}
		end
		if #interface_ghost > 0 then --interface ghost under constant combinator
			event.created_entity.destroy() --remove constant combinator
			local surface = interface_ghost[1].surface -- store attributes of the interface ghost
			local position = interface_ghost[1].position 
			local force = interface_ghost[1].force
			local name = interface_ghost[1].ghost_name
			interface_ghost[1].revive() --revive interface ghost (maintains circuit wire connections)
			if name == INTERFACE_ENTITY_NAME then --build normal reactor ghost
				surface.create_entity{
					name = "entity-ghost",
					position = {position.x, position.y - 1},
					force = force,
					inner_name = REACTOR_ENTITY_NAME,
					expires = false,
				}
			else --build breeder reactor ghost
				surface.create_entity{
					name = "entity-ghost",
					position = {position.x, position.y - 1},
					force = force,
					inner_name = BREEDER_ENTITY_NAME,
					expires = false,
				}
			end
		end
	end
	
end)




-- adds core, eccs, lamp, light, electric interface to the reactor core when it is build
function add_reactor(displayer,interface)
	reactor_core = displayer.surface.create_entity{name = "realistic-reactor-1", position = {displayer.position.x, displayer.position.y}, force = displayer.force.name}
	--reactor is actually the reactor core
	reactor_core.destructible = false
	--logging("---------------------------------------------------------------")
    --logging("Adding new reactor: "..displayer.name)
	--logging("Reactor core ID: " .. reactor_core.unit_number)
	--interface.operable = false 
	interface.destructible = false 
	interface.minable = false
	
	--logging("Reactor ID: " .. interface.unit_number)
	
	--add the eccs
	local eccs = reactor_core.surface.create_entity
	{
		name = BOILER_ENTITY_NAME,
		position = reactor_core.position,
		force = reactor_core.force
	}
	eccs.operable = false 
	eccs.destructible = false
	eccs.minable = false
	
	--add power entity
	local power_name
	if displayer.name == "realistic-reactor-breeder" then
		power_name = BREEDER_POWER_NAME
	else
		power_name = REACTOR_POWER_NAME
	end
	local power = reactor_core.surface.create_entity
	{
		name = power_name,
		position = reactor_core.position,
		force = reactor_core.force
	}
	power.destructible=false
	power.energy = math.max(0,(1.5-settings.global["rr_energy_consumption_multiplier"].value)) * 17000000
	--add light
	local reactor_lamp
	local reactor_light
	reactor_lamp = reactor_core.surface.create_entity{name = "rr-black-lamp", position = {reactor_core.position.x+0.017,reactor_core.position.y+0.88}, force = reactor_core.force.name}
	reactor_light = reactor_core.surface.create_entity{name = "rr-black-light", position = {reactor_core.position.x+0.017,reactor_core.position.y+0.88}, force = reactor_core.force.name}
	--if displayer.name == "realistic-reactor-breeder" then
	--	reactor_lamp = reactor_core.surface.create_entity{name = "rr-black-lamp", position = {reactor_core.position.x+0.62,reactor_core.position.y+0.6}, force = reactor_core.force.name}
	--	reactor_light = reactor_core.surface.create_entity{name = "rr-black-light", position = {reactor_core.position.x+0.62,reactor_core.position.y+0.6}, force = reactor_core.force.name}
	--else
	--	reactor_lamp = reactor_core.surface.create_entity{name = "rr-black-lamp", position = {reactor_core.position.x-0.62,reactor_core.position.y+0.6}, force = reactor_core.force.name}
	--	reactor_light = reactor_core.surface.create_entity{name = "rr-black-light", position = {reactor_core.position.x-0.62,reactor_core.position.y+0.6}, force = reactor_core.force.name}
	--end
	reactor_lamp.destructible = false
	reactor_light.destructible = false
	
	-- reactor is not active when it is build (state=stopped)
	reactor_core.active=false
	
	--max power for gui
	if settings.global["calculate-stats-function"].value == "ingo's formulas" then
		reactor_max_power = 123
		reactor_max_efficiency = 200
	else
		reactor_max_power = 250
		reactor_max_efficiency = 210
	end
	local reactor = {
		id = interface.unit_number,	-- ID of the reactor (doesn't change)				
		core_id = reactor_core.unit_number, -- ID of the core (changes when core is replaced)
		core = reactor_core, -- core entity
		interface = interface, -- interface entity
		eccs = eccs, -- eccs entity
		power = power, -- power entity
		displayer = displayer, -- displayer entity
		position = reactor_core.position, -- core position = reactor position
		state = 0, -- reactor state
		state_active_since = game.tick, -- state begin
		connected_neighbours_IDs = {}, -- list with IDs of connected reactors 
		neighbours = 0, -- number of connected reactors
		control = interface.get_or_create_control_behavior(), -- control behaviour for interface signals
		efficiency = 0, -- reactor efficiency
		bonus_cells = {}, -- list of bonus cell amount for breeder
		cooling_history=0, -- average power loss through cooling in the last TICKS_PER_UPDATE*8 ticks 
		lamp = reactor_lamp, --reactor lamp dummy
		light = reactor_light, --light dummy for the lamp
		interface_warning_tick = 0, --last tick an electricity warning was displayed on the interface (for imitating the game's behaviour)
		interface_warning = nil, --electricity warning dummy (interface)
		cooling_warning_tick = 0, --last tick an electricity warning was displayed on the cooling
		cooling_warning = nil, --electricity warning dummy (cooling)
		power_usage = {starting = 0,cooling = 0, interface = 0}, --portions of the power consumption
		last_states_update = game.tick,
		fuel_last_tick = 0, -- fuel value in the core on last tick
		--fluid_amount_last_tick = 0, -- fluid amount in eccs on last tick
		power_output_last_tick = 0, --power output in MW on last tick (only updated in start or running phase)
		last_temp_update = game.tick,
		max_power = reactor_max_power, --dynamic maximum value for gui
		max_efficiency = reactor_max_efficiency, --dynamic maximum value for gui
		signals = -- signals for interface
		{
		  parameters =
		  {
			["core_temperature"] = {signal=SIGNAL_CORE_TEMP, count=0, index=1},
			["state_stopped"] = {signal=SIGNAL_STATE_STOPPED, count=1, index=2},
			["state_starting"] = {signal=SIGNAL_STATE_STARTING, count=0, index=3},
			["state_running"] = {signal=SIGNAL_STATE_RUNNING, count=0, index=4},
			["state_scramed"] = {signal=SIGNAL_STATE_SCRAMED, count=0, index=5},
			["coolant-amount"] = {signal=SIGNAL_COOLANT_AMOUNT, count=0, index=6},
			["power-output"] = {signal=SIGNAL_REACTOR_POWER_OUTPUT, count=0, index=7},
			["uranium-fuel-cells"] = {signal=SIGNAL_URANIUM_FUEL_CELLS, count=0, index=8},
			--["used-uranium-fuel-cells"] = {signal=SIGNAL_USED_URANIUM_FUEL_CELLS, count=0, index=9},
			["efficiency"] = {signal=SIGNAL_REACTOR_EFFICIENCY, count=0, index=10},
			["cell-bonus"] = {signal=SIGNAL_REACTOR_CELL_BONUS, count=0, index=11},
			["electric-power"] = {signal=SIGNAL_REACTOR_ELECTRIC_POWER, count=0, index=12},
			["neighbour-bonus"] = {signal=SIGNAL_NEIGHBOUR_BONUS, count=0, index=13}
		  }
		}
	}
	reactor.core.get_fuel_inventory().insert{name="rr-dummy-fuel-cell", count = 50}
	table.insert(global.reactors, reactor)
	--logging("-> reactor successfully added")
	--logging("")
	
	-- register event for updating list of connected reactors
	local hp_neighbour_entities_ew = reactor.core.surface.find_entities_filtered{area = {{reactor.position.x-2,reactor.position.y-1},{reactor.position.x+2,reactor.position.y}}, type='heat-pipe'} --east and west
	local hp_neighbour_entities_n = reactor.core.surface.find_entities_filtered{area = {{reactor.position.x-1,reactor.position.y-2},{reactor.position.x+1,reactor.position.y}}, type='heat-pipe'} -- north
	local table_of_heat_pipes_to_check = union_tables(hp_neighbour_entities_ew,hp_neighbour_entities_n)
	for _, hp in pairs(table_of_heat_pipes_to_check) do
		table.insert(global.all_heat_pipes[reactor.core.surface.name][hp.unit_number][3],reactor)
	end
	register_update_connected_reactors_event(game.tick)
end

-- removes other reactor parts when its reactor core is removed
function remove_reactor(event)
	for i,reactor in pairs(global.reactors) do
		if reactor.displayer == event.entity  then
			local hp_neighbour_entities_ew = reactor.core.surface.find_entities_filtered{area = {{reactor.position.x-2,reactor.position.y-1},{reactor.position.x+2,reactor.position.y}}, type='heat-pipe'} --east and west
			local hp_neighbour_entities_n = reactor.core.surface.find_entities_filtered{area = {{reactor.position.x-1,reactor.position.y-2},{reactor.position.x+1,reactor.position.y}}, type='heat-pipe'} -- north
			local table_of_heat_pipes_to_check = union_tables(hp_neighbour_entities_ew,hp_neighbour_entities_n)
			for _, hp in pairs(table_of_heat_pipes_to_check) do
				for key, rea in pairs(global.all_heat_pipes[reactor.core.surface.name][hp.unit_number][3]) do
					if reactor.displayer == rea.displayer then
						global.all_heat_pipes[reactor.core.surface.name][hp.unit_number][3][key] = nil
					end
				end
			end
			
			local dead_reactor_core = reactor.core
			local dead_reactor_id = reactor.id
			local dead_reactor_name = reactor.displayer.name
			local surface = reactor.core.surface		
						
			-- cause meltdown?
			if reactor.state ~= 0 and settings.startup["meltdown-mode"].value ~= "no meltdown" then
				surface.pollute(dead_reactor_core.position, 150000) --0.006 evo @ 0.80
				--if game.forces["enemy"] then
				--	game.forces["enemy"].evolution_factor=math.min(1,game.forces["enemy"].evolution_factor+0.007)
				--end
				-- working reactor destroyed, causing meltdown
				
				-- do the meltdown explosion		
				if settings.startup["meltdown-explosion"].value == "atomic" then
					--create atomic explosion
					surface.create_entity({
						name="fallout-explosion",
						position=dead_reactor_core.position
					})
				else
					-- create normal explosion
					surface.create_entity({
						name="medium-explosion",
						position=dead_reactor_core.position
					})					
				end
				
				-- create reactor ruin
				local ruin = "none" --TODO DOESNT WORK ON KILLED
				if settings.startup["meltdown-mode"].value == "meltdown with ruin" or settings.startup["meltdown-mode"].value == "meltdown with ruin + sarcophagus" then
				
					-- create reactor ruin
					if dead_reactor_name == REACTOR_ENTITY_NAME then
						ruin = surface.create_entity{
							name=REACTOR_RUIN_NAME,
							position=dead_reactor_core.position,
							force=dead_reactor_core.force, 
							create_build_effect_smoke = false
						}
					else
						ruin = surface.create_entity{
							name=BREEDER_RUIN_NAME,
							position=dead_reactor_core.position,
							force=dead_reactor_core.force, 
							create_build_effect_smoke = false
						}
					end
					ruin.destructible = false
					
					-- set health of ruin (for only ruin mode...)
					if settings.startup["meltdown-mode"].value == "meltdown with ruin" then
						ruin.health = 0.1
						ruin.minable = false
					end
					
					-- create steam producing entity
					local steam
                    if settings.startup["fallout-mode"].value == "clouds and radioactivity" then
                        steam = surface.create_entity
                        {
                            name = RUIN_SMOKE_NAME,
                            position = {dead_reactor_core.position.x,dead_reactor_core.position.y+0.3},
                            force = dead_reactor_core.force
                        }
                        steam.operable = false 
                        steam.destructible = false 
                        steam.get_fuel_inventory().insert({name="solid-fuel", count=50}) -- at 1 watt, this is enough fuel to run for 39 years, should suffice
                        steam.fluidbox[1] = {name="water", amount=1} -- water for dummy steam puff recipe
                        steam.active = true -- start active - it's always active
                    end
					local glow = surface.create_entity
						{
							name = "rr-ruin-glow",
							position = {dead_reactor_core.position.x,dead_reactor_core.position.y},
							force = dead_reactor_core.force
						}
					-- reactor ruin is saved in global table
					table.insert(global.ruins,
					{
						id = ruin.unit_number, --same id as reactor
						entity = ruin,
						steam = steam,
						glow = glow,
						tick = game.tick,--changes during radiation creation
						meltdown_tick = game.tick,
						spread = 6
					})
					
				end				
				
				--create radiation and cloud
				if settings.startup["fallout-mode"].value == "clouds and radioactivity" then
					local fallout_size = 4
					if settings.startup["meltdown-mode"].value == "meltdown with ruin" then
						fallout_size = 2 + math.floor(math.min(1,settings.startup["rr-fallout-duration"].value / settings.startup["sarcophagus-duration"].value)*8) -- (4-2) + 600/1800*(fallout_growth+2) = 300/1800 = gets bigger 6 times up to 10
					end
					-- create fallout cloud
					local cloud = surface.create_entity({
						name="fallout-cloud",
						position=dead_reactor_core.position,
						force = "radioactivity-strong"
					})
					table.insert(global.falloutclouds,cloud)
					if settings.startup["meltdown-mode"].value == "meltdown without ruin" then
						table.insert(global.fallout,{tick = game.tick, position = dead_reactor_core.position, surface = surface})
					end
					--create delayed event for fallout around the dead_reactor_core
					local delay = 2
					while global.delayed_fallout[event.tick+delay] do 
						delay = delay + 1
					end
					global.delayed_fallout[event.tick+delay]={surface=surface,position = dead_reactor_core.position,min_radius = 0, fallout_size = math.floor(fallout_size/2)}
					
					delay = 180
					while global.delayed_fallout[event.tick+delay] do 
						delay = delay + 1
					end
					global.delayed_fallout[event.tick+delay]={surface=surface,position = dead_reactor_core.position,min_radius = 0, fallout_size = fallout_size}
					
				elseif settings.startup["fallout-mode"].value == "radioactivity" then
				
					--create delayed event for fallout around the dead_reactor_core
					if settings.startup["meltdown-explosion"].value == "atomic" then
						local fallout_size = 4
						if settings.startup["meltdown-mode"].value == "meltdown with ruin" then
							fallout_size = 2 + math.floor(math.min(1,settings.startup["rr-fallout-duration"].value / settings.startup["sarcophagus-duration"].value)*8) -- (4-2) + 600/1800*(fallout_growth+2) = 300/1800 = gets bigger 6 times up to 10
						end
						local delay = 60
						while global.delayed_fallout[event.tick+delay] do 
							delay = delay + 1
						end
						global.delayed_fallout[event.tick+delay]={surface=surface,position = dead_reactor_core.position,fallout_size = fallout_size}
					else
						local fallout_size = 6
						if settings.startup["meltdown-mode"].value == "meltdown with ruin" then
							fallout_size = 4 + math.floor(math.min(1,settings.startup["rr-fallout-duration"].value / settings.startup["sarcophagus-duration"].value)*8) -- (4-2) + 600/1800*(fallout_growth+2) = 300/1800 = gets bigger 6 times up to 10
						end
						local skips = 0
						local delay = 1
							while global.delayed_fallout[event.tick+delay] do 
								delay = delay + 1
							end
							 if delay >11 then
							 	skips =skips + 1
							 end
						
						local delay2 = 60
							while global.delayed_fallout[event.tick+delay2] do 
								delay2 = delay2 + 1
							end
							 if delay2 >70 then
							 	skips =skips + 1
							 end
						
						local delay3 = 120
							while global.delayed_fallout[event.tick+delay3] do 
								delay3 = delay3 + 1
							end
							 if delay3 >130 then
							 	skips =skips + 1
							 end
							
						if skips == 0 then
							global.delayed_fallout[event.tick+delay]={surface=surface,position = dead_reactor_core.position,min_radius = 1, fallout_size = math.floor(fallout_size/6)} --1
							global.delayed_fallout[event.tick+delay2]={surface=surface,position = dead_reactor_core.position,min_radius = 2, fallout_size = math.floor(fallout_size/3)} --2
							global.delayed_fallout[event.tick+delay3]={surface=surface,position = dead_reactor_core.position,min_radius = 3, fallout_size = math.floor(fallout_size*2/3)} --4
							
							delay = 180
							 while global.delayed_fallout[event.tick+delay] do 
							 	delay = delay + 1
							 end
							global.delayed_fallout[event.tick+delay]={surface=surface,position = dead_reactor_core.position,min_radius = 5, fallout_size = fallout_size} --6
						else
							delay = 1
							 while global.delayed_fallout[event.tick+delay] do 
							 	delay = delay + 1
							 end
							global.delayed_fallout[event.tick+delay]={surface=surface,position = dead_reactor_core.position,min_radius = 0, fallout_size = fallout_size} --5
						end
					end
					
					--table.insert(global.fallout,{tick = game.tick, position = dead_reactor_core.position, surface = surface, ruin = ruin, spread = fallout_size}) --i think this one is only for clouds
				end
							
				-- remove the reactor ghost
				-- problem: ghost does not exist yet, it will be created in the next tick
				--> register event to remove the reactor ghost
				--register_remove_reactor_ghost_event(event.tick,dead_reactor_core.position)
				
			end	--meltdown		
			
			-- remove ghosts if ruin was build
			if event.name == defines.events.on_entity_died and (settings.startup["meltdown-mode"].value == "meltdown without ruin" or settings.startup["meltdown-mode"].value == "no meltdown") then 
				reactor.interface.destructible=true
				reactor.interface.damage(1000000,game.forces.neutral,"laser") --retain wire connections in the ghost
			else
				reactor.interface.destroy() -- remove interface entity
			end
			
			--remove other stuff
			reactor.eccs.destroy() -- remove eccs
			reactor.power.destroy() -- remove power entity
			if reactor.core.valid then reactor.core.destroy() end
			if reactor.lamp.valid then reactor.lamp.destroy() end
			if reactor.light.valid then reactor.light.destroy() end
			if reactor.interface_warning and reactor.interface_warning.valid then reactor.interface_warning.destroy() end
			if reactor.cooling_warning and reactor.cooling_warning.valid then reactor.cooling_warning.destroy() end
			if event.name == defines.events.on_entity_died and (settings.startup["meltdown-mode"].value == "meltdown with ruin" or settings.startup["meltdown-mode"].value == "meltdown with ruin + sarcophagus") then
				reactor.displayer.destroy() --only destroy when there should not remain a ghost
			end
			
			--remove global table entry
			global.reactors[i] = nil
		
		end 
	end
	-- register event for updating list of connected reactors
	register_update_connected_reactors_event(event.tick)
end

-- adds the steam entity to the cooling tower when it is build
function add_cooling_tower(tower)
-- the steam entity makes happy clouds when the tower is active
-- this is needed because the cooling tower is an electric furnace, and only burner furnaces can produce smoke
  --logging("---------------------------------------------------------------")
  --logging("Adding new cooling tower with ID: " .. tower.unit_number)
  local steam = tower.surface.create_entity
  {
    name = STEAM_ENTITY_NAME,
    position = tower.position,
    force = tower.force
  }
  steam.operable = false -- disable opening the happy cloud maker's GUI
  steam.destructible = false -- it can't be destroyed (we remove it when the cooling tower dies)
  steam.get_fuel_inventory().insert({name="solid-fuel", count=50}) -- at 1 watt, this is enough fuel to run for 39 years, should suffice
  steam.fluidbox[1] = {name="water", amount=1} -- water for dummy steam puff recipe
  steam.active = false -- start inactive
  table.insert(global.towers,
  {
    id = tower.unit_number,
    entity = tower,
    steam = steam
  })
  --logging("-> tower successfully added")
  --logging("")
end

-- remove reactor ruin
function remove_reactor_ruin(dead_ruin)
	--when the reactor ruin was replaced by a sarcophagus, the steam creator entity needs to be removed 
	--logging("---------------------------------------------------------------")
	--logging("Removing reactor ruin ID: " .. dead_ruin.unit_number)
	for i,ruin in pairs(global.ruins) do
	--logging("Checking global.ruins: "..dead_ruin.unit_number)
		if ruin.id == dead_ruin.unit_number then
			--logging("-> found matching entry")
			if ruin.steam and ruin.steam.valid then ruin.steam.destroy() end
			if ruin.glow and ruin.glow.valid then ruin.glow.destroy() end
			global.ruins[i]=nil
		end
	end
end

-- removes the steam entity when its cooling tower is removed 
function remove_cooling_tower(dead_tower)
--logging("---------------------------------------------------------------")
--logging("Removing cooling tower ID: " .. dead_tower.unit_number)
  for i,tower in pairs(global.towers) do
    if tower.id == dead_tower.unit_number then
      --logging("-> found tower, removing it and all its parts")
	  tower.steam.destroy() -- remove happy cloud maker
      table.remove(global.towers, i) -- remove table entry so we stop trying to update this tower
    end
  end
--logging("-> tower successfully removed")
--logging("")
end