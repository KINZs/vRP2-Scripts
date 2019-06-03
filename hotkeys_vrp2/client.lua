-- GLOBAL VARIABLES
handsup = false
crouched = false
pointing = false
engine = true
called = 0



local HotKeys = class("HotKeys", vRP.Extension)

function HotKeys:__construct()
    vRP.Extension.__construct(self)

-- MAIN THREAD
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		for k,v in pairs(hotkeys) do
		  if IsControlJustPressed(v.group, k) or IsDisabledControlJustPressed(v.group, k) then
		    v.pressed()
		  end

		  if IsControlJustReleased(v.group, k) or IsDisabledControlJustReleased(v.group, k) then
		    v.released()
		  end
		end
	end
end)


-- OTHER THREADS
-- THIS IS FOR KNEEL
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsEntityPlayingAnim(GetPlayerPed(PlayerId()), "random@arrests@busted", "idle_a", 3) then
            DisableControlAction(1, 140, true)
            DisableControlAction(1, 141, true)
            DisableControlAction(1, 142, true)
            DisableControlAction(0,21,true)
        end
    end
end)

-- THIS IS FOR CROUCH
Citizen.CreateThread(function()
  while true do 
    Citizen.Wait(0)
    if DoesEntityExist(GetPlayerPed(-1)) and not IsEntityDead(GetPlayerPed(-1)) then 
      DisableControlAction(0,36,true) -- INPUT_DUCK   
    end 
  end
end)

-- THIS IS FOR HANDSUP
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    if handsup then
      SetPedStealthMovement(GetPlayerPed(-1),true,"")
      DisableControlAction(0,21,true) -- disable sprint
      DisableControlAction(0,24,true) -- disable attack
      DisableControlAction(0,25,true) -- disable aim
      DisableControlAction(0,47,true) -- disable weapon
      DisableControlAction(0,58,true) -- disable weapon
      DisableControlAction(0,71,true) -- veh forward
      DisableControlAction(0,72,true) -- veh backwards
      DisableControlAction(0,63,true) -- veh turn left
      DisableControlAction(0,64,true) -- veh turn right
      DisableControlAction(0,263,true) -- disable melee
      DisableControlAction(0,264,true) -- disable melee
      DisableControlAction(0,257,true) -- disable melee
      DisableControlAction(0,140,true) -- disable melee
      DisableControlAction(0,141,true) -- disable melee
      DisableControlAction(0,142,true) -- disable melee
      DisableControlAction(0,143,true) -- disable melee
      --DisableControlAction(0,75,true) -- disable exit vehicle
      --DisableControlAction(27,75,true) -- disable exit vehicle
    end
  end
end)

-- THIS IS FOR POINTING
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    if pointing then
      local camPitch = GetGameplayCamRelativePitch()
      if camPitch < -70.0 then
          camPitch = -70.0
      elseif camPitch > 42.0 then
          camPitch = 42.0
      end
      camPitch = (camPitch + 70.0) / 112.0

      local camHeading = GetGameplayCamRelativeHeading()
      local cosCamHeading = Cos(camHeading)
      local sinCamHeading = Sin(camHeading)
      if camHeading < -180.0 then
          camHeading = -180.0
      elseif camHeading > 180.0 then
          camHeading = 180.0
      end

      camHeading = (camHeading + 180.0) / 360.0

      local blocked = 0
      local nn = 0

      local coords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), (cosCamHeading * -0.2) - (sinCamHeading * (0.4 * camHeading + 0.3)), (sinCamHeading * -0.2) + (cosCamHeading * (0.4 * camHeading + 0.3)), 0.6)
      local ray = Cast_3dRayPointToPoint(coords.x, coords.y, coords.z - 0.2, coords.x, coords.y, coords.z + 0.2, 0.4, 95, GetPlayerPed(-1), 7);
      nn,blocked,coords,coords = GetRaycastResult(ray)

      Citizen.InvokeNative(0xD5BB4025AE449A4E, GetPlayerPed(-1), "Pitch", camPitch)
      Citizen.InvokeNative(0xD5BB4025AE449A4E, GetPlayerPed(-1), "Heading", camHeading * -1.0 + 1.0)
      Citizen.InvokeNative(0xB0A6CFD2C69C1088, GetPlayerPed(-1), "isBlocked", blocked)
      Citizen.InvokeNative(0xB0A6CFD2C69C1088, GetPlayerPed(-1), "isFirstPerson", Citizen.InvokeNative(0xEE778F8C7E1142E2, Citizen.InvokeNative(0x19CAFA3C87F7C2FF)) == 4)
    end
  end
