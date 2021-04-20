APP.Name	= "Settings"
APP.Author	= "Krede"
APP.Icon	= "asset://garrysmod/materials/gphone/apps/settings.png"
function APP.Run( frame, w, h, ratio )
	function frame:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 220, 220, 220, 255 ) )
	end
	
	local mar = (64 - 36) / 2 * ratio
	
	local main = frame:AddTab( "home", "panel" )
    local space = 12 * ratio
    
	local pad = 8 * ratio
	local size = 64 * ratio - pad * 2
	
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
		
		draw.SimpleText("Apps", "GPMedium", mar, h/2, Color(70, 70, 70), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	function apptab:OnClick()
		local pnl = frame:GetTab( "apps" )
		pnl:Refresh()
		frame:OpenTab( "apps", 0.25, "in-right", "out-left" )
	end
	
	space = space + 64 * ratio
	
	local storagetab = GPnl.AddPanel( scroll )
	storagetab:SetSize( w, 64 * ratio )
	storagetab:SetPos( 0, space )
	function storagetab:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("Storage", "GPMedium", mar, h/2, Color(70, 70, 70), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	function storagetab:OnClick()
		local pnl = frame:GetTab( "storage" )
		pnl:Refresh()
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
	
	local systemtab = GPnl.AddPanel( scroll )
	systemtab:SetSize( w, 64 * ratio )
	systemtab:SetPos( 0, space )
	function systemtab:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("System", "GPMedium", mar, h/2, Color(70, 70, 70), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	function systemtab:OnClick()
		frame:OpenTab( "system", 0.25, "in-right", "out-left" )
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
	
	local holdlabel = GPnl.AddPanel( scroll, "panel" )
	holdlabel:SetSize( w, 64 * ratio )
	holdlabel:SetPos( 0, space )
	function holdlabel:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("Hold time", "GPMedium", mar, h/2, Color(70, 70, 70), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
    
	local hold = GPnl.AddPanel( holdlabel, "textentry" )
	hold:SetSize( size * 2, 64 * ratio )
	hold:SetPos( w - size * 2 - pad, 0 )
    hold:SetFont( "GPMedium" )
    hold:SetBackColor( Color(0, 0, 0, 0) )
	hold:SetText( math.Round(GetConVar("gphone_holdtime"):GetFloat(), 2) )
    hold:SetAlignment( TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
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
	
	local toggle = GPnl.AddPanel( ampm, "toggle" )
	toggle:SetSize( size*2, size )
	toggle:SetPos( w - size*2 - pad, pad )
	if GPhone.GetData("ampm", false) then
		toggle:SetToggle( true )
	end
    function toggle:OnChange( bool )
        GPhone.SetData("ampm", bool)
	end
	
	space = space + 64 * ratio
	
	local murica = GPnl.AddPanel( scroll, "panel" )
	murica:SetSize( w, 64 * ratio )
	murica:SetPos( 0, space )
	function murica:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("Use imperial units", "GPMedium", mar, h/2, Color(70, 70, 70), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	
	local toggle = GPnl.AddPanel( murica, "toggle" )
	toggle:SetSize( size*2, size )
	toggle:SetPos( w - size*2 - pad, pad )
	if GPhone.GetData("imperial", false) then
		toggle:SetToggle( true )
	end
    function toggle:OnChange( bool )
        GPhone.SetData("imperial", bool)
	end
	
	space = space + 64 * ratio
	
	local rowlabel = GPnl.AddPanel( scroll, "panel" )
	rowlabel:SetSize( w, 64 * ratio )
	rowlabel:SetPos( 0, space )
	function rowlabel:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("App rows", "GPMedium", mar, h/2, Color(70, 70, 70), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
    
	local rows = GPnl.AddPanel( rowlabel, "textentry" )
	rows:SetSize( size * 2, 64 * ratio )
	rows:SetPos( w - size * 2 - pad, 0 )
    rows:SetFont( "GPMedium" )
    rows:SetBackColor( Color(0, 0, 0, 0) )
	rows:SetText( GetConVar("gphone_rows"):GetInt() )
    rows:SetAlignment( TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
	function rows:OnEnter( val )
		local val = tonumber(val)
		if val then
			local num = math.Clamp(val, 0, 6)
			self:SetText( num )
			RunConsoleCommand("gphone_rows", num)
		end
	end
	
	space = space + 64 * ratio
	
	local brightlabel = GPnl.AddPanel( scroll, "panel" )
	brightlabel:SetSize( w, 64 * ratio )
	brightlabel:SetPos( 0, space )
	function brightlabel:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("Brightness", "GPMedium", mar, h/2, Color(70, 70, 70), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
    
	local brightness = GPnl.AddPanel( brightlabel, "textentry" )
	brightness:SetSize( size * 2, 64 * ratio )
	brightness:SetPos( w - size * 2 - pad, 0 )
    brightness:SetFont( "GPMedium" )
    brightness:SetBackColor( Color(0, 0, 0, 0) )
	brightness:SetText( math.Round(GetConVar("gphone_brightness"):GetFloat() * 100) )
    brightness:SetAlignment( TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
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
    wallpaper:SetFont("GPMedium")
	wallpaper:SetText( "" )
	function wallpaper:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		local text = self.b_typing and GPhone.GetInputText() or "Change wallpaper"
		draw.SimpleText(text, self:GetFont(), mar, h/2, Color(70, 70, 70), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	function wallpaper:OnEnter( path )
        GPhone.SetData("background", path)
        self:SetText( "" )
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
	
	
	
	local apps = frame:AddTab( "apps", "panel" )
	
	local scroll = GPnl.AddPanel( apps, "scroll" )
	scroll:SetPos( 0, 64 * ratio )
	scroll:SetSize( w, h - 64 * ratio )
	
	function apps:Refresh()
		scroll:Clear()
		local space = 12 * ratio
		for _,name in pairs(GPhone.Data.apps or {}) do
			if GPDefaultApps and table.HasValue(GPDefaultApps, name) then continue end
			local app = GPhone.GetApp(name)
			if !app then return end
			
			local but = GPnl.AddPanel( scroll )
			but:SetSize( w, 110 * ratio )
			but:SetPos( 0, space )
			but.Name = app.Name or name
			but.Author = app.Author or "N/A"
			function but:Paint( x, y, w, h )
				draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
				draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
				
				draw.SimpleText(self.Name, "GPMedium", h + 4, 4, Color(70, 70, 70), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				draw.SimpleText(self.Author or "N/A", "GPSmall", h + 4, h/2, Color(160, 160, 160), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
			
			local icon = GPnl.AddPanel( but )
			icon:SetSize( 102 * ratio, 102 * ratio )
			icon:SetPos( 4 * ratio, 4 * ratio )
			icon.Icon = app.Icon or "N/A"
			function icon:Paint( x, y, w, h )
				surface.SetDrawColor( 255, 255, 255 )
				surface.SetMaterial( GPhone.GetImage( self.Icon ) )
				surface.DrawTexturedRect( 0, 0, w, h )
			end
			
			local clear = GPnl.AddPanel( but )
			clear:SetSize( 120 * ratio, 40 * ratio )
			clear:SetPos( w - 145 * ratio, 35 * ratio )
			clear.App = name
			function clear:Paint( x, y, w, h )
				draw.RoundedBox(0, 0, 0, w, h, Color(15, 200, 90))
				draw.RoundedBox(0, 4, 4, w-8, h-8, Color(255, 255, 255))
				draw.SimpleText("Uninstall", "GPMedium", w/2, h/2, Color(15, 200, 90), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
			function clear:OnClick()
				GPhone.UninstallApp(self.App)
				self:Remove()
			end
			
			space = space + 110 * ratio
		end
	end
	
	local header = GPnl.AddPanel( apps )
	header:SetPos( 0, 0 )
	header:SetSize( w, 64 * ratio )
	function header:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("Apps", "GPTitle", w/2, h/2, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
	
	local scroll = GPnl.AddPanel( storage, "scroll" )
	scroll:SetPos( 0, 64 * ratio )
	scroll:SetSize( w, h - 64 * ratio )
	
	function storage:Refresh()
		scroll:Clear()
		local space = 12 * ratio
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
    
    
    local system = frame:AddTab( "system", "panel" )
	
	local scroll = GPnl.AddPanel( system, "scroll" )
	scroll:SetPos( 0, 64 * ratio )
	scroll:SetSize( w, h - 64 * ratio )
    
    local number = GPnl.AddPanel( scroll )
	number:SetSize( w, 64 * ratio )
	number:SetPos( 0, 12 * ratio )
	function number:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80 ) )
		
		draw.SimpleText("Phone Number: "..LocalPlayer():AccountID(), "GPMedium", mar, h/2, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
    
    local copy = GPnl.AddPanel( number )
	copy:SetSize( 80 * ratio, 64 * ratio )
	copy:SetPos( w - 80 * ratio, 0 )
	function copy:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 80, 80, 80 ) )
		draw.RoundedBox( 0, 2, 2, w-4, h-4, Color( 255, 255, 255 ) )
		
		draw.SimpleText("Copy", "GPSmall", w/2, h/2, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	function copy:OnClick()
		SetClipboardText( LocalPlayer():AccountID() )
    end
	
	local header = GPnl.AddPanel( system )
	header:SetPos( 0, 0 )
	header:SetSize( w, 64 * ratio )
	function header:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80 ) )
		
		draw.SimpleText("System", "GPTitle", w/2, h/2, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
	
	local scroll = GPnl.AddPanel( about, "scroll" )
	scroll:SetPos( 0, 64 * ratio )
	scroll:SetSize( w, h - 64 * ratio )
	
	local content = GPnl.AddPanel( scroll, "panel" )
	content:SetSize( w, 280 * ratio )
	content:SetPos( 0, 12 * ratio )
	function content:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h - 2, Color( 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h - 2, w, 2, Color( 80, 80, 80, 255 ) )
		
		surface.SetDrawColor(255, 255, 255)
		surface.SetTexture( surface.GetTextureID( "vgui/entities/gmod_gphone" ) )
		surface.DrawTexturedRect( 8, 8, h - 16, h - 16 )
		
		draw.SimpleText("GPhone Remade", "GPTitle", h + 4, 0, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("Created by Krede", "GPMedium", h + 4, 42 * ratio, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		if self.Update then
			draw.SimpleText("Last update:", "GPSmall", h + 4, h - 36*2 * ratio, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			draw.SimpleText(self.Update, "GPSmall", h + 4, h - 36 * ratio, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
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
	
	local update = GPnl.AddPanel( scroll )
	update:SetSize( w, 64 * ratio )
	update:SetPos( 0, 292 * ratio )
	function update:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("Go to Workshop", "GPMedium", w/2, h/2, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	function update:OnClick()
		gui.OpenURL( "https://steamcommunity.com/sharedfiles/filedetails/?id=1370983401" )
	end
end