local outfitNames
local outfits = {}

local function getOutfitNames()
	outfitNames = nil
	TriggerServerEvent('ox_appearance:loadOutfitNames')
	repeat Wait(0) until outfitNames
end

local function getOutfit(slot)
	if not outfits[slot] then
		TriggerServerEvent('ox_appearance:loadOutfit', slot)
		repeat Wait(0) until outfits[slot]
	end

	return outfits[slot]
end

if ESX then
	RegisterNetEvent('esx:playerLoaded', function()
		outfitNames = nil
		table.wipe(outfits)
	end)
end

RegisterNetEvent('ox_appearance:outfitNames', function(data)
	outfitNames = data
end)

RegisterNetEvent('ox_appearance:outfit', function(slot, data)
	outfits[slot] = data
end)

RegisterCommand('outfits', function(source, args, raw)
	if not outfitNames then
		getOutfitNames()
	end
	print(json.encode(outfitNames, {indent=true}))
end)

RegisterCommand('saveoutfit', function(source, args, raw)
	local slot = tonumber(args[1])

	if type(slot) == 'number' then
		if not outfitNames then
			getOutfitNames()
		end

		local appearance = exports['fivem-appearance']:getPedAppearance(cache.ped)
		outfitNames[slot] = args[2]
		outfits[slot] = appearance

		TriggerServerEvent('ox_appearance:saveOutfit', appearance, slot, outfitNames)
	end
end)

RegisterCommand('outfit', function(source, args, raw)
	local slot = tonumber(args[1])

	if type(slot) == 'number' then
		local appearance = getOutfit(slot)

		if not appearance.model then appearance.model = 'mp_m_freemode_01' end
		exports['fivem-appearance']:setPlayerAppearance(appearance)
	end
end)

RegisterCommand('wardrobe', function(source, args, raw)
    lib.registerContext({
        id = 'save_change',
        title = 'Outfit Menu',
        options = {
        {
            title = "Save",
            description = "save new outfit",
            arrow = true,
            event = 'ox_appearance:saveOut',
            args = {slot= "new", name= ""}
        },
        {
            title = "Outfits",
            event = 'ox_appearance:wardrobe',
        }}
    })
    lib.showContext('save_change')
end)

RegisterNetEvent('ox_appearance:wardrobe', function()
    if not outfitNames then
        getOutfitNames()
    end
    options = {}
    for k, v in pairs(outfitNames) do
        options[v] = {}
        options[v].event = 'ox_appearance:setOutfit'
        options[v].args = {slot = k, name = v}
    end
    
    lib.registerContext({
        id = 'wardrobe_menu',
        menu = 'save_change',
        title = 'Guardaroba',
        options = options
    })

    lib.showContext('wardrobe_menu')
end)

function getTableSize(t)
    local count = 0
    for _, __ in pairs(t) do
        count = count + 1
    end
    return count
end

RegisterNetEvent('ox_appearance:setOutfit', function(data)
	lib.registerContext({
		id = 'replace_use',
		title = 'Replace',
		menu = 'wardrobe_menu',
		options = {
			['Use'] = {
				event = 'ox_appearance:use',
				args = data
				
			},
			['Replace'] = {
				description =  "Replace outfit: "..data.name,
				event = 'ox_appearance:saveOut',
				args = data
				
			}
		}
	})
	lib.showContext('replace_use')

end)

RegisterNetEvent('ox_appearance:saveOut', function(data)
	if not outfitNames then
		getOutfitNames()
	end
	if data.slot == "new" then
		data.slot = getTableSize(outfitNames) + 1
		local name = lib.inputDialog('New name', {'Insert Name'})
		if name then
			local appearance = exports['fivem-appearance']:getPedAppearance(cache.ped)
			outfitNames[data.slot] = name[1]
			outfits[data.slot] = appearance

			TriggerServerEvent('ox_appearance:saveOutfit', appearance, data.slot, outfitNames)
		end
	else
		local input = lib.inputDialog('Confirm saving', {'Insert 1234'})

		if input then
			local pin = tonumber(input[1])
			if pin == 1234 then
				Wait(200)
				local name = lib.inputDialog('New name', {'Rename'})
				if name then
					local appearance = exports['fivem-appearance']:getPedAppearance(cache.ped)
					outfitNames[data.slot] = name[1]
					outfits[data.slot] = appearance
			
					TriggerServerEvent('ox_appearance:saveOutfit', appearance, data.slot, outfitNames)
				end
			end
		end
	end
end)

RegisterNetEvent('ox_appearance:use', function(data)
    local slot = data.slot
    local appearance = getOutfit(slot)

    if not appearance.model then appearance.model = 'mp_m_freemode_01' end
    if lib.progressCircle({
        duration = 3000,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
        },
        anim = {
            dict = 'missmic4',
            clip = 'michael_tux_fidget' 
        },
    }) then 
		exports['fivem-appearance']:setPlayerAppearance(appearance)
    	TriggerServerEvent('esx_skin:save', appearance)
    else 
        print('Do stuff when cancelled') 
    end    
end)