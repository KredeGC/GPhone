if !GPhone then
	GPhone					= {}
	GPhone.Data				= {}
	GPhone.SharedHooks		= {}
	GPhone.Panels			= {}
	GPhone.ImageQueue		= {}
	GPhone.ImageHistory		= {}
	GPhone.ImageCache		= {}
	GPhone.AppThumbnails	= {}
	GPhone.MusicStream		= {}
	GPhone.AwaitingCalls	= {}
	GPhone.HTML				= {}
	GPhone.Log				= {}
	GPhone.Apps				= {}
	
	GPhone.CurrentApp		= nil
	GPhone.CurrentFrame		= nil
	GPhone.MovingApp		= nil
	GPhone.MoveMode			= nil
	GPhone.MusicURL			= nil
	GPhone.InputField		= nil
	GPhone.VoiceChatter		= nil
	
	GPhone.Selfie			= false
	GPhone.Landscape		= false
	GPhone.CursorEnabled	= false
	GPhone.Page				= 1
	GPhone.Ratio			= 56 / 83
	GPhone.Height			= ScrH() / 1.032 -- Scaling with rendertargets is weird
	GPhone.Width			= GPhone.Height * GPhone.Ratio
	GPhone.Resolution		= GPhone.Height / 830
	GPhone.CursorPos		= {x = 560, y = 830}
	GPhone.Rows				= 4 -- Placeholder
	
	GPhone.Desk = {
		Spacing = 24 * GPhone.Resolution,
		Offset = 40 * GPhone.Resolution
	}
	GPhone.AppScreen = {
		Enabled = false,
		Scroll = 0,
		Offset = 64 * GPhone.Resolution,
		Spacing = 24 * GPhone.Resolution,
		Scale = 0.6
	}
	
	local w,h = math.floor(GPhone.Width*1.032),math.floor(GPhone.Height*1.032)
	
	GPhone.PhoneRT = GetRenderTarget("GPScreenRT_"..math.ceil(GPhone.Height), w, h, false)
	GPhone.PhoneLSRT = GetRenderTarget("GPScreenLSRT_"..math.ceil(GPhone.Height), h, w, false)
	GPhone.PhoneMT = CreateMaterial(
		"GPScreenMT_"..math.ceil(GPhone.Height),
		"UnlitGeneric",
		{
			["$basetexture"] = GPhone.PhoneRT,
			["$basetexturetransform"] = "center .5 .5 scale 1 1 rotate 0 translate 0 0",
			["$vertexcolor"] = 1,
			["$vertexalpha"] = 1
		}
	)
	
	GPhone.CamRT = GetRenderTarget("GPCameraRT_"..math.ceil(GPhone.Height), w, h, false)
	GPhone.CamLSRT = GetRenderTarget("GPCameraLSRT_"..math.ceil(GPhone.Height), h, w, false)
	GPhone.CamMT = CreateMaterial(
		"GPCameraMT_"..math.ceil(GPhone.Height),
		"GMODScreenspace",
		{
			["$basetexture"] = GPhone.CamRT,
			["$basetexturetransform"] = "center .5 .5 scale -1 -1 rotate 0 translate 0 0",
			["$texturealpha"] = 0,
			["$vertexalpha"] = 1,
		}
	)
end


local function parentPos( p )
	if p then
		local px,py = parentPos( p.parent )
		local x,y = p.x,p.y
		return x+px,y+py
	else
		return 0,0
	end
end

local function resetGPhoneData()
	local data = table.Copy(GPDefaultData)
	file.Write("gphone/users/client.txt", util.TableToJSON(data))
	GPhone.Data = data
end


function GPhone.GetRows()
	return math.ceil(GPhone.Rows * (GPhone.Landscape and GPhone.Resolution or 1))
end

function GPhone.GetAppSize(spacing)
	local w = GPhone.Width
	local spacing = spacing or GPhone.Desk.Spacing
	local rows = GPhone.GetRows()
	
	return (w/rows)-spacing*(1+(1/rows))
end

function GPhone.GetAppPos() -- Became tired of doing all this manually... This is a much better solution since it's dynamic
	local w			= GPhone.Width
	local h			= GPhone.Height
	local spacing	= GPhone.Desk.Spacing
	local rows		= GPhone.GetRows()
	local offset	= GPhone.Desk.Offset
	local size		= GPhone.GetAppSize(spacing, rows)
	local ratio		= GPhone.Resolution
	
	local windows	= {{}}
	local page		= 1
	local posx		= 0
	local posy		= 0
	
	for k,appid in pairs(GPhone.Data.apps or {}) do
		local app = GPhone.GetApp(appid)
		if !app then continue end
		
		posx = posx + 1
		
		while posx > rows do
			posx = 1
			posy = posy + 1
		end
		
		local x,y = (posx-1)*(size+spacing)+spacing, posy*(size+36*ratio)+offset+spacing
		
		if y + size + 36*ratio >= h then
			page = page + 1
			windows[page] = {}
			posx = 1
			posy = 0
			x,y = spacing, offset + spacing
		end
		
		table.insert(windows[page], {x = x, y = y, size = size, app = appid})
	end
	
	return windows
end

