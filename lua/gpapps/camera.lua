APP.Name	= "Camera"
APP.Author	= "Krede"
APP.Icon	= "https://raw.githubusercontent.com/KredeGC/GPhone/master/images/camera.png"
function APP.Run( frame, w, h, ratio )
	frame:SetFullScreen( true )
	local h = frame.h
	frame.front = GPhone.SelfieEnabled()
	frame.fov = 80
	
	function frame:OnScroll( num )
		self.fov = math.Clamp(self.fov - num*5, 5, 100)
	end
	function frame:Paint( x, y, w, h )
		local mat = GPhone.RenderCamera( frame.fov, self.front )
		
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial( mat )
		surface.DrawTexturedRect(0, 0, w, h)
		
		draw.RoundedBox(0, 0, h - 100 * ratio, w, 100 * ratio, Color(0, 0, 0, 150))
	end
	
	local face = GPnl.AddPanel( frame )
	face:SetSize( 160 * ratio, 80 * ratio )
	face:SetPos( w - 160 * ratio, 0 )
	face:SetVisible( false )
	function face:Paint( x, y, w, h )
		surface.SetDrawColor(255, 255, 255)
		surface.SetTexture( surface.GetTextureID( "vgui/face/grin" ) )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
	function face:OnClick()
		frame.smile = !frame.smile
	end
	
	local switch = GPnl.AddPanel( frame )
	switch:SetSize( 80 * ratio, 80 * ratio )
	switch:SetPos( 0, 0 )
	function switch:Paint( x, y, w, h )
		surface.SetDrawColor(255, 255, 255)
		surface.SetTexture( surface.GetTextureID( "gui/html/refresh" ) )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
	function switch:OnClick()
		local bool = !frame.front
		frame.front = bool
		face:SetVisible( bool )
		GPhone.EnableSelfie( bool )
	end
	
	local photo = GPnl.AddPanel( frame )
	photo:SetSize( 80 * ratio, 80 * ratio )
	photo:SetPos( w-90 * ratio, h-90 * ratio )
	function photo:Paint( x, y, w, h )
		if self.last then
			local s = w/GPhone.Ratio
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial( GPhone.GetImage( "data/"..self.last ) )
			surface.DrawTexturedRect( 0, h/2 - s/2, w, s )
		end
	end
	function photo:OnClick()
		if !self.last then return end
		local frame = GPhone.RunApp( "photos" )
		if frame then
			frame:Open( self.last, GPhone.GetImage( "data/"..self.last ) )
		end
	end
	
	local screenshot = GPnl.AddPanel( frame )
	screenshot:SetSize( 100 * ratio, 100 * ratio )
	screenshot:SetPos( w/2 - (100 * ratio)/2, h - 100 * ratio )
	function screenshot:Paint( x, y, w, h )
		surface.SetDrawColor(255, 255, 255)
		surface.SetTexture( surface.GetTextureID( "sgm/playercircle" ) )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
	function screenshot:OnClick()
		surface.PlaySound("npc/scanner/scanner_photo1.wav")
		
		file.CreateDir("gphone/photos")
		
		GPhone.RenderCamera(frame.fov, frame.front, nil, function(pos, ang)
			local data = render.Capture( {
				format = "jpeg",
				quality = 100,
				x = 0,
				y = 0,
				w = w,
				h = h
			} )
			
			local name = os.time()..".jpg"
			file.Write("gphone/photos/"..name, data)
			GPhone.DownloadImage( "data/gphone/photos/"..name )
			photo.last = "gphone/photos/"..name
		end)
	end
end

function APP.Think( frame )
	local p = frame.smile and 1 or 0
	local ply = LocalPlayer()
	local flex = ply:GetFlexNum() - 1
	if flex > 0 then
		for i = 0, flex do
			if ply:GetFlexName(i) == "smile" then -- Makes a creepy smile
				ply:SetFlexWeight( i, p )
			end
		end
	end
end

function APP.Focus( frame )
	if frame.front then
		GPhone.EnableSelfie( true )
	end
end