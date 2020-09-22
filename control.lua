require "scripts.stats"
require "scripts.migration"
require "scripts.formulas"
require "scripts.connect_reactors"
require "scripts.fx"
require "scripts.on_tick"
require "scripts.util"
require "scripts.construct_destruct"

-- VARIABLE DECLARATION
TICKS_PER_UPDATE = 15 
	-- each reactor and cooling tower gets updated once every 15 ticks (60 ticks = 1 s)
CHANGE_MULTIPLIER = 0.2 
	-- used to multiply the temperature change 
	-- CHANGE_MULTIPLIER and TICKS_PER_UPDATE work together and are balanced: 
	-- 0.2 CHANGE_MULTIPLIER = 15 TICKS_PER_UPDATE
REACTOR_MASS = 6000
	-- used to calculate temperature changes when emergency cooling is used
	-- the mass is an estimate best guess based on many tries and errors 
BONUS_CELL_MULTIPLIER = 0.5
	-- multiplier for breeder bonus cell production. 
	-- BONUS_CELL_MULTIPLIER=1 and bonus_cell_Production=100 means 1 additional empty cell per minute
POWER_USAGE_STARTING=3600000 -- 3600 KW
POWER_USAGE_INTERFACE=200000 -- 200 KW
POWER_USAGE_COOLING=1000000 -- 1 MW when reactor was cooled (static) or 1 MW per 20 MW cooling (non-static)
	-- electric power usage of the reactor

-- entity names
REACTOR_ENTITY_NAME = "realistic-reactor-normal"
REACTOR_POWER_NAME = "realistic-reactor-power-normal"
BREEDER_ENTITY_NAME = "realistic-reactor-breeder"
BREEDER_POWER_NAME = "realistic-reactor-power-breeder"
REACTOR_RUIN_NAME = "reactor-ruin"
BREEDER_RUIN_NAME = "breeder-ruin"
SARCOPHAGUS_ENTITY_NAME="reactor-sarcophagus"
INTERFACE_ENTITY_NAME = "realistic-reactor-interface"
BREEDER_INTERFACE_ENTITY_NAME = "realistic-breeder-interface"
BOILER_ENTITY_NAME = "realistic-reactor-eccs"
TOWER_ENTITY_NAME = "rr-cooling-tower"
STEAM_ENTITY_NAME = "rr-cooling-tower-steam"
HEAT_PIPE_ENTITY_NAME = "heat-pipe"
RUIN_SMOKE_NAME = "ruin-smoke"

--signal names
SIGNAL_CORE_TEMP = {type="virtual", name="signal-reactor-core-temp"}
SIGNAL_STATE_STOPPED = {type="virtual", name="signal-state-stopped"}
SIGNAL_STATE_STARTING = {type="virtual", name="signal-state-starting"}
SIGNAL_STATE_RUNNING = {type="virtual", name="signal-state-running"}
SIGNAL_STATE_SCRAMED = {type="virtual", name="signal-state-scramed"}
SIGNAL_CONTROL_START = {type="virtual", name="signal-control-start"}
SIGNAL_CONTROL_SCRAM = {type="virtual", name="signal-control-scram"}
SIGNAL_COOLANT_AMOUNT = {type="virtual", name="signal-coolant-amount"}
--SIGNAL_COOLANT_TEMP = {type="virtual", name="signal-coolant-temperature"}
SIGNAL_URANIUM_FUEL_CELLS = {type="item", name="uranium-fuel-cell"}
SIGNAL_USED_URANIUM_FUEL_CELLS = {type="item", name="used-up-uranium-fuel-cell"}
SIGNAL_REACTOR_POWER_OUTPUT = {type="virtual", name="signal-reactor-power-output"}
SIGNAL_REACTOR_EFFICIENCY = {type="virtual", name="signal-reactor-efficiency"}
SIGNAL_REACTOR_CELL_BONUS = {type="virtual", name="signal-reactor-cell-bonus"}
SIGNAL_REACTOR_ELECTRIC_POWER = {type="virtual", name="signal-reactor-electric-power"}
SIGNAL_NEIGHBOUR_BONUS  = {type="virtual", name="signal-neighbour-bonus"}



-- INITIALIZING AND UPDATING FUNCTIONS

