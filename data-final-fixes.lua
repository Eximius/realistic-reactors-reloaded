local categories = {
"thorium",
"deuterium",
}


function insert_categories(reactor)
	for _, cat in pairs(categories) do
		if data.raw["fuel-category"][cat] then
			table.insert(reactor.energy_source.fuel_categories,cat)
		end
	end
end



insert_categories(data.raw.reactor["realistic-reactor-breeder"])
insert_categories(data.raw.reactor["realistic-reactor-normal"])

for i=1, 250 do
	insert_categories(data.raw.reactor["realistic-reactor-"..i])
end

require("prototypes.apm_fix")