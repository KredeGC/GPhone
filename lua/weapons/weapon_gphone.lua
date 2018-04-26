AddCSLuaFile()

SWEP.PrintName = "GPhone"
SWEP.Author =	"Krede"
SWEP.Contact =	"Steam"
SWEP.Purpose =	"Used for RP. Read addon desc for more info."
SWEP.Instructions =	"A newer version of an old diamond of mine."

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("vgui/hud/phone")
	SWEP.BounceWeaponIcon = false
end

SWEP.SwayScale 	= 0
SWEP.BobScale 	= 0

SWEP.Spawnable				= true
SWEP.Category				= "Krede's SWEPs"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.HoldType				= "slam"
SWEP.ViewModelFOV			= 55
SWEP.ViewModelFlip			= false
SWEP.ViewModel				= "models/weapons/c_garry_phone.mdl"
SWEP.WorldModel				= "models/nitro/iphone4.mdl"
SWEP.DrawCrosshair			= false
SWEP.UseHands				= true

SWEP.ViewModelBones = {
	["ValveBiped.Bip01_R_Finger41"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 2.005, 7.734) },
	["ValveBiped.Bip01_R_Finger31"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(4.939, 0.391, 2.486) },
	["ValveBiped.Bip01_R_Forearm"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(12.364, -4.447, -166.75) },
	["ValveBiped.Bip01_R_Hand"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(-26.625, 46.612, 148.677) },
	["ValveBiped.Bip01_R_Finger4"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(2.838, -8.886, 8.005) },
	["ValveBiped.Bip01_R_Finger32"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(1.215, 3.562, -15.863) },
	["ValveBiped.Bip01_R_Finger42"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(-14.054, -2.49, -14.485) },
	["ValveBiped.Bip01_R_Finger2"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(-2.967, 5.788, 0.527) },
	["ValveBiped.Bip01_R_Finger22"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, -0.002, -6.613) },
	["ValveBiped.Bip01_R_Finger3"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(-1.554, 0.397, 12.392) },
	["ValveBiped.Bip01_R_Finger1"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(3.894, 3.219, 0) },
	["ValveBiped.Bip01_R_Finger0"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(5.468, -0.203, 54.722) }
}


SWEP.IronSightsPos = Vector(-2.3, -10.2, 2.1)
SWEP.IronSightsAng = Vector(0, 3, 0.25)
SWEP.CallSightsPos = Vector(-10.461, -12.421, 0.55)
SWEP.CallSightsAng = Vector(0, -90, 5)


SWEP.WorldModelInfo = {
	pos = Vector(2,-0.4,0.4),
	ang = Angle(20,150,5)
}

SWEP.PhoneInfo = {
	model = "models/nitro/iphone4.mdl",
	pos = Vector(1.5, 1.774, -1.912),
	ang = Angle(-2.198, -90.477, 180),
	scale = Vector(1, 1, 1),
	bone = "ValveBiped.Bip01_MobilePhone"
}


local function parentPos( p )
	if p then
		local px,py = parentPos( p.parent )
		local x,y = p.x,p.y
		return x+px,y+py
	else
		return 0,0
	end
end


-- Movement
local c_jump = 0
local c_move = 0
local c_sight = 0
local c_iron = 0


function SWEP:GetViewModelPosition(pos, ang)
	local ct,ft = CurTime(),FrameTime()
	local iftp = game.SinglePlayer() or IsFirstTimePredicted()
	
	if self:GetNWFloat("DeployTime") > ct and self:GetNWBool("Deployed") then
		local p = (self:GetNWFloat("DeployTime")-ct)/0.8
		ang:RotateAroundAxis(ang:Right(), -(8 * p)^2)
		ang:RotateAroundAxis(ang:Up(), -(2 * p)^2)
		ang:RotateAroundAxis(ang:Forward(), -(8 * p)^2)
	elseif !self:GetNWBool("Deployed") then
		ang:RotateAroundAxis(ang:Right(), -64)
		ang:RotateAroundAxis(ang:Up(), -4)
		ang:RotateAroundAxis(ang:Forward(), -64)
	end
	
	local pos,ang = self:Movement(pos, ang, ct, ft, iftp)
	local pos,ang = self:Sights(pos, ang, ct, ft, iftp)
	
	return pos,ang
end

function SWEP:Movement(pos, ang, ct, ft, iftp)
	local bob = 1
	local idle = 1
	
	local move = Vector(self.Owner:GetVelocity().x, self.Owner:GetVelocity().y, 0)
	local movement = move:LengthSqr()
	local movepercent = math.Clamp(movement/self.Owner:GetRunSpeed()^2, 0, 1)
	
	local vel = move:GetNormalized()
	local rd = self.Owner:GetRight():Dot( vel )
	local fd = (self.Owner:GetForward():Dot( vel ) + 1)/2
	
	if iftp then
		local ft8 = math.min(ft * 8, 1)
		
		c_move = Lerp(ft8, c_move or 0, self.Owner:OnGround() and movepercent or 0)
		c_sight = Lerp(ft8, c_sight or 0, GPhone.CursorEnabled and 0.1 or 1)
		c_jump = Lerp(ft8, c_jump or 0, self.Owner:GetMoveType() == MOVETYPE_NOCLIP and 0 or math.Clamp(self.Owner:GetVelocity().z/120, -1.5, 1))
	end
	
	pos = pos + ang:Up()*0.75*c_jump*c_sight
	ang.p = ang.p + (c_jump or 0)*3*c_sight
	
	if bob != 0 and c_move > 0 then
		local p = c_move*c_sight*bob
		pos = pos - ang:Forward()*c_move*c_sight*fd - ang:Up()*0.75*c_move*c_sight + ang:Right()*0.5*c_move*c_sight
		ang.y = ang.y + math.sin(ct*8.4)*1.2*p
		ang.p = ang.p + math.sin(ct*16.8)*0.8*p
		ang.r = ang.r + math.cos(ct*8.4)*0.3*p
	end
	
	if idle != 0 then
		local p = (1-c_move)*c_sight*idle
		ang.p = ang.p + math.sin(ct*0.6)*1*p
		ang.y = ang.y + math.sin(ct*1.2)*0.5*p
		ang.r = ang.r + math.sin(ct*1.8)*0.25*p
	end
	
	return pos,ang
