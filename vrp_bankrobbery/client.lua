local vRPbankrob = class("vRPbankrob", vRP.Extension)

cfg = module("vrp_bankrobbery", "cfg/bankrobbery")
lang = module("vrp_bankrobbery", "cfg/lang/"..cfg.lang)

robb = ""
timer = 0
robbing = false
incircle = false
wanted = false

function vRPbankrob:__construct()
  vRP.Extension.__construct(self)


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		if robbing then
			if(timer > 0)then
				timer = timer - 1
			end
		end
	end
end)

Citizen.CreateThread(function()
    while true do
		Citizen.Wait(1)
        local pos = GetEntityCoords(GetPlayerPed(-1), true)
        if robbing then

            wanted = robb
            robbery_drawTxt(0.66, 1.44, 1.0, 1.1, 0.4, string.gsub(lang.robbery.robbing, "{1}", timer), 255, 255, 255, 255)
            local ped = GetPlayerPed(-1)
            local health = GetEntityHealth(ped)
            local pos2 = cfg.bankrobbery[robb].pos
            local dist = cfg.bankrobbery[robb].dist

            if health == 120 or health < 120 or (Vdist(pos.x, pos.y, pos.z, pos2[1], pos2[2], pos2[3]) > dist) then
            self.remote._cancelRobbery(robb)
				
                robb = ""
                timer = 0
                robbing = false
                incircle = false
            end
        end
    end
end)
		

end

-- TUNNEL
vRPbankrob.tunnel = {}

function vRPbankrob:robberyEnter()
    for k, v in pairs(cfg.bankrobbery) do
	    local pos = GetEntityCoords(GetPlayerPed(-1), true)
        if (Vdist(pos.x, pos.y, pos.z, v.pos[1], v.pos[2], v.pos[3]) < v.dist) then
            

            if (Vdist(pos.x, pos.y, pos.z, v.pos[1], v.pos[2], v.pos[3]) < 2.0) then
                if (incircle == false) then
                end

                incircle = true
                robb = k
                timer = v.rob
                robbing = true
                self.remote._startRobbery(robb)
            end
        elseif (Vdist(pos.x, pos.y, pos.z, v.pos[1], v.pos[2], v.pos[3]) > 2.0) then
            incircle = false
        end
    end
end

function vRPbankrob:robberyComplete()
	robb = ""
	timer = 0
	robbing = false
	incircle = false
end


function robbery_drawTxt(x,y ,width,height,scale, text, r,g,b,a, outline)

    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    if(outline)then
	    SetTextOutline()
	end
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.005)
end


vRPbankrob.tunnel = {}
vRPbankrob.tunnel.robberyComplete = vRPbankrob.robberyComplete
vRPbankrob.tunnel.robberyEnter = vRPbankrob.robberyEnter


vRP:registerExtension(vRPbankrob)