end)

-- THIS IS FOR ENGINE-CONTROL
Citizen.CreateThread(function()
  while true do
	Citizen.Wait(0)
    if DoesEntityExist(GetVehiclePedIsTryingToEnter(PlayerPedId())) then
      local veh = GetVehiclePedIsTryingToEnter(PlayerPedId())
	  engine = IsVehicleEngineOn(veh)
	end
	if IsPedInAnyVehicle(GetPlayerPed(-1), false) and not engine then
	
	  local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
	  local damage = GetVehicleBodyHealth(vehicle)
	  SetVehicleEngineOn(vehicle, engine, false, false)
	end
  end
end)

-- THIS IS FOR NO DOC COMA
--[[Citizen.CreateThread(function() -- coma thread
  while true do
    Citizen.Wait(1000)
      local ped = GetPlayerPed(-1)
      
      local health = GetEntityHealth(ped)
      if self.remote._isComa() then
	  if called == 0 then
		    local docs = self.remote._docsOnline()
		      if docs == 0 then
			    vRP.EXT.Base:notify("~r~There are no medics online")
			  elseif docs > 0 then
			    vRP.EXT.Base:notify("~g~There are doctors online.\n~b~Press ~g~E~b~ to call an ambulance.")
          end
	  else
	    called = called - 1
	  end
	else
	  called = 0
	end
  end
end)--]]





hotkeys = {
--[[  [46] = { --not working
    -- E call/skip emergency
    group = 0, 
	pressed = function() 
      local ped = GetPlayerPed(-1)
      
      local health = GetEntityHealth(ped)
      if self.remote.isComa() then
	    if called == 0 then
		      local docs = self.remote._docsOnline()
		        if docs == 0 then
				  --vRP.EXT.Survival:killComa()
			    else
				  called = 30
				  local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1),true))
				  self.remote._helpComa(x,y,z)
				  Citizen.Wait(1000)
            end
		else
		  vRP.EXT.Base:notify("~r~You already called the ambulance.")
		end
	  end
	end,
	released = function()
	  -- Do nothing on release because it's toggle.
	end,
  },
