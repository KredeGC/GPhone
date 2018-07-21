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
SWEP.UseHands				= false

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
	["ValveBiped.Bip01_R_Finger0"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(6.468, -2.203, 54.722) },
	["ValveBiped.Bip01_R_Finger01"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(-2, 2, 0) }
}


SWEP.IronSightsPos = Vector(-2.28, -10.3, 2.37)
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
	if !IsValid(self.Owner) then return pos,ang end
	local cv = GetConVar("gphone_bob")
	local bob = cv and cv:GetFloat() or 1
	if bob == 0 then return pos,ang end
	
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
	
	if bob != 0 then
		local p = (1-c_move)*c_sight*bob
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
	
	local cv = GetConVar("gphone_focus")
	local focus = cv and cv:GetFloat() or 0
	local offset = self.IronSightsPos
	ang = ang * 1
	
	if self.IronSightsAng then
		ang:RotateAroundAxis(ang:Right(), 	self.IronSightsAng.x * c_iron)
		ang:RotateAroundAxis(ang:Up(), 		self.IronSightsAng.y * c_iron)
		ang:RotateAroundAxis(ang:Forward(), self.IronSightsAng.z * c_iron)
	end
	
	pos = pos + (offset.x + focus*0.052) * ang:Right() * c_iron
	pos = pos + (offset.y + focus) * ang:Forward() * c_iron
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