end

function SWEP:Sights(pos, ang, ct, ft, iftp)
	if iftp then
		c_iron = Lerp(math.min(ft * 6, 1), c_iron or 0, GPhone.CursorEnabled and 1 or 0)
	end
	
	local offset = self.IronSightsPos
	ang = ang * 1
	
	if self.IronSightsAng then
		ang:RotateAroundAxis(ang:Right(), 	self.IronSightsAng.x * c_iron)
		ang:RotateAroundAxis(ang:Up(), 		self.IronSightsAng.y * c_iron)
		ang:RotateAroundAxis(ang:Forward(), self.IronSightsAng.z * c_iron)
	end
	
	pos = pos + offset.x * ang:Right() * c_iron
	pos = pos + offset.y * ang:Forward() * c_iron
	pos = pos + offset.z * ang:Up() * c_iron
	
	return pos, ang
end

function SWEP:PrimaryAttack()
	return false
end

function SWEP:SecondaryAttack()
	return false
end

function SWEP:Reload()
	return false
end

function SWEP:Think()
	local ct = CurTime()
	self:NextThink( ct )
	if SERVER then return true end
	if !game.SinglePlayer() and !IsFirstTimePredicted() then return true end
	local st = SysTime()
	local vm = self.Owner:GetViewModel()
	
	if IsValid(vm) then
		local bone_id = vm:LookupBone("ValveBiped.Bip01_MobilePhone")
		if bone_id then
			vm:ManipulateBoneScale(bone_id, Vector(0.01, 0.01, 0.01))
		end
		for bone,data in pairs(self.ViewModelBones) do
			local bone_id = vm:LookupBone(bone)
			if bone_id then
				vm:ManipulateBoneScale(bone_id, data.scale)
				vm:ManipulateBonePosition(bone_id, data.pos)
				vm:ManipulateBoneAngles(bone_id, data.angle)
			end
		end
	end
	
	if self.ToggleDelay < st and input.IsMouseDown( MOUSE_RIGHT ) and !vgui.CursorVisible() then
		self.ToggleDelay = st + 0.3
		GPhone.CursorEnabled = !GPhone.CursorEnabled
	end
	
	if GPhone.CurrentApp and GPhone.CurrentApp != "" and GPhone.CurrentFrame then
		local app = GP.GetApp( GPhone.CurrentApp )
		
		local function animChildren( pnl )
			local anim = pnl.f_anim
			if anim then
				local delta = math.Clamp((ct - anim.start) / anim.max, 0, 1)
				GPhone.DebugFunction( anim.func, pnl, delta, anim.pos.x, anim.pos.y )
				if delta >= 1 then
					if anim.stop then
						GPhone.DebugFunction( anim.stop, pnl )
					end
					pnl.f_anim = nil
				end
			end
			
			for _,child in pairs(pnl.children) do
				animChildren( child )
			end
		end
		
		animChildren( GPhone.CurrentFrame )
		
		if app.Think then
			app.Think( GPhone.CurrentFrame, GPhone.Width, GPhone.Height )
		end
	end
	
	if GPhone.CursorEnabled and !vgui.CursorVisible() then
		if input.IsMouseDown( MOUSE_LEFT ) and !self.b_leftdown then -- Mouse click
			self.b_leftdown = true
			self.b_override = nil
			self.b_lefthold = st
			
			if !GPhone.AppScreen.Enabled and GPhone.MoveMode then -- Moving apps
				local x,y = CurrentMousePos.x, CurrentMousePos.y
				
				for k,data in pairs(GPhone.GetAppPos()) do
					local posx,posy,size,appid = data.x,data.y,data.size,data.app
					
					if x > posx and x < posx + size and y > posy and y < posy + size then
						if GP.GetApp( appid ) then
							GPhone.MovingApp = k
							break
						end
					end
				end
			end
		elseif ( self.b_lefthold or st ) < st - GetConVar("gphone_holdtime"):GetFloat() and !GPhone.MoveMode and !GPhone.AppScreen.Enabled then -- Mouse hold
			self.b_lefthold = nil
			local x,y = CurrentMousePos.x,CurrentMousePos.y
			local home = self.ScreenInfo.home
			
			if x > home.x and x < home.x + home.size and y > home.y and y < home.y + home.size then -- Hold home button
				self.b_override = true
				GPhone.AppScreen.Enabled = true
				GPhone.AppScreen.Scroll = 0
				if GPhone.CurrentApp then
					local space = 0
					for appid,_ in pairs(GPhone.Panels) do
						if appid == GPhone.CurrentApp then
							GPhone.AppScreen.Scroll = -space
							break
						end
						space = space + 1
					end
					GPhone.AppThumbnail( GPhone.CurrentApp )
					GPhone.FocusHome()
				end
			elseif x >= 0 and x <= GPhone.Width and y >= 0 and y <= GPhone.Height and (!GPhone.CurrentApp or GPhone.CurrentApp == "") then
				self.b_override = true
				GPhone.MoveMode = true
			else
				self.b_double = true
			end
		elseif !input.IsMouseDown( MOUSE_LEFT ) and self.b_leftdown then -- Mouse release
			self.b_leftdown = nil
			self.b_lefthold = nil
			
			if self.b_override then return end
			
			local double = self.b_double
			self.b_double = nil
			self.b_downtime = ct + 0.25
			local x,y = CurrentMousePos.x, CurrentMousePos.y
			
			if GPhone.GetInputText() then -- Exit text input
				GPhone.CloseInput()
				self.b_downtime = 0
			elseif GPhone.AppScreen.Enabled then -- Inside app screen
				local appscr = GPhone.AppScreen
				local space,scale = 0,appscr.Scale
				local w,h = GPhone.Width*scale,GPhone.Height*scale
				for appid,frame in pairs(GPhone.Panels) do
					local px,py = GPhone.Width/2 - w/2 + (w + appscr.Spacing) * (space + appscr.Scroll), GPhone.Height/2 - h/2
					if x > px and x < px + w and y > py and y < py + h then
						GPhone.AppScreen.Enabled = false
						GPhone.FocusApp( appid )
						return
					elseif x > px and x < px + w and y > (py - appscr.Offset * scale) and y < py then
						GPhone.StopApp( appid )
						
						local max = -(table.Count(GPhone.Panels) - 1)
						if appscr.Scroll < max then
							appscr.Scroll = max
						end
						
						if table.Count(GPhone.Panels) > 0 then return end
					end
					space = space + 1
				end
				
				GPhone.AppScreen.Enabled = false
				GPhone.FocusHome()
			elseif GPhone.MovingApp and GP.GetApp( GPhone.Data.apps[GPhone.MovingApp] ) then -- Move app on top of one another
				local oldappid = GPhone.Data.apps[GPhone.MovingApp]
				
				for k,data in pairs(GPhone.GetAppPos()) do
					local posx,posy,size,appid = data.x,data.y,data.size,data.app
					local app = GP.GetApp(appid)
					
					if x > posx and x < posx + size and y > posy and y < posy + size then
						GPhone.Data.apps[k] = oldappid
						GPhone.Data.apps[GPhone.MovingApp] = appid
						GPhone.MovingApp = nil
						break
					end
				end
				GPhone.MovingApp = nil
				self.b_downtime = 0
			elseif GPhone.MoveMode then -- Stop editing screen
				GPhone.MovingApp = nil
				GPhone.MoveMode = nil
			elseif x > self.ScreenInfo.home.x and x < self.ScreenInfo.home.x + self.ScreenInfo.home.size and y > self.ScreenInfo.home.y and y < self.ScreenInfo.home.y + self.ScreenInfo.home.size then -- Home button pressed
				if GPhone.CurrentApp then -- Go to home screen
					GPhone.AppThumbnail( GPhone.CurrentApp )
					GPhone.FocusHome()
				end
			elseif GPhone.CurrentApp and GPhone.CurrentApp != "" then -- Inside an app
				local frame = GPhone.CurrentFrame
				if !frame or !frame.visible then return end
				
				--[[local function sortChildren( pnl )
					local children = {}
					
					local function cutoutParents( pnl )
						if pnl.parent then
							pnl.parent.children = nil
							cutoutParents( pnl.parent )
						end
					end
					
					local function returnChildren( pnl )
						if pnl.children and #pnl.children > 0 then
							local tbl = {}
							for k,child in pairs(pnl.children) do
								local c = returnChildren( child )
								cutoutParents( c )
								table.insert(tbl, c)
							end
							return tbl
						else
							table.insert(children, pnl)
							return pnl
						end
					end
					
					returnChildren( pnl )
					
					return children
				end
				
				local function pressChildren( children )
					local parents = {}
					for _,child in pairs(children) do
						local px,py = parentPos( child )
						local bx,by,bw,bh = px,py,child.w,child.h
						
						if x >= bx and x <= bx + bw and y >= by and y <= by + bh and child.visible then -- If we're clicking within the panel
							if child.OnClick then
								GPhone.DebugFunction( child.OnClick, child )
							end
							return true
						elseif !table.HasValue(parents, child.parent) and child.parent and child.parent.parent then -- If it's a root frame, dont add it
							table.insert(parents, child.parent)
						end
					end
					
					if #parents > 0 then
						return pressChildren( parents )
					else
						return false
					end
				end]]
				
				local children = {}
				local function clickChildren( pnl )
					local px,py = parentPos( pnl )
					local bx,by,bw,bh = px,py,pnl.w,pnl.h
					if x < bx or x > bx + bw or y < by or y > by + bh or !pnl.visible then return end
					table.insert(children, pnl)
					for _,child in pairs(pnl.children) do
						clickChildren( child )
					end
					return pnl
				end
				
				clickChildren( frame )
				
				local button = children[#children]
				if button then
					if button.OnClick then
						GPhone.DebugFunction( button.OnClick, button, double or false )
					end
				end
			else
				for k,data in pairs(GPhone.GetAppPos()) do -- Home screen
					local posx,posy,size,appid = data.x,data.y,data.size,data.app
					
					if x >= posx and x <= posx + size and y >= posy and y <= posy + size then
						local res = GPhone.FocusApp( appid )
						if !res then
							GPhone.RunApp( appid )
						end
						break
					end
				end
			end
		end
	end
	
	return true
end

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	self:SetHoldType(self.HoldType)
	self.ToggleDelay = SysTime() + 0.3
	
	if CLIENT then
		GPhone.DownloadImage( GPhone.Data.background, 512, true, "background-color: #FFF" )
		
		for k,app in pairs(GP.GetApps()) do
			GPhone.DownloadImage( app.Icon, 128, true, "background-color: #FFF; border-radius: 32px 32px 32px 32px" )
		end
	end
end

function SWEP:Deploy()
	self:SetNWFloat("DeployTime", CurTime() + 0.8)
	self:SetNWBool("Deployed", true)
	return true
end

function SWEP:Holster()
	self:SetNWBool("Deployed", false)
	
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			for bone = 1, vm:GetBoneCount() do
				vm:ManipulateBoneScale(bone, Vector(1, 1, 1))
				vm:ManipulateBonePosition(bone, Vector(0,0,0))
				vm:ManipulateBoneAngles(bone, Angle(0,0,0))
			end
		end
	end
	
	return true
end

function SWEP:OnRemove()
	if CLIENT then
		GPhone.CursorEnabled = false
		
		for k,v in pairs(file.Find("gphone/screens/*.jpg", "DATA")) do
			file.Delete("gphone/screens/"..v)
		end
	end
	
	self:Holster()
end


if SERVER then return end -- Stop the server from here on

local blurmat = Material("pp/blurscreen")
local screenlight = 1

local phonert = GetRenderTarget("GPhoneRT", GPhone.Width*1.032, GPhone.Height*1.032, false)
local phonemt = CreateMaterial(
	"GPhoneMT",
	"UnlitGeneric",
	{
		["$basetexture"] = phonert,
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 1
	}
)

SWEP.ScreenInfo = {
	pos = Vector(2.625, 2, -3.592),
	ang = Angle(0, -180.477, -92.2),
	size = 0.004,
	bone = "ValveBiped.Bip01_MobilePhone",
	home = {
		x = 246,
		y = 896,
		size = 72,
	},
	draw = function( wep, w, h )
		if GPhone.AppScreen and GPhone.AppScreen.Enabled then
			local appscr = GPhone.AppScreen
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial( GPhone.GetImage( GPhone.Data.background ) )
			surface.DrawTexturedRect(0, 0, GPhone.Width, GPhone.Height)
			
			-- render.BlurRenderTarget( render.GetRenderTarget(), 3, 3, 3 )
			
			local space,scale = 0,appscr.Scale
			local offset = appscr.Offset * scale
			local w,h = GPhone.Width*scale,GPhone.Height*scale
			for appid,frame in pairs(GPhone.Panels) do
				local app = GP.GetApp( appid )
				if !app then continue end
				
				local x,y = GPhone.Width/2 - w/2 + (w + appscr.Spacing) * (space + appscr.Scroll), GPhone.Height/2 - h/2
				space = space + 1
				if x + w < 0 or x > GPhone.Width then continue end
				draw.RoundedBox(0, x, y - offset, w, offset + h, Color(0, 0, 0, 200))
				
				surface.SetDrawColor(255, 255, 255)
				surface.SetTexture( surface.GetTextureID( "gui/html/stop" ) )
				surface.DrawTexturedRect( x + w/2 - offset/2, y - offset, offset, offset )
				
				surface.SetDrawColor(255, 255, 255, 255)
				if file.Exists("gphone/screens/"..appid..".jpg", "DATA") then
					surface.SetMaterial( Material("data/gphone/screens/"..appid..".jpg") )
					surface.DrawTexturedRect(x, y, w, h)
				else
					surface.DrawRect(x, y, w, h)
				end
				
				surface.SetMaterial( GPhone.GetImage( app.Icon ) )
				surface.DrawTexturedRect(x + w/2 - 32, y + h + appscr.Spacing, 64, 64)
			end
		elseif GPhone.CurrentApp and GPhone.CurrentApp != "" then
			local app = GP.GetApp( GPhone.CurrentApp )
			if !app then return end
			local frame = GPhone.CurrentFrame
			if !frame then return end
			local oldw,oldh = ScrW(),ScrH()
			
			local function drawChildren( pnl )
				if pnl.children and #pnl.children > 0 then
					for _,child in pairs(pnl.children) do
						if !child.visible then continue end
						
						if child.Paint then
							local px,py = parentPos( child.parent )
							local max,may = GPhone.Width*0.016 + math.max(px + child.x, 0), GPhone.Height*0.016 + math.max(py + child.y, 0)
							local mix,miy = math.min(GPhone.Width*0.016 + px + child.x + child.w, phonemt:Width()), math.min(GPhone.Height*0.016 + py + child.y + child.h, phonemt:Height())
							
							render.SetViewPort(max, may, oldw, oldh)
							render.SetScissorRect(max, may, mix, miy, true)
							GPhone.DebugFunction( child.Paint, child, child.x, child.y, child.w, child.h )
							render.SetScissorRect(0, 0, 0, 0, false)
						end
						
						drawChildren( child )
					end
				end
			end
			
			if frame.Paint then
				local offset = GPhone.Height*0.016 + (frame.b_fullscreen and 0 or GPhone.Desk.Offset)
				render.SetViewPort(GPhone.Width*0.016, offset, oldw, oldh)
				GPhone.DebugFunction( frame.Paint, frame, frame.x, frame.y, frame.w, frame.h )
			end
			drawChildren( frame )
			
			render.SetViewPort(GPhone.Width*0.016, GPhone.Height*0.016, oldw, oldh)
		else
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial( GPhone.GetImage( GPhone.Data.background ) )
			surface.DrawTexturedRect(0, 0, w, h)
			
			for k,data in pairs(GPhone.GetAppPos()) do
				local posx,posy,size,appid = data.x,data.y,data.size,data.app
				local app = GP.GetApp(appid)
				
				if GPhone.MoveMode then
					if GPhone.MovingApp != k then
						local ran = math.Rand(-4,4)
						
						surface.SetDrawColor(255, 255, 255, 255)
						surface.SetMaterial( GPhone.GetImage( app.Icon ) )
						surface.DrawTexturedRectRotated(posx + size/2, posy + size/2, size, size, ran)
						
						draw.SimpleText(app.Name, "GPAppName", posx + size/2 - ran/4 + 2, posy + size - ran/4 + 2, Color(0,0,0), TEXT_ALIGN_CENTER)
						draw.SimpleText(app.Name, "GPAppName", posx + size/2 - ran/4, posy + size - ran/4, Color(255,255,255), TEXT_ALIGN_CENTER)
					end
				else
					surface.SetDrawColor(255, 255, 255, 255)
					surface.SetMaterial( GPhone.GetImage( app.Icon ) )
					surface.DrawTexturedRect(posx, posy, size, size)
					
					draw.SimpleText(app.Name, "GPAppName", posx + size/2 + 2, posy + size + 2, Color(0,0,0), TEXT_ALIGN_CENTER)
					draw.SimpleText(app.Name, "GPAppName", posx + size/2, posy + size, Color(255,255,255), TEXT_ALIGN_CENTER)
				end
			end
		end
	end
}

function SWEP:ViewModelDrawn()
	if GetConVar("gphone_blur"):GetBool() then
		local st = SysTime()
		if GPhone.CursorEnabled or self.ToggleDelay > st then
			cam.Start2D()
				local p = math.Clamp((self.ToggleDelay - st)/0.3, 0, 1)
				if GPhone.CursorEnabled then
					p = 1 - p
				end
				surface.SetDrawColor(255,255,255)
				surface.SetMaterial(blurmat)
				
				for i = 1, 3 do
					blurmat:SetFloat("$blur", (i / 3) * 3 * p)
					blurmat:Recompute()
					
					render.UpdateScreenEffectTexture()
					
					surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
				end
			cam.End2D()
		end
	end
	
	local ply = LocalPlayer()
	local vm = LocalPlayer():GetViewModel()
	
	if !self.PhoneInfo then return end
	
	if !IsValid(self.PhoneModel) then
		local mdl = ClientsideModel(self.PhoneInfo.model, RENDERGROUP_OPAQUE)
		mdl:SetNoDraw(true)
		self.PhoneModel = mdl
	end
	
	local bone_id = vm:LookupBone(self.PhoneInfo.bone)
	if !bone_id then return end
	
	local pos,ang = vm:GetBonePosition(bone_id)
	
	if IsValid(self.Owner) and self.Owner:IsPlayer() and self.ViewModelFlip then
		ang.r = -ang.r
	end
	
	self.PhoneModel:SetPos(pos + ang:Forward() * self.PhoneInfo.pos.x + ang:Right() * self.PhoneInfo.pos.y + ang:Up() * self.PhoneInfo.pos.z)
	ang:RotateAroundAxis(ang:Up(), self.PhoneInfo.ang.y)
	ang:RotateAroundAxis(ang:Right(), self.PhoneInfo.ang.p)
	ang:RotateAroundAxis(ang:Forward(), self.PhoneInfo.ang.r)
	
	self.PhoneModel:SetAngles(ang)
	
	self.PhoneModel:SetSkin(4)
	self.PhoneModel:SetupBones()
	self.PhoneModel:DrawModel()
	
	
	local subs = self.PhoneModel:GetMaterials()
	if LocalPlayer():GetNWString("PhoneCase") != "" then
		for i = 1, #subs do
			if subs[i] == "models/nitro/iphone_case" then
				self.PhoneModel:SetSubMaterial(i-1, LocalPlayer():GetNWString("PhoneCase"))
			end
		end
	else
		local pcol = LocalPlayer():GetWeaponColor()
		local col = Color(math.Round(pcol.x*255),math.Round(pcol.y*255),math.Round(pcol.z*255))
		
		local mat = "models/nitro/iphone_case"
		local params = { ["$basetexture"] = mat, ["$vertexcolor"] = 1, ["$color2"] = "{ "..col.r.." "..col.g.." "..col.b.." }" }
		local matname = mat.."-"..col.r.."-"..col.g.."-"..col.b
		local phonemat = CreateMaterial(matname, "VertexLitGeneric", params)
		
		for i = 1, #subs do
			if subs[i] == "models/nitro/iphone_case" then
				self.PhoneModel:SetSubMaterial(i-1, "!"..matname)
			end
		end
	end
	
	
	local bone_id = vm:LookupBone(self.ScreenInfo.bone)
	if !bone_id then return end
	
	local pos,ang = vm:GetBonePosition(bone_id)
	
	if IsValid(self.Owner) and self.Owner:IsPlayer() and self.ViewModelFlip then
		ang.r = -ang.r
	end
	
	pos = pos + ang:Forward() * self.ScreenInfo.pos.x + ang:Right() * self.ScreenInfo.pos.y + ang:Up() * self.ScreenInfo.pos.z
	ang:RotateAroundAxis(ang:Up(), self.ScreenInfo.ang.y)
	ang:RotateAroundAxis(ang:Right(), self.ScreenInfo.ang.p)
	ang:RotateAroundAxis(ang:Forward(), self.ScreenInfo.ang.r)
	
	local dlight = DynamicLight( self:EntIndex() )
	if dlight then
		dlight.Pos = pos + ang:Up()*4
		dlight.r = 150
		dlight.g = 150
		dlight.b = 255
		dlight.Brightness = 1
		dlight.Decay = 1000
		dlight.size = 30
		dlight.DieTime = CurTime() + 1
	end
	
	cam.Start3D2D(pos, ang, self.ScreenInfo.size)
		local light = 0.65 + math.Clamp(render.ComputeLighting(EyePos(), -ang:Forward()):Length(), 0, 0.35)
		screenlight = Lerp(FrameTime()*5, screenlight, light)
		
		surface.SetDrawColor(255 * screenlight, 255 * screenlight, 255 * screenlight)
		surface.SetMaterial( phonemt )
		surface.DrawTexturedRect(0, 0, GPhone.Width, GPhone.Height)
		
		-- draw.RoundedBox(0, self.ScreenInfo.home.x, self.ScreenInfo.home.y, self.ScreenInfo.home.size, self.ScreenInfo.home.size, Color(250,250,250,100)) -----For drawing the HOME-button. Debugging
		
		if !GPhone.MovingApp or !GPhone.Data.apps[GPhone.MovingApp] then
			local col = LocalPlayer():GetWeaponColor()
			local x,y = CurrentMousePos.x,CurrentMousePos.y
			
			if GPhone.CursorEnabled then
				if GPhone.GetInputText() then
					draw.RoundedBox(0, x-7, y-9, 16, 4, Color(70,70,70,255))
					draw.RoundedBox(0, x-1, y-5, 4, 16, Color(70,70,70,255))
					draw.RoundedBox(0, x-7, y+11, 16, 4, Color(70,70,70,255))
					
					draw.RoundedBox(0, x-8, y-10, 16, 4, Color(col.x*255, col.y*255, col.z*255,255))
					draw.RoundedBox(0, x-2, y-6, 4, 16, Color(col.x*255, col.y*255, col.z*255,255))
					draw.RoundedBox(0, x-8, y+10, 16, 4, Color(col.x*255, col.y*255, col.z*255,255))
				else
					surface.SetDrawColor(col.x*255, col.y*255, col.z*255, 255)
					surface.SetTexture(surface.GetTextureID("effects/select_dot"))
					surface.DrawTexturedRect(x - 18, y - 18, 36, 36)
				end
			end
		end
	cam.End3D2D()
end

hook.Add("RenderScene", "GPhoneRenderPhoneRT", function(origin, angles, fov)
	local wep = LocalPlayer():GetActiveWeapon()
	if IsValid(wep) and wep:GetClass() == "weapon_gphone" then
		phonemt:SetTexture("$basetexture", phonert)
		
		render.PushRenderTarget(phonert)
		render.Clear(0, 0, 0, 255, true, true)
		cam.Start2D()
			render.SetViewPort(GPhone.Width*0.016, GPhone.Height*0.016, ScrW(), ScrH())
			local x,y = CurrentMousePos.x,CurrentMousePos.y
			local app = GP.GetApp( GPhone.CurrentApp )
			local frame = GPhone.GetPanel(GPhone.CurrentApp)
			local fullscreen = (!app or frame and frame.b_fullscreen) and !GPhone.AppScreen.Enabled
			
			if wep.ScreenInfo.draw then
				if fullscreen then
					wep.ScreenInfo.draw( wep, GPhone.Width, GPhone.Height )
				else
					wep.ScreenInfo.draw( wep, GPhone.Width, GPhone.Height - GPhone.Desk.Offset )
				end
			end
			
			local appid = GPhone.Data.apps[GPhone.MovingApp]
			if GPhone.MovingApp and appid then
				local a = GP.GetApp( appid )
				local size = GPhone.GetAppSize()
				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetMaterial( GPhone.GetImage( a.Icon ) )
				surface.DrawTexturedRect(x-size/2, y-size/2, size, size)
				
				draw.SimpleText(a.Name, "GPAppName", x+2, y+size/2+2, Color(0,0,0), TEXT_ALIGN_CENTER)
				draw.SimpleText(a.Name, "GPAppName", x, y+size/2, Color(255,255,255), TEXT_ALIGN_CENTER)
			end
			
			if GPhone.CursorEnabled then
				if (wep.b_downtime or 0) > CurTime() then
					local p = (wep.b_downtime-CurTime())*4
					local size = 36*(1-p)*2
					
					surface.SetDrawColor(255, 255, 255, p*255)
					surface.SetTexture(surface.GetTextureID("effects/select_ring"))
					surface.DrawTexturedRect(x - size/2, y - size/2, size, size)
				end
			end
			
			if !app or !fullscreen then
				local p_col = Color(255,255,255)
				local shadow = true
				if app and !GPhone.AppScreen.Enabled then
					shadow = false
					if app.Negative then
						draw.RoundedBox(0, 0, 0, GPhone.Width, GPhone.Desk.Offset, Color(0,0,0))
					else
						draw.RoundedBox(0, 0, 0, GPhone.Width, GPhone.Desk.Offset, Color(255,255,255))
						p_col = Color(0,0,0)
					end
				end
				
				local time = GetConVar("gphone_ampm"):GetBool() and os.date("%I:%M %p") or os.date("%H:%M")
				if GetConVar("gphone_sf"):GetBool() and StormFox then
					time = StormFox.GetRealTime(nil, GetConVar("gphone_ampm"):GetBool())
				end
				
				if shadow then
					draw.SimpleText(time, "GPTopBar", GPhone.Width/2 + 2, GPhone.Desk.Offset/2 + 2, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					draw.SimpleText("GMad Inc.", "GPTopBar", 6, GPhone.Desk.Offset/2 + 2, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					
					surface.SetDrawColor(0, 0, 0, 255)
					surface.SetTexture( surface.GetTextureID( "gphone/battery") )
					surface.DrawTexturedRect(GPhone.Width-GPhone.Desk.Offset*2-2, 6, GPhone.Desk.Offset*2-8, GPhone.Desk.Offset-8)
				end
				
				draw.SimpleText(time, "GPTopBar", GPhone.Width/2, GPhone.Desk.Offset/2, p_col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText("GMad Inc.", "GPTopBar", 4, GPhone.Desk.Offset/2, p_col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				
				surface.SetDrawColor(p_col.r, p_col.g, p_col.b, 255)
				surface.SetTexture( surface.GetTextureID( "gphone/battery") )
				surface.DrawTexturedRect(GPhone.Width-GPhone.Desk.Offset*2-4, 4, GPhone.Desk.Offset*2-8, GPhone.Desk.Offset-8)
				
				local p = math.Clamp(system.BatteryPower()/100, 0, 1)
				if p > 0 then
					if shadow then
						draw.SimpleText(math.Round(p*100).."%", "GPTopBar", GPhone.Width-GPhone.Desk.Offset*2-6, GPhone.Desk.Offset/2 + 2, Color(0, 0, 0), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
						
						surface.SetDrawColor(0, 0, 0, 255)
						surface.SetTexture( surface.GetTextureID( "gphone/battery_meter") )
						surface.DrawTexturedRectUV(GPhone.Width-GPhone.Desk.Offset*2-2, 6, (GPhone.Desk.Offset*2-8)*p, GPhone.Desk.Offset-8, 0, 0, p, 1)
					end
					
					draw.SimpleText(math.Round(p*100).."%", "GPTopBar", GPhone.Width-GPhone.Desk.Offset*2-8, GPhone.Desk.Offset/2, p_col, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
					if p <= 0.2 then
						surface.SetDrawColor(255, 0, 0, 255)
					else
						surface.SetDrawColor(p_col.r, p_col.g, p_col.b, 255)
					end
					surface.SetTexture( surface.GetTextureID( "gphone/battery_meter") )
					surface.DrawTexturedRectUV(GPhone.Width-GPhone.Desk.Offset*2-4, 4, (GPhone.Desk.Offset*2-8)*p, GPhone.Desk.Offset-8, 0, 0, p, 1)
				end
			end
			
			render.SetViewPort(0, 0, ScrW(), ScrH())
		cam.End2D()
		render.PopRenderTarget()
	end
end)


local lmbmat = Material("gphone/icons/lmb.png")
local rmbmat = Material("gphone/icons/rmb.png")
local infmat = Material("gphone/icons/hint.png")
local scrmat = Material("gphone/icons/scroll.png")

function SWEP:DrawHUD()
	if GetConVar("gphone_hints"):GetBool() then
		surface.SetDrawColor( 10, 10, 10, 200 )
		surface.SetTexture( surface.GetTextureID( "gui/gradient" ) )
		surface.DrawTexturedRect( ScrW()/2, ScrH()-88, 256, 88 )
		
		surface.SetDrawColor( 10, 10, 10, 200 )
		surface.SetTexture( surface.GetTextureID( "gui/gradient" ) )
		surface.DrawTexturedRectRotated( ScrW()/2 - 128, ScrH()-88 + 44, 256, 88, 180 )
		
		if !GPhone.CursorEnabled then
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( rmbmat )
			surface.DrawTexturedRect( ScrW()/2-16, ScrH() - 80, 32, 32 )
			
			draw.SimpleText("Right-click to toggle focus on the phone", "GPSmall", ScrW()/2, ScrH() - 54, Color(255,255,255), TEXT_ALIGN_CENTER)
		elseif GPhone.GetInputText() then
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( infmat )
			surface.DrawTexturedRect( ScrW()/2-16, ScrH() - 80, 32, 32 )
			
			draw.SimpleText("You can type using your keyboard", "GPSmall", ScrW()/2, ScrH() - 54, Color(255,255,255), TEXT_ALIGN_CENTER)
			draw.SimpleText("Left-click to cancel. Enter to continue", "GPSmall", ScrW()/2, ScrH() - 32, Color(255,255,255), TEXT_ALIGN_CENTER)
		elseif GPhone.MovingApp then
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( lmbmat )
			surface.DrawTexturedRect( ScrW()/2-16, ScrH() - 80, 32, 32 )
			
			draw.SimpleText("Release left-click on any app to swap them", "GPSmall", ScrW()/2, ScrH() - 54, Color(255,255,255), TEXT_ALIGN_CENTER)
		elseif GPhone.MoveMode then
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( lmbmat )
			surface.DrawTexturedRect( ScrW()/2-16, ScrH() - 80, 32, 32 )
			
			draw.SimpleText("Hold left-click on an app to move it", "GPSmall", ScrW()/2, ScrH() - 54, Color(255,255,255), TEXT_ALIGN_CENTER)
			draw.SimpleText("Left-click to go back", "GPSmall", ScrW()/2, ScrH() - 32, Color(255,255,255), TEXT_ALIGN_CENTER)
		elseif GPhone.AppScreen.Enabled then
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( lmbmat )
			surface.DrawTexturedRect( ScrW()/2-16, ScrH() - 80, 32, 32 )
			
			draw.SimpleText("Left-click on a window to open it", "GPSmall", ScrW()/2, ScrH() - 54, Color(255,255,255), TEXT_ALIGN_CENTER)
			draw.SimpleText("Left-click on a cross to close the window", "GPSmall", ScrW()/2, ScrH() - 32, Color(255,255,255), TEXT_ALIGN_CENTER)
		elseif GPhone.CurrentApp and GPhone.CurrentApp != "" then
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( scrmat )
			surface.DrawTexturedRect( ScrW()/2-16, ScrH() - 80, 32, 32 )
			
			draw.SimpleText("Use your scroll-wheel to scroll up and down", "GPSmall", ScrW()/2, ScrH() - 54, Color(255,255,255), TEXT_ALIGN_CENTER)
			draw.SimpleText("Scrolling only works on supported apps", "GPSmall", ScrW()/2, ScrH() - 32, Color(255,255,255), TEXT_ALIGN_CENTER)
		else
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( lmbmat )
			surface.DrawTexturedRect( ScrW()/2-16, ScrH() - 80, 32, 32 )
			
			draw.SimpleText("Left-click on an app to run it", "GPSmall", ScrW()/2, ScrH() - 54, Color(255,255,255), TEXT_ALIGN_CENTER)
			draw.SimpleText("Hold left-click to edit the screen", "GPSmall", ScrW()/2, ScrH() - 32, Color(255,255,255), TEXT_ALIGN_CENTER)
		end
	end
end


function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	-- Borders
	y = y + 10
	x = x + 10
	wide = wide - 20
	tall = tall - 20
	alpha = (alpha-191)/64*255
	
	if GetConVar("gphone_wepicon"):GetBool() then
		local col = LocalPlayer():GetWeaponColor()
		local fsin = math.sin( RealTime() * 10 )
		
		surface.SetDrawColor( col.x*255, col.y*255, col.z*255, alpha )
		surface.SetTexture( surface.GetTextureID("effects/hwn_spell_wheel01") )
		surface.DrawTexturedRectRotated( x + wide/2, y + tall/2, tall, tall, RealTime()*30 )
		
		local centerx, centery = x + wide/2,y + tall/2
		local radius = tall/2 + 32
		
		local apps = GP.GetApps()
		local size = 32 + 8*fsin
		local start = (math.pi * 2) / table.Count( apps )
		local i = start
		
		for name,app in pairs(apps) do
			i = i + start
			
			local r = RealTime()*4
			local s,c = math.sin(i + r),math.cos(i + r)
			
			surface.SetDrawColor( 255, 255, 255, alpha )
			surface.SetMaterial( GPhone.GetImage( app.Icon ) )
			surface.DrawTexturedRectRotated( centerx - s * radius, centery - c * radius, size, size, (i + r)*180/math.pi )
		end
		
		if !IsValid(WeaponInfoEnt) then
			WeaponInfoEnt = ClientsideModel( self.WorldModel, RENDER_GROUP_OPAQUE_ENTITY )
			WeaponInfoEnt:SetNoDraw( true )
			WeaponInfoEnt:SetModel( self.WorldModel )
			WeaponInfoEnt:SetSkin( 1 )
		else
			local subs = WeaponInfoEnt:GetMaterials()
			if LocalPlayer():GetNWString("PhoneCase") != "" then
				for i = 1, #subs do
					if subs[i] == "models/nitro/iphone_case" then
						WeaponInfoEnt:SetSubMaterial(i-1, LocalPlayer():GetNWString("PhoneCase"))
					end
				end
			else
				local pcol = LocalPlayer():GetWeaponColor()
				local col = Color(math.Round(pcol.x*255),math.Round(pcol.y*255),math.Round(pcol.z*255))
				
				local mat = "models/nitro/iphone_case"
				local params = { ["$basetexture"] = mat, ["$vertexcolor"] = 1, ["$color2"] = "{ "..col.r.." "..col.g.." "..col.b.." }" }
				local matname = mat.."-"..col.r.."-"..col.g.."-"..col.b
				local phonemat = CreateMaterial(matname,"VertexLitGeneric",params)
				
				for i = 1, #subs do
					if subs[i] == "models/nitro/iphone_case" then
						WeaponInfoEnt:SetSubMaterial(i-1, "!"..matname)
					end
				end
			end
			
			local vec = Vector(32,32,32 - fsin)
			local ang = Vector(-32,-32,-32):Angle()
			
			local matrix = Matrix()
			matrix:Scale(Vector(1,1,1 + 0.25*fsin))
			WeaponInfoEnt:EnableMatrix( "RenderMultiply", matrix )
			
			cam.Start3D( vec, ang, 20, x, y+35, wide, tall, 5, 4096 )
				cam.IgnoreZ( true )
				render.SuppressEngineLighting( true )
				
				render.SetLightingOrigin( self:GetPos() )
				render.ResetModelLighting( 50/255, 50/255, 50/255 )
				render.SetColorModulation( 1, 1, 1 )
				render.SetBlend( alpha/255 )
				
				render.SetModelLighting( 4, 1, 1, 1 )
				
				WeaponInfoEnt:SetRenderAngles( Angle( 0, 0, 0 ) )
				WeaponInfoEnt:DrawModel()
				WeaponInfoEnt:SetRenderAngles( )
				
				render.SetColorModulation( 1, 1, 1 )
				render.SetBlend( 1 )
				render.SuppressEngineLighting( false )
				cam.IgnoreZ( false )
			cam.End3D()
		end
	else
		surface.SetDrawColor( 255, 255, 255, alpha )
		surface.SetTexture( self.WepSelectIcon )
		surface.DrawTexturedRect( x, y, wide, tall )
	end
end


function SWEP:DrawWorldModel()
	local ply = self.Owner
	
	if IsValid(ply) then
		local attach_id = ply:LookupAttachment("anim_attachment_RH")
		if !attach_id then return end
		local attach = ply:GetAttachment(attach_id)
		if !attach then return end
		
		local pos,ang = attach.Pos,attach.Ang
		local organg = ang
		
		self:SetRenderOrigin(pos + ang:Forward() * self.WorldModelInfo.pos.x + ang:Right() * self.WorldModelInfo.pos.y + ang:Up() * self.WorldModelInfo.pos.z)
		ang:RotateAroundAxis(ang:Up(), self.WorldModelInfo.ang.y)
		ang:RotateAroundAxis(ang:Right(), self.WorldModelInfo.ang.p)
		ang:RotateAroundAxis(ang:Forward(), self.WorldModelInfo.ang.r)
		
		self:SetRenderAngles(ang)
		
		self:SetSkin(1)
		self:DrawModel()
		
		local subs = self:GetMaterials()
		if ply:GetNWString("PhoneCase") != "" then
			for i = 1, #subs do
				if subs[i] == "models/nitro/iphone_case" then
					self:SetSubMaterial(i-1, ply:GetNWString("PhoneCase"))
				end
			end
		else
			local pcol = ply:GetWeaponColor()
			local col = Color(math.Round(pcol.x*255),math.Round(pcol.y*255),math.Round(pcol.z*255))
			
			local mat = "models/nitro/iphone_case"
			local params = { ["$basetexture"] = mat, ["$vertexcolor"] = 1, ["$color2"] = "{ "..col.r.." "..col.g.." "..col.b.." }" }
			local matname = mat.."-"..col.r.."-"..col.g.."-"..col.b
			local phonemat = CreateMaterial(matname,"VertexLitGeneric",params)
			
			for i = 1, #subs do
				if subs[i] == "models/nitro/iphone_case" then
					self:SetSubMaterial(i-1, "!"..matname)
				end
			end
		end
		
		local dlight = DynamicLight( self:EntIndex() )
		if dlight then
			local pos = pos - organg:Forward()*1 + organg:Right()*2
			
			dlight.Pos = pos
			dlight.r = 150
			dlight.g = 150
			dlight.b = 255
			dlight.Brightness = 3
			dlight.Decay = 1000
			dlight.size = 30
			dlight.DieTime = CurTime() + 1
		end
	else
		self:SetSkin( 1 )
		self:DrawModel()
	end
end