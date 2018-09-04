-- APP.Name	= "Contacts"
APP.Author	= "Krede"
APP.Icon	= "https://raw.githubusercontent.com/KredeGC/GPhone/master/images/contacts.png"
function APP.Run( frame, w, h )
	function frame:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 220, 220, 220, 255 ) )
	end
	
	local scroll = GPnl.AddPanel( frame, "scroll" )
	scroll:SetPos( 0, 64 )
	scroll:SetSize( w, h-128 )
	
	for k,ply in pairs(player.GetAll()) do
		if !IsValid(ply) or ply == LocalPlayer() then continue end
		local name = ply:Nick()
		
		local but = GPnl.AddPanel( scroll )
		but:SetSize( GPhone.Width, 64 )
		but:SetPos( 0, k*64 + -25 )
		function but:Paint( x, y, w, h )
			draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
			draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
			
			surface.SetDrawColor(80, 80, 80)
			surface.SetMaterial( GPhone.GetImage( "https://raw.githubusercontent.com/KredeGC/GPhone/master/images/useranony.png" ) )
			surface.DrawTexturedRect( 2, 2, h-4, h-4 )
			
			draw.SimpleText(name, "GPMedium", 34, h/2, Color(70, 70, 70), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
		function but:OnClick()
			if IsValid(ply) then
				GPhone.RequestVoiceChat( ply )
			end
		end
	end
	
	local header = GPnl.AddPanel( frame )
	header:SetPos( 0, 0 )
	header:SetSize( w, 64 )
	function header:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("Contacts", "GPTitle", w/2, h/2, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	local footer = GPnl.AddPanel( frame )
	footer:SetPos( 0, h-64 )
	footer:SetSize( w, 64 )
	function footer:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, 2, Color( 80, 80, 80, 255 ) )
		draw.RoundedBox( 0, 0, 2, w, h-2, Color( 255, 255, 255, 255 ) )
	end
	
	local trash = GPnl.AddPanel( footer )
	trash:SetPos( footer:GetWidth()-64, 0 )
	trash:SetSize( 64, 64 )
	function trash:Paint( x, y, w, h )
		if GPhone.VoiceChatting then
			surface.SetDrawColor(255, 0, 0)
		else
			surface.SetDrawColor(50, 50, 50)
		end
		surface.SetTexture( surface.GetTextureID( "gui/html/stop" ) )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
	function trash:OnClick()
		GPhone.StopVoiceChat()
	end
end