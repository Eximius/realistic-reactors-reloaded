function periodic_pollution(entity,mult) --on_tick
	if settings.startup["meltdown-mode"].value == "meltdown with ruin" then
		local healing_mult = 1800 / math.max(1,settings.startup["sarcophagus-duration"].value)
		entity.surface.pollute(entity.position, math.floor(7500*mult*healing_mult)) --0.0003% evo
		--if game.forces["enemy"] then
		--	game.forces["enemy"].evolution_factor=math.min(1,game.forces["enemy"].evolution_factor+0.000026*mult*healing_mult)
		--end
	else
		entity.surface.pollute(entity.position, math.floor(20000*mult)) --0.002% evo
		--if game.forces["enemy"] then
		--	game.forces["enemy"].evolution_factor=math.min(1,game.forces["enemy"].evolution_factor+0.00007*mult)
		--end
	end
end


script.on_event(defines.events.on_trigger_created_entity, function(event)
    local ent = event.entity
	local surface = event.entity.surface.name
	local pos = ent.position
    if ent.name == "RR-uranium-explosion-LUQ" then -- this is the left upper quarter of the explosion graphics
        for i, player in pairs(game.connected_players) do
			if player.surface.name == surface then
				local distance = ((player.position.x-pos.x)^2 + (player.position.y - pos.y)^2)^0.5
				--game.print(123)
				--game.print(distance)
				if distance > 70 then
					if distance < 270 then
						player.play_sound{path = "RR-nuclear-detonation-sound", position = player.position, volume_modifier = ((distance-70)/200)^0.7*0.7}
					else
						player.play_sound{path = "RR-nuclear-detonation-sound", position = player.position, volume_modifier = (270/distance)^0.5*0.7}
					end
				end
            end--player.surface.create_entity({name = "RR-nuclear-detonation-sound", position = player.position})
		end
		if settings.startup["RR-light_fx"].value then
			--local renderFlashForPlayers = {}
			--for i, player in pairs(game.connected_players) do
			flashBase = rendering.draw_light{sprite = "utility/light_medium", scale = 5, intensity = 1, minimum_darkness = 0, 
				target = pos, surface = ent.surface, time_to_live = 300, players = game.connected_players}
			flash = rendering.draw_sprite{sprite = "utility/light_medium", x_scale = 5, y_scale = 5, render_layer = "light-effect", 
				minimum_darkness = 0, tint = {0.95, 0.95, 1, 1}, target = pos, surface = ent.surface, time_to_live = 300, players = game.connected_players}
				local lightGlow = rendering.draw_light{sprite = "utility/light_medium", scale = 50, intensity = 0.4, minimum_darkness = 0, 
				target = pos, surface = ent.surface, color = {1, 0.5, 0.2, 0.1}, time_to_live = 500}	
			local lightBase = rendering.draw_light{sprite = "utility/light_medium", scale = 20, intensity = 1, minimum_darkness = 0, 
				target = pos, surface = ent.surface, time_to_live = 500}
			local lightSurface = rendering.draw_sprite{sprite = "utility/light_medium", x_scale = 20, y_scale = 17, render_layer = "lower-object-above-shadow", 
				minimum_darkness = 0, tint = {0.75, 0.65, 0.6, 0.2}, target = pos, surface = ent.surface, time_to_live = 500}
			local lightObjects = rendering.draw_sprite{sprite = "utility/light_medium", x_scale = 25, y_scale = 21.5, render_layer = "entity-info-icon-above", 
				minimum_darkness = 0, tint = {1, 0.9, 0.5, 0.4}, target = pos, surface = ent.surface, time_to_live = 500}
			local lightCenterGlow = rendering.draw_sprite{sprite = "utility/light_medium", x_scale = 10, y_scale = 8, render_layer = "light-effect", 
				minimum_darkness = 0, tint = {1, 0.5, 0.2, 0.4}, target = pos, surface = ent.surface, time_to_live = 500}
			local effects = {}
			effects.maxDur = 500
			effects.ttl = 500
			effects.tickstart = game.tick
			effects.tickend = game.tick + effects.ttl
			effects.ids = {glow = lightGlow, light = lightBase, surface = lightSurface, objects = lightObjects, center = lightCenterGlow}

				
			effects.flashDuration = 5
			effects.flashMaxScale = 100
			effects.flashTransition = 300
			effects.flashTransitionScale = 20
			effects.flashTransitionStartFadeOut = 150
			local flashTransitionColorStart = {0.95, 0.95, 1, 1}
			local flashTransitionColorEnd = {1, 0.5, 0.2, 0.4}
			local flashTransitionTicks = effects.flashDuration - effects.flashTransitionStartFadeOut
			local flashTransitionColorStep = {
				(flashTransitionColorStart[1] - flashTransitionColorEnd[1]) / flashTransitionTicks,  
				(flashTransitionColorStart[2] - flashTransitionColorEnd[2]) / flashTransitionTicks,
				(flashTransitionColorStart[3] - flashTransitionColorEnd[3]) / flashTransitionTicks,
				(flashTransitionColorStart[4] - flashTransitionColorEnd[4]) / flashTransitionTicks}			
			effects.flashTransitionColorStep = flashTransitionColorStep
			effects.flashTransitionColorEnd = flashTransitionColorEnd
			effects.ids.flashBase = flashBase
			effects.ids.flash = flash

			
			if global.lightEffects == nil then
				global.lightEffects = {}
			end
			
			table.insert(global.lightEffects, effects)
		end
	end
end)

