APP.Name = "HL2 Go"
APP.Icon = "https://raw.githubusercontent.com/KredeGC/GPhone/master/images/hlgo.png"
function APP.Run( frame, w, h, ratio )
	frame:SetFullScreen( true )
	local h = frame.h
	net.Start("GPhone_Selfie")
		net.WriteBool( true )
	net.SendToServer()
	
	LocalPlayer():EmitSound( "weapons/smg1/switch_burst.wav", 50, math.random(95,105), 1, CHAN_WEAPON )
	
	local c_iron = 0
	local IronSightsPos = Vector(-6.43, -8.506, 3.539)
	
	local RunSightsPos = Vector(3.92, -3.586, -2.6)
	local RunSightsAng = Vector(-18.879, 39.603, -35.044)
	
	if !IsValid(frame.viewmodel) then
		local mdl = ClientsideModel("models/weapons/v_smg1.mdl", RENDERGROUP_OPAQUE)
		mdl:SetNoDraw(true)
		mdl:ResetSequence( mdl:LookupSequence("draw") )
		mdl:SetPlaybackRate( 0.7 )
		mdl:SetCycle( 0 )
		function mdl:GetPlayerColor()
			return Vector(1, 0.5, 0)
		end
		frame.viewmodel = mdl
		frame.f_nextfire = CurTime() + 1.2
	end
	
	function frame:Paint( x, y, w, h )
		local mat = GPhone.RenderCamera( 50, false, function(pos, ang, fov)
			local vm = self.viewmodel
			local ft = FrameTime()
			if IsValid(vm) then
				cam.Start3D(pos, ang, 60, 0, 0, w, h, 1, 128)
					c_iron = Lerp(math.min(ft * 10, 1), c_iron or 0, GPhone.CursorEnabled and 1 or 0)
					
					local pos = pos + IronSightsPos.x * ang:Right() * c_iron + IronSightsPos.y * ang:Forward() * c_iron + IronSightsPos.z * ang:Up() * c_iron
					
					cam.IgnoreZ(true)
						vm:SetRenderOrigin( pos - ang:Up() )
						vm:SetRenderAngles( ang )
						vm:SetupBones()
						vm:FrameAdvance( ft )
						vm:DrawModel()
					cam.IgnoreZ(false)
				cam.End3D()
			end
		end)
		
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial( mat )
		surface.DrawTexturedRect(0, 0, w, h)
		
		local hp = LocalPlayer():Health()
		if hp <= 50 then
			local p = 1-(hp/50)
			surface.SetDrawColor(255, 0, 0, 150 * p)
			surface.DrawRect(0, 0, w, h)
		end
	end
end

function APP.Focus( frame )
	net.Start("GPhone_Selfie")
		net.WriteBool( true )
	net.SendToServer()
	LocalPlayer():EmitSound( "weapons/smg1/switch_burst.wav", 50, math.random(95,105), 1, CHAN_WEAPON )
	frame.f_nextfire = CurTime() + 0.5
	local vm = frame.viewmodel
	if IsValid(vm) then
		vm:ResetSequence( vm:LookupSequence("draw") )
		vm:SetPlaybackRate( 1 )
		vm:SetCycle( 0 )
	end
end

function APP.Think( frame )
	local x,y = GPhone.GetCursorPos()
	if x > 0 and y > 0 and x <= GPhone.Width and y <= GPhone.Height and GPhone.CursorEnabled then
		local ct = CurTime()
		if LocalPlayer():KeyDown(IN_ATTACK) and (frame.f_nextfire or 0) < ct then
			frame.f_nextfire = ct + 0.08
			local vm = frame.viewmodel
			if IsValid(vm) then
				LocalPlayer():EmitSound( "weapons/smg1/smg1_fire1.wav", 50, math.random(95,105), 1, CHAN_WEAPON )
				vm:ResetSequence( vm:LookupSequence("fire0"..math.random(1,4)) )
				vm:SetPlaybackRate( 1 )
				vm:SetCycle( 0 )
			end
			
			--[[local bullet = {}
			bullet.Num = 1
			bullet.Src = LocalPlayer():GetShootPos()
			bullet.Dir = LocalPlayer():GetAimVector()
			bullet.Spread = Vector( 0, 0, 0 )
			bullet.Tracer = 0
			bullet.Force = 10
			bullet.Damage = 10
			bullet.AmmoType = "smg1"
			
			LocalPlayer():FireBullets( bullet )]]
		end
	end
end

function APP.Stop( frame )
	if IsValid(frame.viewmodel) then
		frame.viewmodel:Remove()
	end
end