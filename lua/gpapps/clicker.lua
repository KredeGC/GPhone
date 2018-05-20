APP.Name = "Garry Clicker"
APP.Icon = "https://raw.githubusercontent.com/KredeGC/GPhone/master/images/gmail.png"
function APP.Run( frame, w, h, ratio )
	function frame:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 200, 200, 255 ) )
		
		draw.SimpleText(GPhone.GetData("cookies", 0).." Cookies", "GPTitle", w/2, 42, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	local button = GPnl.AddPanel( frame )
	button:SetPos( w/2 - h/4, h/4 )
	button:SetSize( h/2, h/2 )
	function button:Paint( x, y, w, h )
		local p = math.Clamp((self.b_lerp or 0) - CurTime(), 0, 0.25)
		local size = w * (p + 0.75)
		surface.SetDrawColor(255, 255, 255)
		surface.SetTexture( surface.GetTextureID( "vgui/hsv" ) )
		surface.DrawTexturedRect( w/2 - size/2, w/2 - size/2, size, size )
	end
	function button:OnClick()
		self.b_lerp = CurTime() + 0.25
		local cookies = GPhone.GetData("cookies", 0)
		GPhone.SaveData("cookies", cookies + 1)
	end
end