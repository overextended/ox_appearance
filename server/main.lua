Players = {}
lib.locale()

function SaveAppearance(identifier, appearance)
	local outfitKey = ('%s:appearance'):format(identifier)

	if appearance then
		SetResourceKvp(outfitKey, json.encode(appearance))
	else
		DeleteResourceKvp(outfitKey)
	end
end

exports('save', SaveAppearance)

function LoadAppearance(source, identifier)
	Players[source] = identifier
	local data = GetResourceKvpString(('%s:appearance'):format(identifier))
	return data and json.decode(data) or {}
end

exports('load', LoadAppearance)

function SaveOutfit(identifier, appearance, slot, outfitNames)
	local outfitKey = ('%s:outfit_%s'):format(identifier, slot)

	if appearance then
		SetResourceKvp(outfitKey, json.encode(appearance))
	else
		DeleteResourceKvp(outfitKey)
	end

	SetResourceKvp(('%s:outfits'):format(identifier), json.encode(outfitNames))
end

exports('saveOutfit', SaveOutfit)

function LoadOutfit(identifier, slot)
	local data = GetResourceKvpString(('%s:outfit_%s'):format(identifier, slot))
	return data and json.decode(data) or {}
end

exports('loadOutfit', LoadOutfit)

function OutfitNames(identifier)
	local data = GetResourceKvpString(('%s:outfits'):format(identifier))
	return data and json.decode(data) or {}
end

exports('outfitNames', OutfitNames)

RegisterNetEvent('ox_appearance:save', function(appearance)
	local identifier = Players[source]

	if identifier then
		SaveAppearance(identifier, appearance)
	end
end)

RegisterNetEvent('ox_appearance:saveOutfit', function(appearance, slot, outfitNames)
	local identifier = Players[source]

	if identifier then
		SaveOutfit(identifier, appearance, slot, outfitNames)
	end
end)

RegisterNetEvent('ox_appearance:loadOutfitNames', function()
	local identifier = Players[source]
	TriggerClientEvent('ox_appearance:outfitNames', source, identifier and OutfitNames(identifier) or {})
end)

RegisterNetEvent('ox_appearance:loadOutfit', function(slot)
	local identifier = Players[source]
	TriggerClientEvent('ox_appearance:outfit', source, slot, identifier and LoadOutfit(identifier, slot) or {})
end)

AddEventHandler('playerDropped', function()
	Players[source] = nil
end)

lib.addCommand('skin', {
    help = locale('command_help'),
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = locale('command_help_target'),
	    optional = true
	}
    },
    restricted = 'group.admin'
}, function(source, args, raw)
	if args.target then
		TriggerClientEvent('ox_appearance:triggeredCommand', args.target)
	else
		TriggerClientEvent('ox_appearance:triggeredCommand', source)
	end
end)
