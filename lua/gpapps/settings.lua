APP.Name	= "Settings"
APP.Author	= "Krede"
APP.Icon	= "https://raw.githubusercontent.com/KredeGC/GPhone/master/images/settings.png"
function APP.Run( frame, w, h, ratio )
	function frame:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 220, 220, 220, 255 ) )
	end
	
	local mar = (64 - 36) * ratio
	
	local main = frame:AddTab( "home", "panel" )
	local space = 12 * ratio
	
	local scroll = GPnl.AddPanel( main, "scroll" )
	scroll:SetPos( 0, 64 * ratio )
	scroll:SetSize( w, h - 64 * ratio )
		
	local appeartab = GPnl.AddPanel( scroll )
	appeartab:SetSize( w, 64 * ratio )
	appeartab:SetPos( 0, space )
	function appeartab:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("Appearance", "GPMedium", mar, h/2, Color(70, 70, 70), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	function appeartab:OnClick()
		frame:OpenTab( "appearance", 0.25, "in-right", "out-left" )
	end
	
	space = space + 64 * ratio
		
	local apptab = GPnl.AddPanel( scroll )
	apptab:SetSize( w, 64 * ratio )
	apptab:SetPos( 0, space )
	function apptab:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("Storage", "GPMedium", mar, h/2, Color(70, 70, 70), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	function apptab:OnClick()
		frame:OpenTab( "storage", 0.25, "in-right", "out-left" )
	end
	
	space = space + 64 * ratio
	
	local debugtab = GPnl.AddPanel( scroll )
	debugtab:SetSize( w, 64 * ratio )
	debugtab:SetPos( 0, space )
	function debugtab:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("Developer", "GPMedium", mar, h/2, Color(70, 70, 70), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	function debugtab:OnClick()
		frame:OpenTab( "debug", 0.25, "in-right", "out-left" )
	end
	
	space = space + 64 * ratio
	
	local abouttab = GPnl.AddPanel( scroll )
	abouttab:SetSize( w, 64 * ratio )
	abouttab:SetPos( 0, space )
	function abouttab:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("About", "GPMedium", mar, h/2, Color(70, 70, 70), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	function abouttab:OnClick()
		frame:OpenTab( "about", 0.25, "in-right", "out-left" )
	end
	
	local header = GPnl.AddPanel( main )
	header:SetPos( 0, 0 )
	header:SetSize( w, 64 * ratio )
	function header:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("Settings", "GPTitle", w/2, h/2, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	frame:OpenTab( "home" )
	
	
	
	local appearance = frame:AddTab( "appearance", "panel" )
	local space = 12 * ratio
	
	local scroll = GPnl.AddPanel( appearance, "scroll" )
	scroll:SetPos( 0, 64 * ratio )
	scroll:SetSize( w, h - 64 * ratio )
	
	local hold = GPnl.AddPanel( scroll, "textentry" )
	hold:SetSize( w, 64 * ratio )
	hold:SetPos( 0, space )
	hold:SetText( math.Round(GetConVar("gphone_holdtime"):GetFloat(), 2) )
	function hold:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		local text = self.b_typing and GPhone.GetInputText() or self:GetText()
		draw.SimpleText("Hold time: "..text, self:GetFont(), mar, h/2, Color(70, 70, 70), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	function hold:OnEnter( val )
		if tonumber(val) then
			self:SetText( val )
			RunConsoleCommand("gphone_holdtime", val)
		end
	end
	
	space = space + 64 * ratio
	
	local ampm = GPnl.AddPanel( scroll, "panel" )
	ampm:SetSize( w, 64 * ratio )
	ampm:SetPos( 0, space )
	function ampm:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("Use AM/PM", "GPMedium", mar, h/2, Color(70, 70, 70), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	
	local pad = 8 * ratio
	local size = 64 * ratio - pad*2
	local toggle = GPnl.AddPanel( ampm, "toggle" )
	toggle:SetSize( size*2, size )
	toggle:SetPos( w - size*2 - pad, pad )
	if GetConVar("gphone_ampm"):GetBool() then
		toggle:SetToggle( true )
	end
	function toggle:OnChange( bool )
		RunConsoleCommand("gphone_ampm", bool and 1 or 0)
	end
	
	space = space + 64 * ratio
	
	local rows = GPnl.AddPanel( scroll, "textentry" )
	rows:SetSize( w, 64 * ratio )
	rows:SetPos( 0, space )
	rows:SetText( GetConVar("gphone_rows"):GetInt() )
	function rows:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		local text = self.b_typing and GPhone.GetInputText() or self:GetText()
		draw.SimpleText("App rows: "..text, self:GetFont(), mar, h/2, Color(70, 70, 70), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	function rows:OnEnter( val )
		local val = tonumber(val)
		if val then
			local num = math.Clamp(val, 0, 6)
			self:SetText( num )
			RunConsoleCommand("gphone_rows", num)
		end
	end
	
	space = space + 64 * ratio
	
	local brightness = GPnl.AddPanel( scroll, "textentry" )
	brightness:SetSize( w, 64 * ratio )
	brightness:SetPos( 0, space )
	brightness:SetText( math.Round(GetConVar("gphone_brightness"):GetFloat()*100) )
	function brightness:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		local text = self.b_typing and GPhone.GetInputText() or self:GetText()
		draw.SimpleText("Brightness: "..text.."%", self:GetFont(), mar, h/2, Color(70, 70, 70), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	function brightness:OnEnter( val )
		local val = tonumber(val)
		if val then
			local num = math.Clamp(val, 0, 100)
			self:SetText( math.Round(num) )
			RunConsoleCommand("gphone_brightness", math.Round(num/100, 2))
		end
	end
	
	space = space + 64 * ratio
	
	local wallpaper = GPnl.AddPanel( scroll, "textentry" )
	wallpaper:SetSize( w, 64 * ratio )
	wallpaper:SetPos( 0, space )
	function wallpaper:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		local text = self.b_typing and GPhone.GetInputText()
		if text then
			if text == "" then
				draw.SimpleText("...", "GPMedium", mar, h/2, Color(70, 70, 70), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			else
				surface.SetFont("GPMedium")
				local size = surface.GetTextSize(text)
				
				if size > w - mar*2 then
					draw.SimpleText(text, "GPMedium", w - mar, h/2, Color(70, 70, 70), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
				else
					draw.SimpleText(text, "GPMedium", mar, h/2, Color(70, 70, 70), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end
			end
		else
			draw.SimpleText("Change Wallpaper", "GPMedium", mar, h/2, Color(70, 70, 70), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	end
	function wallpaper:OnEnter( val )
		GPhone.SetData("background", val)
		GPhone.DownloadImage( val, 512, true )
	end
	
	local header = GPnl.AddPanel( appearance )
	header:SetPos( 0, 0 )
	header:SetSize( w, 64 * ratio )
	function header:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("Appearance", "GPTitle", w/2, h/2, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	local back = GPnl.AddPanel( header )
	back:SetPos( 0, 0 )
	back:SetSize( 64 * ratio, 64 * ratio )
	function back:OnClick()
		frame:OpenTab( "home", 0.25, "in-left", "out-right" )
	end
	function back:Paint( x, y, w, h )
		draw.SimpleText("<", "GPTitle", w/2, h/2, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	
	
	local storage = frame:AddTab( "storage", "panel" )
	local space = 12 * ratio
	
	local scroll = GPnl.AddPanel( storage, "scroll" )
	scroll:SetPos( 0, 64 * ratio )
	scroll:SetSize( w, h - 64 * ratio )
	
	
	for name,data in pairs(GPhone.Data.appdata or {}) do
		local app = GPhone.GetApp(name)
		
		local but = GPnl.AddPanel( scroll )
		but:SetSize( w, 48 * ratio )
		but:SetPos( 0, space )
		but.Name = app and app.Name or name
		but.Size = string.len( util.TableToJSON( data ) ) - 2
		function but:Paint( x, y, w, h )
			draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
			draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
			
			draw.SimpleText(math.Round(self.Size/1024, 3).." kb", "GPSmall", w - h - mar, h/2, Color(70, 70, 70), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			
			draw.SimpleText(self.Name, "GPMedium", mar, h/2, Color(70, 70, 70), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
		
		local clear = GPnl.AddPanel( but )
		clear:SetSize( 48 * ratio, 48 * ratio )
		clear:SetPos( w - 48 * ratio, 0 )
		clear.App = name
		function clear:Paint( x, y, w, h )
			surface.SetDrawColor(70, 70, 70)
			surface.SetTexture( surface.GetTextureID( "gui/html/stop" ) )
			surface.DrawTexturedRect( 0, 0, w, h )
		end
		function clear:OnClick()
			but.Size = 0
			GPhone.ClearAllAppData(self.App)
			self:Remove()
		end
		
		space = space + 48 * ratio
	end
	
	local header = GPnl.AddPanel( storage )
	header:SetPos( 0, 0 )
	header:SetSize( w, 64 * ratio )
	function header:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("Storage", "GPTitle", w/2, h/2, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	local back = GPnl.AddPanel( header )
	back:SetPos( 0, 0 )
	back:SetSize( 64 * ratio, 64 * ratio )
	function back:OnClick()
		frame:OpenTab( "home", 0.25, "in-left", "out-right" )
	end
	function back:Paint( x, y, w, h )
		draw.SimpleText("<", "GPTitle", w/2, h/2, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	
	
	local debugger = frame:AddTab( "debug", "panel" )
	local space = 12 * ratio
	
	local scroll = GPnl.AddPanel( debugger, "scroll" )
	scroll:SetPos( 0, 64 * ratio )
	scroll:SetSize( w, h-64 * ratio )
		
	local wipe = GPnl.AddPanel( scroll )
	wipe:SetSize( w, 64 * ratio )
	wipe:SetPos( 0, space )
	function wipe:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("Wipe log", "GPMedium", mar, h/2, Color(70, 70, 70), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	function wipe:OnClick()
		GPhone.WipeLog()
	end
	
	space = space + 64 * ratio
	
	local plog = GPnl.AddPanel( scroll )
	plog:SetSize( w, 64 * ratio )
	plog:SetPos( 0, space )
	function plog:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("Print log", "GPMedium", mar, h/2, Color(70, 70, 70), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	function plog:OnClick()
		GPhone.PrintLog()
	end
	
	space = space + 64 * ratio
	
	local imag = GPnl.AddPanel( scroll )
	imag:SetSize( w, 64 * ratio )
	imag:SetPos( 0, space )
	function imag:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("Redownload Images", "GPMedium", mar, h/2, Color(70, 70, 70), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	function imag:OnClick()
		RunConsoleCommand("gphone_redownloadimages")
	end
	
	space = space + 64 * ratio
	
	local reset = GPnl.AddPanel( scroll )
	reset:SetSize( w, 64 * ratio )
	reset:SetPos( 0, space )
	function reset:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("Factory Reset", "GPMedium", mar, h/2, Color(255, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	function reset:OnClick()
		RunConsoleCommand("gphone_reset")
	end
	
	local header = GPnl.AddPanel( debugger )
	header:SetPos( 0, 0 )
	header:SetSize( w, 64 * ratio )
	function header:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("Developer", "GPTitle", w/2, h/2, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	local back = GPnl.AddPanel( header )
	back:SetPos( 0, 0 )
	back:SetSize( 64 * ratio, 64 * ratio )
	function back:OnClick()
		frame:OpenTab( "home", 0.25, "in-left", "out-right" )
	end
	function back:Paint( x, y, w, h )
		draw.SimpleText("<", "GPTitle", w/2, h/2, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	
	
	local about = frame:AddTab( "about", "panel" )
	
	local content = GPnl.AddPanel( about, "panel" )
	content:SetPos( 0, 64 * ratio )
	content:SetSize( w, h - 64 * ratio )
	function content:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 220, 220, 220 ) )
		draw.RoundedBox( 0, 0, 12, w, w/2-2, Color( 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, 10 + w/2, w, 2, Color( 80, 80, 80, 255 ) )
		
		surface.SetDrawColor(255, 255, 255)
		surface.SetTexture( surface.GetTextureID( "vgui/entities/gmod_gphone" ) )
		surface.DrawTexturedRect( 4, 16, w/2-8, w/2-8 )
		
		draw.SimpleText("GPhone Remade", "GPTitle", w/2 + 4, 16, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("Created by Krede", "GPMedium", w/2 + 4, 16 + 42 * ratio, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		if self.Update then
			draw.SimpleText("Last update:", "GPMedium", w/2 + 4, 8 + w/2 - 36*2 * ratio, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			draw.SimpleText(self.Update, "GPMedium", w/2 + 4, 8 + w/2 - 36 * ratio, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end
	end
	
	http.Fetch("https://steamcommunity.com/sharedfiles/filedetails/changelog/1370983401", function(body)
		local start = string.find(body, "Update: ")
		if start then
			local stop = string.find(body, "</div>", start)
			if stop then
				content.Update = string.Trim( string.sub(body, start+8, stop-1) )
			end
		end
	end,
	function(err)
		print(err)
	end)
	
	local header = GPnl.AddPanel( about )
	header:SetPos( 0, 0 )
	header:SetSize( w, 64 * ratio )
	function header:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("About", "GPTitle", w/2, h/2, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	local back = GPnl.AddPanel( header )
	back:SetPos( 0, 0 )
	back:SetSize( 64 * ratio, 64 * ratio )
	function back:OnClick()
		frame:OpenTab( "home", 0.25, "in-left", "out-right" )
	end
	function back:Paint( x, y, w, h )
		draw.SimpleText("<", "GPTitle", w/2, h/2, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	local update = GPnl.AddPanel( content )
	update:SetPos( 0, w/2 + 12 )
	update:SetSize( w, 64 * ratio )
	function update:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("Go to Workshop", "GPMedium", w/2, h/2, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	function update:OnClick()
		gui.OpenURL( "https://steamcommunity.com/sharedfiles/filedetails/?id=1370983401" )
	end
end