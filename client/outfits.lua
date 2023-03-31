lib.locale()

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

local function getTableSize(t)
    local count = 0
    for _, __ in pairs(t) do
        count = count + 1
    end
    return count
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

RegisterNetEvent('ox_appearance:wardrobe', function()
    if not outfitNames then getOutfitNames() end

    options = {}

    for k, v in pairs(outfitNames) do
        options[v] = {}
        options[v].event = 'ox_appearance:setOutfit'
        options[v].args = {slot = k, name = v}
    end

    lib.registerContext({
        id = 'wardrobe_menu',
        menu = 'save_change',
        title = locale('wardrobe'),
        options = options
    })

    lib.showContext('wardrobe_menu')
end)

AddEventHandler('ox_appearance:setOutfit', function(data)
	lib.registerContext({
		id = 'set_outfit',
		title = data.name,
		menu = 'wardrobe_menu',
		options = {
			{
				title = locale('wear', data.name),
				event = 'ox_appearance:use',
				args = data

			},
			{
				title = locale('update', data.name),
				event = 'ox_appearance:saveOutfit',
				args = data

			},
			{
				title = locale('delete', data.name),
				event = 'ox_appearance:deleteOutfit',
				args = data
			}
		}
	})

	lib.showContext('set_outfit')
end)

AddEventHandler('ox_appearance:saveOutfit', function(data)
	if not outfitNames then getOutfitNames() end

	if data.slot == 'new' then
		data.slot = getTableSize(outfitNames) + 1
		local name = lib.inputDialog(locale('new_outfit'), {locale('outfit_name')})

		if name then
			local appearance = exports['fivem-appearance']:getPedAppearance(cache.ped)
			outfitNames[data.slot] = name[1]
			outfits[data.slot] = appearance

			TriggerServerEvent('ox_appearance:saveOutfit', appearance, data.slot, outfitNames)
		end
	else
		---@type string[]?
		local input = lib.inputDialog(locale('update', data.name), {
			{ type = 'input', label = locale('outfit_name') }
		})

		if input then
			if input[1]:len() < 1 then
				return lib.notify({ type = 'error', description = locale('invalid_name') })
			end

			local appearance = exports['fivem-appearance']:getPedAppearance(cache.ped)
			outfitNames[data.slot] = input[1] or data.name
			outfits[data.slot] = appearance

			TriggerServerEvent('ox_appearance:saveOutfit', appearance, data.slot, outfitNames)
		end
	end

	lib.showContext('save_change')
end)

AddEventHandler('ox_appearance:deleteOutfit', function(data)
	if not outfitNames then getOutfitNames() end

	local alert = lib.alertDialog({
		header = locale('delete', data.name),
		centered = true,
		cancel = true
	})

	if alert == 'confirm' then
		outfitNames[data.slot] = nil
		outfits[data.slot] = nil

		TriggerServerEvent('ox_appearance:saveOutfit', nil, data.slot, outfitNames)
	end

	lib.showContext('save_change')
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

    	if ESX then
			TriggerServerEvent('esx_skin:save', appearance)
		else
			TriggerServerEvent('ox_appearance:save', appearance)
		end
    end
end)

if GetConvarInt("ox_appearance:disable_commands", 0) == 0 then
	RegisterCommand('saveoutfit', function(source, args, raw)
		local slot = tonumber(args[1])

		if type(slot) == 'number' then
			if not outfitNames then getOutfitNames() end

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

	RegisterCommand('outfits', function(source, args, raw)
		lib.showContext('save_change')
	end)
end

lib.registerContext({
	id = 'save_change',
	title = locale('outfits'),
	options = {
		{
			title = locale('wardrobe'),
			event = 'ox_appearance:wardrobe',
		},
		{
			title = locale('save_outfit'),
			arrow = true,
			event = 'ox_appearance:saveOutfit',
			args = {slot = 'new', name = ''}
		},
	}
})

RegisterNetEvent('ox_appearance:triggeredCommand', function()
	local config = {
		ped = true,
		headBlend = true,
		faceFeatures = true,
		headOverlays = true,
		components = true,
		props = true,
		allowExit = true,
		tattoos = true
	  }
	
	  exports['fivem-appearance']:startPlayerCustomization(function (appearance)
		if (appearance) then
			if ESX then
				TriggerServerEvent('esx_skin:save', appearance)
			else
				TriggerServerEvent('ox_appearance:save', appearance)
			end
		end
	  end, config)
end)
