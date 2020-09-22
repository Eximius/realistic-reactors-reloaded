script.on_event(defines.events.on_tick, function(event)
	--global.dbg = 1
	--sarcophagus healing
	if event.tick % 180 ==0 then 
		for key, entity in pairs(global.sarcophagus) do
			entity.health = entity.health + 1000/math.max(1,settings.startup["sarcophagus-duration"].value) * 3
			if entity.health ==1000 then
				entity.minable = true
				entity.destructible = true
				global.sarcophagus[key]=nil
			end
		end
	end
	
	
	-- radiation around reactor ruin
	if settings.startup["fallout-mode"].value == "radioactivity" or settings.startup["fallout-mode"].value == "clouds and radioactivity" then
		
		if game.tick % 180 == 0 then -- max 2x radiation
			for i,tbl in pairs(global.ruins) do
				local ruin = tbl.entity
				if settings.startup["meltdown-mode"].value == "meltdown with ruin" then
					ruin.health = ruin.health + 1000/math.max(1,settings.startup["sarcophagus-duration"].value) /60*180--settings.startup["rr-fallout-duration"].value*5
					if ruin.health ==1000 then
						--entity.minable = true
						--entity.destructible = true
						remove_reactor_ruin(ruin)
						ruin.minable = true
						ruin = nil
					end
				end
				if ruin and ruin.valid then
					periodic_pollution(ruin,0.1)
					if tbl.tick + (settings.startup["rr-fallout-duration"].value*30) < game.tick then
						
						tbl.tick = game.tick
						tbl.spread = tbl.spread + 1
						circular_radiation(ruin.surface,ruin.position,0,math.min(16,tbl.spread))
					end
				end
			end
		end
		
	end
	
	
	-- radioactive cloud
	if settings.startup["fallout-mode"].value == "clouds and radioactivity" then
	
		if event.tick % 300 ==0 then
			if global.ruins ~= nil then
				for key,ruin in pairs(global.ruins) do
					if ruin.meltdown_tick + 60*settings.startup["clouds_generation"].value > game.tick then
						-- create fallout cloud
						local cloud = ruin.entity.surface.create_entity({
							name="fallout-cloud",
							position=ruin.entity.position,
							force = "radioactivity-strong"
						})	
						table.insert(global.falloutclouds, cloud)
					else
						-- disable steamer entity of ruin
						ruin.steam.active=false
					end
				end
			end

			if global.fallout ~= nil then
				for key,meltdown in pairs(global.fallout) do 
					if meltdown.tick+60*settings.startup["clouds_generation"].value < game.tick then--and settings.startup["sarcophagus-mode"].value == "no sarcophagus" then
						--remove cloud creating entry
						global.fallout[key] = nil
					else
						
						-- create fallout cloud
						local cloud = meltdown.surface.create_entity({
							name="fallout-cloud",
							position=meltdown.position,
							force = "radioactivity-strong"
						})	
						table.insert(global.falloutclouds, cloud)
						
					end
				end
			end
			
		end
		
		-- fallout radiation (from clouds)
		if event.tick % 79 ==0 then
			if global.falloutclouds ~= nil then
				if #global.falloutclouds > 0 then
					local rnd = math.random(#global.falloutclouds)
					--for _,cloud in pairs(global.falloutclouds) do --fallout 300 secs
					if global.falloutclouds[rnd] and global.falloutclouds[rnd].valid then
						periodic_pollution(global.falloutclouds[rnd],0.05)
						global.falloutclouds[rnd].surface.create_entity({
							name="permanent-radiation",
							position=global.falloutclouds[rnd].position,
							force = "radioactivity"
						})
					else
						table.remove(global.falloutclouds,rnd)
					end
				end
			end
		end
		
	end
	
	
	-- delayed fallout
	if global.delayed_fallout[event.tick] then
		circular_radiation(global.delayed_fallout[event.tick].surface, global.delayed_fallout[event.tick].position, global.delayed_fallout[event.tick].min_radius or 0, global.delayed_fallout[event.tick].fallout_size)
		global.delayed_fallout[event.tick] = nil
	end

	
	-- registered tick to remove reactor ghost after meltdown	-not necessary, you can destroy the entity in the death event
	--if event.tick == global.tick_remove_reactor_ghost then	
	--	local reactor_ghost
	--	reactor_ghost = surface.find_entities_filtered{type="entity-ghost",position=global.remove_reactor_ghost_position}
	--	if #reactor_ghost == 0 then
	--		--something is wrong - no ghost found
	--	else
	--		--remove ghost entity
	--		for i,e in pairs(reactor_ghost) do
	--			e.destroy()
	--		end
	--	end		
	--end	
	
	-- registered tick for update event of connected reactors list
	if event.tick == global.tick_update_connected_reactors then
		if settings.global["manually-check-neighbours"].value == false then
			--logging("---------------------------------------------------------------")
			--logging("Updating connected reactors list")
			--logging("Tick: " .. event.tick)
			--logging("---------------------------------------------------------------")
			for _, surface in pairs(game.surfaces) do
				checked_reactors = {}		
				for i,reactor in pairs(global.reactors) do
					if reactor.core.surface == surface and not checked_reactors[reactor.id] then
						build_connected_reactors_list(reactor)
					end
				end
			end
			--logging("")
		end	
	end

	local i		--frequently used vars
	local maxruns
	
	-- reactor update events
	
	local temp_count = table_size(global.reactors)
	local reactor_count = math.floor((temp_count+global.tick_delayer)/TICKS_PER_UPDATE)
	if not (reactor_count > 0) then	-- run events only when a reactor exists
		global.tick_delayer = global.tick_delayer + temp_count
	else
		global.tick_delayer = 0
			
		--cooling reactors
		if not global.iterate_reactor_temp then
			global.iterate_reactor_temp = next(global.reactors,global.iterate_reactor_temp)
		elseif not global.reactors[global.iterate_reactor_temp] then
			global.iterate_reactor_temp = nil
		end
		i = 0
		maxruns = math.min(2,reactor_count) --120/s
		while i< maxruns and global.iterate_reactor_temp do --eats 0.050 ticks at 64 reactors
			
			update_reactor_temperature(global.iterate_reactor_temp,event)	--update function
			
			if not global.skip_temp_iteration then	--if reactor is destroyed, the function has set the next value
				global.iterate_reactor_temp = next(global.reactors,global.iterate_reactor_temp)
			else
				global.skip_temp_iteration = nil
			end
			if not global.iterate_reactor_temp then
				global.iterate_reactor_temp = next(global.reactors,global.iterate_reactor_temp)
			end
			i=i+1
		end

		
		-- signals (temp + fluid)
		if not global.iterate_reactor_temp_signals then
			global.iterate_reactor_temp_signals = next(global.reactors,global.iterate_reactor_temp_signals)
		elseif not global.reactors[global.iterate_reactor_temp_signals] then
			global.iterate_reactor_temp_signals = nil
		end
		i = 0
		maxruns = math.min(3,reactor_count) --180/s
		while i<maxruns and global.iterate_reactor_temp_signals do --eats 0.050 ticks at 64 reactors
		
			--update function:
				local reactor = global.reactors[global.iterate_reactor_temp_signals]
				local inventory = reactor.displayer.get_fuel_inventory()
				if inventory.is_empty() then
					reactor.signals.parameters["uranium-fuel-cells"].count = 0
					reactor.signals.parameters["uranium-fuel-cells"].signal = {type="item", name="uranium-fuel-cell"}
				else
					reactor.signals.parameters["uranium-fuel-cells"].signal = {type="item", name=inventory[1].name}
					reactor.signals.parameters["uranium-fuel-cells"].count = inventory[1].count
				end
				-- destroy energy warning entity
				if game.tick - reactor.interface_warning_tick >=60  and reactor.interface_warning and reactor.interface_warning.valid then
					reactor.interface_warning.destroy()
				end
				reactor.signals.parameters["core_temperature"].count = reactor.core.temperature
				
				local fluid = reactor.eccs.fluidbox[1]
				if fluid then
					reactor.signals.parameters["coolant-amount"].count = fluid.amount
				else
					reactor.signals.parameters["coolant-amount"].count = 0
				end
				-- check if interface has enough power
				if reactor.power.energy >= (POWER_USAGE_INTERFACE * TICKS_PER_UPDATE / 60* settings.global["rr_energy_consumption_multiplier"].value) then   --- TICKS_PER_UPDATE // TODO: compare with correct power usage (not critical)
					-- show updated signals on interface
					--if not compare_tables(reactor.signals, reactor.old_signals, false) then
						reactor.control.parameters = reactor.signals
					--	reactor.old_signals = deepcopy(reactor.signals)
					--end
					-- apply power consumption for interface
					reactor.power_usage.interface = math.floor(POWER_USAGE_INTERFACE/60)
				else
					reactor.power_usage.interface = 0
					-- disable interface signals
					reactor.control.parameters = {parameters={}}
					--reactor.old_signals = {parameters={}}
					-- show energy warning entity
					if game.tick - reactor.interface_warning_tick >=120 then
						reactor.interface_warning=reactor.interface.surface.create_entity{name="rr-electricity-warning", position = reactor.interface.position, force = "neutral"}
						reactor.interface_warning.destructible = false
						reactor.interface_warning_tick = game.tick
					end
				end
			
			global.iterate_reactor_temp_signals = next(global.reactors,global.iterate_reactor_temp_signals) --iterating...
			if not global.iterate_reactor_temp_signals then
				global.iterate_reactor_temp_signals = next(global.reactors,global.iterate_reactor_temp_signals)
			end
			i=i+1
		end
		--logging("}")
		--logging("--------------------------------")
		--logging("Updating reactor states")
		--logging("--------------------------------")
		--logging("{")

			
		-- reactor_states
		if not global.iterate_reactor_states then
			global.iterate_reactor_states = next(global.reactors,global.iterate_reactor_states)
		elseif not global.reactors[global.iterate_reactor_states] then
			global.iterate_reactor_states = nil
		end
		i = 0
		maxruns = math.min(1,reactor_count) --60/s
		while i<maxruns and global.iterate_reactor_states do --eats 0.020 ticks at 64 reactors
		
			update_reactor_states(global.iterate_reactor_states,event)	--update function
			
			global.iterate_reactor_states = next(global.reactors,global.iterate_reactor_states) --iterating...
			if not global.iterate_reactor_states then
				global.iterate_reactor_states = next(global.reactors,global.iterate_reactor_states)
			end
			i=i+1
		end
		
	end	-- if reactor_count > 0
	
	-- cooling towers
	if (event.tick-4) % 5 == 0 then
		if not global.iterate_cooling_towers then
			global.iterate_cooling_towers = next(global.towers,global.iterate_cooling_towers)
		elseif not global.towers[global.iterate_cooling_towers] then
			global.iterate_cooling_towers = nil
		end
		
		i = 0
		maxruns = math.floor((table_size(global.towers)+11)/12) --eats 0.0001/tower (all towers per sec, at least 12)
		while i<maxruns and global.iterate_cooling_towers do 
		
			update_cooling_tower(global.iterate_cooling_towers) --update function
			
			global.iterate_cooling_towers = next(global.towers,global.iterate_cooling_towers) --iterating...
			if not global.iterate_cooling_towers then
				global.iterate_cooling_towers = next(global.towers,global.iterate_cooling_towers)
			end
			i=i+1
		end
	end
	
	-- reactor ruins
	if (event.tick-7) % (TICKS_PER_UPDATE*4) == 0 then
		for i,_ in pairs(global.ruins) do
			update_reactor_ruin(i)
		end
		--logging("}")
	end
	
	stats_tick(event)
	light_tick(event)
end)


function update_reactor_temperature(index, update_event)

	-- load the reactor
	local reactor = global.reactors[index]
	local powerusagecooling = POWER_USAGE_COOLING
	local time_passed = math.max(1,update_event.tick - reactor.last_temp_update)
	reactor.last_temp_update = update_event.tick
	local change_mult = CHANGE_MULTIPLIER * (time_passed / 15)
	local reactor_core_temperature = reactor.core.temperature
	local reactor_state = reactor.state
	local powersignal = reactor.signals.parameters["power-output"].count
	local reactor_efficiency = reactor.efficiency
	local reactor_power_energy = reactor.power.energy
	
	--apply efficiency by adding a fuel bonus
	if reactor_efficiency > 0 then
		local fuel_consumption = (powersignal/60*1000000)*(time_passed)*(100/reactor_efficiency)
		local reactor_displayer_burner_remaining_burning_fuel = reactor.displayer.burner.remaining_burning_fuel

		if reactor_displayer_burner_remaining_burning_fuel - fuel_consumption > 0 then
			reactor.displayer.burner.remaining_burning_fuel = reactor_displayer_burner_remaining_burning_fuel - fuel_consumption
		else
			reactor.displayer.burner.remaining_burning_fuel = 0
		end

	else
		--no fuel bonus, efficiency=0 (reactor stopped)
	end	
	
	--apply starting power consumption
	if reactor_state == 1 then
		--apply cooling power consumption
		reactor.power_usage.starting = math.floor(POWER_USAGE_STARTING / 60)
	else
		reactor.power_usage.starting = 0
	end
	
	-- do environment cooling if state is stopped
	if reactor_state == 0 then
		if reactor_core_temperature > 15 then
			--logging("Reactor state is stopped, apply cooling by the environment")
			
			--[[
			local Tmix_env = ((reactor_core_temperature * REACTOR_MASS) + (15 * 10000)) / (REACTOR_MASS + 10000)
			--logging("Tmix_env: " .. Tmix_env)
			local Tdelta_reactor_env = reactor_core_temperature - Tmix_env	
			--logging("Tdelta_reactor_env: " .. Tdelta_reactor_env)
			local Tchange_reactor_env = (Tdelta_reactor_env * change_mult * 0.1)
			--logging("-> Tchange_reactor_env: " .. Tchange_reactor_env)
			if (reactor_core_temperature - Tchange_reactor_env) > 15 then
				reactor.core.temperature = reactor_core_temperature - Tchange_reactor_env
				reactor_core_temperature = reactor_core_temperature - Tchange_reactor_env
			else
				reactor.core.temperature = 15
				reactor_core_temperature = 15
			end
			]]
			
			if reactor_core_temperature > 15.125 then
				reactor_core_temperature = reactor_core_temperature - 0.125 * (time_passed / 15)
			else
				reactor_core_temperature = 15
			end
						
			--logging("Reactor core temperature after environment cooling: " .. reactor_core_temperature)
		end
	end
	
	-- do decay heat effect if state is scramed
	if reactor_state == 3 and settings.global["scram-behaviour"].value == "decay heat (v1.0.x)" then
		reactor_core_temperature = reactor_core_temperature + powersignal/20
	end
	
	reactor.power_usage.cooling = 0 -- supposed to be overwritten
	local cooling_history = reactor.cooling_history
	cooling_history = cooling_history*7/8 --devaluing previous history (only used by graph)
	
	--remove cooling power alert (gfx)
	if game.tick - reactor.cooling_warning_tick >=60  and reactor.cooling_warning and reactor.cooling_warning.valid then
		reactor.cooling_warning.destroy()
	end
 	
	-- check fluid level in eccs and calculate temperature changes
	local fluid = reactor.eccs.fluidbox[1]
	local Tchange_reactor = 0
	local Tchange_fluid = 0
	
	if fluid == nil then
		--do nothing, no coolant
		reactor.signals.parameters["coolant-amount"].count = 0		
		
	else
		--reactor has coolant
		
		local fluid_temperature = fluid.temperature
		local fluid_amount = fluid.amount
		
		reactor.signals.parameters["coolant-amount"].count = fluid_amount
		
		if fluid_amount < 100 then
			--do nothing, not enough coolant

		else
			
			--calculate the mixing temperature with richmann's mixing rule
			local Tmix = ((reactor_core_temperature * REACTOR_MASS) + (fluid_amount * fluid_temperature)) / (REACTOR_MASS + fluid_amount)
			
			-- check which is hotter and cool/heat accordingly
			local Tdelta_reactor = reactor_core_temperature - Tmix
			local Tdelta_fluid = fluid_temperature - Tmix
			
			if Tdelta_reactor > Tdelta_fluid then
				-- reactor is hotter than fluid (that is how it should be)
				
				Tchange_reactor = (Tdelta_reactor * change_mult)
				Tchange_fluid = (Tdelta_fluid * change_mult)

				if fluid_temperature - Tchange_fluid > 100 then
					-- resulting fluid would be too hot (max 100°, set by game)
					
					--reduce both temperature changes by the same factor, so that resulting fluid is = 100°
					efficiency_factor = (100 - fluid_temperature) / (Tdelta_fluid * change_mult * -1)
					Tchange_reactor = (Tchange_reactor * efficiency_factor)
					Tchange_fluid = (Tchange_fluid * efficiency_factor)					

				end			
				
			else
				-- fluid is hotter than reactor (it's possible to heat the reactor with a hot fluid)
				
				Tchange_reactor = (Tdelta_reactor * change_mult)
				Tchange_fluid = (Tdelta_fluid * change_mult)
				
				if reactor_core_temperature - Tchange_reactor > 100 then
					Tchange_reactor = 0
					Tchange_fluid = 0
					--do nothing, reactor is already 100°
					-- this is necessary, because theoretically it would be possible to heat the reactor with steam to 1000°, thus causing the meltdown

				end
				
			end

			
			-- --save the fluid back to the eccs
			-- fluid.temperature = fluid_temperature
			-- fluid.amount = fluid_amount
			-- reactor.eccs.fluidbox[1] = fluid
			
		end -- not enough coolant 
		
		
		--do the actual cooling
		local cooled = true
		if Tchange_reactor ~=0 then
			if settings.global["static-cooling-power-consumption"].value then
				-- static cooling power consumption
				
				if reactor_power_energy < (powerusagecooling * time_passed / 60* settings.global["rr_energy_consumption_multiplier"].value) then
					-- not enough energy - don't cool
					cooled = false
				else
					-- cool/heat the core and the fluid
					reactor_core_temperature = reactor_core_temperature - Tchange_reactor
					fluid_temperature = fluid_temperature - Tchange_fluid
					-- cooling power consumption
					if Tchange_reactor>0.1 then
						reactor.power_usage.cooling = math.floor(powerusagecooling / 60)
					end
					cooling_history = cooling_history + (Tchange_reactor * 20 / 8/ (time_passed/15))
				end
			else
				local max_cooling = reactor_power_energy / (powerusagecooling * time_passed / 60* settings.global["rr_energy_consumption_multiplier"].value)
				local cooling_mult = 1
				if max_cooling < math.abs(Tchange_reactor) then
					cooled = false
					cooling_mult = max_cooling/math.abs(Tchange_reactor)
				end
				cooling_history = cooling_history + (Tchange_reactor * cooling_mult * 20 / 8/ (time_passed/15))
				reactor_core_temperature = reactor_core_temperature - Tchange_reactor * cooling_mult
				--cool the fluid
				fluid_temperature = fluid_temperature - Tchange_fluid * cooling_mult
				
				--cooling power consumption

				--dynamic cooling power consumption
				reactor.power_usage.cooling = math.floor(Tchange_reactor * cooling_mult * powerusagecooling / 60 / (time_passed/15))
				cooling_history = cooling_history + reactor.power_usage.cooling*60/1000000/8* settings.global["rr_energy_consumption_multiplier"].value
	
			end
		
		end
		
		--save the fluid back to the eccs
		fluid.temperature = fluid_temperature
		fluid.amount = fluid_amount
		reactor.eccs.fluidbox[1] = fluid
		
		if not cooled then
			-- core wasn't cooled - show energy warning signal
			if game.tick - reactor.cooling_warning_tick >=120 then
				reactor.cooling_warning=reactor.displayer.surface.create_entity{name="rr-electricity-warning", position = reactor.displayer.position, force = "neutral"}
				reactor.cooling_warning.destructible = false
				reactor.cooling_warning_tick = game.tick
			end
		end
		
	end --empty eccs
	
	
	reactor.cooling_history = cooling_history

	-- update reactor signals
	reactor.signals.parameters["electric-power"].count = (reactor_power_energy/17000000)*100
	
	-- set power usage value of power entity
	reactor.power.power_usage = (reactor.power_usage.starting + reactor.power_usage.cooling + reactor.power_usage.interface) * settings.global["rr_energy_consumption_multiplier"].value
	
	-- start nuclear meltdown
	if reactor_core_temperature >= 1000 and settings.startup["meltdown-mode"].value ~= "no meltdown" then
		--logging("Core temperature > 998°, MELTDOWN")
		global.iterate_reactor_temp = next(global.reactors, global.iterate_reactor_temp)
		global.skip_temp_iteration = true
		-- destroy the reactor core (will trigger meltdown)
		reactor.displayer.damage(1000,game.forces.neutral)
	else
		reactor.core.temperature = reactor_core_temperature
	end

end

function update_reactor_states(index, update_event)
	--logging("---")
	-- load the reactor
	local reactor = global.reactors[index]
	--logging("Updating reactor ID: " .. reactor.id)
	--logging("Reactor core ID: " .. reactor.core_id)
	--logging("Reactor type: ".. reactor.displayer.name)
	--logging("Reactor model: " .. reactor.core.name)
	--logging("Reactor state: " .. reactor.state)
	local running_time = math.ceil((update_event.tick - reactor.state_active_since)/60)
	--logging("-> state active for (s): " .. running_time) 
	
		
	-- get control signals
	--logging("Checking circuit network signals")
	local signal_start = false
	local signal_scram = false
	local green_network = reactor.control.get_circuit_network(defines.wire_type.green)
	if green_network then
		--logging("-> Found green circuit network. Network ID: " .. green_network.network_id)
		if green_network.get_signal(SIGNAL_CONTROL_SCRAM) > 0 then
			signal_scram = true
			--logging("--> found green SCRAM signal")
		elseif green_network.get_signal(SIGNAL_CONTROL_START) > 0 then
			signal_start = true
			--logging("--> found green START signal")
		end

	end
	local red_network = reactor.control.get_circuit_network(defines.wire_type.red)
	if red_network then
		--logging("-> Found red circuit network. Network ID: " .. red_network.network_id)
		if red_network.get_signal(SIGNAL_CONTROL_SCRAM) > 0 then
			signal_scram = true
			--logging("--> found red SCRAM signal")
		elseif red_network.get_signal(SIGNAL_CONTROL_START) > 0 then
			signal_start = true
			--logging("--> found red START signal")
		end
		
	end	
	
	-- check for changed states
	--logging("Checking for changed reactor state")
	local reactor_state = reactor.state
	local state_changed = false
	if reactor_state == 0 then
		
		if reactor.displayer.get_fuel_inventory().is_empty() == false
		  and signal_start == true
		  and reactor.power.energy >= (POWER_USAGE_STARTING * TICKS_PER_UPDATE * 4 / 60* settings.global["rr_energy_consumption_multiplier"].value)
		  and signal_scram == false then
			state_changed = true
			change_reactor_state(1, reactor, update_event)
		end	
		
	elseif reactor_state == 1 then
		
		if signal_scram == true then
			state_changed = true
			change_reactor_state(3, reactor, update_event)
		elseif running_time >= settings.global["reactor-starting-duration"].value then
			state_changed = true
			change_reactor_state(2, reactor, update_event)
		elseif reactor.power.energy < (POWER_USAGE_STARTING * TICKS_PER_UPDATE * 4 / 60* settings.global["rr_energy_consumption_multiplier"].value) then
			--ToDo: show alarm on map?
			game.players[1].print("The starting phase of a nuclear reactor was aborted, because the reactor core didn't get enough electric energy from the grid. The fuel cell is lost.")
			state_changed = true
			change_reactor_state(0, reactor, update_event)
		end
		
	elseif reactor_state == 2 then
		
		if signal_scram == true then
			state_changed = true
			change_reactor_state(3, reactor, update_event)
		elseif reactor.displayer.get_fuel_inventory().is_empty() and reactor.displayer.burner.remaining_burning_fuel == 0 and reactor.displayer.burner.currently_burning == nil then
			state_changed = true
			change_reactor_state(0, reactor, update_event)
		end		
	
	elseif reactor_state == 3 then
		if running_time >= settings.global["reactor-scram-duration"].value then
			state_changed = true
			local usedfuel = reactor.displayer.burner.currently_burning and reactor.displayer.burner.currently_burning.burnt_result.name
			if settings.global["scram-behaviour"].value ~= "stop half-empty" then
				if usedfuel then
					reactor.displayer.get_burnt_result_inventory().insert({name = usedfuel, count = 1})
				end
				reactor.displayer.burner.currently_burning = nil
			end
			change_reactor_state(0, reactor, update_event)			
		elseif reactor.displayer.get_fuel_inventory().is_empty() and reactor.displayer.burner.remaining_burning_fuel == 0 then
			state_changed = true
			change_reactor_state(0, reactor, update_event)
		elseif settings.global["scram-behaviour"].value == "limit to current cell" and reactor.displayer.burner.remaining_burning_fuel < (reactor.signals.parameters["power-output"].count/60*1000000*(300)*(100/reactor.signals.parameters["efficiency"].count)) then --200 ticks at 200 reactors, but lets say 300
			
			local usedfuel = reactor.displayer.burner.currently_burning and reactor.displayer.burner.currently_burning.burnt_result.name
			state_changed = true
			if usedfuel then
				reactor.displayer.get_burnt_result_inventory().insert({name = usedfuel, count = 1})
			end
			reactor.displayer.burner.currently_burning = nil
			change_reactor_state(0, reactor, update_event)
		end
		
	end	
	running_time = math.ceil((update_event.tick - reactor.state_active_since)/60)
	
	if state_changed == false then
		--logging("-> reactor state unchanged")
	else
		reactor_state = reactor.state
	end
	
	--update reactor signals
	if reactor_state  == 1 then
		reactor.signals.parameters["state_starting"].count = settings.global["reactor-starting-duration"].value - running_time
		reactor.signals.parameters["neighbour-bonus"].count = 0
	end
	if reactor_state  == 3 then
		reactor.signals.parameters["state_scramed"].count = settings.global["reactor-scram-duration"].value - running_time
		reactor.signals.parameters["neighbour-bonus"].count = 0
	end	
	if reactor_state  == 0 then
		-- reactor is not running
		reactor.signals.parameters["power-output"].count = 0
		reactor.signals.parameters["efficiency"].count = 0
		reactor.signals.parameters["cell-bonus"].count = 0
		reactor.signals.parameters["neighbour-bonus"].count = 0
	end
	

	-- check reactor and replace it with the appropriate version depending on temperature and connected reactors
	if reactor_state == 1 or reactor_state == 2 or reactor_state == 3 then
		
		--logging("---Updating reactor stats---")
		
		-- check how many running reactors are connected
		local reactor_neighbours = 1
		--logging("Checking running reactor neighbours:")
		local neighbours = 0
		for i,rid in pairs(reactor.connected_neighbours_IDs) do
			----logging("- connected reactor ID: " .. rid)
			neighbours = neighbours + 1
		end
		--logging("- Number of connected reactors: " .. neighbours)		
		
		for i,id in pairs(reactor.connected_neighbours_IDs) do
			--logging("- checking connected reactor ID: " .. id)
			
			if id == reactor.id then
				-- same reactor, do nothing
				--logging("-> this is the current reactor")					
			else
				-- found another reactor, check if it is running
				for i,global_reactor in pairs(global.reactors) do
					if global_reactor.id == id then
						--logging("-> loaded connected reactor ID: " .. global_reactor.id)
						if global_reactor.state == 2 then
							reactor_neighbours = reactor_neighbours +1
							--logging("--> reactor is running, bonus: " .. reactor_neighbours)
						else
							--logging("--> reactor is not running, no bonus")
						end
					end
				end
			end
		end
		--logging("-> Running reactor neighbours: " .. reactor_neighbours)	
		reactor.neighbours = reactor_neighbours
		--reactor.signals.parameters["neighbour-bonus"].count = reactor_neighbours
		
		--load reactor parameters: 
		-- power , efficiency, bonus_cells, (max_power, max_efficiency)
		--logging("Calculating reactor stats:")
		local reactor_parameters
		if settings.global["calculate-stats-function"].value == "ingo's formulas" then
			reactor_parameters = calculate_stats_ingo(reactor,running_time)
		else
			reactor_parameters = calculate_stats_ownly(reactor,running_time)
		end
		-- -> in stats function
		-- if reactor.state  == 1 then
			-- reactor.signals.parameters["state_starting"].count = settings.global["reactor-starting-duration"].value - running_time + 1 --ToDo: starting phase should end, when first fuel cell is half empty
			-- reactor_parameters.power = math.floor(reactor_parameters.power * ((running_time)/settings.global["reactor-starting-duration"].value)^2)
			-- --reactor_parameters.efficiency = reactor_parameters.efficiency
			-- reactor_parameters.bonus_cells = 0
		-- end
		-- if reactor.state  == 3 then
			-- reactor.signals.parameters["state_scramed"].count = settings.global["reactor-scram-duration"].value - running_time + 1
			-- reactor_parameters.power = math.floor(reactor_parameters.power * ((settings.global["reactor-scram-duration"].value - (running_time)/3.5)/settings.global["reactor-scram-duration"].value)^11+0.45)
			-- --reactor_parameters.efficiency = reactor_parameters.efficiency
			-- reactor_parameters.bonus_cells = 0
		-- end	
			
		--logging("-> Temperature="..reactor.core.temperature.." PowerOutput="..reactor_parameters.power.." Efficiency="..math.floor(reactor_parameters.efficiency).." BonusCellAmount: "..reactor_parameters.bonus_cells)
		
		--apply material bonus by adding empty fuel cell
		local burnt_result 
		--logging("Applying empty fuel cell bonus:")
		if reactor.displayer.burner.currently_burning == nil then
			-- burner is empty, can't read fuel type
			-- cell bonus is skipped for now
			-- ToDo: save it in global.reactors and add it during the next update
		else
			--logging("- currently burning: "..reactor.displayer.burner.currently_burning.name)
			if reactor_parameters.bonus_cells == 0 then
				-- do nothing
				-- normal reactor or breeder too cold
				--logging("-> adding nothing, too cold or no breeder reactor")
			else
				-- add bonus to current empty fuel cell amount
				burnt_result = reactor.displayer.burner.currently_burning.burnt_result
				if burnt_result.name == "apm_fuel_cell_mox_used" then
					burnt_result = game.item_prototypes["apm_nuclear_breeder_uranium_inventory_enriched"]
				end
				local burn_duration = ((reactor.displayer.burner.currently_burning.fuel_value/1000000)*(reactor_parameters.efficiency/100))/reactor_parameters.power*15/TICKS_PER_UPDATE -- burn duration in ticks
				local cell_bonus_amount

				if settings.global["calculate-stats-function"].value == "ingo's formulas" then
					--adding bonus cell per time
					cell_bonus_amount = ((reactor_parameters.bonus_cells*TICKS_PER_UPDATE)/900)*BONUS_CELL_MULTIPLIER -- reactor_parameters.bonus_cells=100 means one cell per minute
				else
					--adding bonus per burn duration
					cell_bonus_amount = reactor_parameters.bonus_cells / burn_duration
				end
				
				reactor.bonus_cells[burnt_result.name] = (reactor.bonus_cells[burnt_result.name] or 0) + cell_bonus_amount * (game.tick-reactor.last_states_update) / 60
				--logging("- bonus cell amount: "..cell_bonus_amount)
				
				-- msg("reactor.bonus_cells:     "..reactor.bonus_cells[burnt_result.name])
				-- msg("bonus amount (time):     "..((reactor_parameters.bonus_cells*TICKS_PER_UPDATE)/900)*BONUS_CELL_MULTIPLIER)
				-- msg("")
				-- msg("bonus amount (duration): "..reactor_parameters.bonus_cells / burn_duration)
				-- msg("---")				
				
			end
		end
		
		
		if burnt_result and reactor.bonus_cells[burnt_result.name] and reactor.bonus_cells[burnt_result.name] > 1 then
			-- add used-up-uranium-fuel-cell
			--logging("Inserting used-up-uranium-fuel-cell:")
			--game.players[1].print("bonuscell")
			if not reactor.displayer.get_burnt_result_inventory().is_empty() then
				--burnt fuel inventory not empty
				if reactor.displayer.get_burnt_result_inventory().can_insert{name = burnt_result.name, count = 1} then
					-- same cell
					reactor.displayer.get_burnt_result_inventory().insert({name=burnt_result.name, count=1})
					reactor.bonus_cells[burnt_result.name] = reactor.bonus_cells[burnt_result.name] -1
					--logging("-> inserted")
				else
					--different cell, wait
					--logging("-> can't insert, different used up cell present. waiting...")
				end
			else
				--burnt fuel inventory empty
				reactor.displayer.get_burnt_result_inventory().insert({name=burnt_result.name,count=1})
				reactor.bonus_cells[burnt_result.name] = reactor.bonus_cells[burnt_result.name] -1
				--logging("-> inserted")
			end	
			
		end
		
		
		-- update reactor signals 
		reactor.signals.parameters["power-output"].count = reactor_parameters.power
		reactor.signals.parameters["efficiency"].count = math.floor(reactor_parameters.efficiency)
		reactor.signals.parameters["cell-bonus"].count = reactor_parameters.bonus_cells*100
		reactor.efficiency = reactor_parameters.efficiency
		if reactor_state == 2 or reactor_state == 1 then
			reactor.power_output_last_tick = reactor_parameters.power
		end
		
		
		-- replace reactor with updated level version
		--logging("Replace reactor model:")
		local reactor_to_build = "realistic-reactor-"..math.max(1,reactor_parameters.power)
		--logging("-Reactor to be: "..reactor_to_build)
		--logging("-Current reactor: "..reactor.core.name)
		if reactor.core.name==reactor_to_build then
			--logging("-> Reactor already build.")
		elseif not (reactor_state ==3 and settings.global["scram-behaviour"].value == "decay heat (v1.0.x)") then
			replace_reactor(reactor,reactor_to_build)
		end
		
	
	end
	
	
	-- UPDATE DISPLAYER --
	reactor.displayer.temperature = reactor.core.temperature
	
	reactor.last_states_update = game.tick
end

-- changes reactor state
function change_reactor_state(new_state, reactor, update_event)
	--logging("-> changing reactor state to: " .. new_state)
	reactor.state = new_state
	reactor.state_active_since = update_event.tick
	reactor.lamp.destroy()
	reactor.light.destroy()
	local light_color = "black"
	if new_state == 0 then
		-- set signals
		reactor.signals.parameters["state_stopped"].count = 1
		reactor.signals.parameters["state_starting"].count = 0
		reactor.signals.parameters["state_running"].count = 0
		reactor.signals.parameters["state_scramed"].count = 0
		-- configure reactor
		replace_reactor(reactor,"realistic-reactor-1")
		reactor.displayer.active = false
		reactor.core.active = false
		reactor.displayer.minable = true
	elseif new_state == 1 then
		--set signals
		reactor.signals.parameters["state_stopped"].count = 0
		reactor.signals.parameters["state_starting"].count = 1
		reactor.signals.parameters["state_running"].count = 0
		reactor.signals.parameters["state_scramed"].count = 0	
		-- configure reactor
		reactor.displayer.active = true
		reactor.core.active = true
		--reactor.debug_start_cell = true
		reactor.displayer.minable = false
		light_color = "yellow"
	elseif new_state == 2 then	
		-- set signals
		reactor.signals.parameters["state_stopped"].count = 0
		reactor.signals.parameters["state_starting"].count = 0
		reactor.signals.parameters["state_running"].count = 1
		reactor.signals.parameters["state_scramed"].count = 0
		-- configure reactor
		reactor.displayer.active = true
		reactor.core.active = true
		
		reactor.displayer.minable = false
		light_color = "green"
	elseif new_state == 3 then
		--set signals
		reactor.signals.parameters["state_stopped"].count = 0
		reactor.signals.parameters["state_starting"].count = 0
		reactor.signals.parameters["state_running"].count = 0
		reactor.signals.parameters["state_scramed"].count = 1	
		-- configure reactor
		if settings.global["scram-behaviour"].value == "decay heat (v1.0.x)" then
			reactor.core.active = false
			reactor.displayer.active = false
			if reactor.displayer.burner.currently_burning then
				reactor.displayer.get_burnt_result_inventory().insert({name = reactor.displayer.burner.currently_burning.burnt_result.name, count = 1})
			end
			reactor.displayer.burner.currently_burning = nil
			reactor.displayer.burner.remaining_burning_fuel = 0
		else
			reactor.core.active = true
			reactor.displayer.active = true
		end
		reactor.displayer.minable = false
		light_color = "red"
	end
	reactor.lamp = reactor.core.surface.create_entity{name = "rr-"..light_color.."-lamp", position = {reactor.core.position.x+0.017,reactor.core.position.y+0.88}, force = reactor.core.force.name}
	reactor.light = reactor.core.surface.create_entity{name = "rr-"..light_color.."-light", position = {reactor.core.position.x+0.017,reactor.core.position.y+0.88}, force = reactor.core.force.name}

	--if reactor.displayer.name == "realistic-reactor-breeder" then
	--	reactor.lamp = reactor.core.surface.create_entity{name = "rr-"..light_color.."-lamp", position = {reactor.core.position.x+0.62,reactor.core.position.y+0.6}, force = reactor.core.force.name}
	--	reactor.light = reactor.core.surface.create_entity{name = "rr-"..light_color.."-light", position = {reactor.core.position.x+0.62,reactor.core.position.y+0.6}, force = reactor.core.force.name}
	--else
	--	reactor.lamp = reactor.core.surface.create_entity{name = "rr-"..light_color.."-lamp", position = {reactor.core.position.x-0.62,reactor.core.position.y+0.6}, force = reactor.core.force.name}
	--	reactor.light = reactor.core.surface.create_entity{name = "rr-"..light_color.."-light", position = {reactor.core.position.x-0.62,reactor.core.position.y+0.6}, force = reactor.core.force.name}
	--end
	reactor.lamp.destructible = false
	reactor.light.destructible = false
end

-- replaces the reactor core entity with another one
function replace_reactor(reactor, new_reactor_entity_name)
	local temp = reactor.core.temperature
	--logging("Building reactor model: "..new_reactor_entity_name)
		
	-- get table entry index for reactor to be replaced
	local table_index
	for i,table_reactor in pairs(global.reactors) do
		if table_reactor.id == reactor.id then
			table_index = i
		end
	end
	--logging("- old reactor ID: " .. reactor.id)
	--logging("- old reactor core ID: " .. reactor.core_id)
	
	-- create new reactor core
	new_reactor_core = reactor.core.surface.create_entity
	{
		name = new_reactor_entity_name,
		position = reactor.core.position,
		force = reactor.core.force, 
		create_build_effect_smoke = false		
	}
	--logging("- new reactor core ID: " .. new_reactor_core.unit_number)
	
	-- copy everything from old core to new core 
	new_reactor_core.copy_settings(reactor.core) --(what is this actually copying???)
	new_reactor_core.temperature = temp
	new_reactor_core.destructible = false
	--logging("-> updated temperature: " .. new_reactor_core.temperature)
	-- transfer burner heat and remaining fuel in burner

	--if reactor.state == 0 and not (settings.global["scram-behaviour"].value == "stop half-empty") then
	--	-- do nothing (don't transfer burner heat to a stopped or scramed reactor)
	--	if settings.global["scram-behaviour"].value == "consume additional cell" and reactor.displayer.burner.currently_burning then
	--		reactor.displayer.get_burnt_result_inventory().insert({name = reactor.displayer.burner.currently_burning.burnt_result.name, count = 1})
	--		reactor.displayer.burner.currently_burning = nil
	--	end
    --
	--	--logging("-> burner settings not transferred, state: stopped or scramed")
	--else
	--	-- transfer current burner settings
	--	--if reactor.core.burner.heat > 0 then --not reliable!
	--	if reactor.displayer.burner.remaining_burning_fuel > 0 then
			--new_reactor_core.burner.currently_burning = game.item_prototypes["uranium-fuel-cell"]
			--new_reactor_core.burner.currently_burning = reactor.displayer.burner.currently_burning
			new_reactor_core.burner.currently_burning = "rr-dummy-fuel-cell"
			new_reactor_core.burner.remaining_burning_fuel = 9223372035000000000
			new_reactor_core.burner.heat = reactor.displayer.burner.heat
			--logging("-> updated burner heat: " .. new_reactor_core.burner.heat)
			--new_reactor_core.burner.remaining_burning_fuel = reactor.displayer.burner.remaining_burning_fuel
			--logging("-> updated burner remaining_burning_fuel: " .. new_reactor_core.burner.remaining_burning_fuel)
	--	else
	--		--logging("-> burner settings not transferred, empty")
	--	end			
	--end
	
	new_reactor_core.minable = false -- core should be unminable in any case cause its removed via script

	new_reactor_core.get_fuel_inventory().insert{name="rr-dummy-fuel-cell", count = 50}
	
	

	-- destroy old core
	reactor.core.destroy()
	-- store new core
	reactor.core = new_reactor_core
	--update reactor core id with new core unit_number
	reactor.core_id = new_reactor_core.unit_number
	-- update table entry
	global.reactors[table_index]=reactor
	
	--logging("-> reactor replaced")
	--logging("- new reactor ID: " .. reactor.id)
	--logging("- new reactor core ID: " .. reactor.core_id)
end


function update_cooling_tower(index)
     local tower = global.towers[index]

     -- enable or disable steamer
     if tower.entity.is_crafting() then
        tower.steam.active = true
        -- reset steam puff crafting progress so it never actually finishes
        tower.steam.crafting_progress = 0.1
     else
        tower.steam.active = false
     end

   -- if tower and tower.entity.valid then
    -- -- only show steam puffs if cooling tower is actively working and not backed up
    -- tower.steam.active = tower.entity.is_crafting() and tower.entity.crafting_progress < 1 and tower.name == TOWER_ENTITY_NAME
    -- -- reset steam puff crafting progress so it never actually finishes
    -- tower.steam.crafting_progress = 0.1 
  -- end
end

function update_reactor_ruin(index)
	local ruin = global.ruins[index]
	local surface = ruin.surface
	
	if ruin and ruin.entity.valid and ruin.steam and ruin.steam.valid then
		-- reset steam puff crafting progress so it never actually finishes
		ruin.steam.crafting_progress = 0.1 
	end
end