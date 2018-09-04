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
	
	GPhone.CursorEnabled	= false
	GPhone.Page				= 1
	GPhone.Ratio			= 56 / 83
	GPhone.Height			= ScrH() / 1.032 -- Scaling with rendertargets is weird
	GPhone.Width			= GPhone.Height * GPhone.Ratio
	GPhone.Resolution		= GPhone.Height / 830
	GPhone.CursorPos		= {x = 560, y = 830}
	
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


function GPhone.GetAppSize(spacing, rows)
	local cv = GetConVar("gphone_rows")
	local w = GPhone.Width
	local spacing = spacing or GPhone.Desk.Spacing
	local rows = rows or cv and cv:GetInt() or 4
	
	return (w/rows)-spacing*(1+(1/rows))
end

function GPhone.GetAppPos() -- Became tired of doing all this manually... This is a much better solution since it's dynamic
	local cv		= GetConVar("gphone_rows")
	local w			= GPhone.Width
	local h			= GPhone.Height
	local spacing	= GPhone.Desk.Spacing
	local rows		= cv and cv:GetInt() or 4
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
	local rt = GetRenderTarget("GPAppRT2_"..name, GPhone.Width*1.032, (GPhone.Height - GPhone.Desk.Offset)*1.032, false)
	local mat = CreateMaterial(
		"GPAppMT2_"..name,
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

surface.CreateFont("GPAppName", { font = "Open Sans Light", size = 30 * GPhone.Resolution, additive = false, shadow = false})

surface.CreateFont("GPSmall", { font = "Open Sans", size = 28 * GPhone.Resolution, additive = false, shadow = false})

surface.CreateFont("GPMedium", { font = "Open Sans", size = 36 * GPhone.Resolution, additive = false, shadow = false})

surface.CreateFont("GPTitle", { font = "Open Sans", size = 44 * GPhone.Resolution, additive = false, shadow = false})


surface.CreateFont("GPBugReport", { font = "Open Sans", size = 48 * GPhone.Resolution, additive = false, shadow = false})

surface.CreateFont("GPLoading", { font = "Open Sans", size = 128, additive = false, shadow = false})

GPhone.PhoneRT = GetRenderTarget("GPScreenRT_"..math.ceil(GPhone.Height), GPhone.Width*1.032, GPhone.Height*1.032, false)
GPhone.PhoneMT = CreateMaterial(
	"GPScreenMT_"..math.ceil(GPhone.Height),
	"UnlitGeneric",
	{
		["$basetexture"] = GPhone.PhoneRT,
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 1
	}
)

GPhone.CamRT = GetRenderTarget("GPCameraRT_"..math.ceil(GPhone.Height), GPhone.Width, GPhone.Height, false)
GPhone.CamMV = CreateMaterial(
	"GPCameraMT_"..math.ceil(GPhone.Height),
	"GMODScreenspace",
	{
		["$basetexture"] = GPhone.CamRT,
		["$basetexturetransform"] = "center .5 .5 scale -1 -1 rotate 0 translate 0 0",
		["$texturealpha"] = 0,
		["$vertexalpha"] = 1,
	}
)


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
	
	local shared = GPhone.GetData("shared", {})
	shared[name] = data
	GPhone.SetData("shared", shared)
	
	local func = GPhone.SharedHooks[name]
	if func then
		GPhone.DebugFunction( func, ply, name, data )
	end
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

function GPhone.Debug( str, spam, notify )
	local last = GPhone.Log[#GPhone.Log]
	if spam or last != str then -- Prevent spam
		table.insert(GPhone.Log, str)
		if notify then
			ErrorNoHalt( str.."\n" )
		else
			MsgN(str)
		end
		if IsValid(GPErrorTextField) then
			GPErrorTextField:SetText( string.Implode("\n", GPhone.Log) )
		end
		local cv = GetConVar("gphone_report")
		if notify and cv and cv:GetBool() then
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
	net.Start( "GPhone_Share_Data" )
		net.WriteEntity( ply )
		net.WriteString( name )
		net.WriteTable( data )
	net.SendToServer()
end

function GPhone.GetSharedData(name, def)
	local data = GPhone.GetData("shared", {})
	return data[name] or def or false
end

function GPhone.GetCursorPos()
	local p = GPhone.CursorPos
	local x,y = p.x / 1120 * GPhone.Width,p.y / 1660 * GPhone.Height
	return x,y
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
	net.Start("GPhone_Selfie")
		net.WriteBool( bool or false )
	net.SendToServer()
	return true
end

function GPhone.SelfieEnabled()
	return LocalPlayer():GetNWBool("GPSelfie")
end

function GPhone.CreateRootPanel()
	local frame = GPnl.AddPanel( nil, "frame" )
	if !frame then return false end
	
	local offset = GPhone.Desk.Offset
	local w,h = GPhone.Width,GPhone.Height - offset
	
	frame:SetPos( 0, offset )
	frame:SetSize( w, h )
	frame.Remove = nil
	
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

function GPhone.RunApp( name )
	if GPhone.Panels[name] then -- Focus the app instead
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
	
	GPhone.CurrentApp = name
	GPhone.CurrentFrame = frame
	GPhone.Panels[name] = frame
	
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
	
	if file.Exists("gphone/screens/"..name..".jpg", "DATA") then
		file.Delete("gphone/screens/"..name..".jpg")
	end
	return true
end

function GPhone.FocusApp( name )
	local frame = GPhone.Panels[name]
	if !frame then return false end
	GPhone.CurrentApp = name
	GPhone.CurrentFrame = frame
	local app = GPhone.GetApp( name )
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

function GPhone.DownloadApp( url )
	local cv = GetConVar("gphone_csapp")
	if !cv or !cv:GetBool() then return false end
	local name = GPhone.SerializeAppName( url )
	http.Fetch(url, function(body, size, headers, code)
		file.Write("gphone/apps/"..name..".txt", body)
		
		APP = {}
		
		RunString(body, name)
		
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

function GPhone.Rotate( landscape ) -- I'm not sure how to approach this yet
	if true then return end
	GPhone.Landscape = landscape
	local oldw = GPhone.Width
	local oldh = GPhone.Height
	GPhone.Width = oldh
	GPhone.Height = oldw
end

function GPhone.RenderCamera( fov, front, pre, post )
	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()
	if IsValid(wep) and wep:GetClass() == "gmod_gphone" then
		render.PushRenderTarget(GPhone.CamRT)
		
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
			local mdl = wep.PhoneModel
			if IsValid(mdl) then
				ang = mdl:GetAngles()
				ang:RotateAroundAxis(ang:Up(), 180)
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
		
		GPhone.CamMV:SetTexture("$basetexture", GPhone.CamRT)
		
		return GPhone.CamMV
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

function GPhone.InputText( enter, change, cancel, starttext )
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
	frame.Paint = function()
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
			enter( self:GetValue() )
		end
	end
	function GPhone.InputField:OnTextChanged()
		if change then
			change( self:GetValue() )
		end
	end
	function GPhone.InputField:OnLoseFocus()
		self:GetParent():Close()
		if self.m_entered then return end
		if cancel then
			cancel()
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
	html:SetPos(0, 0)
	html:SetSize(w or GPhone.Width, h or GPhone.Height)
	html.b_keepvolume = vol
	if url then
		html:OpenURL( url )
	end
	
	function html:ConsoleMessage() return end -- Removes all the annoying HTML messages
	
	html:AddFunction( "gmod", "getURL", function( str )
		if str != "about:blank" then
			html.URL = str
		end
	end)
	
	html:AddFunction( "gmod", "inputField", function( tag, id, oldval )
		if tag and id then
			local function onEnter( val )
				if IsValid(html) and tag and id then
					local js = [[
						var x = document.getElementsByTagName("]]..tag..[[");
						x[]]..id..[[].value = "]]..val..[[";
					]]
					html:RunJavascript( js )
				end
			end
			local function onCancel()
				if IsValid(html) and tag and id and oldval and type(oldval) == "string" then
					local js = [[
						var x = document.getElementsByTagName("]]..tag..[[");
						x[]]..id..[[].value = "]]..oldval..[[";
					]]
					html:RunJavascript( js )
				end
			end
			GPhone.InputText( onEnter, onEnter, onCancel, oldval )
		end
	end)
	
	html:AddFunction( "gmod", "redirect", function( href )
		if href then
			html:OpenURL( href )
		end
	end)
	
	html:AddFunction( "gmod", "print", function( ... )
		local str = string.Implode(" ", { ... })
		print("[GPhone][HTML] "..str)
	end)
	
	html:AddFunction( "gmod", "javascript", function( ... ) -- Why have I done this
		local js = string.Implode(" ", { ... })
		html:RunJavascript( js )
	end)
	
	html:AddFunction( "window", "open", function() -- From Cinema
		-- Prevents pop-ups from opening
	end)
	
	html:SetKeyBoardInputEnabled(false)
	html:SetPaintedManually(false)
	html:SetVisible(false)
	timer.Simple(0, function()
		html:SetPaintedManually(true)
	end)
	
	table.insert(GPhone.HTML, html)
	
	return html
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

function GPhone.ReturnHTMLMaterial( html )
	local valid = IsValid(html)
	if valid then
		html:UpdateHTMLTexture()
	end
	if !html.Mat and valid and html:GetHTMLMaterial() then
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
		
		local id = string.Replace(mat:GetName(), "__vgui_texture_", "")
		html.Mat = CreateMaterial("GPhone_HTMLMaterial_"..id, "UnlitGeneric", matdata)
		
		return html.Mat
	elseif valid and html.Mat then
		return html.Mat
	else
		return genicon
	end
end

function GPhone.GetHTMLPos( frame, html, mx, my )
	if !frame or !IsValid(html) then return mx,my end
	
	local fx,fy = parentPos( frame )
	local fw,fh = frame.w,frame.h
	
	local mx,my = ((mx-fx)/fw)*html:GetWide(),((my-fy)/fh)*html:GetTall()
	return mx,my
end

function GPhone.PerformHTMLClick( html, x, y )
	if !IsValid(html) then return false end
	html:RunJavascript([[
		var elem = document.elementFromPoint(]]..x..[[, ]]..y..[[);
		// elem.style.color = 'red';
		
		// This is quite a hacky way, but elem.click() only works on buttons....
		
		function pressParents( el ) {
			if (el.tagName == "INPUT" && el.type == "text") {
				var x = document.getElementsByTagName(el.tagName);
				for (i = 0; i < x.length; i++) {
					if (x[i] == el) {
						gmod.inputField( el.tagName, i, el.value );
					}
				}
			} else if (el.onclick) {
				el.onclick();
			} else if (el.tagName == "A") {
				if (el.href) {
					if (el.href.search("javascript:") > -1) { // Run javascript code if possible
						gmod.print(el.href.sub(11));
						eval(el.href.sub(11));
					} else if (el.href.search(window.location.protocol) == 0 || el.href.search(window.location.protocol) == -1) {
						gmod.redirect(el.href);
					} else if (el.href.search("#")) {
						gmod.redirect(window.location.href + el.href);
					} else {
						gmod.redirect(window.location.hostname + "/" + el.href);
					}
				}
			} else if (el.tagName == "IFRAME") {
				if (el.src) {
					gmod.redirect(el.src + "?hd=1&autoplay=true");
				}
			} else if (el.parentElement) {
				pressParents( el.parentElement );
			}
		}
		pressParents( elem )
		elem.click();
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