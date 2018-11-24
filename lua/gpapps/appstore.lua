APP.Name	= "AppStore"
APP.Author	= "Krede"
APP.Icon	= "https://raw.githubusercontent.com/KredeGC/GPhone/master/images/appstore.png"
function APP.Run( frame, w, h, ratio )
	function frame:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(220, 220, 220, 255) )
	end
	
	frame.title = "AppStore"
	frame.online = {}
	
	local function addbutton(name, app, click)
		local but = GPnl.AddPanel()
		but:SetSize( w, 110 * ratio )
		but:SetPos( 0, 0 )
		but.Name = app.Name
		but.App = name
		but.Author = app.Author
		function but:Paint( x, y, w, h )
			draw.RoundedBox( 0, 0, 0, w, h-2, Color(255, 255, 255, 255) )
			draw.RoundedBox( 0, 0, h-2, w, 2, Color(80, 80, 80, 255) )
			
			draw.SimpleText(self.Name, "GPMedium", h + 4, 4, Color(70, 70, 70), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			draw.SimpleText(self.Author or "N/A", "GPSmall", h + 4, h/2, Color(160, 160, 160), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
		
		local icon = GPnl.AddPanel( but )
		icon:SetSize( 102 * ratio, 102 * ratio )
		icon:SetPos( 4 * ratio, 4 * ratio )
		icon.Icon = app.Icon
		function icon:Paint( x, y, w, h )
			surface.SetDrawColor( 255, 255, 255 )
			surface.SetMaterial( GPhone.GetImage( self.Icon ) )
			surface.DrawTexturedRect( 0, 0, w, h )
		end
		
		local install = GPnl.AddPanel( but )
		install:SetSize( 120 * ratio, 40 * ratio )
		install:SetPos( w - (120 + 25) * ratio, 35 * ratio )
		function install:Paint( x, y, w, h )
			draw.RoundedBox(0, 0, 0, w, h, Color(15, 200, 90))
			draw.RoundedBox(0, 4, 4, w-8, h-8, Color(255, 255, 255))
			local text = table.HasValue(GPhone.Data.apps, but.App) and "Uninstall" or "Install"
			draw.SimpleText(text, "GPMedium", w/2, h/2, Color(15, 200, 90), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		function install:OnClick()
			click( but, self )
		end
		
		return but
	end
	
	local function addOnlineButton(name, app, click)
		local url = "http://gphone.icu/api/list?app="..app.App.."&id="..app.Id
		local name = GPhone.SerializeAppName(url)
		local but = addbutton(name, app, function(but)
			click( but, self )
		end)
		
		but.URL = url
		
		if app.Rating then
			local rating = GPnl.AddPanel( but )
			rating:SetSize( 24 * 5 * ratio, 24 * ratio )
			rating:SetPos( 110 * ratio + 4, (110 - 28) * ratio - 4 )
			rating.Rating = app.Rating
			rating.App = app.App
			rating.Id = app.Id
			function rating:Paint( x, y, w, h )
				local mx,my = GPhone.GetCursorPos()
				local votes = self.Rating
				
				if mx >= x and my >= y and mx <= x + w and my <= y + h then
					votes = math.Clamp( math.ceil( (mx - x) / w * 5 ), 1, 5 )
				end
				
				local rate = votes / 5
				local last = math.floor(votes)
				
				surface.SetDrawColor( 255 * (1-rate), 255 * rate, 0 )
				surface.SetTexture( surface.GetTextureID("gphone/dot_empty") )
				
				for i = 0, 4 do
					surface.DrawTexturedRect( i * h, 0, h, h )
				end
				
				surface.SetTexture( surface.GetTextureID("gphone/dot_full") )
				for i = 0, last do
					if i == last then
						local p = votes - last
						surface.DrawTexturedRectUV( i * h, 0, h * p, h, 0, 0, p, 1 )
					else
						surface.DrawTexturedRect( i * h, 0, h, h )
					end
				end
			end
			function rating:OnClick()
				local x = GPhone.RootToLocal( self, GPhone.GetCursorPos() )
				local rate = math.Clamp( math.ceil( x / self:GetWidth() * 5 ), 1, 5 )
				
				http.Post("http://gphone.icu/api/vote",
					{
						id = self.Id,
						app = self.App,
						vote = tostring(rate)
					},
					function( body, len, headers, code )
						print("[GPhone] "..body)
					end,
					function( err )
						print("[GPhone] "..err)
						return false
					end
				)
			end
		end
		
		if table.HasValue(GPhone.Data.apps, but.App) and app.Update then
			local update = GPnl.AddPanel( but )
			update:SetSize( 100 * ratio, 40 * ratio )
			update:SetPos( w - (120 * 2 + 25) * ratio, 35 * ratio )
			function update:Paint( x, y, w, h )
				draw.RoundedBox(0, 0, 0, w, h, Color(15, 200, 90))
				draw.RoundedBox(0, 4, 4, w-8, h-8, Color(255, 255, 255))
				draw.SimpleText("Update", "GPMedium", w/2, h/2, Color(15, 200, 90), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
			function update:OnClick()
				GPhone.DownloadApp( but.URL )
				self:Remove()
				app.Update = nil
			end
		end
		
		return but
	end
	
	local panel = GPnl.AddPanel( frame, "frame" )
	panel:SetPos( 0, 64 * ratio )
	panel:SetSize( w, h - 128 * ratio )
	
	
	local offline = panel:AddTab( "offline", "scroll" )
	offline:SetPos( 0, 0 )
	offline:SetSize( panel:GetSize() )
	function offline:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(220, 220, 220, 255) )
	end
	
	local count = -1
	for name,app in pairs(GPhone.GetApps()) do
		if GPDefaultApps and table.HasValue(GPDefaultApps, name) then continue end
		if file.Exists("gphone/apps/"..name..".txt", "DATA") then continue end
		count = count + 1
		
		local but = addbutton(name, app, function(but)
			if table.HasValue(GPhone.Data.apps, but.App) then
				GPhone.UninstallApp( but.App )
			else
				GPhone.InstallApp( but.App )
			end
		end)
		
		but:SetParent( offline )
		but:SetPos( 0, ( count * 110 + 6 ) * ratio )
	end
	
	
	local online = panel:AddTab( "online", "scroll" )
	online:SetPos( 0, 0 )
	online:SetSize( panel:GetSize() )
	function online:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(220, 220, 220, 255) )
	end
	
	local function loadOnlineApps()
		online:Clear()
		local count = -1
		for _,app in pairs(frame.online) do
			count = count + 1
			
			local but = addOnlineButton(name, app, function(but)
				if table.HasValue(GPhone.Data.apps, but.App) then
					GPhone.UninstallApp( but.App )
					app.Update = false
				else
					GPhone.DownloadApp( but.URL )
				end
			end)
			
			but:SetParent( online )
			but:SetPos( 0, ( count * 110 + 6 ) * ratio )
		end
	end
	
	
	local updates = panel:AddTab( "updates", "scroll" )
	updates:SetPos( 0, 0 )
	updates:SetSize( panel:GetSize() )
	function updates:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(220, 220, 220, 255) )
	end
	
	local function loadUpdateApps()
		updates:Clear()
		local count = -1
		for _,app in pairs(frame.online) do
			if !app.Update then continue end
			count = count + 1
			
			local but = addOnlineButton(name, app, function(but)
				if table.HasValue(GPhone.Data.apps, but.App) then
					GPhone.UninstallApp( but.App )
					app.Update = false
				else
					GPhone.DownloadApp( but.URL )
				end
			end)
			
			but:SetParent( updates )
			but:SetPos( 0, ( count * 110 + 6 ) * ratio )
		end
	end
	
	panel:OpenTab( "offline" )
	
	
	local header = GPnl.AddPanel( frame )
	header:SetPos( 0, 0 )
	header:SetSize( w, 64 * ratio )
	function header:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		local text = GPhone.GetInputText() or frame.title or "AppStore"
		if text then
			surface.SetFont("GPTitle")
			local size = surface.GetTextSize(text)
			
			if size > w - 64 then
				draw.SimpleText(text, "GPTitle", w - 64, h/2, Color(0, 0, 0), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			else
				draw.SimpleText(text, "GPTitle", w/2, h/2, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
	end
	
	local add = GPnl.AddPanel( header )
	add:SetPos( w - 64 * ratio, 0 )
	add:SetSize( 64 * ratio, 64 * ratio )
	add:SetVisible(false)
	function add:OnClick()
		local function onEnter( value )
			GPhone.DownloadApp( value )
		end
		
		GPhone.InputText( onEnter, nil, nil )
	end
	function add:Paint( x, y, w, h )
		draw.SimpleText("+", "GPTitle", w/2, h/2, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	
	local footer = GPnl.AddPanel( frame )
	footer:SetPos( 0, h - 64 * ratio )
	footer:SetSize( w, 64 * ratio )
	function footer:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, 2, Color( 80, 80, 80, 255 ) )
		draw.RoundedBox( 0, 0, 2, w, h-2, Color( 255, 255, 255, 255 ) )
	end
	
	local offtab = GPnl.AddPanel( footer )
	offtab:SetPos( 0, 0 )
	offtab:SetSize( 64 * ratio, 64 * ratio )
	frame.b_hover = offtab
	function offtab:Paint( x, y, w, h )
		if frame.b_hover == self then
			surface.SetDrawColor(0, 200, 255)
		else
			surface.SetDrawColor(50, 50, 50)
		end
		surface.SetTexture( surface.GetTextureID( "gui/html/stop" ) )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
	function offtab:OnClick()
		add:SetVisible(false)
		frame.b_hover = self
		frame.title = "AppStore"
		panel:OpenTab( "offline", 0.25, "in-right", "out-right" )
	end
	
	local ontab = GPnl.AddPanel( footer )
	ontab:SetPos( w/2 - 32 * ratio, 0 )
	ontab:SetSize( 64 * ratio, 64 * ratio )
	function ontab:Paint( x, y, w, h )
		surface.SetDrawColor(50, 50, 50)
		surface.SetTexture( surface.GetTextureID( "gphone/wifi_3" ) )
		surface.DrawTexturedRect( 0, 0, w, h )
		
		if frame.b_hover == self then
			surface.SetDrawColor(0, 200, 255)
			surface.SetTexture( surface.GetTextureID( "gphone/wifi_"..math.Round(math.sin(CurTime() * 3) + 2) ) )
			surface.DrawTexturedRect( 0, 0, w, h )
		end
	end
	function ontab:OnClick()
		if GetConVar("gphone_csapp"):GetBool() then
			add:SetVisible(true)
		end
		frame.b_hover = self
		frame.title = "Online"
		loadOnlineApps()
		panel:OpenTab( "online", 0.25, "in-right", "out-right" )
	end
	
	local uptab = GPnl.AddPanel( footer )
	uptab:SetPos( w - 64 * ratio, 0 )
	uptab:SetSize( 64 * ratio, 64 * ratio )
	function uptab:Paint( x, y, w, h )
		if frame.b_hover == self then
			surface.SetDrawColor(0, 200, 255)
		else
			surface.SetDrawColor(50, 50, 50)
		end
		surface.SetTexture( surface.GetTextureID( "gui/html/home" ) )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
	function uptab:OnClick()
		add:SetVisible(false)
		frame.b_hover = self
		frame.title = "Updates"
		loadUpdateApps()
		panel:OpenTab( "updates", 0.25, "in-right", "out-right" )
	end
	
	if GetConVar("gphone_csapp"):GetBool() then
		http.Fetch("http://gphone.icu/api/list", function(body, size, headers, code)
			local tbl = util.JSONToTable(body)
			if type(tbl) == "table" then
				frame.online = tbl
				for _,app in pairs(tbl) do
					if app.Icon then
						GPhone.DownloadImage( app.Icon, 128, "background-color: #FFF; border-radius: 32px 32px 32px 32px" )
					end
					GPhone.UpdateApp("http://gphone.icu/api/list?app="..app.App.."&id="..app.Id, function(content)
						app.Update = true
					end)
				end
			else
				print("[GPhone] data not a table")
			end
		end,
		function(err)
			print(err)
		end)
	end
end