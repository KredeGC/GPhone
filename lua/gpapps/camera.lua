APP.Name	= "Camera"
APP.Author	= "Krede"
APP.Icon	= "https://raw.githubusercontent.com/KredeGC/GPhone/master/images/camera.png"
function APP.Run( frame, w, h, ratio )
	frame:SetFullScreen( true )
	local h = frame.h
	local ls = GPhone.Landscape
	local size = 100 * ratio
	frame.front = GPhone.SelfieEnabled()
	frame.fov = 80
	frame.pad = 110 * ratio
	
	function frame:OnScroll( num )
		self.fov = math.Clamp(self.fov - num*5, 5, 100)
	end
    function frame:Paint( x, y, w, h )
        local mat = GPhone.RenderCamera( frame.fov, self.front )
		
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial( mat )
		surface.DrawTexturedRect(0, 0, w, h)
		
		if GPhone.Landscape then
			draw.SimpleText(self.fov, "GPMedium", w - self.pad, h/2, Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText(self.fov, "GPMedium", w/2, h - self.pad, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
		end
	end
	
	local panel = GPnl.AddPanel( frame )
	if ls then
		panel:SetSize( size, w )
		panel:SetPos( w - size, 0 )
	else
		panel:SetSize( w, size )
		panel:SetPos( 0, h - size )
	end
	function panel:Paint( x, y, w, h )
		surface.SetDrawColor( Color(0, 0, 0, 150) )
		surface.DrawRect(0, 0, w, h)
	end
	
	local photo = GPnl.AddPanel( panel )
	photo:SetSize( size * 0.8, size * 0.8 )
    photo:SetPos( (ls and 0 or w - size) + size * 0.1, size * 0.1 )
	function photo:Paint( x, y, w, h )
		if self.last then
			local s = w/GPhone.Ratio
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial( photo.mat )
			surface.DrawTexturedRect( 0, h/2 - s/2, w, s )
		end
	end
	function photo:OnClick()
		if !self.last then return end
		local photos = GPhone.RunApp( "photos" )
		if photos then
			photos:Open( self.last, photo.mat )
		end
	end
	
	local screenshot = GPnl.AddPanel( panel )
	screenshot:SetSize( size, size )
	if ls then
		screenshot:SetPos( 0, h/2 - size/2 )
	else
		screenshot:SetPos( w/2 - size/2, 0 )
	end
	function screenshot:Paint( x, y, w, h )
		surface.SetDrawColor(255, 255, 255)
		surface.SetTexture( surface.GetTextureID( "sgm/playercircle" ) )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
	function screenshot:OnClick()
        surface.PlaySound("npc/scanner/scanner_photo1.wav")
        
        --[[local dlight = DynamicLight( ent:EntIndex() )
        if dlight then
            dlight.Pos = vOffset
            dlight.r = 255
            dlight.g = 255
            dlight.b = 255
            dlight.Brightness = 10
            dlight.Size = 512
            dlight.DieTime = CurTime() + 0.02
            dlight.Decay = 512
        end]]
		
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
            photo.mat = Material("data/"..photo.last, "smooth")
		end)
	end
	
	local face = GPnl.AddPanel( frame )
	face:SetSize( 160 * ratio, 80 * ratio )
	if ls then
		face:SetPos( 0, h - 80 * ratio )
	else
		face:SetPos( w - 160 * ratio, 0 )
	end
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
end

function APP.Think( frame )
	if !frame.front then return end
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