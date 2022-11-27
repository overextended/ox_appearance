if GetResourceState('es_extended'):find('start') then
	ESX = true
	local exp = exports['fivem-appearance']

	AddEventHandler('skinchanger:loadDefaultModel', function(male, cb)
		exp:setPlayerModel(male and 'mp_m_freemode_01' or 'mp_f_freemode_01')
		if cb then cb() end
	end)

	AddEventHandler('skinchanger:loadSkin', function(skin, cb)
        if not skin then skin = {} end
		if not skin.model then skin.model = 'mp_m_freemode_01' end

		exp:setPlayerAppearance(skin)

		if cb then cb() end
	end)

	RegisterNetEvent('esx_skin:openSaveableMenu', function(submitCb, cancelCb)
		exp:startPlayerCustomization(function (appearance)
			if (appearance) then
				TriggerServerEvent('esx_skin:save', appearance)
				if submitCb then submitCb() end
			else
				if cancelCb then cancelCb() end
			end
		end, {
			ped = true,
			headBlend = true,
			faceFeatures = true,
			headOverlays = true,
			components = true,
			props = true,
			tattoos = true
		})
	end)

	AddEventHandler('skinchanger:getSkin', function(cb)
		cb(exp:getPedAppearance(cache.ped))
	end)
end