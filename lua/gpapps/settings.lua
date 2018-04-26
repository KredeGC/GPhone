APP.Name = "Settings"
APP.Icon = "https://raw.githubusercontent.com/KredeGC/GPhone/master/gphone/settings.png"
function APP.Run( frame, w, h )
	function frame:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 220, 220, 220, 255 ) )
	end
	
	
	local main = frame:AddTab( "home", "panel" )
	local space = 12
	
	local scroll = GPnl.AddPanel( main, "scroll" )
	scroll:SetPos( 0, 64 )
	scroll:SetSize( w, h-64 )
		
	local appeartab = GPnl.AddPanel( scroll )
	appeartab:SetSize( w, 64 )
	appeartab:SetPos( 0, space )
	function appeartab:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("Appearance", "GPMedium", w/2, h/2, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	function appeartab:OnClick()
		frame:OpenTab( "appearance", 0.25, "in-right", "out-left" )
	end
	
	space = space + 64
	
	local debugtab = GPnl.AddPanel( scroll )
	debugtab:SetSize( w, 64 )
	debugtab:SetPos( 0, space )
	function debugtab:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("Developer", "GPMedium", w/2, h/2, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	function debugtab:OnClick()
		frame:OpenTab( "debug", 0.25, "in-right", "out-left" )
	end
	
	space = space + 64
	
	local abouttab = GPnl.AddPanel( scroll )
	abouttab:SetSize( w, 64 )
	abouttab:SetPos( 0, space )
	function abouttab:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("About", "GPMedium", w/2, h/2, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	function abouttab:OnClick()
		frame:OpenTab( "about", 0.25, "in-right", "out-left" )
	end
	
	local header = GPnl.AddPanel( main )
	header:SetPos( 0, 0 )
	header:SetSize( w, 64 )
	function header:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("Settings", "GPTitle", w/2, h/2, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	frame:OpenTab( "home" )
	
	
	
	local appearance = frame:AddTab( "appearance", "panel" )
	local space = 12
	
	local scroll = GPnl.AddPanel( appearance, "scroll" )
	scroll:SetPos( 0, 64 )
	scroll:SetSize( w, h-64 )
	
	local hold = GPnl.AddPanel( scroll, "textentry" )
	hold:SetSize( w, 64 )
	hold:SetPos( 0, space )
	hold:SetText( math.Round(GetConVar("gphone_holdtime"):GetFloat(), 2) )
	function hold:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		local text = self.b_typing and GPhone.GetInputText() or self:GetText()
		draw.SimpleText("Hold time: "..text, self:GetFont(), w/2, h/2, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	function hold:OnEnter( val )
		if tonumber(val) then
			self:SetText( val )
			RunConsoleCommand("gphone_holdtime", val)
		end
	end
	
	space = space + 64
	
	local ampm = GPnl.AddPanel( scroll, "panel" )
	ampm:SetSize( w, 64 )
	ampm:SetPos( 0, space )
	function ampm:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("Use AM/PM", "GPMedium", w/2, h/2, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	local pad = 8
	local size = 64-pad*2
	local toggle = GPnl.AddPanel( ampm, "toggle" )
	toggle:SetSize( size*2, size )
	toggle:SetPos( w - size*2 - pad, pad )
	if GetConVar("gphone_ampm"):GetBool() then
		toggle:SetToggle( true )
	end
	function toggle:OnChange( bool )
		RunConsoleCommand("gphone_ampm", bool and 1 or 0)
	end
	
	space = space + 64
	
	local wallpaper = GPnl.AddPanel( scroll, "textentry" )
	wallpaper:SetSize( w, 64 )
	wallpaper:SetPos( 0, space )
	function wallpaper:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		local text = self.b_typing and GPhone.GetInputText()
		if text then
			if text == "" then
				draw.SimpleText("...", "GPMedium", w/2, h/2, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			else
				surface.SetFont("GPMedium")
				local size = surface.GetTextSize(text)
				
				if size > w then
					draw.SimpleText(text, "GPMedium", w, h/2, Color(70, 70, 70), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
				else
					draw.SimpleText(text, "GPMedium", w/2, h/2, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			end
		else
			draw.SimpleText("Change Wallpaper", "GPMedium", w/2, h/2, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
	function wallpaper:OnEnter( val )
		GPhone.SaveData("background", val)
		GPhone.DownloadImage( val, 512, true )
	end
	
	local header = GPnl.AddPanel( appearance )
	header:SetPos( 0, 0 )
	header:SetSize( w, 64 )
	function header:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("Appearance", "GPTitle", w/2, h/2, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	local back = GPnl.AddPanel( header )
	back:SetPos( 0, 0 )
	back:SetSize( 64, 64 )
	function back:OnClick()
		frame:OpenTab( "home", 0.25, "in-left", "out-right" )
	end
	function back:Paint( x, y, w, h )
		draw.SimpleText("<", "GPTitle", w/2, h/2, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	
	
	local debugger = frame:AddTab( "debug", "panel" )
	local space = 12
	
	local scroll = GPnl.AddPanel( debugger, "scroll" )
	scroll:SetPos( 0, 64 )
	scroll:SetSize( w, h-64 )
		
	local wipe = GPnl.AddPanel( scroll )
	wipe:SetSize( w, 64 )
	wipe:SetPos( 0, space )
	function wipe:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("Wipe log", "GPMedium", w/2, h/2, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	function wipe:OnClick()
		GPhone.WipeLog()
	end
	
	space = space + 64
	
	local plog = GPnl.AddPanel( scroll )
	plog:SetSize( w, 64 )
	plog:SetPos( 0, space )
	function plog:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("Print log", "GPMedium", w/2, h/2, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	function plog:OnClick()
		GPhone.PrintLog()
	end
	
	local header = GPnl.AddPanel( debugger )
	header:SetPos( 0, 0 )
	header:SetSize( w, 64 )
	function header:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("Developer", "GPTitle", w/2, h/2, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	local back = GPnl.AddPanel( header )
	back:SetPos( 0, 0 )
	back:SetSize( 64, 64 )
	function back:OnClick()
		frame:OpenTab( "home", 0.25, "in-left", "out-right" )
	end
	function back:Paint( x, y, w, h )
		draw.SimpleText("<", "GPTitle", w/2, h/2, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	
	
	local about = frame:AddTab( "about", "panel" )
	
	local content = GPnl.AddPanel( about, "panel" )
	content:SetPos( 0, 64 )
	content:SetSize( w, h - 64 )
	function content:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 220, 220, 220 ) )
		draw.RoundedBox( 0, 0, 12, w, w/2-2, Color( 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, 10 + w/2, w, 2, Color( 80, 80, 80, 255 ) )
		
		surface.SetDrawColor(255, 255, 255)
		surface.SetTexture( surface.GetTextureID( "vgui/entities/weapon_gphone" ) )
		surface.DrawTexturedRect( 4, 16, w/2-8, w/2-8 )
		
		draw.SimpleText("GPhone 2.0", "GPTitle", w/2 + 4, 16, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("Created by Krede", "GPMedium", w/2 + 4, 16 + 42, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end
	
	local header = GPnl.AddPanel( about )
	header:SetPos( 0, 0 )
	header:SetSize( w, 64 )
	function header:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("About", "GPTitle", w/2, h/2, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	local back = GPnl.AddPanel( header )
	back:SetPos( 0, 0 )
	back:SetSize( 64, 64 )
	function back:OnClick()
		frame:OpenTab( "home", 0.25, "in-left", "out-right" )
	end
	function back:Paint( x, y, w, h )
		draw.SimpleText("<", "GPTitle", w/2, h/2, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	local update = GPnl.AddPanel( content )
	update:SetPos( 0, w/2 + 12 )
	update:SetSize( w, 64 )
	function update:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("Go to Workshop", "GPMedium", w/2, h/2, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	function update:OnClick()
		gui.OpenURL( "https://steamcommunity.com/sharedfiles/filedetails/?id=251989385" )
	end
end