-- radiation damage function
function radio_damage(event,entity)
	if entity.type == "character" then
		--sound
		if entity.player then
			if 	global.geigers[entity.player.index] == nil or 
				global.geigers[entity.player.index]+3 < event.tick then
				
				local rnd = math.floor(math.random()*1.99)
				global.geigers[entity.player.index] = event.tick
				
				entity.player.play_sound({path = "RR-geiger-"..rnd, volume_modifier =0.7})
				
			end
		end
		--damage
		local resist = 1 --resistances
		if entity.grid then
			if entity.grid.max_shield > 0 then
				resist = 1 - math.min(35,entity.grid.shield)/35
				entity.damage(math.min(entity.grid.shield, 35)+0.0001,game.forces.neutral,"electric")
			else
				entity.damage(0.0001,game.forces.neutral,"electric")
			end
			if entity.grid.shield >0 then return end
			if entity.grid.prototype.name == "radiation-suit-grid" then
				resist = resist*0.1
			elseif entity.grid.prototype.name == "small-equipment-grid" then
				resist = resist*0.85
			elseif entity.grid.prototype.name == "medium-equipment-grid" then
				resist = resist*0.7
			else
				resist = resist*0.55
			end
		else
			entity.damage(0.0001,game.forces.neutral,"electric")
		end
		if event.force == "radioactivity" then
			entity.health = entity.health -0.25*resist
			entity.damage(0.13*resist,game.forces.neutral,"electric")
		else
			entity.health = entity.health -0.4*resist
			entity.damage(0.2*resist,game.forces.neutral,"electric")
		end
		if entity.health < 1 then
			entity.die(event.force)
		end
	else
		if event.force == "radioactivity" then
			entity.health = entity.health -0.4
		else
			entity.health = entity.health -0.6
		end
		if entity.health < 1 then
			entity.die(event.force)
		end
	
	end
end


-- radiation damage (event)
script.on_event(defines.events.on_script_trigger_effect,function(event)
	local effect_id = event.effect_id
	if (effect_id == "radiation-damage" or effect_id == "radiation-damage-strong") and event.target_entity then
		if effect_id == "radiation-damage" then
			event.force = "radioactivity"
		else
			event.force = "radioactivity-strong"
		end
		local entity = event.target_entity
		if entity.type == "car" then
		
			local passenger = entity.get_passenger()	--passenger
			if passenger and passenger.type == "character" and passenger.has_flag("breaths-air") then
				radio_damage(event,passenger)
			end
			
			local passenger = entity.get_driver()		--driver
			if passenger and passenger.name == "character" and passenger.has_flag("breaths-air") then
				radio_damage(event, passenger)
			end
			
		elseif entity.type == "character" and entity.has_flag("breaths-air") then
			radio_damage(event, entity)
			
		elseif entity.has_flag("breaths-air") then
			radio_damage(event, entity)
		end
	end
end)


--fallout stuff...
function circular_radiation(surface,position,min_radius,size)
	local step = 3.2
	if min_radius == 0 then
		surface.create_entity({
			name="permanent-radiation",
			position={position.x,position.y},
			force = "radioactivity"
		})
		surface.create_entity({
			name="permanent-radiation",
			position={position.x,position.y},
			force = "radioactivity"
		})
		min_radius = min_radius + 1
	end
	for spread=min_radius, size do	--each run adds another layer
		local x =position.x-step/2*spread
		local y =position.y-step/2*spread
		for i=1, spread*4 do
			
			surface.create_entity({
				name="permanent-radiation",
				position={x,y},
				force = "radioactivity"
			})
			if i <= spread then
				x=x+step
				y=y-step*0.7*(1- i / ((spread+1)/2)) --almost perfect circle
	
			elseif i <= spread * 2 then
				y=y+step
				x=x+step*0.7*(1- (i-spread) / ((spread+1)/2))
	
			elseif i <= spread * 3 then
				x=x-step
				y=y+step*0.7* (1- (i-spread*2) / ((spread+1)/2))
	
			elseif i <= spread * 4 then
				y=y-step
				x=x-step*0.7*(1- (i-spread*3) / ((spread+1)/2))
	
			end
		end	
	end
