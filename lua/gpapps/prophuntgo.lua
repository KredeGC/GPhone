-- APP.Name = "Prophunt Go"
APP.Icon = "https://raw.githubusercontent.com/KredeGC/GPhone/master/gphone/gmail.png"
function APP.Run( frame, w, h )
	frame:SetFullScreen( true )
	
	function frame:Paint( x, y, w, h )
		local mat = GPhone.RenderCamera(90, false, function(pos, ang)
			cam.Start3D( pos, ang )
				
			cam.End3D()
		end)
		
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial( mat )
		surface.DrawTexturedRect(0, 0, w, h)
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
		print("You catched one!")
	end
end