local gpnotfound = false
local noicon = Material("noicon.png", "nocull smooth")
local GPLoadingRT = GetRenderTarget("GPLoadingRT", 512, 512, false)
GPLoadingMT = CreateMaterial(
	"GPLoadMT",
	"UnlitGeneric",
	{
		["$basetexture"] = GPLoadingRT,
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 1
	}
)


hook.Add("Think", "GPhoneQueueImage", function()
	for _,html in pairs(GPhone.HTML) do
		if IsValid(html) then
			if html:IsLoading() then
				if !html.b_loading then
					html.b_loading = true
					if GPhone.IsAwesomium then
						html:QueueJavascript([[window.onerror = function(msg, url, line, col, error) {
							gmod.print("Line " + line + ": " + msg);
						};
						isAwesomium = navigator.userAgent.indexOf("Awesomium") != -1;
						gmod.getURL( window.location.href );]])
					end
				end
			else
				if html.b_loading then
					html.b_loading = false
					GPhone.UpdateHTMLControl( html ) -- Chromium likes to randomly delete these. Remind it who's boss
					html:QueueJavascript([[window.onerror = function(msg, url, line, col, error) {
						gmod.print("Line " + line + ": " + msg);
					};
					isAwesomium = navigator.userAgent.indexOf("Awesomium") != -1;
					gmod.getURL( window.location.href );]])
					
					if GPhone.IsAwesomium == nil then
						html:QueueJavascript([[gmod.isAwesomium( isAwesomium );]])
					end
				elseif !html.b_keepvolume then
					local vol = GetConVar("gphone_volume")
					html:RunJavascript([[var x = [];
					x.push.apply( x, document.getElementsByTagName("VIDEO") );
					x.push.apply( x, document.getElementsByTagName("AUDIO") );
					for (i = 0; i < x.length; i++) {
						x[i].volume = ]]..(vol and vol:GetFloat() or 1)..[[;
					}]])
				end
			end
		end
	end
	
	local count = table.Count(GPhone.ImageQueue)
	if count > 0 then
		gpnotfound = false
		render.PushRenderTarget(GPLoadingRT)
		render.Clear(0, 0, 0, 255, true, true)
		cam.Start2D()
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial( noicon )
			surface.DrawTexturedRect( 0, 0, 512, 512 )
			
			surface.SetDrawColor(255, 255, 255)
			surface.SetTexture( surface.GetTextureID("vgui/loading-rotate") )
			surface.DrawTexturedRectRotated( 256, 256, 512, 512, RealTime()*360 )
			
			draw.SimpleText("Loading", "GPLoading", 256, 256, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
			draw.SimpleText(count, "GPLoading", 256, 256, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		cam.End2D()
		render.PopRenderTarget()
		
		GPLoadingMT:SetTexture("$basetexture", GPLoadingRT)
		
		for k,data in pairs(GPhone.ImageQueue) do
			if GPhone.ImageCache[data.URL] then continue end
			
			if !ImgDownloadTime and !ImgReady and !IsValid(DownloadHTML) then
				DownloadHTML = vgui.Create( "HTML" )
				DownloadHTML:SetPos(ScrW()-1, ScrH()-1)
				DownloadHTML:SetSize(data.Size, data.Size)
				DownloadHTML:SetHTML([[
					<style type="text/css">
						html { overflow:hidden; margin: -8px -8px; }
						img { ]]..(data.Style or "")..[[ }
					</style>
					
					<body>
						<img src="]]..data.URL..[[" alt="]]..data.URL..[[" width="]]..data.Size..[[" height="]]..data.Size..[[" />
					</body>
				]])
			end
			
			local tex = DownloadHTML:GetHTMLMaterial()
			
			if !ImgReady and tex and !DownloadHTML:IsLoading() then
				ImgDownloadTime = CurTime() + 0.1
				ImgReady = true
			end
			
			if ImgReady and ImgDownloadTime < CurTime() then
				ImgReady = nil
				ImgDownloadTime = nil
				local scale_x,scale_y = DownloadHTML:GetWide() / tex:Width(),DownloadHTML:GetTall() / tex:Height()
				local matdata = {
					["$basetexture"] = tex:GetName(),
					["$basetexturetransform"] = "center 0 0 scale "..scale_x.." "..scale_y.." rotate 0 translate 0 0",
					["$vertexcolor"] = 1,
					["$vertexalpha"] = 1,
					["$nocull"] = 1,
					["$model"] = 1
				}
				local id = string.Replace(tex:GetName(), "__vgui_texture_", "")
				GPhone.ImageCache[data.URL] = CreateMaterial("GPhone_CachedImage_"..id, "UnlitGeneric", matdata)
				GPhone.ImageQueue[k] = nil
				DownloadHTML:Remove()
				DownloadHTML = nil
			end
			
			break
		end
	elseif !gpnotfound then -- No need to update if we're not downloading anything
		gpnotfound = true
		render.PushRenderTarget(GPLoadingRT)
		render.Clear(0, 0, 0, 255, true, true)
		cam.Start2D()
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial( noicon )
			surface.DrawTexturedRect( 0, 0, 512, 512 )
			
			draw.SimpleText("Image", "GPLoading", 512/2, 512/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
			draw.SimpleText("Not Found", "GPLoading", 512/2, 512/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		cam.End2D()
		render.PopRenderTarget()
		
		GPLoadingMT:SetTexture("$basetexture", GPLoadingRT)
	end
end)

hook.Add("HUDShouldDraw", "_GPhoneHideWPSelection", function(name)
	local ply = LocalPlayer()
	if IsValid(ply) then
		local wep = ply:GetActiveWeapon()
		if IsValid(wep) and wep:GetClass() == "gmod_gphone" then
			if GPhone.CursorEnabled and name == "CHudWeaponSelection" then return false end
		end
	end
end)

local matflash = Material( "sprites/light_ignorez" )

hook.Add("PostPlayerDraw", "DrawGFlashlight", function(ply)
	local wep = ply:GetActiveWeapon()
	if ply:FlashlightIsOn() and IsValid(wep) and wep:GetClass() == "gmod_gphone" then
		if ply != LocalPlayer() or GetViewEntity() != LocalPlayer() then
			local id = ply:LookupAttachment("anim_attachment_RH")
			if !id then return end
			local attach = ply:GetAttachment(id)
			if !attach then return end
			
			local pos,ang = attach.Pos,attach.Ang
			
			pos = pos + ang:Forward() * wep.WorldModelInfo.pos.x + ang:Right() * wep.WorldModelInfo.pos.y + ang:Up() * wep.WorldModelInfo.pos.z
			pos = pos + ang:Up()*1.9 + ang:Forward()*0.6 + ang:Right()*1.1
			
			local dir = ply:EyeAngles():Forward():Dot( (GetViewEntity():GetPos() - pos):GetNormalized() )
			
			local leng = (GetViewEntity():GetPos() - pos):Length()
			local a = math.max(1000-leng, 0)
			
			if dir > 0.2 then
				render.SetMaterial( matflash )
				render.DrawSprite( pos, dir*(leng/4), dir*(leng/4), Color(255,255,255,a) )
			end
		end
	end
end)

hook.Add("InputMouseApply", "_GPhoneMouseInput", function( cmd, x, y, angle )
	local wep = LocalPlayer():GetActiveWeapon()
	if IsValid(wep) and wep:GetClass() == "gmod_gphone" and GPhone.CursorEnabled then
		local cv = GetConVar("gphone_sensitivity")
		local sens = cv and cv:GetFloat() or 4
		
		local inv = GPhone.Landscape
		local ychange = (inv and x or y) * sens * 0.2
		local xchange = (inv and -y or x) * sens * 0.2
		
		local x = math.Clamp(GPhone.CursorPos.x + xchange, -40, 1168)
		local y = math.Clamp(GPhone.CursorPos.y + ychange, -380, 2052)
		
		GPhone.CursorPos = {x = x, y = y}
		
		cmd:SetViewAngles( angle )
		
		return true
	end
end)

hook.Add("ShouldDrawLocalPlayer", "_GPhoneDrawSelfiePlayer", function(ply)
	local wep = LocalPlayer():GetActiveWeapon()
	if IsValid(wep) and wep:GetClass() == "gmod_gphone" and GPhone.SelfieEnabled() then
		cam.Start3D()
		cam.End3D()
		if GPSelfieRendering then return true end
	end
end)


local function parentPos( p )
	if p then
		local px,py = parentPos( p.parent )
		local x,y = p.x,p.y
		return x+px,y+py
	else
		return 0,0
	end
end


function InitGPhoneAppCreator()
	if IsValid(GPAppCreator) then return end
	
	local spacing = 10
	local pwidth = 600
	local w,h = GPhone.Width + pwidth + spacing*3,GPhone.Height + spacing*2
	
	GPAppCreator = vgui.Create( "DFrame" )
	GPAppCreator:SetSize(w, h)
	GPAppCreator:SetPos(ScrW()/2 - w/2, ScrH()/2 - h/2)
	GPAppCreator:SetTitle("")
	GPAppCreator:SetDraggable(false)
	GPAppCreator:ShowCloseButton(false)
	GPAppCreator:SetSizable(false)
	GPAppCreator.Paint = function(self)
		draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(70,70,70))
	end
	GPAppCreator:MakePopup()
	GPAppCreator.Frame = GPhone.CreateRootPanel()
	GPAppCreator.Code = "function( frame, w, h, ratio )\n    function frame:Paint( x, y, w, h )\n        draw.RoundedBox( 0, 0, 0, w, h, Color( 220, 220, 220, 255 ) )\n    end\nend"
	GPAppCreator.Caret = 0
	GPAppCreator.m_lastcarot = 0
	GPAppCreator.m_nextblink = 0
	GPAppCreator.Selection = {}
	
	surface.SetFont("DermaDefault")
	local _,fontheight = surface.GetTextSize(" ")
	
	function GPAppCreator:CoordsToCarot( x, y )
		local stops = GPAppCreator:GetTextTable()
		
		for cy = 1, y do
			local w = string.len(stops[cy])
			x = x + w
		end
		
		return x
	end
	function GPAppCreator:GetCaret()
		return math.Clamp(self.Caret or 0, 0, string.len(self.Code or "") + 1)
	end
	function GPAppCreator:GetCaretCoords()
		local text = self.Code or ""
		local pos = self:GetCaret()
		local x,y = pos,1
		
		for i = 0, pos do
			if string.sub(text, i, i) == "\n" then
				y = y + 1
				x = pos - i
			end
		end
		
		return x,y
	end
	function GPAppCreator:GetCaretPos()
		local x,y = self:GetCaretCoords()
		local line = self:GetTextIndex( y )
		
		if line then
			surface.SetFont("DermaDefault")
			local w = surface.GetTextSize(string.sub(line, 0, x))
			
			return w,y*fontheight
		end
		return x,y*fontheight
	end
	
	function GPAppCreator:SelectArea( start, stop )
		self.Selection = {start or 0, stop or 0}
	end
	
	function GPAppCreator:GetSelection()
		local pos = self:GetSelectionPos()
		local text = string.sub(self.Code or "", pos[1]+1, pos[2])
		return text
	end
	function GPAppCreator:GetSelectionPos()
		return (self.Selection and #self.Selection > 1 and self.Selection) or {0,0}
	end
	
	function GPAppCreator:GetTextTable( t )
		local text = t or self.Code or ""
		local stops = {}
		local laststop = 0
		
		for i = 0, string.len(text) do
			if string.sub(text, i, i) == "\n" or i == string.len(text) then
				table.insert(stops, string.sub(text, laststop+1, i))
				laststop = i
			end
		end
		
		return stops
	end
	function GPAppCreator:GetTextIndex( index )
		return self:GetTextTable()[index] or false
	end
	
	local GPanel = vgui.Create("DPanel", GPAppCreator)
	GPanel:SetSize(pwidth, h - spacing*2 - 30)
	GPanel:SetPos( GPhone.Width + spacing*2, spacing )
	GPanel:SetCursor( "beam" )
	function GPanel:Paint()
		surface.SetDrawColor(255, 255, 255)
		surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
		
		local text	= GPAppCreator.Code or ""
		local pos	= GPAppCreator:GetSelectionPos()
		local cx,cy	= GPAppCreator:GetCaretPos()
		local stops	= GPAppCreator:GetTextTable()
		
		surface.SetFont("DermaDefault")
		local offset = surface.GetTextSize(#stops) + 4
		
		surface.SetDrawColor(200, 200, 200)
		surface.DrawRect(0, 0, offset, self:GetTall())
		
		surface.SetDrawColor(180, 220, 255)
		surface.DrawRect(offset, cy-fontheight, self:GetWide()-offset, fontheight)
		
		if pos[1] != pos[2] then -- Messy way of drawing the selection box...
			local laststop = 0
			local x = 0
			local y = 0
			local h = 0
			local tbl = GPAppCreator:GetTextTable( string.sub(text, pos[1], pos[2]) )
			surface.SetFont("DermaDefault")
			
			for i = 0, pos[1] do
				if string.sub(text, i, i) == "\n" then
					laststop = i
					y = y + 1
				elseif i == pos[1] then
					x = surface.GetTextSize(string.sub(text, laststop, i))
				end
			end
			
			for i,val in pairs(tbl) do
				local w = surface.GetTextSize(val)
				surface.SetDrawColor(160, 180, 200)
				
				if i == 1 then
					surface.DrawRect(offset + x, (i-1)*fontheight + y*fontheight, w, fontheight)
				else
					surface.DrawRect(offset, (i-1)*fontheight + y*fontheight, w, fontheight)
				end
			end
		end
		
		for i,val in pairs(stops) do
			draw.SimpleText(val, "DermaDefault", offset+2, fontheight*(i-1), Color(0,0,0))
			draw.SimpleText(i, "DermaDefault", offset-2, fontheight*(i-1), Color(70,70,70), TEXT_ALIGN_RIGHT)
		end
		
		local flash = math.sin((CurTime()-GPAppCreator.m_nextblink)*10) > 0
		
		if flash then
			surface.SetDrawColor(0, 0, 0)
			surface.DrawRect(offset+cx, cy-fontheight, 1, fontheight)
		end
	end
	function GPanel:OnMousePressed(code)
		if code == MOUSE_LEFT then
			surface.SetFont("DermaDefault")
			local mx,my = self:CursorPos()
			local stops = GPAppCreator:GetTextTable()
			local offset = surface.GetTextSize(#stops+1) + 6
			local y = math.floor( my / fontheight )
			local line = stops[y + 1]
			local cx = string.len(line or "")
			if string.sub(line or "", string.len(line or ""), string.len(line or "")+1) == "\n" then -- Fixing a few issues
				cx = string.len(line or "")-1
			end
			
			GPAppCreator:SelectArea( 0, 0 )
			
			GPAppCreator.m_nextblink = CurTime()
			
			if line then
				for x = 0, string.len(line) do -- There probably is a better way...
					local start = surface.GetTextSize(string.sub(line, 0, x-1))
					local stop = surface.GetTextSize(string.sub(line, 0, x+1))
					if mx > start + offset and mx < stop + offset then
						cx = x
					end
				end
				
				if mx <= offset then cx = 0 end -- Fixing a few issues
				
				local coords = GPAppCreator:CoordsToCarot( cx,y )
				
				GPAppCreator.Caret = coords
				GPAppCreator.m_lastcarot = coords
			else
				GPAppCreator.m_lastcarot = string.len(GPAppCreator.Code or "")
				
				GPAppCreator.Caret = string.len(GPAppCreator.Code or "")
			end
		elseif code == MOUSE_RIGHT then
			local Menu = DermaMenu()
			
			local text = GPAppCreator:GetSelection()
			if string.len(text) > 0 then
				Menu:AddOption("Copy", function()
					SetClipboardText(text)
				end):SetIcon("icon16/page_code.png")
			end
			
			Menu:AddOption("Run", function()
				
			end):SetIcon("icon16/page_code.png")
			
			Menu:Open()
		end
	end
	function GPanel:OnMouseReleased(code)
		if code == MOUSE_LEFT then
			surface.SetFont("DermaDefault")
			local mx,my = self:CursorPos()
			local stops = GPAppCreator:GetTextTable()
			local offset = surface.GetTextSize(#stops+1) + 6
			local y = math.floor( my / fontheight )
			local line = stops[y + 1]
			local cx = string.len(line or "")
			if string.sub(line or "", string.len(line or ""), string.len(line or "")+1) == "\n" then --Fixing a few issues
				cx = string.len(line or "")-1
			end
			
			if line then
				for x = 0, string.len(line) do --There probably is a better way...
					local start = surface.GetTextSize(string.sub(line, 0, x-1))
					local stop = surface.GetTextSize(string.sub(line, 0, x+1))
					if mx > start + offset and mx < stop + offset then
						cx = x
					end
				end
				
				if mx <= offset then cx = 0 end --Fixing a few issues
				
				local coords = GPAppCreator:CoordsToCarot( cx,y )
				
				if coords == GPAppCreator.m_lastcarot then return end
				
				GPAppCreator.Caret = GPAppCreator:CoordsToCarot( cx,y )
				
				if coords > GPAppCreator.m_lastcarot then
					GPAppCreator:SelectArea( GPAppCreator.m_lastcarot, coords )
				else
					GPAppCreator:SelectArea( coords, GPAppCreator.m_lastcarot )
				end
			elseif GPAppCreator.m_lastcarot != string.len(GPAppCreator.Code or "") then
				GPAppCreator.Caret = string.len(GPAppCreator.Code or "")
				
				GPAppCreator:SelectArea( GPAppCreator.m_lastcarot, string.len(GPAppCreator.Code or "") )
			end
		end
	end
	
	GPTextField = vgui.Create("DTextEntry", GPanel)
	GPTextField:SetText("")
	GPTextField:SetSize(1, 1)
	GPTextField:SetPos( 0, 0 )
	GPTextField:SetDrawLanguageID( false )
	GPTextField:SetMultiline( true )
	GPTextField:SetTabbingDisabled( true )
	GPTextField:SetMouseInputEnabled( false )
	GPTextField:RequestFocus()
	function GPTextField:Paint()
	end
	function GPTextField:OnTextChanged()
		local new = self:GetValue()
		self:SetText("")
		local pos = GPAppCreator:GetCaret()
		local val = GPAppCreator.Code
		local first = string.sub(val, 0, pos)
		local rest = string.sub(val, pos+1, string.len(val))
		local text = first..new..rest
		GPAppCreator.Code = text
		GPAppCreator.Caret = pos + string.len(new)
	end
	function GPTextField:OnKeyCodeTyped( key )
		if input.IsKeyDown(KEY_LCONTROL) or input.IsKeyDown(KEY_RCONTROL) then
			if key == KEY_A then
				GPAppCreator:SelectArea( 0, string.len(GPAppCreator.Code or "") )
			elseif key == KEY_C or key == KEY_X or key == KEY_V then
				local pos = GPAppCreator:GetSelectionPos()
				if pos[1] != pos[2] then
					if key == KEY_C or key == KEY_X then
						SetClipboardText( GPAppCreator:GetSelection() )
					end
					if key == KEY_X or key == KEY_V then
						local val = GPAppCreator.Code
						local first = string.sub(val, 0, pos[1])
						local rest = string.sub(val, pos[2]+1, string.len(val))
						GPAppCreator.Code = first..rest
						GPAppCreator.Caret = pos[1]
						GPAppCreator:SelectArea( 0, 0 )
					end
				end
			end
		elseif key == KEY_LEFT or key == KEY_RIGHT or key == KEY_UP or key == KEY_DOWN then
			if key == KEY_LEFT then
				GPAppCreator.Caret = math.max(GPAppCreator.Caret - 1, 0)
			elseif key == KEY_RIGHT then
				GPAppCreator.Caret = math.min(GPAppCreator.Caret + 1, string.len(GPAppCreator.Code))
			end
			return true
		elseif key == KEY_ENTER then
			local pos = GPAppCreator:GetCaret()
			local val = GPAppCreator.Code
			
			local indent = 0
			
			for i = 0, pos do
				if string.sub(val, i-3, i) == "then" or string.sub(val, i-1, i) == "do" or string.sub(val, i-7, i) == "function" then
					indent = indent + 1
				elseif string.sub(val, i-2, i) == "end" then
					indent = indent - 1
				end
			end
			
			local first = string.sub(val, 0, pos)
			local text = first.."\n"
			for i = 1, indent do
				text = text.."    "
			end
			local rest = string.sub(val, pos+1, string.len(val))
			GPAppCreator.Code = text..rest
			GPAppCreator.Caret = pos + indent*4 + 1
			return true
		elseif key == KEY_TAB then
			local pos = GPAppCreator:GetCaret()
			local val = GPAppCreator.Code
			local first = string.sub(val, 0, pos)
			local rest = string.sub(val, pos+1, string.len(val))
			local text = first.."    "..rest
			GPAppCreator.Code = text
			GPAppCreator.Caret = pos + 4
			return true
		elseif key == KEY_BACKSPACE then
			local pos = GPAppCreator:GetSelectionPos()
			if pos[1] != pos[2] then
				GPAppCreator:SelectArea( 0, 0 )
				local val = GPAppCreator.Code
				local first = string.sub(val, 0, pos[1])
				local rest = string.sub(val, pos[2]+1, string.len(val))
				GPAppCreator.Code = first..rest
			else
				local pos = GPAppCreator:GetCaret()
				if pos == 0 then return true end
				local val = GPAppCreator.Code
				local found = string.sub(val, pos-3, pos) == "    "
				if found then
					local first = string.sub(val, 0, pos-4)
					local rest = string.sub(val, pos+1, string.len(val))
					GPAppCreator.Code = first..rest
					GPAppCreator.Caret = pos-4
				else
					local first = string.sub(val, 0, pos-1)
					local rest = string.sub(val, pos+1, string.len(val))
					GPAppCreator.Code = first..rest
					GPAppCreator.Caret = pos-1
				end
			end
			return true
		elseif key == KEY_DELETE then
			local pos = GPAppCreator:GetSelectionPos()
			if pos[1] != pos[2] then
				GPAppCreator:SelectArea( 0, 0 )
				local val = GPAppCreator.Code
				local first = string.sub(val, 0, pos[1])
				local rest = string.sub(val, pos[2]+1, string.len(val))
				GPAppCreator.Code = first..rest
			else
				local pos = GPAppCreator:GetCaret()
				local val = GPAppCreator.Code
				if pos > string.len(val) then return true end
				local found = string.sub(val, pos, pos+3) == "    "
				if found then
					local first = string.sub(val, 0, pos-1)
					local rest = string.sub(val, pos+4, string.len(val))
					local text = first..rest
					GPAppCreator.Code = text
				else
					local first = string.sub(val, 0, pos)
					local rest = string.sub(val, pos+2, string.len(val))
					local text = first..rest
					GPAppCreator.Code = text
				end
			end
			return true
		else
			local pos = GPAppCreator:GetSelectionPos()
			if pos[1] != pos[2] then
				local val = GPAppCreator.Code
				local first = string.sub(val, 0, pos[1])
				local rest = string.sub(val, pos[2]+1, string.len(val))
				GPAppCreator.Code = first..rest
				GPAppCreator.Caret = pos[1]
				GPAppCreator:SelectArea( 0, 0 )
			end
		end
	end
	
	local Run = vgui.Create( "DButton", GPAppCreator )
	Run:SetPos( GPhone.Width + spacing*2, h-spacing-20 )
	Run:SetSize( pwidth/2, 20 )
	Run:SetText("Run App")
	Run:SetTextColor(Color(255,255,255))
	function Run:Paint()
		if self.Hovering then
			surface.SetDrawColor(255, 0, 0)
		else
			surface.SetDrawColor(200, 40, 40)
		end
		surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
	end
	function Run:OnCursorEntered()
		self.Hovering = true
	end
	function Run:OnCursorExited()
		self.Hovering = false
	end
	function Run:DoClick()
		local str = RunString( "appinit = "..GPAppCreator.Code, "App Builder", false )
		if !str and appinit then
			GPAppCreator.Frame = GPhone.CreateRootPanel()
			GPhone.DebugFunction( appinit, GPAppCreator.Frame, GPhone.Width, GPhone.Height - GPhone.Desk.Offset, GPhone.Resolution )
			GPhone.CurrentFrame = GPAppCreator.Frame
		else
			GPhone.Debug("[ERROR] in app 'AppBuilder': "..str, false, true)
		end
	end
	
	local Save = vgui.Create( "DButton", GPAppCreator )
	Save:SetPos( GPhone.Width + spacing*2 + pwidth/2, h-spacing-20 )
	Save:SetSize( pwidth/2, 20 )
	Save:SetText("Save")
	Save:SetTextColor(Color(255,255,255))
	function Save:Paint()
		if self.Hovering then
			surface.SetDrawColor(0, 0, 255)
		else
			surface.SetDrawColor(40, 40, 200)
		end
		surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
	end
	function Save:OnCursorEntered()
		self.Hovering = true
	end
	function Save:OnCursorExited()
		self.Hovering = false
	end
	function Save:DoClick()
		
	end
	
	local Panel = vgui.Create( "DPanel", GPAppCreator )
	Panel:SetSize(GPhone.Width, GPhone.Height)
	Panel:SetPos(spacing, spacing)
	function Panel:Think()
		local frame = GPhone.CurrentFrame
		if !frame then return end
		
		local mx,my = gui.MousePos()
		local px,py = self:LocalToScreen( self:GetPos() )
		local x,y = mx - px, my - py
		local rx,ry = x / GPhone.Width * 560, y / GPhone.Height * 830
		
		GPhone.CursorPos = {x = rx, y = ry}
		
		if input.IsMouseDown( MOUSE_LEFT ) and !self.b_leftdown then
			self.b_leftdown = true
		elseif !input.IsMouseDown( MOUSE_LEFT ) and self.b_leftdown then
			self.b_leftdown = false
			
			local children = {}
			local function clickChildren( pnl )
				local px,py = parentPos( pnl )
				local bx,by,bw,bh = px,py,pnl.w,pnl.h
				if x < bx or x > bx + bw or y < by or y > by + bh or !pnl.visible then return end
				table.insert(children, pnl)
				for _,child in pairs(pnl.children) do
					clickChildren( child )
				end
			end
			
			clickChildren( frame )
			
			local button = children[#children]
			if button then
				if button.OnClick then
					GPhone.DebugFunction( button.OnClick, button, false )
				end
			end
		end
	end
	function Panel:Paint()
		local frame = GPhone.CurrentFrame
		if !frame then return end
		
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial( GPhone.PhoneMT )
		surface.DrawTexturedRect(0, 0, self:GetWide(), self:GetTall())
	end
end

--[[hook.Add("PreRender", "GPhoneAppCreatorInput", function()
	if input.IsKeyDown(KEY_B) and input.IsKeyDown(KEY_LCONTROL) and !b_pressed then
		b_pressed = true
		if IsValid(GPAppCreator) then
			GPAppCreator:Close()
		else
			InitGPhoneAppCreator()
		end
	elseif !input.IsKeyDown(KEY_B) and b_pressed then
		b_pressed = nil
	end
end)]]