APP.Name = "Maps"
APP.Icon = "https://raw.githubusercontent.com/KredeGC/GPhone/master/gphone/maps.png"
function APP.Run( frame, w, h )
	function frame:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 255 ) )
	end
	
	local arrowmat = Material("gphone/maps/arrow.png", "nocull smooth")
	local pointmat = Material("gphone/maps/point.png", "nocull smooth")
	local mat,offset,dist = LoadMapRT()
	
	local map = GPnl.AddPanel( frame )
	map:SetPos( 0, 64 )
	map:SetSize( w, w )
	function map:OnClick()
		local mx,my = CurrentMousePos.x,CurrentMousePos.y
		local point = GPnl.AddPanel( self )
		point:SetPos( mx-16, my-32-64-GPhone.Desk.Offset )
		point:SetSize( 32, 32 )
		function point:Paint( x, y, w, h )
			surface.SetDrawColor( 255, 0, 0 )
			surface.SetMaterial( pointmat )
			surface.DrawTexturedRect( 0, 0, w, h )
		end
		function point:OnClick()
			point:Remove()
		end
	end
	function map:Paint( x, y, w, h )
		local offx,offy = offset.x or 0,offset.y or 0
		local max = dist*2
		
		surface.SetDrawColor( 255, 255, 255 )
		surface.SetMaterial( mat )
		surface.DrawTexturedRect( 0, 0, w, w )
		
		--[[for _,v in pairs(self:GetChildren()) do
			local px,py = v:GetPos()
			local x,y = screenToRealPos( px, py, w, offx, offy, max )
			local pos = LocalPlayer():GetPos()
			local path = ComputeAStar( navmesh.GetNearestNavArea( pos ), navmesh.GetNearestNavArea( Vector(x, y, pos.z) ) )
			
			PrintTable(path)
		end]]
		
		for k,ply in pairs(player.GetAll()) do
			local plypos = ply:GetPos()
			local plyang = ply:EyeAngles()
			local plycol = ply:GetPlayerColor()*255
			local px,py = realToScreenPos( plypos.x, plypos.y, w, offx, offy, max )
			
			surface.SetDrawColor( plycol.r, plycol.g, plycol.b )
			surface.SetMaterial( arrowmat )
			surface.DrawTexturedRectRotated( px, py, 32, 32, plyang.y )
		end
	end
	
	local header = GPnl.AddPanel( frame )
	header:SetPos( 0, 0 )
	header:SetSize( w, 64 )
	function header:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText(game.GetMap(), "GPTitle", w/2, h/2, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	local refresh = GPnl.AddPanel( header )
	refresh:SetPos( w - 64, 0 )
	refresh:SetSize( 64, 64 )
	function refresh:Paint( x, y, w, h )
		surface.SetDrawColor(50, 50, 50)
		surface.SetTexture( surface.GetTextureID( "gui/html/refresh" ) )
		local ct = CurTime()
		
		if (self.Delay or 0) < ct then
			surface.DrawTexturedRect( 0, 0, w, h )
		else
			local p = (self.Delay - ct)*720
			surface.DrawTexturedRectRotated( w/2, h/2, w, h, p )
		end
	end
	function refresh:OnClick()
		self.Delay = CurTime() + 0.5
		mat,offset,dist = LoadMapRT( true )
	end
end


function realToScreenPos(x, y, size, offx, offy, max)
	local px,py = (x - offx),(y - offy)
	local x = size/2 - (px/max*size)
	local y = size/2 - (py/max*size)
	return y,x
end

function screenToRealPos(x, y, size, offx, offy, max)
	local px = (x/size*max) - max/2
	local py = (y/size*max) - max/2
	local x,y = -(px - offy),-(py - offx)
	return y,x
end

function LoadMapRT( reset )
	local size = 512
	local offset,dist = 0,0
	
	local bMapRT = GetRenderTarget("GPhoneMapRT", size, size, false)
	
	local oldDraw = nil
	LocalPlayer().ShouldDisableLegs = true
	if EnhancedCamera then
		oldDraw = EnhancedCamera.ShouldDraw
		EnhancedCamera.ShouldDraw = function() return false end
	end
	
	if !reset and file.Exists("maps/"..game.GetMap()..".jpg", "DATA") and file.Exists("maps/"..game.GetMap()..".txt", "DATA") then
		local r = file.Read("maps/"..game.GetMap()..".txt", "DATA")
		local data = util.JSONToTable(r)
		
		offset = data.offset
		dist = data.dist
	else
		local ratio = 16384 / size
		
		render.PushRenderTarget(bMapRT, 0, 0, size, size)
		
		render.Clear(0, 0, 0, 0)
		render.ClearStencil()
		render.ClearDepth()
		
		local pos = Vector(0, 0, 0)
		local ang = Angle(90,0,0)
		
		if bit.band( util.PointContents( Vector(0, 0, 0) ), CONTENTS_SOLID ) != CONTENTS_SOLID then
			local trace = util.TraceLine( {start = Vector(0, 0, 0), endpos = Vector(0, 0, 16384*2), mask = MASK_SOLID_BRUSHONLY} )
			pos = trace.HitPos + Vector(0, 0, -8)
		end
		
		rendering_gphone_map = true
		
		render.SetLightingMode( 1 )
		
		render.RenderView({
			x = 0,
			y = 0,
			w = size,
			h = size,
			origin = pos,
			angles = ang,
			drawviewmodel = false,
			drawhud = false,
			dopostprocess = false,
			drawmonitors = false,
			znear = 16,
			zfar = 32768,
			ortho = true,
			ortholeft = -16384,
			orthoright = 16384,
			orthotop = -16384,
			orthobottom = 16384
		})
		
		local leftpos = nil
		local toppos = nil
		local rightpos = nil
		local downpos = nil
		
		render.CapturePixels()
		
		for x = 1, size do
			for y = 1, size do
				if !leftpos then
					local r,g,b = render.ReadPixel( x, y ) -- Left
					if ( r != 255 or g != 255 or b != 255 ) and ( r != 0 or g != 0 or b != 0 ) then
						leftpos = x
					end
				end
				
				if !toppos then
					local r,g,b = render.ReadPixel( y, x ) -- Top
					if ( r != 255 or g != 255 or b != 255 ) and ( r != 0 or g != 0 or b != 0 ) then
						toppos = x
					end
				end
				
				if !rightpos then
					local r,g,b = render.ReadPixel( size - x, size - y ) -- Right
					if ( r != 255 or g != 255 or b != 255 ) and ( r != 0 or g != 0 or b != 0 ) then
						rightpos = x - 1
					end
				end
				
				if !downpos then
					local r,g,b = render.ReadPixel( size - y, size - x ) -- Bottom
					if ( r != 255 or g != 255 or b != 255 ) and ( r != 0 or g != 0 or b != 0 ) then
						downpos = x - 1
					end
				end
			end
		end
		
		local b_coords_x = (leftpos or 0)
		local b_coords_y = (toppos or 0)
		local b_coords_u = size - (rightpos or 0)
		local b_coords_v = size - (downpos or 0)
		
		local diffx = b_coords_u - b_coords_x
		local diffy = b_coords_v - b_coords_y
		
		local y,x = (size/2-(b_coords_x + diffx/2))*ratio*2, (size/2-(b_coords_y + diffy/2))*ratio*2
		
		offset = {x = x, y = y}
		dist = (math.max(diffx, diffy) + 4) * ratio
		
		render.RenderView({
			x = 0,
			y = 0,
			w = size,
			h = size,
			origin = pos,
			angles = ang,
			drawviewmodel = false,
			drawhud = false,
			dopostprocess = false,
			drawmonitors = false,
			znear = 16,
			zfar = 32768,
			ortho = true,
			ortholeft = - y - dist,
			orthoright = - y + dist,
			orthotop = x - dist,
			orthobottom = x + dist
		})
		
		render.SetLightingMode( 0 )
		
		rendering_gphone_map = false
		
		file.CreateDir("maps")
		
		local data = render.Capture( { format = "jpeg", quality = 100, x = 0, y = 0, h = size, w = size } )
		local mapimg = file.Open( "maps/"..game.GetMap()..".jpg", "wb", "DATA" )
		mapimg:Write( data )
		mapimg:Close()
		
		local data = {
			offset = offset,
			dist = dist
		}
		local mapfile = file.Open( "maps/"..game.GetMap()..".txt", "wb", "DATA" )
		mapfile:Write( util.TableToJSON(data) )
		mapfile:Close()
		
		render.PopRenderTarget()
	end
	
	LocalPlayer().ShouldDisableLegs = false
	if EnhancedCamera and oldDraw then
		EnhancedCamera.ShouldDraw = oldDraw
	end
	
	local bMapMat = Material("data/maps/"..game.GetMap()..".jpg")
	
	return bMapMat,offset,dist
end


hook.Add("PreDrawSkyBox", "GPhoneMapRenderSkybox", function()
	if rendering_gphone_map then
		return true
	end
end)

hook.Add("SetupWorldFog", "GPhoneMapSetupWorldFog", function()
	if rendering_gphone_map then
		render.FogMode( 0 )
		return true
	end
end)
hook.Add("SetupSkyboxFog", "GPhoneMapSetupSkyFog", function()
	if rendering_gphone_map then
		render.FogMode( 0 )
		return true
	end
end)