local function clickFrame( frame, x, y, double )
	local children = {}
	local function clickChildren( pnl )
		local px,py = parentPos( pnl )
		local bx,by,bw,bh = px,py,pnl.w,pnl.h
		if x < bx or x > bx + bw or y < by or y > by + bh or !pnl.visible then return end
		table.insert(children, pnl)
		for _,child in pairs(pnl.children) do
			clickChildren( child )
		end
	end
	clickChildren( frame )
	
	local button = children[#children]
	if button then
		if button.OnClick then
			GPhone.DebugFunction( button.OnClick, button, double )
		end
	end
end

local function clickApp( x, y )
	for k,data in pairs(GPhone.GetPage()) do
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

function SWEP:Think()
	local ct = CurTime()
	self:NextThink( ct )
	if SERVER then return true end
	if !IsValid(self.Owner) or !game.SinglePlayer() and !IsFirstTimePredicted() then return true end
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
	
	if GPhone.CurrentFrame then
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
		
		if GPhone.CurrentApp and GPhone.CurrentApp != "" then
			local app = GPhone.GetApp( GPhone.CurrentApp )
			
			if app.Think then
				GPhone.DebugFunction( app.Think, GPhone.CurrentFrame, GPhone.Width, GPhone.Height, GPhone.Resolution )
			end
		end
	end
	
	if GPhone.CursorEnabled and !vgui.CursorVisible() then
		local cv = GetConVar("gphone_holdtime")
		local rx,ry = GPhone.CursorPos.x,GPhone.CursorPos.y
		local x,y = rx / 1120 * GPhone.Width,ry / 1660 * GPhone.Height
		
		if input.IsMouseDown( MOUSE_LEFT ) and !self.b_leftdown then -- Mouse down
			self.b_leftdown = true
			self.b_override = nil
			self.b_lefthold = st
			
			if !GPhone.AppScreen.Enabled and GPhone.MoveMode then -- Moving apps
				local windows = GPhone.GetAppPos()
				local page = math.Clamp(GPhone.Page, 1, #windows)
				
				for k,data in pairs(windows[page]) do
					local posx,posy,size,appid = data.x,data.y,data.size,data.app
					
					if x > posx and x < posx + size and y > posy and y < posy + size then
						if GPhone.GetApp( appid ) then
							GPhone.MovingApp = appid
							break
						end
					end
				end
			end
		elseif ( self.b_lefthold or st ) < st - (cv and cv:GetFloat() or 0.4) and !GPhone.MoveMode and !GPhone.AppScreen.Enabled then -- Mouse hold
			self.b_lefthold = nil
			local home = self.ScreenInfo.home
			
			if rx > home.x and rx < home.x + home.size and ry > home.y and ry < home.y + home.size then -- Hold home button
				self.b_override = true
				GPhone.AppScreen.Enabled = true
				GPhone.AppScreen.Scroll = 0
				if GPhone.CurrentApp then
					local space = 0
					for appid,_ in pairs(GPhone.Panels) do
						if appid == GPhone.CurrentApp then
							GPhone.AppScreen.Scroll = space
							break
						end
						space = space - 1
					end
					GPhone.AppThumbnail( GPhone.CurrentApp )
					GPhone.FocusHome()
				end
			elseif x >= 0 and x <= GPhone.Width and y >= 0 and y <= GPhone.Height and (!GPhone.CurrentApp or GPhone.CurrentApp == "") then -- Enter MoveMode
				self.b_override = true
				GPhone.MoveMode = true
			elseif GPhone.CurrentFrame then -- Double-clicking in app
				clickFrame( GPhone.CurrentFrame, x, y, true )
				self.b_override = true
				self.b_downtime = ct + 0.25
			end
		elseif !input.IsMouseDown( MOUSE_LEFT ) and self.b_leftdown then -- Mouse release
			self.b_leftdown = nil
			self.b_lefthold = nil
			
			if self.b_override then return end
			
			local home = self.ScreenInfo.home
			self.b_downtime = ct + 0.25
			
			if GPhone.GetInputText() then -- Close text input
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
			elseif GPhone.MovingApp then -- Move app on top of one another
				local oldpos = 0
				
				for k,appid in pairs(GPhone.Data.apps) do
					if appid == GPhone.MovingApp then
						oldpos = k
						break
					end
				end
				
				if oldpos > 0 then
					for _,data in pairs(GPhone.GetPage()) do
						local posx,posy,size,old = data.x,data.y,data.size,data.app
						
						if x > posx and x < posx + size and y > posy and y < posy + size then
							for k,id in pairs(GPhone.Data.apps) do
								if old == id then
									local apps = GPhone.GetData("apps", {})
									apps[k] = GPhone.MovingApp
									apps[oldpos] = id
									GPhone.SetData("apps", apps)
									break
								end
							end
							break
						end
					end
				end
				
				GPhone.MovingApp = nil
				self.b_downtime = 0
			elseif GPhone.MoveMode then -- Stop editing screen
				GPhone.MovingApp = nil
				GPhone.MoveMode = nil
			elseif rx > home.x and rx < home.x + home.size and ry > home.y and ry < home.y + home.size then -- Home button pressed
				if GPhone.CurrentApp then -- Go to home screen
					GPhone.AppThumbnail( GPhone.CurrentApp )
				end
				GPhone.FocusHome()
			elseif GPhone.CurrentFrame then -- Clicking inside an app
				clickFrame( GPhone.CurrentFrame, x, y, false )
			else
				clickApp( x, y )
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
		GPhone.DownloadImage( GPhone.Data.background, 512, "background-color: #FFF" )
		
		for k,app in pairs(GPhone.GetApps()) do
			GPhone.DownloadImage( app.Icon, 128, "background-color: #FFF; border-radius: 32px 32px 32px 32px" )
		end
	end
end

function SWEP:Deploy()
	self:SetNWFloat("DeployTime", CurTime() + 0.8)
	self:SetNWBool("Deployed", true)
	return true
end

function SWEP:Holster( wep )
	self:SetNWBool("Deployed", false)
	
	if CLIENT and IsValid(self.Owner) then
		GPhone.CursorEnabled = false
		
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			for bone = 0, vm:GetBoneCount() do
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
		if IsValid(self.HandModel) then
			self.HandModel:Remove()
		end
		if IsValid(self.PhoneModel) then
			self.PhoneModel:Remove()
		end
		
		GPhone.CursorEnabled = false
		
		for k,v in pairs(file.Find("gphone/screens/*.jpg", "DATA")) do
			file.Delete("gphone/screens/"..v)
		end
	end
	
	self:Holster()
end


if SERVER then return end -- Stop the server from here on

local dotemat = Material("gphone/dot_empty")
local dotfmat = Material("gphone/dot_full")
local blurmat = Material("pp/blurscreen")
local screenlight = 1

GPhone.PhoneRT = GetRenderTarget("GPhoneRT_"..GPhone.Height, GPhone.Width*1.032, GPhone.Height*1.032, false)
GPhone.PhoneMT = CreateMaterial(
	"GPhoneMT_"..GPhone.Height,
	"UnlitGeneric",
	{
		["$basetexture"] = GPhone.PhoneRT,
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 1
	}
)

SWEP.ScreenInfo = {
	pos = Vector(2.625, 2, -3.592),
	ang = Angle(0, -180.477, -92.2),
	size = 0.002,
	bone = "ValveBiped.Bip01_MobilePhone",
	home = {
		x = 492,
		y = 1792,
		size = 144
	},
	draw = function( wep, w, h, ratio )
		local cv = GetConVar("gphone_showbounds")
		
		if GPhone.AppScreen and GPhone.AppScreen.Enabled then
			hook.Run("GPhonePreRenderBackground", w, h)
			
			local appscr = GPhone.AppScreen
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial( GPhone.GetImage( GPhone.Data.background ) )
			surface.DrawTexturedRect(0, 0, GPhone.Width, GPhone.Height)
			
			local blur = GetConVar("gphone_blur")
			if blur and blur:GetBool() then
				render.BlurRenderTarget( render.GetRenderTarget(), 6, 4, 8 )
			end
			
			hook.Run("GPhonePostRenderBackground", w, h)
			
			local space,scale = 0,appscr.Scale
			local offset = appscr.Offset * scale
			local w,h = GPhone.Width*scale,GPhone.Height*scale
			for appid,frame in pairs(GPhone.Panels) do
				local app = GPhone.GetApp( appid )
				if !app then continue end
				
				local x,y = GPhone.Width/2 - w/2 + (w + appscr.Spacing) * (space + appscr.Scroll), GPhone.Height/2 - h/2
				space = space + 1
				if x + w < 0 or x > GPhone.Width then continue end
				draw.RoundedBox(0, x, y - offset, w, offset + h, Color(0, 0, 0, 200))
				
				surface.SetDrawColor(255, 255, 255)
				surface.SetTexture( surface.GetTextureID( "gui/html/stop" ) )
				surface.DrawTexturedRect( x + w/2 - offset/2, y - offset, offset, offset )
				
				if file.Exists("gphone/screens/"..appid..".jpg", "DATA") then
					surface.SetDrawColor(255, 255, 255, 255)
					surface.SetMaterial( Material("data/gphone/screens/"..appid..".jpg") )
					surface.DrawTexturedRect(x, y, w, h)
				else
					surface.DrawRect(x, y, w, h)
				end
				
				if cv and cv:GetBool() then
					surface.SetDrawColor( Color( 255, 0, 0, 255 ) )
					surface.DrawOutlinedRect( x, y, w, h )
					surface.DrawOutlinedRect( x, y - offset, w, offset )
				end
				
				local size = 64*ratio
				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetMaterial( GPhone.GetImage( app.Icon ) )
				surface.DrawTexturedRect(x + w/2 - size/2, y + h + appscr.Spacing, size, size)
			end
		elseif GPhone.CurrentFrame then
			local frame = GPhone.CurrentFrame
			local oldw,oldh = ScrW(),ScrH()
			
			local exclude = {}
			
			local function drawChildren( pnl )
				if pnl.children then
					for _,child in pairs(pnl.children) do
						if !child.visible then continue end
						
						if exclude[child] then
							GPhone.CurrentFrame = nil
							local name = " "
							if GPhone.CurrentApp then
								local app = GPhone.GetApp(GPhone.CurrentApp)
								if app and app.Name then
									name = " '"..app.Name.."' "
								else
									name = " '"..GPhone.CurrentApp.."' "
								end
								GPhone.Panels[GPhone.CurrentApp] = nil
							end
							GPhone.Debug("[ERROR] App"..name.."stuck in infinite loop\n  1. "..tostring(child).." - App terminated\n", false, true)
							GPhone.FocusHome()
							break
						end
						
						if child.Paint then
							local px,py = parentPos( child.parent )
							local max,may = GPhone.Width*0.016 + math.max(px + child.x, 0), GPhone.Height*0.016 + math.max(py + child.y, 0)
							local mix,miy = math.min(GPhone.Width*0.016 + px + child.x + child.w, GPhone.PhoneMT:Width()), math.min(GPhone.Height*0.016 + py + child.y + child.h, GPhone.PhoneMT:Height())
							
							if mix < 0 or miy < 0 or max > GPhone.Width*1.032 or may > GPhone.Height*1.032 then continue end
							
							render.SetViewPort(max, may, oldw, oldh)
							render.SetScissorRect(max, may, mix, miy, true)
							GPhone.DebugFunction( child.Paint, child, px + child.x, py + child.y, child.w, child.h )
							
							if cv and cv:GetBool() then
								surface.SetDrawColor( Color( 255, 0, 0, 255 ) )
								surface.DrawOutlinedRect( 0, 0, child.w, child.h )
							end
							
							render.SetScissorRect(0, 0, 0, 0, false)
						end
						
						exclude[child] = true
						
						drawChildren( child )
					end
				end
			end
			
			if frame.Paint then
				local offset = GPhone.Height*0.016 + (frame.b_fullscreen and 0 or GPhone.Desk.Offset)
				render.SetViewPort(GPhone.Width*0.016, offset, oldw, oldh)
				GPhone.DebugFunction( frame.Paint, frame, frame.x, frame.y, frame.w, frame.h )
				
				if cv and cv:GetBool() then
					surface.SetDrawColor( Color( 255, 0, 0, 255 ) )
					surface.DrawOutlinedRect( 0, 0, frame.w, frame.h )
				end
			end
			drawChildren( frame )
		else
			hook.Run("GPhonePreRenderBackground", w, h)
			
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial( GPhone.GetImage( GPhone.Data.background ) )
			surface.DrawTexturedRect(0, 0, w, h)
			
			hook.Run("GPhonePostRenderBackground", w, h)
			
			for k,data in pairs(GPhone.GetPage()) do
				local posx,posy,size,appid = data.x,data.y,data.size,data.app
				local app = GPhone.GetApp(appid)
				
				if GPhone.MoveMode then
					if GPhone.MovingApp != appid then
						local ran = math.Rand(-4,4)
						
						surface.SetDrawColor(255, 255, 255, 255)
						surface.SetMaterial( GPhone.GetImage( app.Icon ) )
						surface.DrawTexturedRectRotated(posx + size/2, posy + size/2, size, size, ran)
						
						draw.SimpleText(app.Name, "GPAppName", posx + size/2 - ran/4 + 2, posy + size - ran/4 + 2, Color(0,0,0), TEXT_ALIGN_CENTER)
						draw.SimpleText(app.Name, "GPAppName", posx + size/2 - ran/4, posy + size - ran/4, Color(255,255,255), TEXT_ALIGN_CENTER)
						
						if cv and cv:GetBool() then
							surface.SetDrawColor( Color( 255, 0, 0, 255 ) )
							surface.DrawOutlinedRect( posx, posy, size, size )
						end
					end
				else
					surface.SetDrawColor(255, 255, 255, 255)
					surface.SetMaterial( GPhone.GetImage( app.Icon ) )
					surface.DrawTexturedRect(posx, posy, size, size)
					
					draw.SimpleText(app.Name, "GPAppName", posx + size/2 + 2, posy + size + 2, Color(0,0,0), TEXT_ALIGN_CENTER)
					draw.SimpleText(app.Name, "GPAppName", posx + size/2, posy + size, Color(255,255,255), TEXT_ALIGN_CENTER)
					
					if cv and cv:GetBool() then
						surface.SetDrawColor( Color( 255, 0, 0, 255 ) )
						surface.DrawOutlinedRect( posx, posy, size, size )
					end
				end
			end
			
			local pages = #GPhone.GetAppPos()
			if pages > 1 then
				for i = 1, pages do
					surface.SetDrawColor(255, 255, 255, 255)
					if GPhone.Page == i then
						surface.SetMaterial( dotfmat )
					else
						surface.SetMaterial( dotemat )
					end
					surface.DrawTexturedRect(w/2 - (pages*32)/2 + i*32 - 32, h-32, 24, 24)
				end
			end
		end
	end
}

function SWEP:ViewModelDrawn()
	local cv = GetConVar("gphone_blur")
	if cv and cv:GetBool() then
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
	
	local p = (self.ViewModelFlip and -1 or 1)
	
	self.PhoneModel:SetPos(pos + ang:Forward() * self.PhoneInfo.pos.x + ang:Right() * self.PhoneInfo.pos.y * p + ang:Up() * self.PhoneInfo.pos.z)
	ang:RotateAroundAxis(ang:Up(), p * self.PhoneInfo.ang.y)
	ang:RotateAroundAxis(ang:Right(), p * self.PhoneInfo.ang.p)
	ang:RotateAroundAxis(ang:Forward(), p * self.PhoneInfo.ang.r)
	
	self.PhoneModel:SetAngles(ang)
	
	self.PhoneModel:SetLOD(0)
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
	
	pos = pos + ang:Forward() * self.ScreenInfo.pos.x + ang:Right() * self.ScreenInfo.pos.y * p + ang:Up() * self.ScreenInfo.pos.z * p
	ang:RotateAroundAxis(ang:Up(), p * self.ScreenInfo.ang.y)
	ang:RotateAroundAxis(ang:Right(), p * self.ScreenInfo.ang.p)
	ang:RotateAroundAxis(ang:Forward(), p * self.ScreenInfo.ang.r)
	
	local cv = GetConVar("gphone_lighting")
	if cv and cv:GetBool() and !GPhone.SelfieEnabled() then
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
	end
	
	cam.Start3D2D(pos, ang, self.ScreenInfo.size)
		local cv = GetConVar("gphone_brightness")
		local light = 0.65 + math.Clamp(render.ComputeLighting(EyePos(), -ang:Forward()):Length(), 0, 0.35)
		screenlight = Lerp(FrameTime()*5, screenlight, 0.05 + 0.95 * light * math.Clamp(cv and cv:GetFloat() or 1, 0, 1))
		
		surface.SetDrawColor(255 * screenlight, 255 * screenlight, 255 * screenlight)
		surface.SetMaterial( GPhone.PhoneMT )
		surface.DrawTexturedRect(0, 0, 560*2, 830*2)
		
		local dbg = GetConVar("gphone_showbounds")
		if dbg and dbg:GetBool() then
			surface.SetDrawColor( Color(250,250,250,100) )
			surface.DrawRect( self.ScreenInfo.home.x, self.ScreenInfo.home.y, self.ScreenInfo.home.size, self.ScreenInfo.home.size )
		end
		
		-- draw.RoundedBox(0, self.ScreenInfo.home.x, self.ScreenInfo.home.y, self.ScreenInfo.home.size, self.ScreenInfo.home.size, Color(250,250,250,100)) -- For drawing the HOME-button. Debugging
		
		if !GPhone.MovingApp then
			local col = LocalPlayer():GetWeaponColor()
			local x,y = GPhone.CursorPos.x,GPhone.CursorPos.y
			
			if GPhone.CursorEnabled then
				local cv = GetConVar("gphone_cursorsize")
				local size = math.Round(cv and cv:GetFloat() or 60)
				if GPhone.GetInputText() then
					local w = math.Round(size/6)
					local h = math.Round(size - w*2)
					
					draw.RoundedBox(0, x - h/2 + 1, y - size/2 + 1,	h, w, Color(70,70,70,255))
					draw.RoundedBox(0, x - w/2 + 1, y - h/2 + 1,	w, h, Color(70,70,70,255))
					draw.RoundedBox(0, x - h/2 + 1, y + h/2 + 1,	h, w, Color(70,70,70,255))
					
					draw.RoundedBox(0, x - h/2, y - size/2,	h, w, Color(col.x*255, col.y*255, col.z*255,255))
					draw.RoundedBox(0, x - w/2, y - h/2,	w, h, Color(col.x*255, col.y*255, col.z*255,255))
					draw.RoundedBox(0, x - h/2, y + h/2,	h, w, Color(col.x*255, col.y*255, col.z*255,255))
				else
					local cmat = GetConVar("gphone_cursormat")
					local mat = cmat and cmat:GetString() or "effects/select_dot"
					surface.SetDrawColor(col.x*255, col.y*255, col.z*255, 255)
					surface.SetTexture( surface.GetTextureID( mat ) )
					surface.DrawTexturedRect(x - size/2, y - size/2, size, size)
				end
			end
		end
	cam.End3D2D()
end

hook.Add("RenderScene", "GPhoneRenderPhoneRT", function(origin, angles, fov)
	local wep = LocalPlayer():GetActiveWeapon()
	if IsValid(wep) and wep:GetClass() == "gmod_gphone" and wep.ScreenInfo then
		GPhone.PhoneMT:SetTexture("$basetexture", GPhone.PhoneRT)
		
		render.PushRenderTarget(GPhone.PhoneRT)
		render.Clear(0, 0, 0, 255, true, true)
		cam.Start2D()
			local oldw,oldh = ScrW(),ScrH()
			local w,h = GPhone.Width,GPhone.Height
			local offset = GPhone.Desk.Offset
			local x,y = GPhone.GetCursorPos()
			local app = GPhone.GetApp( GPhone.CurrentApp )
			local frame = GPhone.Panels[GPhone.CurrentApp]
			local fullscreen = (!app or frame and frame.b_fullscreen) and !GPhone.AppScreen.Enabled
			
			render.SetViewPort(w*0.016, h*0.016, oldw, oldh)
			
			hook.Run("GPhonePreRenderScreen", w, h)
			
			if wep.ScreenInfo.draw then
				if fullscreen then
					GPhone.DebugFunction( wep.ScreenInfo.draw, wep, w, h, GPhone.Resolution )
				else
					GPhone.DebugFunction( wep.ScreenInfo.draw, wep, w, h - offset, GPhone.Resolution )
				end
			end
			
			render.SetViewPort(w*0.016, h*0.016, oldw, oldh)
			
			if GPhone.MovingApp then
				local a = GPhone.GetApp( GPhone.MovingApp )
				local size = GPhone.GetAppSize()
				local posx,posy = math.Clamp(x, 0, w),math.Clamp(y, 0, h)
				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetMaterial( GPhone.GetImage( a.Icon ) )
				surface.DrawTexturedRect(posx - size/2, posy - size/2, size, size)
				
				draw.SimpleText(a.Name, "GPAppName", posx + 2, posy + size/2 + 2, Color(0,0,0), TEXT_ALIGN_CENTER)
				draw.SimpleText(a.Name, "GPAppName", posx, posy + size/2, Color(255,255,255), TEXT_ALIGN_CENTER)
				
				local cv = GetConVar("gphone_showbounds")
				if cv and cv:GetBool() then
					surface.SetDrawColor( Color( 255, 0, 0, 255 ) )
					surface.DrawOutlinedRect( posx - size/2, posy - size/2, size, size )
				end
			end
			
			if !app or !fullscreen then
				local p_col = Color(255,255,255)
				local shadow = true
				if app and !GPhone.AppScreen.Enabled then
					shadow = false
					if app.Negative then
						draw.RoundedBox(0, 0, 0, w, offset, Color(0,0,0))
					else
						draw.RoundedBox(0, 0, 0, w, offset, Color(255,255,255))
						p_col = Color(0,0,0)
					end
				end
				
				hook.Run("GPhonePreRenderTopbar", w, offset)
				
				local ampm = GetConVar("gphone_ampm")
				local sf = GetConVar("gphone_sf")
				local time = ampm and ampm:GetBool() and os.date("%I:%M %p") or os.date("%H:%M")
				if sf and sf:GetBool() and StormFox then
					time = StormFox.GetRealTime(nil, ampm and ampm:GetBool() or false)
				end
				
				surface.SetFont( "GPTopBar" )
				local gts = surface.GetTextSize( "GMad Inc." )
				
				if shadow then
					draw.SimpleText(time, "GPTopBar", w/2 + 2, offset/2 + 2, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					draw.SimpleText("GMad Inc.", "GPTopBar", 6, offset/2 + 2, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					
					surface.SetDrawColor(0, 0, 0, 255)
					surface.SetTexture( surface.GetTextureID( "gphone/wifi_3") )
					surface.DrawTexturedRect(gts + 10, 6, offset-8, offset-8)
					
					surface.SetDrawColor(0, 0, 0, 255)
					surface.SetTexture( surface.GetTextureID( "gphone/battery") )
					surface.DrawTexturedRect(w-offset*2-2, 6, offset*2-8, offset-8)
				end
				
				draw.SimpleText(time, "GPTopBar", w/2, offset/2, p_col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText("GMad Inc.", "GPTopBar", 4, offset/2, p_col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				
				surface.SetDrawColor(p_col.r, p_col.g, p_col.b, 255)
				surface.SetTexture( surface.GetTextureID( "gphone/wifi_3") )
				surface.DrawTexturedRect(gts + 8, 4, offset-8, offset-8)
				
				surface.SetDrawColor(p_col.r, p_col.g, p_col.b, 255)
				surface.SetTexture( surface.GetTextureID( "gphone/battery") )
				surface.DrawTexturedRect(w-offset*2-4, 4, offset*2-8, offset-8)
				
				local p = math.Clamp(system.BatteryPower()/100, 0, 1)
				if p > 0 then
					if shadow then
						draw.SimpleText(math.Round(p*100).."%", "GPTopBar", w-offset*2-6, offset/2 + 2, Color(0, 0, 0), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
						
						surface.SetDrawColor(0, 0, 0, 255)
						surface.SetTexture( surface.GetTextureID( "gphone/battery_meter") )
						surface.DrawTexturedRectUV(w-offset*2-2, 6, (offset*2-8)*p, offset-8, 0, 0, p, 1)
					end
					
					draw.SimpleText(math.Round(p*100).."%", "GPTopBar", w-offset*2-8, offset/2, p_col, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
					if p <= 0.2 then
						surface.SetDrawColor(255, 0, 0, 255)
					else
						surface.SetDrawColor(p_col.r, p_col.g, p_col.b, 255)
					end
					surface.SetTexture( surface.GetTextureID( "gphone/battery_meter") )
					surface.DrawTexturedRectUV(w-offset*2-4, 4, (offset*2-8)*p, offset-8, 0, 0, p, 1)
				end
				
				hook.Run("GPhonePostRenderTopbar", w, offset)
			end
			
			hook.Run("GPhonePostRenderScreen", w, h)
			
			if GPhone.CursorEnabled then
				local ct = CurTime()
				if (wep.b_downtime or 0) > ct then
					local p = (wep.b_downtime - ct)*4
					local cv = GetConVar("gphone_cursorsize")
					local size = math.Round((1-p)*1.5*(cv and cv:GetFloat() or 60))
					
					surface.SetDrawColor(255, 255, 255, p*255)
					surface.SetTexture(surface.GetTextureID("effects/select_ring"))
					surface.DrawTexturedRect(x - size/2, y - size/2, size, size)
				end
			end
			
			render.SetViewPort(0, 0, oldw, oldh)
		cam.End2D()
		render.PopRenderTarget()
	end
end)


local lmbmat = Material("gphone/icons/lmb.png")
local rmbmat = Material("gphone/icons/rmb.png")
local infmat = Material("gphone/icons/hint.png")
local scrmat = Material("gphone/icons/scroll.png")

function SWEP:DrawHUD()
	local cv = GetConVar("gphone_hints")
	if cv and cv:GetBool() then
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
	
	local cv = GetConVar("gphone_wepicon")
	if cv and cv:GetBool() then
		local fsin = math.sin( RealTime() * 10 )
		
		local centerx, centery = x + wide/2,y + tall/2
		local radius = wide/2
		
		local apps = GPhone.GetApps()
		local size = (32 + 8 * fsin) * GPhone.Resolution
		local frag = (math.pi * 2) / table.Count( apps )
		local i = frag
		
		for name,app in pairs(apps) do
			i = i + frag
			
			local r = RealTime()*4
			local s,c = math.sin(i + r),math.cos(i + r)
			
			surface.SetDrawColor( 255, 255, 255, alpha )
			surface.SetMaterial( GPhone.GetImage( app.Icon ) )
			surface.DrawTexturedRectRotated( centerx - s * radius, centery - c * radius, size, size, math.deg(i + r) )
		end
		
		if !IsValid(WeaponInfoEnt) then
			WeaponInfoEnt = ClientsideModel( self.WorldModel, RENDER_GROUP_OPAQUE_ENTITY )
			WeaponInfoEnt:SetNoDraw( true )
			WeaponInfoEnt:SetModel( self.WorldModel )
			WeaponInfoEnt:SetSkin( 4 )
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
			
			local vec = Vector(32,0,0)
			local ang = Vector(-1,0,0):Angle()
			
			cam.Start3D( vec, ang, 14, x, y + tall*0.22, wide, tall, 5, 48 )
				render.SuppressEngineLighting( true )
				
				render.ResetModelLighting( 50/255, 50/255, 50/255 )
				render.SetColorModulation( 1, 1, 1 )
				render.SetBlend( alpha/255 )
				
				render.SetModelLighting( 4, 1, 1, 1 )
				
				WeaponInfoEnt:SetupBones()
				WeaponInfoEnt:DrawModel()
				
				render.SetColorModulation( 1, 1, 1 )
				render.SetBlend( 1 )
				render.SuppressEngineLighting( false )
			cam.End3D()
		end
	else
		local ratio = GPhone.Ratio
		local w = tall * ratio
		
		surface.SetDrawColor( 255, 255, 255, alpha )
		surface.SetTexture( self.WepSelectIcon )
		surface.DrawTexturedRect( x + wide/2 - w/2, y, w, tall )
	end
end


function SWEP:PostDrawViewModel( vm )
	local cv = GetConVar("gphone_hands")
	if !cv or !cv:GetBool() then
		local hands = self.Owner:GetHands()
		if IsValid( hands ) then hands:DrawModel() end
	else
		if !IsValid(self.HandModel) then
			local mdl = ClientsideModel("models/weapons/c_arms_citizen.mdl", RENDERGROUP_OPAQUE)
			mdl:SetBodygroup( 1, 1 )
			mdl:SetNoDraw(true)
			mdl:SetParent( vm )
			mdl:AddEffects( EF_BONEMERGE )
			function mdl:GetPlayerColor()
				return Vector(0, 0, 0)
			end
			self.HandModel = mdl
		end
		
		local hands = self.HandModel
		if IsValid( hands ) then hands:DrawModel() end
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
		
		local cv = GetConVar("gphone_lighting")
		if cv and cv:GetBool() then
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
		end
	else
		self:SetSkin( 1 )
		self:DrawModel()
	end
end