end

function light_tick(event)
		if global.lightEffects == nil then
			global.lightEffects = {}
		end
		--if game.tick%300 == 0 then
		--	game.print(#global.lightEffects)
		--end
		if global.lightEffects ~= nil then
			for i, effects in pairs(global.lightEffects) do
				effects.ttl = effects.ttl - 1
				if effects.ttl <= 0 then 
					global.lightEffects[i] = nil
				else
					local maxDur = effects.maxDur
					if effects.ids.flash ~= nil then
						local fs = 0
						local ftProgress = 0
						
						local flashBase = effects.ids.flashBase
						local flash = effects.ids.flash
						
						if (maxDur - effects.ttl) < effects.flashDuration then
							fs = ((maxDur - effects.ttl) / effects.flashDuration) * effects.flashMaxScale
							
							rendering.set_scale(flashBase, fs)
							rendering.set_x_scale(flash, fs)
							rendering.set_y_scale(flash, fs)
							
						elseif (maxDur - effects.ttl) < effects.flashTransition then
							fs = effects.flashMaxScale - ((effects.flashMaxScale - effects.flashTransitionScale) / (effects.flashTransition - effects.flashDuration)) * (maxDur - effects.ttl - effects.flashDuration)
							ftProgress = (effects.flashMaxScale - fs) / effects.flashTransitionScale
							
							rendering.set_x_scale(flash, fs)
							rendering.set_y_scale(flash, fs)
							rendering.set_intensity(flashBase, 1 - ftProgress)
							
							if (maxDur - effects.ttl) < effects.flashTransitionStartFadeOut then
								local fctProgress = (maxDur - effects.ttl - effects.flashDuration) / (effects.flashTransitionStartFadeOut - effects.flashDuration) 
								
								local currentColor = rendering.get_color(flash)
								
								rendering.set_color(flash, {currentColor.r + effects.flashTransitionColorStep[1], currentColor.g + effects.flashTransitionColorStep[2], currentColor.b + effects.flashTransitionColorStep[3], currentColor.a + effects.flashTransitionColorStep[4]})
							else
								local ffaProgress = 1 - ((maxDur - effects.ttl - effects.flashTransitionStartFadeOut) / (effects.flashTransition - effects.flashTransitionStartFadeOut))
								
								rendering.set_color(flash, {effects.flashTransitionColorEnd[1] * ffaProgress, effects.flashTransitionColorEnd[2] * ffaProgress, effects.flashTransitionColorEnd[3] * ffaProgress, effects.flashTransitionColorEnd[4] * ffaProgress})
							end
						end
					end
					
					local p0 = math.min(math.max(0, (effects.ttl - 100)) / 400, 1)
					local p02 = math.min(math.max(0, (effects.ttl - 200)) / 300, 1)
					local p03 = math.min(math.max(0, (effects.ttl - 200)) / 300, 1)
					local p1 = math.min(effects.ttl / 400, 1)
					local p2 = math.min(effects.ttl / 300, 1)
					local p3 = math.min(effects.ttl / 240, 1)
					local p4 = math.min(effects.ttl / 180, 1)
					local a1 = math.max((maxDur - effects.ttl) / 250, 1)
					local a2 = math.min((maxDur - effects.ttl) / 120, 1)
					local a3 = math.min((maxDur / effects.ttl) * 5, 2)
					
					
					local glow = effects.ids.glow
					local light = effects.ids.light
					local surface = effects.ids.surface
					local objects = effects.ids.objects
					local center = effects.ids.center
					
					rendering.set_intensity(glow, p2 * 0.4)
					rendering.set_intensity(light, a1 * p3 * 1)
					rendering.set_scale(light, a3 * p3 * 20)
					rendering.set_color(light, {1, math.min(a3/2 * p4, 1), math.min(a3/2 * p4, 1), 1})
					
					rendering.set_color(surface, {p02 * 0.75, p02 * 0.65, p02 * 0.6, p02 * 0.2})
					rendering.set_x_scale(surface, p1 * 20)
					rendering.set_y_scale(surface, p1 * 17)
					
					rendering.set_color(objects, {p02 * 1, p02 * 0.9, p02 * 0.5, p02 * 0.4})
					rendering.set_x_scale(objects, p2 * 25)
					rendering.set_y_scale(objects, p2 * 21.5)
					
					rendering.set_color(center, {p03 * a2 * 1, p03 * a2 * 0.3, p03 * a2 * 0.1, p03 * a2 * 0.4})
					rendering.set_x_scale(center, p1 * 10)
					rendering.set_y_scale(center, p1 * 8)
				end
			end
		end
end