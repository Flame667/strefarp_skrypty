local guiEnabled = false
local myIdentity = {}
local myIdentifiers = {}
local hasIdentity = false
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function EnableGui(enable)
	SetNuiFocus(enable)
	guiEnabled = enable

	SendNUIMessage({
		type = "enableui",
		enable = enable
	})
end

RegisterNetEvent("esx_identity:showRegisterIdentity")
AddEventHandler("esx_identity:showRegisterIdentity", function()
	EnableGui(true)
end)

RegisterNetEvent("esx_identity:identityCheck")
AddEventHandler("esx_identity:identityCheck", function(identityCheck)
	hasIdentity = identityCheck
end)

RegisterNetEvent("esx_identity:saveID")
AddEventHandler("esx_identity:saveID", function(data)
	myIdentifiers = data
end)

RegisterNUICallback('escape', function(data, cb)
	if hasIdentity == true then
		EnableGui(false)
	else
		TriggerEvent("chatMessage", "^1[IDENTITY]", {255, 255, 0}, "You must create your first character in order to play.")
	end
end)

RegisterNUICallback('register', function(data, cb)
	local reason = ""
	myIdentity = data
	for theData, value in pairs(myIdentity) do
		if theData == "firstname" or theData == "lastname" then
			reason = verifyName(value)

			if reason ~= "" then
				break
			end
		elseif theData == "dateofbirth" then
			if value == "invalid" then
				reason = "Invalid date of birth!"
				break
			end
		elseif theData == "height" then
			local height = tonumber(value)
			if height then
				if height > 210 or height < 120 then
					reason = "Unacceptable player height!"
					break
				end
			else
				reason = "Unacceptable player height!"
				break
			end
		end
	end

	if reason == "" then
		TriggerServerEvent('esx_identity:setIdentity', data, myIdentifiers)
		EnableGui(false)
		Citizen.Wait(500)
		TriggerEvent('esx_skin:openSaveableMenu', myIdentifiers.id)
	else
		ESX.ShowNotification(reason)
	end
end)

Citizen.CreateThread(function()
	while true do
		if guiEnabled then
			DisableControlAction(0, 1,   true) -- LookLeftRight
			DisableControlAction(0, 2,   true) -- LookUpDown
			DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
			DisableControlAction(0, 142, true) -- MeleeAttackAlternate
			DisableControlAction(0, 30,  true) -- MoveLeftRight
			DisableControlAction(0, 31,  true) -- MoveUpDown
			DisableControlAction(0, 21,  true) -- disable sprint
			DisableControlAction(0, 24,  true) -- disable attack
			DisableControlAction(0, 25,  true) -- disable aim
			DisableControlAction(0, 47,  true) -- disable weapon
			DisableControlAction(0, 58,  true) -- disable weapon
			DisableControlAction(0, 263, true) -- disable melee
			DisableControlAction(0, 264, true) -- disable melee
			DisableControlAction(0, 257, true) -- disable melee
			DisableControlAction(0, 140, true) -- disable melee
			DisableControlAction(0, 141, true) -- disable melee
			DisableControlAction(0, 143, true) -- disable melee
			DisableControlAction(0, 75,  true) -- disable exit vehicle
			DisableControlAction(27, 75, true) -- disable exit vehicle

			if IsDisabledControlJustReleased(0, 142) then -- MeleeAttackAlternate
				SendNUIMessage({
					type = "click"
				})
			end
		end
		Citizen.Wait(10)
	end
end)

function verifyName(name)
	-- Don't allow short user names
	local nameLength = string.len(name)
	if nameLength > 15 or nameLength < 3 then
		print('Jeden lub oba z członów twojego nazwiska ma niepoprawną długość. (Minimum 3, Maximum: 15)')
	end

	-- Don't allow special characters (doesn't always work)
	local count = 0
	for i in name:gmatch('[abcdefghijklmnopqrstuvwxyzåäöABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖ9óźńćż -]') do
		count = count + 1
	end
	if count ~= nameLength then
		print('Jeden lub oba z członów twojego nazwiska zawierają zakazane znaki. (Wykrzyknii, procenty, podłogi itp.)')
	end

	-- Does the player carry a first and last name?
	--
	-- Example:
	-- Allowed:     'Bob Joe'
	-- Not allowed: 'Bob'
	-- Not allowed: 'Bob joe'
	local spacesInName    = 0
	local spacesWithUpper = 0
	for word in string.gmatch(name, '%S+') do

		if string.match(word, '%u') then
			spacesWithUpper = spacesWithUpper + 1
		end

		spacesInName = spacesInName + 1
	end

	if spacesInName > 1 then
		print('Jeden lub oba z członów twojego nazwiska posiadają dodatkowe spacje. Jest to zakazane.')
	end

	if spacesWithUpper ~= spacesInName then
		print('Jeden lub oba z członów twojego nazwiska nie zaczynają się z dużej litery. Popraw to!')
	end

	return ''
end