-- mod initialization
script.on_init(function()
	
	global.reactors = global.reactors or {} -- global.reactors stores the reactor and its parts(core, circuit interface, eccs)
	global.towers = global.towers or {} -- global.towers stores the cooling tower and the steam maker entity
	global.connected_reactors = {} -- global.connected_reactors stores values during build_connected_reactors_list
	global.ruins = {} -- global.ruins stores reactor ruins
	global.fallout = {}
	global.falloutclouds = {}
	global.geigers = {}
	global.sarcophagus = {}
	if not game.forces["radioactivity"] then
		game.create_force("radioactivity")
	end
	if not game.forces["radioactivity-strong"] then
		game.create_force("radioactivity-strong")
	end
	global.delayed_fallout={}
	global.tick_delayer = 0
	gui_init()
	
	global.all_heat_pipes = {}
	global.underground_heat_pipes = {}
	for _, surface in pairs(game.surfaces) do
		global.all_heat_pipes[surface.name] = {}
		local heat_pipes = surface.find_entities_filtered{type='heat-pipe'}
		
		for _, hp in pairs (heat_pipes) do
		--function get_connected_heat_pipes(heat_pipe)
			local result = {}	
			if hp.name == "rr-underground-heat-pipe" then
				table.insert(global.underground_heat_pipes, hp)
			end
			for i,heatpipe in pairs(heat_pipes) do
				
				if hp.position.x == heatpipe.position.x then
					if hp.position.y == heatpipe.position.y + 1 or hp.position.y == heatpipe.position.y - 1 then
						----logging("--> connected to heat pipe, ID: " .. heatpipe.unit_number)
						table.insert(result, heatpipe)
					end
				end
				
				if hp.position.y == heatpipe.position.y then
					if hp.position.x == heatpipe.position.x + 1 or hp.position.x == heatpipe.position.x - 1 then
						----logging("--> connected to heat pipe, ID: " .. heatpipe.unit_number)
						table.insert(result, heatpipe)
					end
				end		
				
			end
			global.all_heat_pipes[surface.name][hp.unit_number] = {hp,result,{}}
		end
	end
	
	global.version=10
	
	for _,force in pairs (game.forces) do
		if force.technologies["nuclear-power"].researched then
			force.recipes["realistic-reactor"].enabled = true
			force.recipes["rr-cooling-tower"].enabled = true
			if settings.startup["meltdown-mode"].value == "meltdown with ruin + sarcophagus" then
				force.recipes["reactor-sarcophagus"].enabled = true
			end
		end
		--force.recipes["breeder-reactor"].enabled = true
	end
	--game.write_file("RealisticReactors.log"," ") -- this line cleans the log file on game start

end)

-- registers event to remove a reactor ghost after a meltdown
--function register_remove_reactor_ghost_event(tick,position)
--	global.tick_remove_reactor_ghost = tick + 1
--	global.remove_reactor_ghost_position = position
--end

remote.add_interface("rr-interface", {
    add_heatpipe = function(entity)
        local surroundings = entity.surface.find_entities_filtered{area = {{entity.position.x-1,entity.position.y},{entity.position.x+1,entity.position.y}}, type='heat-pipe'}
		local surroundings2 = entity.surface.find_entities_filtered{area = {{entity.position.x,entity.position.y-1},{entity.position.x,entity.position.y+1}}, type='heat-pipe'}
		surroundings = union_tables(surroundings,surroundings2)
		for key, ent in pairs (surroundings) do
			if ent == entity then
				surroundings[key] = nil
			end
		end
		global.all_heat_pipes[entity.surface.name][entity.unit_number]={entity,surroundings,get_connected_reactors(entity)}
		
		for key, ent in pairs (surroundings) do
			table.insert(global.all_heat_pipes[entity.surface.name][ent.unit_number][2],entity)
		end
		-- register event for updating list of connected reactors
		register_update_connected_reactors_event(game.tick)
		
    end,
	remove_heatpipe = function(entity)
		local surroundings = entity.surface.find_entities_filtered{area = {{entity.position.x-1,entity.position.y},{entity.position.x+1,entity.position.y}}, type='heat-pipe'}
		local surroundings2 = entity.surface.find_entities_filtered{area = {{entity.position.x,entity.position.y-1},{entity.position.x,entity.position.y+1}}, type='heat-pipe'}
		surroundings = union_tables(surroundings,surroundings2)
		for _, ent in pairs (surroundings) do
			if ent ~= entity then
				for key, connected_pipe in pairs(global.all_heat_pipes[entity.surface.name][ent.unit_number][2]) do
					if connected_pipe == entity then
						global.all_heat_pipes[entity.surface.name][ent.unit_number][2][key]=nil
					end
				end
			end
		end
		global.all_heat_pipes[entity.surface.name][entity.unit_number]=nil
		
		-- register event for updating list of connected reactors
		register_update_connected_reactors_event(game.tick)
	end
})

