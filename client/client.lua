local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

-- Variables
local curRanPos
local trader
local isMenuOpen = false
local npcSpawned = false
local menu

local ESXMenu = exports['esx_menu_default']:GetMenu()


function DrawText3D(x,y,z, text) -- some useful function, use it if you want!
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = #(vector3(px,py,pz) - vector3(x,y,z))

    local scale = (1/dist)*2
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov

    if onScreen then
        SetTextScale(0.5,0.5)
        SetTextFont(6)
        SetTextProportional(1)
        -- SetTextScale(0.0, 0.55)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 55)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

function SpawnNPC()
	modelHash = GetHashKey(Config.Trader.NPCModel)

	RequestModel(modelHash)
	
	while not HasModelLoaded(modelHash) do
		Wait(1)
	end

	trader = CreatePed(0, modelHash, curRanPos[1], curRanPos[2], curRanPos[3] - 1, curRanPos[4], false, false)

	Wait(1500)
end

function OpenMenu()
	isMenuOpen = true
	
	ESXMenu.UI.Menu.Open('default', GetCurrentResourceName(), 'trader_choice', {
		title    = "Wandering Trader",
		align    = "bottom-right",
		elements = {
			{label = Config.Trader.MenuText.Buy, value = 'buy'},
			{label = Config.Trader.MenuText.Sell, value = 'sell'}
		}
	}, function(data, menu)

		if data.current.value == 'buy' then
			
			local elements = {}
			
			for i=1, #Config.Trader.NPCItems, 1 do
				local item = Config.Trader.NPCItems[i]

				table.insert(elements, {
					label = item.label .. ' (<span style="color:green">$' .. item.price .. "</span>)",
					labelTrue = item.label,
					item = item.item,
					price = item.price,
					isWeapon = item.isWeapon,
		
					value      = 1,
					type       = 'slider',
					min        = 1,
					max        = string.find(item.item, 'WEAPON_') and 1 or 100
				})
		
			end

			ESXMenu.UI.Menu.Open('default', GetCurrentResourceName(), 'trader_menu', {
				title    = "Wandering Trader",
				align    = "bottom-right",
				elements = elements
			}, function(data2, menu2)
		
				ESXMenu.UI.Menu.Open('default', GetCurrentResourceName(), 'trader_confirm', {
					title    = ('Are you sure you want to buy ' .. 'x' .. data2.current.value .. ' ' .. data2.current.labelTrue .. " ($" .. data2.current.price * data2.current.value .. ")" .. '?'),
					align    = 'bottom-right',
					elements = {
						{label = ('No'), value = 'no'},
						{label = ('Yes'),  value = 'yes'}
				}}, function(data3, menu3)
		
					if data3.current.value == 'yes' then
						TriggerServerEvent('snazz:buyItem', data2.current.item, data2.current.labelTrue, data2.current.price, data2.current.value, data2.current.isWeapon)
					end
		
					menu3.close()
				end, function(data3, menu3)
					menu3.close()
				end)
			end,
			function(data2, menu2)
				menu2.close()
				isMenuOpen = false
			end)
		end

		if data.current.value == 'sell' then
			local elements = {}
			
			for i=1, #Config.Trader.NPCItems, 1 do
				local item = Config.Trader.SellItems[i]

				table.insert(elements, {
					label = item.label .. ' (<span style="color:green">$' .. item.price .. "</span>)",
					labelTrue = item.label,
					item = item.item,
					price = item.price,
					isWeapon = item.isWeapon,
		
					value      = 1,
					type       = 'slider',
					min        = 1,
					max        = string.find(item.item, 'WEAPON_') and 1 or 100
				})
		
			end

			ESXMenu.UI.Menu.Open('default', GetCurrentResourceName(), 'trader_menu', {
				title    = "Wandering Trader",
				align    = "bottom-right",
				elements = elements
			}, function(data4, menu4)
		
				ESXMenu.UI.Menu.Open('default', GetCurrentResourceName(), 'trader_confirm', {
					title    = ('Are you sure you want to buy ' .. 'x' .. data4.current.value .. ' ' .. data4.current.labelTrue .. " ($" .. data4.current.price * data4.current.value .. ")" .. '?'),
					align    = 'bottom-right',
					elements = {
						{label = ('No'), value = 'no'},
						{label = ('Yes'),  value = 'yes'}
				}}, function(data5, menu5)
		
					if data5.current.value == 'yes' then
						TriggerServerEvent('snazz:sellItem', data4.current.item, data4.current.labelTrue, data4.current.price, data4.current.value, data4.current.isWeapon)
					end
		
					menu5.close()
				end, function(data5, menu5)
					menu5.close()
				end)
			end,
			function(data4, menu4)
				menu4.close()
				isMenuOpen = false
			end)
		end
	end,
	function(data, menu)
		menu.close()
		isMenuOpen = false
	end)
end

RegisterNetEvent('snazz:spawnNPC')
AddEventHandler('snazz:spawnNPC', function(location)
	curRanPos = location
	SpawnNPC()

	SetEntityInvincible(trader, true)
	FreezeEntityPosition(trader, true)
	SetBlockingOfNonTemporaryEvents(trader, true)
	DisablePedPainAudio(trader, true)
	TaskStartScenarioInPlace(trader, "WORLD_HUMAN_CLIPBOARD", 0, true)

	npcSpawned = true

	if Config.DebugMode then
		print("[Snazz Support] Client Side: NPC Spawn Event Triggered")
	end
end)

RegisterNetEvent('snazz:deleteNPC')
AddEventHandler('snazz:deleteNPC', function()
	DeleteEntity(trader)
	ESXMenu.UI.Menu.Close('default',GetCurrentResourceName(),'trader_choice')
	ESXMenu.UI.Menu.Close('default',GetCurrentResourceName(),'trader_menu')
	ESXMenu.UI.Menu.Close('default',GetCurrentResourceName(),'trader_confirm')
	npcSpawned = false

	if Config.DebugMode then
		print("[Snazz Support] Client Side: NPC Delete Event Triggered")
	end
end)

-- If near alert
Citizen.CreateThread(function()

	while not npcSpawned do
		Wait(1)
		
		while npcSpawned do
			Wait(1)
	
			local ped = PlayerPedId()
			local pPos = GetEntityCoords(ped)
			local vectFormat = vector3(curRanPos[1], curRanPos[2], curRanPos[3])
			local dist = #(pPos-vectFormat)
			if dist < 20.0 then
				SetTextComponentFormat("STRING")
		
				AddTextComponentString("A trader is nearby!")
				DisplayHelpTextFromStringLabel(0, 0, 1, -1)
			end
		end
	end
end)

-- Key Controls
Citizen.CreateThread(function()
	while not npcSpawned do
		Wait(1)

		while npcSpawned do
			Wait(1)
	
			if not npcSpawned then
				break
			end
	
			local ped = PlayerPedId()
			local pPos = GetEntityCoords(ped)
			local vectFormat = vector3(curRanPos[1], curRanPos[2], curRanPos[3])
			local dist = #(pPos-vectFormat)
			if dist < 3.0 then
				DrawText3D(curRanPos[1], curRanPos[2], curRanPos[3], "Press [E] to trade!")
	
				if not npcSpawned then
					break
				end
	
				if IsControlJustPressed(0,Keys["E"]) then
	
					if Config.DebugMode then
						print("[Snazz Support] Client Side: Press E valid")
					end
	
					if not npcSpawned then
						break
					end
	
					OpenMenu()
				end
			end
		end
	end
end)