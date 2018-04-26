APP.Name = "Camera"
APP.Icon = "https://raw.githubusercontent.com/KredeGC/GPhone/master/gphone/camera.png"
function APP.Run( frame, w, h )
	frame:SetFullScreen( true )
	local h = frame.h
	frame.front = LocalPlayer():GetNWBool("GPSelfie")
	
	function frame:Paint( x, y, w, h )
		local mat = GPhone.RenderCamera( 90, self.front )
		
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial( mat )
		surface.DrawTexturedRect(0, 0, w, h)
		
		draw.RoundedBox(0, 0, h-100, w, 100, Color(0, 0, 0, 150))
	end
	
	local switch = GPnl.AddPanel( frame )
	switch:SetSize( 80, 80 )
	switch:SetPos( 0, 0 )
	function switch:Paint( x, y, w, h )
		surface.SetDrawColor(255, 255, 255)
		surface.SetTexture( surface.GetTextureID( "gui/html/refresh" ) )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
	function switch:OnClick()
		local bool = !frame.front
		frame.front = bool
		net.Start("GPhone_Selfie")
			net.WriteBool( bool )
		net.SendToServer()
	end
	
	local photo = GPnl.AddPanel( frame )
	photo:SetSize( 80, 80 )
	photo:SetPos( w-90, h-90 )
	function photo:Paint( x, y, w, h )
		if self.last then
			local s = w/GPhone.Ratio
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial( self.last )
			surface.DrawTexturedRect( 0, h/2 - s/2, w, s )
		end
	end
	
	local screenshot = GPnl.AddPanel( frame )
	screenshot:SetSize( 100, 100 )
	screenshot:SetPos( w/2-100/2, h-100 )
	function screenshot:Paint( x, y, w, h )
		surface.SetDrawColor(255, 255, 255)
		surface.SetTexture( surface.GetTextureID( "sgm/playercircle" ) )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
	function screenshot:OnClick()
		GPhone.RenderCamera(90, frame.front, function(pos, ang)
			local data = render.Capture( {
				format = "jpeg",
				quality = 100,
				x = 0,
				y = 0,
				w = w,
				h = h
			} )
			
			local name = game.GetMap().."_"..os.time()..".jpg"
			file.Write(name, data)
			photo.last = Material("data/"..name)
		end)
	end
end

function APP.Stop( frame )
	net.Start("GPhone_Selfie")
		net.WriteBool( false )
	net.SendToServer()
end