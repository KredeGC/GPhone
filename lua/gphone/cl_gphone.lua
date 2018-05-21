if !GPhone then
	GPhone = {}
	GPhone.Data = {}
	GPhone.Panels = {}
	GPhone.ImageQueue = {}
	GPhone.ImageHistory = {}
	GPhone.CachedImages = {}
	GPhone.MusicStream = {}
	GPhone.AwaitingCalls = {}
	GPhone.HTML = {}
	GPhone.Log = {}
	GPhone.Apps = {}
	
	GPhone.CurrentApp = nil
	GPhone.CurrentFrame = nil
	GPhone.MovingApp = nil
	GPhone.MoveMode = nil
	GPhone.MusicURL = nil
	GPhone.InputField = nil
	GPhone.VoiceChatter = nil
	
	GPhone.CursorEnabled = false
	GPhone.Page = 1
	GPhone.Ratio = 560 / 830
	GPhone.Height = ScrH() / 1.032 -- Scaling with rendertargets is weird
	GPhone.Width = GPhone.Height * GPhone.Ratio
	GPhone.Resolution = GPhone.Height / 830
	GPhone.CursorPos = {x = 280, y = 415}
	
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
	local tbl = {
		apps = table.Copy(GPDefaultApps or {"appstore", "settings"}),
		background = "https://raw.githubusercontent.com/KredeGC/GPhone/master/images/background.jpg"
	}
	file.Write("gphone/users/client.txt", util.TableToJSON(tbl))
	GPhone.Data = tbl
end


function GPhone.GetAppSize(spacing, rows)
	local cv = GetConVar("gphone_rows")
	local w = GPhone.Width
	local spacing = spacing or GPhone.Desk.Spacing
	local rows = rows or cv and cv:GetInt() or 4
	
	return (w/rows)-spacing*(1+(1/rows))
end

function GPhone.GetAppPos() -- Became tired of doing all this manually... This is a much better solution since it's dynamic
	local cv = GetConVar("gphone_rows")
	local w = GPhone.Width
	local h = GPhone.Height
	local spacing = GPhone.Desk.Spacing
	local rows = cv and cv:GetInt() or 4
	local offset = GPhone.Desk.Offset
	local size = GPhone.GetAppSize(spacing, rows)
	local ratio = GPhone.Resolution
	
	local windows = {{}}
	local page = 1
	local posx = 0
	local posy = 0
	
	for k,appid in pairs(GPhone.Data.apps) do
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

function GPhone.AppThumbnail( appid )
	local app = GPhone.GetApp( GPhone.CurrentApp )
	if !app then return end
	local frame = GPhone.Panels[appid]
	if !frame then return false end
	render.PushRenderTarget(phonert)
	render.Clear(0, 0, 0, 255, true, true)
	cam.Start2D()
		local oldw,oldh = ScrW(), ScrH()
		local function drawChildren( pnl )
			if pnl.children and #pnl.children > 0 then
				for _,child in pairs(pnl.children) do
					if !child.visible then continue end
					
					if child.Paint then
						local px,py = parentPos( child.parent )
						local max,may = math.max(px + child.x, 0), math.max(py + child.y, 0)
						local mix,miy = math.min(px + child.x + child.w, GPhone.Width), math.min(py + child.y + child.h, GPhone.Height)
						
						render.SetViewPort(max, may, oldw, oldh)
						render.SetScissorRect(max, may, mix, miy, true)
						GPhone.DebugFunction( child.Paint, child, px + child.x, py + child.y, child.w, child.h )
						render.SetScissorRect(0, 0, 0, 0, false)
					end
					
					drawChildren( child )
				end
			end
		end
		
		if frame.Paint then
			local offset = frame.b_fullscreen and 0 or GPhone.Desk.Offset
			render.SetViewPort(0, offset, oldw, oldh)
			GPhone.DebugFunction( frame.Paint, frame, frame.x, frame.y, frame.w, frame.h )
		end
		drawChildren( frame )
		
		render.SetViewPort(0, 0, oldw, oldh)
		
		local offset = GPhone.Desk.Offset
		local height = GPhone.Height - offset
		
		local data = render.Capture( { format = "jpeg", quality = 100, x = 0, y = offset, h = height, w = GPhone.Width } )
		local appimg = file.Open( "gphone/screens/"..appid..".jpg", "wb", "DATA" )
		appimg:Write( data )
		appimg:Close()
	cam.End2D()
	render.PopRenderTarget()
	return true