--]]
[168] = { --works
    -- F6 Toggle Kneel Surrender
    group = 1, 
    pressed = function() 
	local handcuffed = vRP.EXT.Police:isHandcuffed()
      if not IsPauseMenuActive() and not IsPedInAnyVehicle(GetPlayerPed(-1), true) and not handcuffed then -- Comment to allow use in vehicle
        local player = GetPlayerPed( -1 )
        if ( DoesEntityExist( player ) and not IsEntityDead( player )) then 
            loadAnimDict( "random@arrests" )
            loadAnimDict( "random@arrests@busted" )
            if ( IsEntityPlayingAnim( player, "random@arrests@busted", "idle_a", 3 ) ) then 
                TaskPlayAnim( player, "random@arrests@busted", "exit", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )
                Wait (3000)
                TaskPlayAnim( player, "random@arrests", "kneeling_arrest_get_up", 8.0, 1.0, -1, 128, 0, 0, 0, 0 )
            else
                TaskPlayAnim( player, "random@arrests", "idle_2_hands_up", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )
                Wait (4000)
                TaskPlayAnim( player, "random@arrests", "kneeling_arrest_idle", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )
                Wait (500)
                TaskPlayAnim( player, "random@arrests@busted", "enter", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )
                Wait (1000)
                TaskPlayAnim( player, "random@arrests@busted", "idle_a", 8.0, 1.0, -1, 9, 0, 0, 0, 0 )
            end     
        end
      end -- Comment to allow use in vehicle
    end,
    released = function()
	  -- Do nothing on release because it's toggle.
    end,
  },

  [323] = { --73 includes X on controllers 323 Excludes X on controllers
    -- X toggle HandsUp
    group = 1, 
	pressed = function() 
		local handcuffed = vRP.EXT.Police:isHandcuffed()
      if not IsPauseMenuActive() and not IsPedInAnyVehicle(GetPlayerPed(-1), true) and not handcuffed then -- Comment to allow use in vehicle
			local ped = PlayerPedId()
	
			if ( DoesEntityExist( ped ) and not IsEntityDead( ped ) ) then
	
				RequestAnimDict( "random@mugging3" )
	
				while ( not HasAnimDictLoaded( "random@mugging3" ) ) do 
					Citizen.Wait( 100 )
				end
	
				if IsEntityPlayingAnim(ped, "random@mugging3", "handsup_standing_base", 3) then
					ClearPedSecondaryTask(ped)
				else
					TaskPlayAnim(ped, "random@mugging3", "handsup_standing_base", 2.0, 2.5, -1, 49, 0, 0, 0, 0 )
					local prop_name = prop_name
					local secondaryprop_name = secondaryprop_name
					DetachEntity(prop, 1, 1)
					DeleteObject(prop)
					DetachEntity(secondaryprop, 1, 1)
					DeleteObject(secondaryprop)
				end
			end
		end
	end,
	released = function()
	  -- Do nothing on release because it's toggle.
	end,
  },
  [29] = {
    -- B toggle Point
    group = 0, 
	pressed = function() 
		local handcuffed = vRP.EXT.Police:isHandcuffed()
      if not IsPauseMenuActive() and not IsPedInAnyVehicle(GetPlayerPed(-1), true) and not handcuffed then  -- Comment to allow use in vehicle
		RequestAnimDict("anim@mp_point")
		while not HasAnimDictLoaded("anim@mp_point") do
          Wait(0)
		end
        pointing = not pointing 
		if pointing then 
		  SetPedCurrentWeaponVisible(GetPlayerPed(-1), 0, 1, 1, 1)
		  SetPedConfigFlag(GetPlayerPed(-1), 36, 1)
		  Citizen.InvokeNative(0x2D537BA194896636, GetPlayerPed(-1), "task_mp_pointing", 0.5, 0, "anim@mp_point", 24)
		  RemoveAnimDict("anim@mp_point")
        else
		  Citizen.InvokeNative(0xD01015C7316AE176, GetPlayerPed(-1), "Stop")
		  if not IsPedInjured(GetPlayerPed(-1)) then
		    ClearPedSecondaryTask(GetPlayerPed(-1))
		  end
		  if not IsPedInAnyVehicle(GetPlayerPed(-1), 1) then
		    SetPedCurrentWeaponVisible(GetPlayerPed(-1), 1, 1, 1, 1)
		  end
		  SetPedConfigFlag(GetPlayerPed(-1), 36, 0)
		  ClearPedSecondaryTask(PlayerPedId())
        end 
	  end -- Comment to allow use in vehicle
	end,
	released = function()
	  -- Do nothing on release because it's toggle.
	end,
  },
  [36] = {
    -- CTRL toggle Crouch
    group = 0, 
	pressed = function() 
	  local handcuffed = vRP.EXT.Police:isHandcuffed()
      if not IsPauseMenuActive() and not IsPedInAnyVehicle(GetPlayerPed(-1), true) and not handcuffed then  -- Comment to allow use in vehicle
        RequestAnimSet("move_ped_crouched")
		while not HasAnimSetLoaded("move_ped_crouched") do 
          Citizen.Wait(0)
        end 
        crouched = not crouched 
		if crouched then 
          ResetPedMovementClipset(GetPlayerPed(-1), 0)
        else
          SetPedMovementClipset(GetPlayerPed(-1), "move_ped_crouched", 0.25)
        end 
	  end -- Comment to allow use in vehicle
	end,
	released = function()
	  -- Do nothing on release because it's toggle.
	end,
  },
  [167] = { --F6 if not using surrender toggle
    -- K toggle Vehicle Engine
    group = 1, 
	pressed = function() 
		local handcuffed = vRP.EXT.Police:isHandcuffed()
      if not IsPauseMenuActive() and IsPedInAnyVehicle(GetPlayerPed(-1), false) and not handcuffed then
		engine = not engine
		SetVehicleEngineOn(GetVehiclePedIsIn(GetPlayerPed(-1), false), engine, false, false)
	  end
	end,
	released = function()
	  -- Do nothing on release because it's toggle.
	end,
  },
  [71] = {
    -- W starts Vehicle Engine
    group = 1, 
	pressed = function() 
		local handcuffed = vRP.EXT.Police:isHandcuffed()
      if not IsPauseMenuActive() and IsPedInAnyVehicle(GetPlayerPed(-1), false) and not handcuffed then
		engine = true
		SetVehicleEngineOn(GetVehiclePedIsIn(GetPlayerPed(-1), false), engine, false, false)
	  end
	end,
	released = function()
	  -- Do nothing on release because it's toggle.
	end,
	},
}

end


function loadAnimDict( dict )
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 5 )
    end
end 

vRP:registerExtension(HotKeys)
