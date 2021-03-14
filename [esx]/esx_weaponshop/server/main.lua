ESX = nil
local shopItems = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

MySQL.ready(function()

	MySQL.Async.fetchAll('SELECT * FROM weashops', {}, function(result)
		for i=1, #result, 1 do
			if shopItems[result[i].zone] == nil then
				shopItems[result[i].zone] = {}
			end

			table.insert(shopItems[result[i].zone], {
				item  = result[i].item,
				price = result[i].price,
				label = ESX.GetWeaponLabel(result[i].item)
			})
		end

		TriggerClientEvent('esx_weaponshop:sendShop', -1, shopItems)
	end)

end)

ESX.RegisterServerCallback('esx_weaponshop:getShop', function(source, cb)
	cb(shopItems)
end)

RegisterServerEvent('esx_weaponshop:buyLicense')
AddEventHandler('esx_weaponshop:buyLicense', function(target, license)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if xPlayer.getMoney() >= Config.LicensePrice then
        xPlayer.removeMoney(Config.LicensePrice)
        TriggerEvent('esx_license:addLicense', target, license, function()
            TriggerClientEvent('esx:showNotification', _source, 'Wydałeś ~g~licencję na broń')
            TriggerClientEvent('esx:showNotification', target, 'Otrzymałeś ~g~licencję na broń')
        end)
    else
        TriggerClientEvent('esx:showNotification', _source, 'Nie masz wystarczająco pieniędzy ~g~licencja na broń ~w~kosztuje ~g~' .. Config.LicensePrice .. '$')
    end
end)

ESX.RegisterServerCallback('esx_weaponshop:buyWeapon', function(source, cb, weaponName, zone)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local price = GetPrice(weaponName, zone)

	if price == 0 then
		print(('esx_weaponshop: %s attempted to buy a unknown weapon!'):format(xPlayer.identifier))
		cb(false)
	end

	if xPlayer.hasWeapon(weaponName) then
		TriggerClientEvent('esx:showNotification', source, _U('already_owned'))
		cb(false)
	else
		if zone == 'BlackWeashop' then

			if xPlayer.getAccount('black_money').money >= price then
				xPlayer.removeAccountMoney('black_money', price)
				xPlayer.addWeapon(weaponName, 120)

				cb(true)
			else
				TriggerClientEvent('esx:showNotification', source, _U('not_enough_black'))
				cb(false)
			end

		else

			if xPlayer.getMoney() >= price then
				xPlayer.removeMoney(price)
				xPlayer.addWeapon(weaponName, 120)

				cb(true)
			else
				TriggerClientEvent('esx:showNotification', source, _U('not_enough'))
				cb(false)
			end
	
		end
	end
end)

function GetPrice(weaponName, zone)
	local price = MySQL.Sync.fetchScalar('SELECT price FROM weashops WHERE zone = @zone AND item = @item', {
		['@zone'] = zone,
		['@item'] = weaponName
	})

	if price then
		return price
	else
		return 0
	end
end