end


function GPhone.AddApp( name, tbl )
	if type(tbl) != "table" or !tbl.Name or !tbl.Icon then return false end
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

GPhone.CamRT = GetRenderTarget("GPCameraRT_"..GPhone.Height, GPhone.Width, GPhone.Height, false)
GPhone.CamMV = CreateMaterial(
	"GPCameraMT_"..GPhone.Height,
	"GMODScreenspace",
	{
		[ '$basetexture' ] = GPhone.CamRT,
		[ '$basetexturetransform' ] = "center .5 .5 scale -1 -1 rotate 0 translate 0 0",
		[ '$texturealpha' ] = "0",
		[ '$vertexalpha' ] = "1",
	}
)


concommand.Add("gphone_redownloadimages", function()
	local tbl = table.Copy(GPhone.ImageHistory)
	GPhone.CachedImages = {}
	GPhone.ImageQueue = {}
	GPhone.ImageHistory = {}
	ImgReady = nil
	ImgDownloadTime = nil
	if IsValid(DownLoadHTML) then
		DownLoadHTML:Remove()
		DownLoadHTML = nil
	end
	for img,data in pairs(tbl) do
		GPhone.DownloadImage( data.URL, data.Size, data.SizeHack, data.Style )
	end
end)

concommand.Add("gphone_clearcache", function()
	GPhone.ImageQueue = {}
	GPhone.CachedImages = {}
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
	
	GPhone.DownloadImage( "https://raw.githubusercontent.com/KredeGC/GPhone/master/images/background.jpg", 512, true, "background-color: #FFF" )
end)