function GPhone.GetPage( id )
	local windows = GPhone.GetAppPos()
	local page = windows[math.Clamp(id or GPhone.Page, 1, #windows)]
	return page
end

function GPhone.AppThumbnail( id )
	local cv = GetConVar("gphone_thumbnail")
	local appid = id or GPhone.CurrentApp
	if !cv or !cv:GetBool() then return end
	local frame = GPhone.Panels[appid]
	if !frame then return false end
	
	local name = math.ceil(GPhone.Height).."_"..appid
	local rt = GetRenderTarget("GPAppRT_"..name, GPhone.Width*1.032, (GPhone.Height - GPhone.Desk.Offset)*1.032, false)
	local mat = CreateMaterial(
		"GPAppMT_"..name,
		"UnlitGeneric",
		{
			["$basetexture"] = rt,
			["$vertexcolor"] = 1,
			["$vertexalpha"] = 1
		}
	)
	
	render.PushRenderTarget(rt)
	render.Clear(0, 0, 0, 255, true, true)
	cam.Start2D()
		local oldw,oldh = ScrW(), ScrH()
		local function drawChildren( pnl )
			if pnl.children then
				for _,child in pairs(pnl.children) do
					if !child.visible then continue end
					
					if child.Paint then
						local px,py = parentPos( child.parent )
						local max,may = GPhone.Width*0.016 + math.max(px + child.x, 0), GPhone.Height*0.016 + math.max(py + child.y, 0)
						local mix,miy = math.min(GPhone.Width*0.016 + px + child.x + child.w, GPhone.PhoneMT:Width()), math.min(GPhone.Height*0.016 + py + child.y + child.h, GPhone.PhoneMT:Height())
						
						if mix < 0 or miy < 0 or max > GPhone.Width*1.032 or may > GPhone.Height*1.032 then continue end
						
						render.SetViewPort(max, may, oldw, oldh)
						render.SetScissorRect(max, may, mix, miy, true)
						GPhone.DebugFunction( child.Paint, child, px + child.x, py + child.y, child.w, child.h )
						
						render.SetScissorRect(0, 0, 0, 0, false)
					end
					
					drawChildren( child )
				end
			end
		end
		
		local old = frame.y
		frame.y = 0
		
		if frame.Paint then
			render.SetViewPort(GPhone.Width*0.016, GPhone.Height*0.016, oldw, oldh)
			GPhone.DebugFunction( frame.Paint, frame, frame.x, frame.y, GPhone.Width, GPhone.Height )
		end
		drawChildren( frame )
		
		frame.y = old
		
		render.SetViewPort(0, 0, oldw, oldh)
	cam.End2D()
	render.PopRenderTarget()
	
	mat:SetTexture("$basetexture", rt)
	
	GPhone.AppThumbnails[appid] = mat
	
	return true
end

function GPhone.GetThumbnail( id )
	return GPhone.AppThumbnails[id]
end


function GPhone.AddApp( name, tbl )
	if !name or type(tbl) != "table" or !tbl.Name then return false end
	GPhone.GetApps()[name] = tbl
	return true
end

function GPhone.GetApp( name )
	local app = GPhone.GetApps()[name]
	return app or false
end

function GPhone.GetApps()
	return GPhone.Apps
end


surface.CreateFont("GPTopBar", { font = "Open Sans Light", size = 34 * GPhone.Resolution, additive = false, shadow = false})

for i = 1, 6 do
	surface.CreateFont("GPAppName"..i, { font = "Open Sans Light", size = 120 * GPhone.Resolution / i, additive = false, shadow = false})
end

surface.CreateFont("GPSmall", { font = "Open Sans", size = 28 * GPhone.Resolution, additive = false, shadow = false})

surface.CreateFont("GPMedium", { font = "Open Sans", size = 36 * GPhone.Resolution, additive = false, shadow = false})

surface.CreateFont("GPTitle", { font = "Open Sans", size = 44 * GPhone.Resolution, additive = false, shadow = false})


surface.CreateFont("GPBugReport", { font = "Open Sans", size = 48 * GPhone.Resolution, additive = false, shadow = false})

surface.CreateFont("GPLoading", { font = "Open Sans", size = 128, additive = false, shadow = false})


concommand.Add("gphone_log_wipe", function()
	GPhone.WipeLog()
end)

concommand.Add("gphone_log_print", function()
	GPhone.PrintLog()
end)

concommand.Add("gphone_log_copy", function()
	if #GPhone.Log <= 0 then return end
	SetClipboardText( string.Implode("\r\n", GPhone.Log) )
end)

concommand.Add("gphone_log_report", function()
	if IsValid(GPReporter) then return end
	if #GPhone.Log <= 0 then return end
	
	local w,h = ScrW()/2,ScrH()/2
	local padding = 10
	local offset = 30
	
	GPReporter = vgui.Create( "DFrame" )
	GPReporter:SetSize(w, h)
	GPReporter:SetTitle("")
	GPReporter:SetDraggable( false )
	GPReporter:ShowCloseButton( false )
	GPReporter:SetSizable( false )
	GPReporter.Paint = function(self)
		draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(70,70,70))
	end
	GPReporter:MakePopup()
	GPReporter:Center()
	
	local message = vgui.Create("DTextEntry", GPReporter)
	message:SetText("")
	message:SetPos( padding, padding )
	message:SetSize( w/2 - padding*2, h - padding*3 - offset )
	message:SetDrawLanguageID( false )
	message:SetMultiline( true )
	message:SetPlaceholderText( "What did you do for the error to appear?" )
	message:RequestFocus()
	
	local log = vgui.Create("DTextEntry", GPReporter)
	log:SetText( string.Implode("\n", GPhone.Log) )
	log:SetPos( w/2, padding )
	log:SetSize( w/2 - padding, h - padding*3 - offset )
	log:SetVerticalScrollbarEnabled( true )
	log:SetDrawLanguageID( false )
	log:SetMultiline( true )
	log:SetEditable( false )
	log:SetPlaceholderText( "Nothing logged" )
	log.Log = string.Trim( string.Implode("\r\n", GPhone.Log) )
	
	local report = vgui.Create("DButton", GPReporter)
	report:SetPos( padding, h - padding - offset )
	report:SetSize( w/2 - padding * 2, offset )
	report:SetText("Report")
	report:SetTextColor(Color(255,255,255))
	function report:Paint()
		if self.Hovering then
			surface.SetDrawColor(0, 200, 0)
		else
			surface.SetDrawColor(40, 150, 40)
		end
		surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
	end
	function report:OnCursorEntered()
		self.Hovering = true
		if message:GetValue() == "" then
			self:SetText( "Write a message first" )
		else
			self:SetText( "PRESS CTRL + V IN THE DISCUSSION" )
		end
	end
	function report:OnCursorExited()
		self:SetText( "Report" )
		self.Hovering = false
	end
	function report:DoClick()
		local err = message:GetValue()
		if err == "" then
			message:RequestFocus()
		else
			hook.Add("PostDrawHUD", "GPhoneBugReportOverlay", function()
				surface.SetDrawColor(0, 0, 0)
				surface.DrawRect(0, 0, ScrW(), ScrH())
				draw.SimpleText("Press \"Yes\" and the error discussion will open", "GPBugReport", ScrW()/2, ScrH()/3, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText("Press Ctrl + V in the discussion to post the error report", "GPBugReport", ScrW()/2, ScrH()/3*2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				hook.Add("HUDPaint", "GPhoneBugReportRemove", function()
					hook.Remove("PostDrawHUD", "GPhoneBugReportOverlay")
					hook.Remove("HUDPaint", "GPhoneBugReportRemove")
				end)
			end)
			SetClipboardText( err.."\r\n[code]\r\n"..log.Log.."\r\n[/code]" )
			GPReporter:Remove()
			gui.OpenURL( "https://steamcommunity.com/workshop/filedetails/discussion/1370983401/1696045708645315297/" )
		end
	end
	
	local cancel = vgui.Create("DButton", GPReporter)
	cancel:SetPos( w/2, h - padding - offset )
	cancel:SetSize( w/2 - padding, offset )
	cancel:SetText("Cancel")
	cancel:SetTextColor(Color(255,255,255))
	function cancel:Paint()
		if self.Hovering then
			surface.SetDrawColor(255, 0, 0)
		else
			surface.SetDrawColor(180, 40, 40)
		end
		surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
	end
	function cancel:OnCursorEntered()
		self.Hovering = true
		self:SetText( "Are you sure?" )
	end
	function cancel:OnCursorExited()
		self:SetText( "Cancel" )
		self.Hovering = false
	end
	function cancel:DoClick()
		GPReporter:Remove()
	end
end)

concommand.Add("gphone_redownloadimages", function()
	local tbl = table.Copy(GPhone.ImageHistory)
	GPhone.ImageCache = {}
	GPhone.ImageQueue = {}
	GPhone.ImageHistory = {}
	ImgReady = nil
	ImgDownloadTime = nil
	if IsValid(DownLoadHTML) then
		DownLoadHTML:Remove()
		DownLoadHTML = nil
	end
	for img,data in pairs(tbl) do
		GPhone.DownloadImage( data.URL, data.Size, data.Style )
	end
end)

concommand.Add("gphone_clearcache", function()
	GPhone.ImageQueue = {}
	GPhone.ImageCache = {}
	GPhone.ImageHistory = {}
	ImgReady = nil
	ImgDownloadTime = nil
	if IsValid(DownLoadHTML) then
		DownLoadHTML:Remove()
		DownLoadHTML = nil
	end
end)

concommand.Add("gphone_reset", function()
	GPhone.StopMusic()
	GPhone.CloseInput()
	GPhone.Log = {}
	
	GPhone.MovingApp = nil
	GPhone.MoveMode = nil
	GPhone.MusicURL = nil
	GPhone.AppScreen.Enabled = false
	
	for name,_ in pairs(GPhone.Panels) do
		GPhone.StopApp( name )
	end
	
	local cv = GetConVar("gphone_sync")
	if game.SinglePlayer() or cv and cv:GetBool() then
		resetGPhoneData()
	else
		net.Start("GPhone_Reset")
		net.SendToServer()
	end
	
	GPhone.DownloadImage( "https://raw.githubusercontent.com/KredeGC/GPhone/master/images/background.jpg", 512, "background-color: #FFF" )
end)


net.Receive("GPhone_Load_Client", function(len)
	local cv = GetConVar("gphone_sync")
	if game.SinglePlayer() or cv and cv:GetBool() then
		if file.Exists("gphone/users/client.txt", "DATA") then
			local tbl = util.JSONToTable( file.Read("gphone/users/client.txt", "DATA") )
			
			local apps = {}
			for _,id in pairs(GPDefaultApps) do -- Fix default apps
				if !table.HasValue(tbl.apps, id) then
					table.insert(apps, id)
				end
			end
			
			if #apps > 0 then
				table.Add(tbl.apps, apps)
				file.Write("gphone/users/client.txt", util.TableToJSON(tbl))
				print("[GPhone] Added "..#apps.." missing default apps")
			end
			
			GPhone.Data = tbl
		else
			resetGPhoneData()
		end
	else
		local tbl = net.ReadTable()
		GPhone.Data = tbl
	end
end)

net.Receive("GPhone_Share_Data", function(len)
	local ply = net.ReadEntity()
	local name = net.ReadString()
	local data = net.ReadTable()
	
	local override = hook.Run("GPhoneDataReceived", ply, name, data)
	if !override then
		local shared = GPhone.GetData("shared", {})
		shared[name] = data
		GPhone.SetData("shared", shared)
	end
	
	local func = GPhone.SharedHooks[name]
	if func then
		GPhone.DebugFunction( func, ply, name, data )
	end
end)

net.Receive("GPhone_Rotate", function(len)
	GPhone.Rotate( !GPhone.Landscape )
end)

net.Receive("GPhone_VoiceCall_Request", function(len) -- Somebody requested your presence in a voicecall
	local chatter = net.ReadEntity()
	local calls = GPhone.GetIncomingVoiceChats()
	table.insert(calls, chatter)
end)

net.Receive("GPhone_VoiceCall_Stop", function(len) -- Someone denied your voice request
	GPhone.VoiceChatter = false
end)


function GPhone.DebugFunction( func, ... )
	local function catch(err)
		local info = debug.getinfo( func )
		local text = "[ERROR] "..err.."\n  1. unknown - "..info.short_src..":"..info.linedefined.."-"..info.lastlinedefined.."\n"
		GPhone.Debug( text, false, true )
	end
	xpcall( func, catch, ... )
end

function GPhone.Debug( str, spam, err )
	local last = GPhone.Log[#GPhone.Log]
	if spam or last != str then -- Prevent spam
		table.insert(GPhone.Log, str)
		if err then
			ErrorNoHalt( str.."\n" )
		else
			MsgN(str)
		end
		if IsValid(GPErrorTextField) then
			GPErrorTextField:SetText( string.Implode("\n", GPhone.Log) )
		end
		local cv = GetConVar("gphone_report")
		if err and cv and cv:GetBool() then
			RunConsoleCommand("gphone_log_report")
		end
		return true
	end
	return false
end

function GPhone.WipeLog()
	GPhone.Log = {}
	if IsValid(GPErrorTextField) then
		GPErrorTextField:SetText("")
	end
end

function GPhone.PrintLog()
	for k,v in pairs(GPhone.Log) do
		MsgN(v)
	end
end

function GPhone.SetData(name, v)
	GPhone.Data[name] = v
	local cv = GetConVar("gphone_sync")
	if !game.SinglePlayer() and (!cv or !cv:GetBool()) then
		net.Start( "GPhone_Change_Data" )
			net.WriteTable( GPhone.Data )
		net.SendToServer()
	else
		file.Write("gphone/users/client.txt", util.TableToJSON(GPhone.Data))
	end
end

function GPhone.GetData(name, def)
	return GPhone.Data[name] or def or false
end


function GPhone.SetAppData(name, v, a)
	local data = GPhone.GetAllAppData(a)
	data[name] = v
	GPhone.SetAllAppData(data, a)
end

function GPhone.GetAppData(name, def, a)
	local data = GPhone.GetAllAppData(a)
	return data[name] or def or false
end

function GPhone.SetAllAppData(v, a)
	local app = a or GPhone.CurrentApp
	if !app then return false end
	if !table.HasValue(GPhone.Data.apps, app) then return false end
	local appdata = GPhone.GetData("appdata", {})
	appdata[app] = v
	GPhone.SetData("appdata", appdata)
end

function GPhone.GetAllAppData(a)
	local app = a or GPhone.CurrentApp
	if !app then return false end
	local appdata = GPhone.GetData("appdata", {})
	local data = appdata[app] or {}
	return data
end

function GPhone.ClearAllAppData(a)
	local app = a or GPhone.CurrentApp
	if !app then return false end
	local appdata = GPhone.GetData("appdata", {})
	appdata[app] = nil
	GPhone.SetData("appdata", appdata)
end


function GPhone.HookSharedData(name, func)
	GPhone.SharedHooks[name] = func
end

function GPhone.SendSharedData(ply, name, data)
	if IsValid(ply) and ply:IsPlayer() then
		net.Start( "GPhone_Share_Data" )
			net.WriteEntity( ply )
			net.WriteString( name )
			net.WriteTable( data )
		net.SendToServer()
		return true
	end
	return false
end

function GPhone.GetSharedData(name, def)
	local data = GPhone.GetData("shared", {})
	return data[name] or def or false
end

function GPhone.GetCursorPos()
	local i = GPhone.Landscape
	local p = GPhone.CursorPos
	local x,y = p.x / 1120,p.y / 1660
	return (i and y or x) * GPhone.Width,(i and (1 - x) or y) * GPhone.Height
end

function GPhone.LocalToRoot( pnl, x, y )
	local px,py = parentPos( pnl )
	return x + px, y + py
end

function GPhone.RootToLocal( pnl, x, y )
	local px,py = parentPos( pnl )
	return x - px, y - py
end

function GPhone.EnableSelfie( bool )
	if GPhone.SelfieEnabled() == bool then return false end
	GPhone.Selfie = bool
	net.Start("GPhone_Selfie")
		net.WriteBool( bool or false )
	net.SendToServer()
	return true
end

function GPhone.SelfieEnabled()
	return GPhone.Selfie
end

function GPhone.CreateRootPanel()
	local frame = GPnl.AddPanel( nil, "frame" )
	if !frame then return false end
	
	local offset = GPhone.Desk.Offset
	local w,h = GPhone.Width,GPhone.Height - offset
	
	frame:SetPos( 0, offset )
	frame:SetSize( w, h )
	frame.Remove = nil
	frame.Landscape = GPhone.Landscape
	
	function frame:SetFullScreen( bool )
		self.b_fullscreen = bool
		local offset = bool and 0 or GPhone.Desk.Offset
		self:SetPos( 0, offset )
		self:SetHeight( GPhone.Height - offset )
		return offset
	end
	function frame:GetFullScreen()
		return self.b_fullscreen or false
	end
	
	return frame
end

function GPhone.RunApp( name, force )
	if GPhone.Panels[name] and !force then -- Focus the app instead
		GPhone.AppThumbnail()
		GPhone.FocusApp( name )
		return GPhone.Panels[name]
	end
	
	if !table.HasValue(GPhone.Data.apps, name) then return false end
	local app = GPhone.GetApp( name )
	if !app then return false end
	local frame = GPhone.CreateRootPanel()
	if !frame then return false end
	local offset = GPhone.Desk.Offset
	local w,h = GPhone.Width,GPhone.Height - offset
	
	GPhone.AppThumbnail() -- In case it was run from inside an app
	
	GPhone.CurrentFrame = frame
	if !force then
		GPhone.CurrentApp = name
		GPhone.Panels[name] = frame
	end
	
	if app.Run then
		if type(app.Run) == "string" then
			local str = RunString( "appinit = "..app.Run, name, false )
			if !str and appinit then
				GPhone.DebugFunction( appinit, frame, w, h, GPhone.Resolution )
			else
				GPhone.Debug("[ERROR] App '"..(app.Name or name).."': "..str, false, true)
			end
		else
			GPhone.DebugFunction( app.Run, frame, w, h, GPhone.Resolution )
		end
	end
	
	local exclude = {}
	local function checkChildren( pnl )
		if pnl.children then
			for _,child in pairs(pnl.children) do
				if exclude[child] then
					GPhone.CurrentFrame = nil
					if GPhone.CurrentApp then
						GPhone.Panels[GPhone.CurrentApp] = nil
					end
					GPhone.Debug("[ERROR] App '"..(app.Name or name).."' stuck in infinite loop\n  1. "..tostring(child).." - App terminated\n", true, true)
					GPhone.FocusHome()
					return false
				end
				
				exclude[child] = true
				
				checkChildren( child )
			end
		end
	end
	checkChildren( frame )
	
	return frame
end

function GPhone.StopApp( name )
	local frame = GPhone.Panels[name]
	if !frame then return false end
	local app = GPhone.GetApp( name )
	if app and app.Stop then
		if type(app.Stop) == "string" then
			local str = RunString( "appdel = "..app.Stop, name, false )
			if !str and appdel then
				GPhone.DebugFunction( appdel, frame )
			else
				GPhone.Debug("[ERROR] App '"..(app.Name or name).."': "..str, false, true)
			end
		else
			GPhone.DebugFunction( app.Stop, frame )
		end
	end
	
	local function removeChildren( pnl )
		if pnl.OnRemove then
			pnl:OnRemove()
		end
		if pnl.children and #pnl.children > 0 then
			for _,child in pairs(pnl.children) do
				removeChildren( child )
			end
		end
	end
	removeChildren( frame )
	
	GPhone.EnableSelfie( false )
	
	GPhone.Panels[name] = nil
	if GPhone.CurrentApp == name then
		GPhone.CurrentApp = nil
		GPhone.CurrentFrame = nil
	end
	return true
end

function GPhone.FocusApp( name )
	local frame = GPhone.Panels[name]
	if !frame then return false end
	local app = GPhone.GetApp( name )
	if frame.Landscape != GPhone.Landscape then
		local new = GPhone.RunApp( name, true )
		if !new then return false end
		
		if app.Rotate then
			app.Rotate(GPhone.Panels[name], new)
		end
		
		GPhone.StopApp( name )
		GPhone.Panels[name] = new
		GPhone.FocusApp( name )
		return new
	end
	GPhone.CurrentApp = name
	GPhone.CurrentFrame = frame
	if app and app.Focus then
		if type(app.Focus) == "string" then
			local str = RunString( "appfoc = "..app.Focus, name, false )
			if !str and appfoc then
				GPhone.DebugFunction( appfoc, frame )
			else
				GPhone.Debug("[ERROR] in app '"..(app.Name or name).."': "..str, false, true)
			end
		else
			GPhone.DebugFunction( app.Focus, frame )
		end
	end
	return frame
end

function GPhone.FocusHome()
	local name = GPhone.CurrentApp
	local frame = GPhone.CurrentFrame
	if name and frame then
		local app = GPhone.GetApp( name )
		if app and app.UnFocus then
			if type(app.UnFocus) == "string" then
				local str = RunString( "appunfoc = "..app.UnFocus, name, false )
				if !str and appunfoc then
					GPhone.DebugFunction( appunfoc, frame )
				else
					GPhone.Debug("[ERROR] in app '"..(app.Name or name).."': "..str, false, true)
				end
			else
				GPhone.DebugFunction( app.UnFocus, frame )
			end
		end
	end
	
	GPhone.EnableSelfie( false )
	
	GPhone.CurrentApp = nil
	GPhone.CurrentFrame = nil
end

function GPhone.InstallApp( name )
	if table.HasValue(GPhone.Data.apps, name) then return end
	if !GPhone.GetApp( name ) then return end
	local apps = GPhone.Data.apps
	table.insert(apps, name)
	GPhone.SetData("apps", apps)
end

function GPhone.UninstallApp( name )
	if table.HasValue(GPDefaultApps, name) then return end
	local apps = GPhone.Data.apps
	GPhone.ClearAllAppData( name )
	if file.Exists("gphone/apps/"..name..".txt", "DATA") then
		GPhone.Apps[name] = nil
		file.Delete("gphone/apps/"..name..".txt")
	end
	if table.HasValue(apps, name) then
		GPhone.StopApp( name )
		table.RemoveByValue(apps, name)
		GPhone.SetData("apps", apps)
	end
end

function GPhone.UpdateApp( url, success, failure )
	if !url then return false end
	local name = GPhone.SerializeAppName(url)
	if !table.HasValue(GPhone.Data.apps, name) then return false end
	if !file.Exists("gphone/apps/"..name..".txt", "DATA") then return false end
	local r = file.Read("gphone/apps/"..name..".txt", "DATA")
	http.Fetch(url, function(body, size, headers, code)
		if success and (body.."\nAPP.URL = \""..url.."\"") != r then
			success( body )
		elseif failure then
			failure( "App is up to date" )
		end
	end,
	function(err)
		if failure then
			failure( err )
		end
	end)
	return true
end

function GPhone.DownloadApp( url )
	local cv = GetConVar("gphone_csapp")
	if !cv or !cv:GetBool() then return false end
	local name = GPhone.SerializeAppName( url )
	http.Fetch(url, function(body, size, headers, code)
		local content = body.."\nAPP.URL = \""..url.."\""
		file.Write("gphone/apps/"..name..".txt", content)
		
		APP = {}
		
		RunString(content, name)
		
		GPhone.AddApp(name, APP)
		
		GPhone.DownloadImage( APP.Icon, 128, true, "background-color: #FFF; border-radius: 32px 32px 32px 32px" )
		
		APP = nil
		
		GPhone.InstallApp( name )
	end,
	function(err)
		print(err)
	end)
	
	return name
end

function GPhone.SerializeAppName( url )
	local name = string.lower(url)
	local name = string.gsub(name, "http://", "")
	local name = string.gsub(name, "https://", "")
	local name = string.gsub(name, "/", "-")
	local name = string.gsub(name, ":", "-")
	local name = string.gsub(name, ";", "-")
	local name = string.gsub(name, "?", "-")
	local name = string.gsub(name, "=", "-")
	return string.gsub(name, "%.", "-")
end

function GPhone.Vibrate()
	local ply = LocalPlayer()
	if !ply:Alive() then return false end
	local wep = ply:GetActiveWeapon()
	if IsValid(wep) and wep:GetClass() == "gmod_gphone" then
		wep.b_vibrate = CurTime() + 1
	end
	
	if ply:HasWeapon("gmod_gphone") then
		wep:EmitSound("sound/gphone/vibrate.wav")
		return true
	end
	return false
end

function GPhone.Rotate( landscape )
	if GPhone.Landscape == landscape then return false end
	local wep = LocalPlayer():GetWeapon("gmod_gphone")
	if IsValid(wep) then
		wep.b_quickopen = nil
		wep.b_quickhold = nil
	end
	GPhone.Landscape = landscape
	local oldw = GPhone.Width
	local oldh = GPhone.Height
	if (landscape and oldh > oldw) or (!landscape and oldh < oldw) then
		GPhone.Width = oldh
		GPhone.Height = oldw
	end
	local name = GPhone.CurrentApp
	local app = GPhone.GetApp( name )
	if name and app then
		local new = GPhone.RunApp( name, true )
		if !new then return false end
		
		if app.Rotate then
			app.Rotate(GPhone.Panels[name], new)
		end
		
		GPhone.StopApp( name )
		GPhone.Panels[name] = new
		GPhone.FocusApp( name )
	elseif GPhone.CurrentFrame then
		GPhone.FocusHome()
	end
end

function GPhone.RenderCamera( fov, front, pre, post )
	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()
	if IsValid(wep) and wep:GetClass() == "gmod_gphone" then
		local mtx = GPhone.CamMT:GetMatrix("$basetexturetransform")
		
		if GPhone.Landscape then
			mtx:SetAngles( Angle(0, -90, 0) )
			GPhone.CamMT:SetTexture("$basetexture", GPhone.CamLSRT)
			render.PushRenderTarget(GPhone.CamLSRT)
		else
			mtx:SetAngles( Angle(0, 0, 0) )
			GPhone.CamMT:SetTexture("$basetexture", GPhone.CamRT)
			render.PushRenderTarget(GPhone.CamRT)
		end
		
		GPhone.CamMT:SetMatrix("$basetexturetransform", mtx)
		
		render.Clear(0, 0, 0, 255)
		render.ClearDepth()
		
		local ang = ply:EyeAngles()
		local pos = ply:EyePos() + ang:Forward()*8
		
		if front then
			local attach_id = ply:LookupAttachment("anim_attachment_RH")
			local attach = ply:GetAttachment(attach_id)
			if attach then
				pos = attach.Pos + ang:Up()*6 - ang:Right()*3
				ang:RotateAroundAxis(ang:Up(), 180)
			end
		else
			local vm = LocalPlayer():GetViewModel()
			if IsValid(vm) then
				ang = vm:GetAngles()
			end
		end
		
		local oldLegs = nil
		local oldDraw = nil
		if front then
			local oldlegs = ply.ShouldDisableLegs
			ply.ShouldDisableLegs = true
			if EnhancedCamera then
				oldDraw = EnhancedCamera.ShouldDraw
				EnhancedCamera.ShouldDraw = function() return false end
			end
		end
		
		GPSelfieRendering = front
		
		if pre then
			GPhone.DebugFunction( pre, pos, ang, fov )
		end
		
		render.RenderView({
			x = 0,
			y = 0,
			w = GPhone.Width,
			h = GPhone.Height,
			origin = pos,
			angles = ang,
			fov = fov or 90,
			dopostprocess = true,
			drawhud = false,
			drawmonitors = true,
			drawviewmodel = false
		})
		
		if post then
			GPhone.DebugFunction( post, pos, ang, fov )
		end
		
		GPSelfieRendering = false
		
		if front then
			ply.ShouldDisableLegs = oldlegs
			if EnhancedCamera and oldDraw then
				EnhancedCamera.ShouldDraw = oldDraw
			end
		end
		
		render.PopRenderTarget()
		
		return GPhone.CamMT
	end
	return false
end

--[[function GPhone.SendSMS(number, text)
	net.Start( "GPhone_SMS_Send" )
		net.WriteString( number )
		net.WriteString( text )
	net.SendToServer()
	return true
end]]

function GPhone.RequestVoiceChat( ply )
	if !IsValid(ply) or !ply:IsPlayer() then return false end
	if IsValid(g_VoicePanelList) then
		g_VoicePanelList:SetVisible(false)
	end
	GPhone.VoiceChatter = ply
	net.Start("GPhone_VoiceCall_Request")
		net.WriteEntity( ply )
	net.SendToServer()
	LocalPlayer():ConCommand("+voicerecord")
	return true
end

function GPhone.GetIncomingVoiceChats()
	return GPhone.AwaitingCalls or {}
end

function GPhone.AnswerVoiceChat( index, accept )
	local chats = GPhone.GetIncomingVoiceChats()
	local ply = chats[index]
	if !ply or !IsValid(ply) or !ply:IsPlayer() then return false end
	if accept then
		GPhone.VoiceChatter = ply
		if IsValid(g_VoicePanelList) then
			g_VoicePanelList:SetVisible(false)
		end
		net.Start("GPhone_VoiceCall_Answer")
			net.WriteEntity( ply )
			net.WriteBool( true )
		net.SendToServer()
		LocalPlayer():ConCommand("+voicerecord")
	else
		net.Start("GPhone_VoiceCall_Answer")
			net.WriteEntity( ply )
			net.WriteBool( false )
		net.SendToServer()
	end
	table.remove(chats, index)
	return true
end

function GPhone.StopVoiceChat()
	GPhone.VoiceChatter = false
	if IsValid(g_VoicePanelList) then
		g_VoicePanelList:SetVisible(true)
	end
	net.Start("GPhone_VoiceCall_Stop")
	net.SendToServer()
	LocalPlayer():ConCommand("-voicerecord")
end

function GPhone.InputText( enter, change, cancel, starttext, keypress )
	if IsValid(GPhone.InputField) then return false end
	
	local frame = vgui.Create( "DFrame" )
	frame:SetSize( ScrW()/2, ScrH()/2 )
	frame:SetPos( ScrW()/4, ScrH()/4 )
	frame:SetTitle( "" )
	frame:SetVisible( true )
	frame:SetDraggable( false )
	frame:ShowCloseButton( false )
	frame:MakePopup()
	frame:SetMouseInputEnabled( false )
	function frame:Paint()
		return false
	end
	
	GPhone.InputField = vgui.Create("DTextEntry", frame)
	GPhone.InputField:SetText(starttext or "")
	GPhone.InputField:SetSize(200, 20)
	GPhone.InputField:SetPos( 0, 0 )
	GPhone.InputField:RequestFocus()
	GPhone.InputField:SetCaretPos( string.len(starttext or "") )
	GPhone.InputField:SetDrawLanguageID( false )
	function GPhone.InputField:Paint()
		return false
	end
	
	function GPhone.InputField:OnEnter()
		self.m_entered = true
		self:GetParent():Close()
		if enter then
			GPhone.DebugFunction( enter, self:GetValue() )
		end
	end
	if keypress then
		function GPhone.InputField:OnKeyCodeTyped( key )
			if key == 64 then
				self:OnEnter()
			end
			keypress( key, true )
		end
		function GPhone.InputField:OnKeyCodeReleased( key )
			keypress( key, false )
		end
	end
	function GPhone.InputField:OnChange()
		if change then
			GPhone.DebugFunction( change, self:GetValue() )
		end
	end
	function GPhone.InputField:OnLoseFocus()
		self:GetParent():Close()
		if self.m_entered then return end
		if cancel then
			GPhone.DebugFunction( cancel )
		end
	end
end

function GPhone.CloseInput()
	if !IsValid(GPhone.InputField) or !IsValid(GPhone.InputField:GetParent()) then return false end
	GPhone.InputField:GetParent():Close()
	return true
end

function GPhone.GetInputText()
	if !IsValid(GPhone.InputField) then return false end
	return GPhone.InputField:GetValue()
end

function GPhone.SetCaretPos( pos )
	if !IsValid(GPhone.InputField) then return false end
	GPhone.InputField:SetCaretPos( pos )
	return true
end

function GPhone.GetCaretPos()
	if !IsValid(GPhone.InputField) then return 0 end
	return GPhone.InputField:GetCaretPos()
end

function GPhone.CreateHTMLPanel( w, h, url, vol )
	local html = vgui.Create("DHTML")
	html.URL = url or "about:blank"
	html.Title = "about:blank"
	html:SetPos(0, 0)
	html:SetSize(w or GPhone.Width, h or GPhone.Height)
	html.b_keepvolume = vol
	if url then
		html:OpenURL( url )
	end
	
	function html:OnChangeTitle( title )
		html.Title = title
	end
	
	GPhone.UpdateHTMLControl( html )
	
	html:SetKeyBoardInputEnabled(false)
	html:SetPaintedManually(false)
	html:SetVisible(false)
	timer.Simple(0, function()
		html:SetPaintedManually(true)
	end)
	
	table.insert(GPhone.HTML, html)
	
	return html
end

function GPhone.UpdateHTMLControl( html )
	if !IsValid(html) then return end
	function html:ConsoleMessage( str )
		if string.find(str or "", "Uncaught ReferenceError: gmod is not defined") then
			print("[ERROR] '"..tostring(html).."': "..str)
			GPhone.UpdateHTMLControl( html )
		end
	end
	
	html:AddFunction( "gmod", "getURL", function( str )
		if str != "about:blank" then
			html.URL = str
		end
	end)
	
	html:AddFunction( "gmod", "inputField", function( tag, id, oldval )
		if tag and id then
			local function onChange( val )
				if IsValid(html) and tag and id then
					local js = [[var x = document.getElementsByTagName("]]..tag..[[")[]]..id..[[].value = "]]..val..[[";]]
					html:RunJavascript( js )
				end
			end
			local function onEnter( val )
				if IsValid(html) then
					if string.StartWith(html.URL, "https://www.google.com") then // Why are javascript events so confusing to hack together?
						html:OpenURL("https://www.google.com/search?q="..string.gsub(val, " ", "+"))
					elseif tag and id then
						local js = [[var el = document.getElementsByTagName("]]..tag..[[")[]]..id..[[];
							
							var ev = new Event("keydown"); // Fuck Awesomium for being this old
							ev.key = "Enter";
							ev.keyCode = 13;
							ev.charCode = ev.keyCode;
							ev.which = ev.keyCode;
							ev.altKey = false;
							ev.ctrlKey = false;
							ev.shiftKey = false;
							ev.metaKey = false;
							ev.bubbles = true;
							
							el.dispatchEvent(ev);
						]]
						html:RunJavascript( js )
					end
				end
			end
			local function keyPress( key, pressed )
				local chr = input.GetKeyName(key)
				local asc = string.byte(chr)
				if string.len(chr) > 1 then
					if chr == "BACKSPACE" then chr = "Backspace" asc = 8 end
					if chr == "LEFTARROW" then chr = "ArrowLeft" asc = 37 end
					if chr == "UPARROW" then chr = "ArrowUp" asc = 38 end
					if chr == "RIGHTARROW" then chr = "ArrowRight" asc = 39 end
					if chr == "DOWNARROW" then chr = "ArrowDown" asc = 40 end
				end
				
				local js = [[var el = document.getElementsByTagName("]]..tag..[[")[]]..id..[[];
					
					var ev = new Event("]]..(pressed and "keydown" or "keyup")..[["); // Fuck Awesomium for being this old
					ev.key = "]]..chr..[[";
					ev.keyCode = ]]..asc..[[;
					ev.charCode = ev.keyCode;
					ev.which = ev.keyCode;
					ev.altKey = false;
					ev.ctrlKey = false;
					ev.shiftKey = false;
					ev.metaKey = false;
					ev.bubbles = true;
					
					el.dispatchEvent(ev);
				]]
				
				html:RunJavascript( js )
			end
			GPhone.InputText( onEnter, onChange, nil, oldval, keyPress )
		end
	end)
	
	html:AddFunction( "gmod", "print", function( ... )
		local str = string.Implode(" ", { ... })
		print("[GPhone][HTML] "..str)
	end)
	
	html:AddFunction( "gmod", "run", function( ... ) -- I don't even need this but whatever
		local code = string.Implode(" ", { ... })
		if code != "" then
			this = html
			local str = RunString(code, "gmod.run", false)
			if str then
				GPhone.Debug("[ERROR] '"..tostring(html).."': "..str, false, true)
			end
			this = nil
		end
	end)
	
	html:AddFunction( "gmod", "isAwesomium", function( str )
		local bool = tobool(str)
		GPhone.IsAwesomium = bool
		if bool and GetConVar("gphone_chromium"):GetBool() then
			html:SetHTML([[<!doctype>
			<html>
				<head>
					<title>Fuck Awesomium</title>
					<style>
						p {
							color: #acb2b8;
							font-size: 40px;
						}
					</style>
				</head>
				<body style="background-color: #1b2838;">
					<p>I would <b>HIGHLY</b> suggest switching to the Chromium branch due to the Awesomium browser being very old and unsupported on many sites.</p>
					<img src="https://raw.githubusercontent.com/KredeGC/GPhone/master/tutorial/chromium.png" width="100%" />
					<p>This can be done by right-clicking Garry's Mod in your Steam Library and selecting properties.
					<br>In the properties-window, navigate to the 'BETAS' tab and select 'chromium -' from the dropdown.</p>
					<p>If you <b>DON'T</b> want to switch to Chromium, click <a style="color: #ffffff; text-decoration: none;" href="javascript:gmod.run('this:GoBack() this.Title=\'Google\' RunConsoleCommand(\'gphone_chromium\', 0)');">here</a> to turn off this notification and go back.</p>
				</body>
			</html>]])
		end
	end)
	
	html:AddFunction( "gmod", "redirect", function( url ) -- TODO: Make a popup asking for permission to redirect
		
	end)
	
	html:AddFunction( "window", "open", function( ... )
		-- Remove popups
	end)
end

function GPhone.CloseHTMLPanel( html )
	if table.HasValue(GPhone.HTML, html) then
		table.RemoveByValue(GPhone.HTML, html)
	end
	if IsValid(html) then
		html:Remove()
	end
end

local genicon = Material( "vgui/spawnmenu/generating" )

function GPhone.GetHTMLMaterial( html )
	if IsValid(html) then
		html:UpdateHTMLTexture()
		if html.Mat then
			return html.Mat
		elseif html:GetHTMLMaterial() then
			local mat = html:GetHTMLMaterial() -- Get the html material
			
			local scale_x,scale_y = html:GetWide() / mat:Width(),html:GetTall() / mat:Height() -- Setup the material-data with the proper scaling
			local matdata = {
				["$basetexture"] = mat:GetName(),
				["$basetexturetransform"] = "center 0 0 scale "..scale_x.." "..scale_y.." rotate 0 translate 0 0",
				["$vertexcolor"] = 1,
				["$vertexalpha"] = 1,
				["$nocull"] = 1,
				["$model"] = 1
			}
			
			local id = string.gsub(mat:GetName(), "__vgui_texture_", "")
			html.Mat = CreateMaterial("GPhone_HTMLMaterial_"..id, "UnlitGeneric", matdata)
			
			return html.Mat
		end
	end
	return genicon
end

function GPhone.GetHTMLPos( frame, html, mx, my )
	if !frame or !IsValid(html) then return mx,my end
	
	local fx,fy = parentPos( frame )
	local fw,fh = frame.w,frame.h
	
	local mx,my = ((mx - fx) / fw) * html:GetWide(),((my - fy) / fh) * html:GetTall()
	return mx,my
end

function GPhone.PerformHTMLClick( html, x, y )
	if !IsValid(html) then return false end
	html:RunJavascript([[
		var elem = document.elementFromPoint(]]..x..[[, ]]..y..[[);
		elem.focus();
		
		function pressParents( el ) {
			if (el.tagName == "INPUT" && el.type == "text") {
				var x = document.getElementsByTagName(el.tagName);
				for (i = 0; i < x.length; i++) {
					if (x[i] == el) {
						gmod.inputField( el.tagName, i, el.value );
						break;
					}
				}
			} else if (el.tagName == "A" && el.target == "_blank") {
				if (el.href) {
					if (el.href.search(window.location.protocol) == 0 || el.href.search(window.location.protocol) == -1) {
						gmod.redirect(el.href);
					} else if (el.href.search("#")) {
						gmod.redirect(window.location.href + el.href);
					} else {
						gmod.redirect(window.location.hostname + "/" + el.href);
					}
				}
			} else if (el.click) {
				el.click();
			} else if (el.onclick) {
				el.onclick();
			} else if (el.tagName == "A") {
				if (el.href) {
					if (el.href.search("javascript:") > -1) {
						eval(el.href.substr(11));
					} else if (el.href.search(window.location.protocol) == 0 || el.href.search(window.location.protocol) == -1) {
						window.location.href = el.href;
					} else if (el.href.search("#")) {
						window.location.href = window.location.href + el.href;
					} else {
						window.location.href = window.location.hostname + "/" + el.href;
					}
				}
			} else if (el.parentElement) {
				pressParents( el.parentElement );
			}
		}
		pressParents( elem )
	]])
	return true
end

function GPhone.StartMusic( id )
	if !id and !GPhone.MusicURL then return false end
	
	GPhone.StopMusic()
	GPhone.MusicURL = id or GPhone.MusicURL
	local vol = GetConVar("gphone_volume")
	
	if string.StartWith(id, "http://") or string.StartWith(id, "https://") then
		if string.find(id, "youtube.com") then
			local frame = GPhone.RunApp( "furfox" )
			frame:OpenURL( id )
			GPhone.CloseInput()
		else
			sound.PlayURL(GPhone.MusicURL, "noplay noblock", function(channel)
				if IsValid(channel) then
					channel:SetVolume( vol and vol:GetFloat() or 1 )
					channel:Play()
					
					if GPhone.MusicStream.Channel then
						GPhone.MusicStream.Channel:Stop()
					end
					
					GPhone.MusicStream.URL = GPhone.MusicURL
					GPhone.MusicStream.Playing = true
					GPhone.MusicStream.Channel = channel
					GPhone.MusicStream.Length = channel:GetLength()
				end
			end)
		end
	else
		if !file.Exists(GPhone.MusicURL, "GAME") then
			GPhone.MusicURL = "sound/"..GPhone.MusicURL
		end
		if !file.Exists(GPhone.MusicURL, "GAME") then return false end
		
		sound.PlayFile(GPhone.MusicURL, "noplay noblock", function(channel)
			if IsValid(channel) then
				channel:SetVolume( vol and vol:GetFloat() or 1 )
				channel:Play()
				
				if GPhone.MusicStream.Channel then
					GPhone.MusicStream.Channel:Stop()
				end
				
				GPhone.MusicStream.URL = GPhone.MusicURL
				GPhone.MusicStream.Playing = true
				GPhone.MusicStream.Channel = channel
				GPhone.MusicStream.Length = channel:GetLength()
			end
		end)
	end
	
	return true
end

function GPhone.StopMusic()
	if GPhone.MusicStream.Channel then
		GPhone.MusicStream.Channel:Stop()
		GPhone.MusicStream = {}
	end
end

function GPhone.ToggleMusic( play )
	if GPhone.MusicStream.Channel then
		if play == nil then
			if GPhone.MusicStream.Playing then
				GPhone.MusicStream.Playing = false
				GPhone.MusicStream.Channel:Pause()
			else
				GPhone.MusicStream.Playing = true
				GPhone.MusicStream.Channel:Play()
			end
		elseif GPhone.MusicStream.Playing and !play then
			GPhone.MusicStream.Playing = false
			GPhone.MusicStream.Channel:Pause()
		elseif !GPhone.MusicStream.Playing and play then
			GPhone.MusicStream.Playing = true
			GPhone.MusicStream.Channel:Play()
		end
	end
end

function GPhone.GetMusic()
	if GPhone.MusicStream.Channel then
		return GPhone.MusicStream
	end
	return false
end

function GPhone.ChangeVolume( dec )
	local dec = math.Clamp(math.Round(dec, 2), 0, 1)
	
	RunConsoleCommand("gphone_volume", dec)
	if GPhone.MusicStream.Channel then
		GPhone.MusicStream.Channel:SetVolume( dec )
	end
end

function GPhone.DownloadImage( url, size, style )
	if !url then return false end
	if GPhone.ImageCache[url] then return false end
	local data = {URL = url, Size = size or 128, Style = style}
	if string.StartWith(url, "http://") or string.StartWith(url, "https://") then -- Online files
		http.Fetch(url, function(body, size, headers, code)
			table.insert(GPhone.ImageHistory, data)
			if code == 200 then
				table.insert(GPhone.ImageQueue, data)
			else
				GPhone.ImageCache[url] = genicon
			end
		end,
		function(err)
			print("[GPhone] "..err)
		end)
	else
		table.insert(GPhone.ImageHistory, data)
		if string.EndsWith(url, ".png") or string.EndsWith(url, ".jpg") or string.EndsWith(url, ".jpeg") then -- Local files
			GPhone.ImageCache[url] = Material(url, "smooth")
		else
			GPhone.ImageCache[url] = Material(url)
		end
		if !GPhone.ImageCache[url] or GPhone.ImageCache[url]:IsError() then
			GPhone.ImageCache[url] = genicon
		end
	end
	return true
end

function GPhone.GetImage( url )
	if GPhone.ImageCache[url] and !GPhone.ImageCache[url]:IsError() then return GPhone.ImageCache[url] end
	return GPLoadingMT or genicon
end