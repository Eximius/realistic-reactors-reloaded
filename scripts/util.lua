function dbg (str)
	if not global.dbg then global.dbg = 1 end
		if type(str) ~= "number" and type(str) ~= "string" then
		if str == true then 
			str = "true" 
		elseif str == false then 
			str = "false" 
		else
			str = type(str)
		end
	end
	game.players[1].print(global.dbg.."/"..game.tick..": "..str)
	global.dbg = global.dbg+1
end

function msg(s)
	game.print(s)
	--for _, player in pairs(game.players) do
	--	if player.connected then
	--		player.print(s)
	--	end
	--end
end

-- function logging(message)
	-- game.write_file("RealisticReactors.log","\r\n[" .. game.tick .. "] " .. message,true)
-- end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function compare_tables(o1, o2, ignore_mt)
    if o1 == o2 then return true end
    local o1Type = type(o1)
    local o2Type = type(o2)
    if o1Type ~= o2Type then return false end
    if o1Type ~= 'table' then return false end

    if not ignore_mt then
        local mt1 = getmetatable(o1)
        if mt1 and mt1.__eq then
            --compare using built in method
            return o1 == o2
        end
    end

    local keySet = {}

    for key1, value1 in pairs(o1) do
        local value2 = o2[key1]
        if value2 == nil or compare_tables(value1, value2, ignore_mt) == false then
            return false
        end
        keySet[key1] = true
    end

    for key2, _ in pairs(o2) do
        if not keySet[key2] then return false end
    end
    return true
end