net.Receive("GPhone_Load_Client", function(len)
	local cv = GetConVar("gphone_sync")
	if game.SinglePlayer() or cv and cv:GetBool() then
		if file.Exists("gphone/users/client.txt", "DATA") then
			local tbl = util.JSONToTable( file.Read("gphone/users/client.txt", "DATA") )
			GPhone.Data = tbl
		else
			resetGPhoneData()
		end
	else
		local tbl = net.ReadTable()
		GPhone.Data = tbl
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
		end
		return true
	end
	return false
end

function GPhone.WipeLog()
	GPhone.Log = {}
end

function GPhone.PrintLog()
	for k,v in pairs(GPhone.Log) do
		MsgN(v)
	end
end

function GPhone.SaveData(name, v)
	GPhone.Data[name] = v
	local cv = GetConVar("gphone_sync")
	if !game.SinglePlayer() and (!cv or !cv:GetBool()) then
		net.Start( "GPhone_Change_Data" )
			net.WriteTable( GPhone.Data )
		net.SendToServer()
	else
		file.Write("gphone/users/client.txt", util.TableToJSON(GPhone.Data))
	end
	return true
end

function GPhone.GetData(name, def)
	return GPhone.Data[name] or def or false
end

function GPhone.BroadcastData(name, v)
	
end

function GPhone.ReceiveData(name)
	
end

function GPhone.GetCursorPos()
	local p = GPhone.CursorPos
	local x,y = p.x / 560 * GPhone.Width,p.y / 830 * GPhone.Height
	return x,y
end

function GPhone.GetPanel( name )
	local frame = GPhone.Panels[name]
	if !frame then return false end
	return frame,frame:GetSize()
end

function GPhone.RunApp( name )
	if GPhone.Panels[name] then return false end
	if !table.HasValue(GPhone.Data.apps, name) then return false end
	local app = GPhone.GetApp( name )
	if !app then return false end
	local frame = GPnl.AddPanel( nil, "frame" )
	if !frame then return false end
	
	GPhone.CurrentApp = name
	GPhone.CurrentFrame = frame
	GPhone.Panels[name] = frame
	
	local offset,w,h = GPhone.Desk.Offset,GPhone.Width,GPhone.Height - GPhone.Desk.Offset
	if app.Fullscreen then
		offset,h = 0,GPhone.Height
	end
	
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
	
	if app.Run then
		if type(app.Run) == "string" then
			local str = RunString( "appinit = "..app.Run, name, false )
			if !str and appinit then
				GPhone.DebugFunction( appinit, frame, w, h, GPhone.Resolution )
			else
				GPhone.Debug("[ERROR] in app '"..(app.Name or name).."': "..str, false, true)
			end
		else
			GPhone.DebugFunction( app.Run, frame, w, h, GPhone.Resolution )
		end
	end
	return true
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
				GPhone.Debug("[ERROR] in app '"..(app.Name or name).."': "..str, false, true)
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
	
	net.Start("GPhone_Selfie")
		net.WriteBool( false )
	net.SendToServer()
	
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
	if !GPhone.Panels[name] then return false end
	local frame = GPhone.Panels[name]
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
	return true
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
	
	net.Start("GPhone_Selfie")
		net.WriteBool( false )
	net.SendToServer()
	
	GPhone.CurrentApp = nil
	GPhone.CurrentFrame = nil
	return true
end

function GPhone.InstallApp( name )
	if table.HasValue(GPhone.Data.apps, name) then return false end
	local apps = GPhone.Data.apps
	table.insert(apps, name)
	GPhone.SaveData("apps", apps)
	return true
end

function GPhone.UninstallApp( name )
	if table.HasValue(GPDefaultApps, name) then return false end
	local apps = GPhone.Data.apps
	if file.Exists("gphone/apps/"..name..".txt", "DATA") then
		file.Delete("gphone/apps/"..name..".txt")
		GPhone.Apps[name] = nil
	end
	if table.HasValue(apps, name) then
		GPhone.StopApp( name )
		table.RemoveByValue(apps, name)
		GPhone.SaveData("apps", apps)
		return true
	end
	return false
end

function GPhone.DownloadApp( url )
	local cv = GetConVar("gphone_csapp")
	if !cv or !cv:GetBool() then return end
	local name = string.lower(url)
	local name = string.gsub(name, "http://", "")
	local name = string.gsub(name, "https://", "")
	local name = string.gsub(name, "/", "-")
	local name = string.gsub(name, ":", "-")
	local name = string.gsub(name, ";", "-")
	local name = string.gsub(name, "%.", "-")
	http.Fetch(url, function(body, size, headers, code)
		file.Write("gphone/apps/"..name..".txt", body)
		
		APP = {}
		
		RunString(body, name, false)
		
		GPhone.AddApp(name, APP)
		
		APP = nil
		
		GPhone.InstallApp( name )
	end,
	function(err)
		print(err)
	end)
end

function GPhone.Vibrate()
	local ply = LocalPlayer()
	if !ply:Alive() then return false end
	local wep = ply:GetActiveWeapon()
	if IsValid(wep) and wep:GetClass() == "weapon_gphone" then
		wep.b_vibrate = CurTime() + 1
	end
	
	if ply:HasWeapon("weapon_gphone") then
		wep:EmitSound("sound/gphone/vibrate.wav")
		return true
	end
	return false
end

function GPhone.RenderCamera( fov, front, post )
	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()
	if IsValid(wep) and wep:GetClass() == "weapon_gphone" then
		local oldWepColor = ply:GetWeaponColor()
		
		ply:SetWeaponColor( Vector(0, 0, 0) )
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
		
		-- GPCamRendering = true
		GPSelfieRendering = front
		
		render.RenderView({
			x = 0,
			y = 0,
			w = GPhone.Width,
			h = GPhone.Height,
			origin = pos,
			angles = ang,
			fov = fov or 90,
			drawpostprocess = true,
			drawhud = false,
			drawmonitors = false,
			drawviewmodel = false
		})
		
		if post then
			GPhone.DebugFunction( post, pos, ang, fov )
		end
		
		GPSelfieRendering = false
		-- GPCamRendering = false
		
		if front then
			ply.ShouldDisableLegs = oldlegs
			if EnhancedCamera and oldDraw then
				EnhancedCamera.ShouldDraw = oldDraw
			end
		end
		
		render.PopRenderTarget()
		
		ply:SetWeaponColor( oldWepColor )
		
		GPhone.CamMV:SetTexture("$basetexture", GPhone.CamRT)
		
		return GPhone.CamMV
	end
	return false
end

function GPhone.SendSMS(number, text)
	net.Start( "GPhone_SMS_Send" )
		net.WriteString( number )
		net.WriteString( text )
	net.SendToServer()
	return true
end

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

function GPhone.CreateHTMLPanel( w, h, url )
	local html = vgui.Create("DHTML")
	html.URL = url or "about:blank"
	html:SetPos(0, 0)
	html:SetSize(w or GPhone.Width, h or GPhone.Height)
	html:OpenURL( url or "https://www.google.com" )
	
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
		print(str)
	end)
	
	html:AddFunction( "gmod", "javascript", function( ... )
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

local noicon = Material("noicon.png", "nocull smooth")
local genicon = Material( "vgui/spawnmenu/generating" )

function GPhone.ReturnHTMLMaterial( html )
	if IsValid(html) then
		html:UpdateHTMLTexture()
	end
	if !html.Mat and IsValid(html) and html:GetHTMLMaterial() then
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
	elseif html.Mat then
		return html.Mat
	else
		return noicon
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
	if !id and !GPhone.MusicURL or GPhone.GetData("music_disable") then return false end
	
	GPhone.StopMusic()
	GPhone.MusicURL = id or GPhone.MusicURL
	
	if string.StartWith(id, "http://") or string.StartWith(id, "https://") then
		if string.find(id, "youtube.com") then
			gui.OpenURL(id)
		else
			sound.PlayURL(GPhone.MusicURL, "noplay noblock", function(channel)
				if IsValid(channel) then
					channel:SetVolume( GPhone.GetData("music_volume") or 1 )
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
		
		sound.PlayFile(GPhone.MusicURL, "noplay noblock", function(channel)
			if IsValid(channel) then
				channel:SetVolume( GPhone.GetData("music_volume") or 1 )
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
	
	GPhone.SaveData("music_volume", dec)
	if GPhone.MusicStream.Channel then
		GPhone.MusicStream.Channel:SetVolume( dec )
	end
end

function GPhone.DownloadImage( url, size, hack, style )
	if GPhone.CachedImages[url] then return false end
	if string.StartWith(url, "http://") or string.StartWith(url, "https://") then -- Local files
		local data = {URL = url, Size = size, SizeHack = hack, Style = style}
		table.insert(GPhone.ImageHistory, data)
		table.insert(GPhone.ImageQueue, data)
	else
		local data = {URL = url, Size = size or 128, Style = ""}
		table.insert(GPhone.ImageHistory, data)
		if string.EndsWith(url, "png") or string.EndsWith(url, "jpg") or string.EndsWith(url, "jpeg") then
			GPhone.CachedImages[url] = Material(url, "smooth")
		else
			GPhone.CachedImages[url] = Material(url)
		end
	end
	return true
end

function GPhone.GetImage( url )
	if GPhone.CachedImages[url] and !GPhone.CachedImages[url]:IsError() then return GPhone.CachedImages[url] end
	return genicon
end