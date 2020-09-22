function register_update_connected_reactors_event(tick)
	--logging("---")
	--logging("Registered event update_connected_reactors on tick: " .. tick + settings.global["neighbour-check-delay"].value)
	--logging("---")
	global.tick_update_connected_reactors = tick + settings.global["neighbour-check-delay"].value
end

script.on_event( defines.events.on_console_chat, function(event)
	if event.message and event.message == "connect reactors" and (not event.player_index or not game.players[event.player_index] or game.players[event.player_index].admin) then
		--logging("---------------------------------------------------------------")
		--logging("Updating connected reactors list (called via console)")
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
end)

-- updates reactor.connected_neighbours_IDs with the IDs of the current connected reactors
function build_connected_reactors_list(reactor)
	-- find reactor neighbours
	--logging("Reactor.id: " .. reactor.id)
	--logging("Reactor.core_id: " .. reactor.core_id)
	--logging("Reactor position. X: " .. reactor.position.x .. " Y: " .. reactor.position.y)
	local surface = reactor.core.surface
	local hp_neighbour_entities_ew
	local hp_neighbour_entities_n
	local table_of_heat_pipes_to_check
	
	-- reset global table
	global.connected_reactors = {}	
	-- reset connected_neighbours_IDs and insert own id
	-- (a reactor is always connected with itself)
	reactor.connected_neighbours_IDs = {}
	table.insert(reactor.connected_neighbours_IDs,reactor.id)	
	
	-- load all heat pipes
	-- table empty check
	if next(global.all_heat_pipes) == nil then
		--logging("-> no heat pipes on map, skipping check")
		--goto end_function
	else
	
		-- find all heat pipes next to reactor
		hp_neighbour_entities_ew = surface.find_entities_filtered{area = {{reactor.position.x-2,reactor.position.y-1},{reactor.position.x+2,reactor.position.y}}, type='heat-pipe'} --east and west
		hp_neighbour_entities_n = surface.find_entities_filtered{area = {{reactor.position.x-1,reactor.position.y-2},{reactor.position.x+1,reactor.position.y}}, type='heat-pipe'} -- north
		table_of_heat_pipes_to_check = union_tables(hp_neighbour_entities_ew,hp_neighbour_entities_n)
		--hp_neighbour_entities = surface.find_entities_filtered{area = {{reactor.position.x-2,reactor.position.y-2},{reactor.position.x+2,reactor.position.y+2}}, type='heat-pipe'} --east and west
		--table_of_heat_pipes_to_check = {}
		--for _, pipe in pairs(hp_neighbour_entities) do
		--	if pipe.position.x==reactor.position.x or pipe.position.y== reactor.position.y then
		--		table.insert(table_of_heat_pipes_to_check,pipe)
		--	end
		--end
		local checked_pipes = {}
		-- loop through all 7 start heat pipes 
		--logging("Checking connected heat pipes")
		if next(table_of_heat_pipes_to_check) == nil then
			--logging("-> no heat pipes connected")
		else
			for i,hp in ipairs(table_of_heat_pipes_to_check) do
				--logging("- checking heat pipe, ID: " .. hp.unit_number .. " X:" .. hp.position.x .. " Y:" .. hp.position.y)
				
				-- load connected reactors
				local connected_reactors = global.all_heat_pipes[hp.surface.name][hp.unit_number][3]
				for i,connected_reactor in pairs(connected_reactors) do
					-- check if connected reactor is already in global list
					local is_in_list = false
					for i,list_reactor in pairs(global.connected_reactors) do
						if connected_reactor.id == list_reactor.id then
							-- reactor is already in list
							is_in_list = true
						end
					end
					-- if not add it to list
					if is_in_list == false then
						table.insert(global.connected_reactors,connected_reactor)
						--logging("--> found NEW connected reactor, ID: " .. connected_reactor.id)
					end
				end			
				
				-- load connected heat pipes
				local connected_heat_pipes = global.all_heat_pipes[hp.surface.name][hp.unit_number][2]
				if hp.name == "rr-underground-heat-pipe" then
					connected_heat_pipes = union_tables(connected_heat_pipes,global.underground_heat_pipes)
				end
				for i,connected_heat_pipe in pairs(connected_heat_pipes) do
					---- check if heat pipe is already in list
					--local is_in_list2 = false
					--for i,list_heat_pipe in pairs(table_of_heat_pipes_to_check) do
					--	if connected_heat_pipe.unit_number == list_heat_pipe.unit_number then
					--		is_in_list2 = true
					--	end
					--end
					---- if not add it to list
					--if is_in_list2 == false then
					if connected_heat_pipe.valid and not checked_pipes[connected_heat_pipe.unit_number] then
						checked_pipes[connected_heat_pipe.unit_number] = true
						table.insert(table_of_heat_pipes_to_check,connected_heat_pipe)
					end
						----logging("--> found NEW connected heat pipe, ID: " .. connected_heat_pipe.unit_number)
					--end
				end
				
						
			end -- for
			
			-- add connected reactors to list
			for _,rea in pairs (global.connected_reactors) do
				rea.connected_neighbours_IDs = {}
				checked_reactors[rea.id] = true
				for i,connected_reactor in pairs(global.connected_reactors) do
					table.insert(rea.connected_neighbours_IDs,connected_reactor.id)
				end
			end
			
			
		end -- no heat pipes connected to reactor
	end -- no heat pipes on map
	
	
	--logging("Connected reactors (including self)")
	for k,rid in pairs(reactor.connected_neighbours_IDs) do
		--logging("- ID: " .. rid)
	end		
	--logging("---")
end

-- returns the connected reactors as array or nil
function get_connected_reactors(heat_pipe)
	local hp = heat_pipe
	local result = {}
	
	for i,reactor in pairs(global.reactors) do
		-- pipes on west reactor side
		if reactor.position.x - 2 == hp.position.x then
			if reactor.position.y == hp.position.y or reactor.position.y - 1 == hp.position.y then
				----logging("--> connected to reactor, ID: " .. reactor.id)
				table.insert(result, reactor)
			end
		end
		-- pipes on east reactor side
		if reactor.position.x + 2 == hp.position.x then
			if reactor.position.y == hp.position.y or reactor.position.y - 1 == hp.position.y then
				----logging("--> connected to reactor, ID: " .. reactor.id)
				table.insert(result, reactor)
			end		
		end		
		-- pipes on north reactor side
		if reactor.position.y - 2 == hp.position.y then
			if reactor.position.x - 1 == hp.position.x
			   or reactor.position.x == hp.position.x
			   or reactor.position.x + 1 == hp.position.x then
					----logging("--> connected to reactor, ID: " .. reactor.id)
					table.insert(result, reactor)
			end
		end		
	end -- for
	
	return result
end

function union_tables(t1, t2)

   for i,v in ipairs(t2) do
      table.insert(t1, v)
   end 

   return t1
end