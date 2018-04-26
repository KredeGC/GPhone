APP.Name = "Photos"
APP.Icon = "https://raw.githubusercontent.com/KredeGC/GPhone/master/gphone/photos.png"
function APP.Run( frame, w, h )
	function frame:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 220, 220, 220, 255 ) )
	end
	frame.m_chosen = {}
	
	function frame.Open( pic, mat )
		frame:Clear()
		
		local bigpic = GPnl.AddPanel( frame )
		bigpic:SetPos( 0, -GPhone.Desk.Offset )
		bigpic:SetSize( w, GPhone.Height )
		function bigpic:Paint( x, y, w, h )
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial( mat )
			surface.DrawTexturedRect( 0, 0, w, h )
		end
		function bigpic:OnClick()
			local bool = !footer:GetVisible()
			footer:SetVisible( bool )
			header:SetVisible( bool )
			local off = frame:SetFullScreen( !bool )
			self:SetPos( 0, -off )
		end
		
		footer = GPnl.AddPanel( frame )
		footer:SetPos( 0, h-64 )
		footer:SetSize( w, 64 )
		function footer:Paint( x, y, w, h )
			draw.RoundedBox( 0, 0, 0, w, 2, Color( 80, 80, 80, 255 ) )
			draw.RoundedBox( 0, 0, 2, w, h-2, Color( 255, 255, 255, 255 ) )
		end
		
		header = GPnl.AddPanel( frame )
		header:SetPos( 0, 0 )
		header:SetSize( w, 64 )
		function header:Paint( x, y, w, h )
			draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
			draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
			
			draw.SimpleText(pic, "GPTitle", w/2, h/2, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		
		if file.Exists(pic, "DATA") then
			local trash = GPnl.AddPanel( footer )
			trash:SetPos( footer:GetWidth()-64, 0 )
			trash:SetSize( 64, 64 )
			function trash:Paint( x, y, w, h )
				surface.SetDrawColor(255, 0, 0)
				surface.SetTexture( surface.GetTextureID( "gui/html/stop" ) )
				surface.DrawTexturedRect( 0, 0, w, h )
			end
			function trash:OnClick()
				if file.Exists(pic, "DATA") then
					file.Delete(pic)
				end
				frame.Main()
			end
		end
		
		local back = GPnl.AddPanel( header )
		back:SetPos( 0, 0 )
		back:SetSize( 64, 64 )
		function back:OnClick()
			frame.Main()
		end
		function back:Paint( x, y, w, h )
			draw.SimpleText("<", "GPTitle", w/2, h/2, Color(0, 160, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
	
	function frame.Main()
		frame:Clear()
		
		local scroll = GPnl.AddPanel( frame, "scroll" )
		scroll:SetPos( 0, 64 )
		scroll:SetSize( w, h-128 )
		
		local x = 0
		local y = 0
		local width = w/4
		local height = width / GPhone.Ratio
		local pics = file.Find("*.jpg", "DATA")
		
		for i,jpg in pairs(pics) do
			timer.Simple((i-1)*0.05, function()
				x = x + 1
				
				while x > 4 do
					x = 1
					y = y + 1
				end
				
				local but = GPnl.AddPanel( scroll )
				but:SetSize( width, height )
				but:SetPos( x*width - width, y*height )
				but.pic = jpg
				but.mat = Material("data/"..jpg)
				function but:Paint( x, y, w, h )
					if frame and frame.m_choose and table.HasValue(frame.m_chosen, but) then
						draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 200, 255 ) )
					end
					
					surface.SetDrawColor(255, 255, 255)
					surface.SetMaterial( but.mat )
					surface.DrawTexturedRect( 2, 2, w-4, h-4 )
				end
				function but:OnClick()
					if frame.m_choose then
						if table.HasValue(frame.m_chosen, but) then
							table.RemoveByValue(frame.m_chosen, but)
						else
							table.insert(frame.m_chosen, but)
						end
					else
						frame.Open( but.pic, but.mat )
					end
				end
			end)
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
		trash:SetVisible(false)
		function trash:Paint( x, y, w, h )
			if frame and frame.m_chosen and #frame.m_chosen > 0 then
				surface.SetDrawColor(255, 0, 0)
				surface.SetTexture( surface.GetTextureID( "gui/html/stop" ) )
				surface.DrawTexturedRect( 0, 0, w, h )
			else
				surface.SetDrawColor(50, 50, 50)
				surface.SetTexture( surface.GetTextureID( "gui/html/stop" ) )
				surface.DrawTexturedRect( 0, 0, w, h )
			end
		end
		function trash:OnClick()
			if frame and frame.m_chosen and #frame.m_chosen > 0 then
				for k,but in pairs(frame.m_chosen) do
					if file.Exists(but.pic, "DATA") then
						file.Delete(but.pic)
					end
					but:Remove()
				end
				frame.m_choose = false
				frame.m_chosen = {}
				trash:SetVisible(false)
				frame.Main()
			end
		end
		
		local header = GPnl.AddPanel( frame )
		header:SetPos( 0, 0 )
		header:SetSize( w, 64 )
		function header:Paint( x, y, w, h )
			draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
			draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
			
			draw.SimpleText("Photos", "GPTitle", w/2, h/2, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		
		local choose = GPnl.AddPanel( header )
		choose:SetSize( 104, 64 )
		choose:SetPos( w-104, 0 )
		function choose:Paint( x, y, w, h )
			if !frame then return end
			if !frame.m_choose then
				draw.SimpleText("Pick", "GPMedium", w-5, h/2, Color(0, 160, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			else
				draw.SimpleText("Cancel", "GPMedium", w-5, h/2, Color(0, 160, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			end
		end
		function choose:OnClick()
			local b = !frame.m_choose
			frame.m_choose = b
			if !b then
				frame.m_chosen = {}
				trash:SetVisible(false)
			else
				trash:SetVisible(true)
			end
		end
	end
	
	frame.Main()
end