APP.Name	= "AppBuilder"
APP.Author	= "Krede"
APP.Icon	= "https://raw.githubusercontent.com/KredeGC/GPhone/master/images/steam.png"
function APP.Run( frame, w, h, ratio )
	function frame:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(220, 220, 220, 255) )
	end
	
	
	local fontsize = 36 * ratio
	local pad = 8 * ratio
	local size = w/2 - pad * 1.5
	
	local builds = frame:AddTab( "builds", "panel" )
	
	local scroll = GPnl.AddPanel( builds, "scroll" )
	scroll:SetPos( 0, 64 * ratio )
	scroll:SetSize( w, h - 64 * ratio )
	
	function builds:Refresh()
		scroll:Clear()
		local space = 12 * ratio
		local apps = file.Find("gphone/builds/*", "DATA")
		if #apps <= 0 then
			local info = GPnl.AddPanel( scroll )
			info:SetSize( w, 128 * ratio )
			info:SetPos( 0, space )
			function info:Paint( x, y, w, h )
				draw.SimpleText("No Apps could be found", "GPMedium", w/2, 0, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
				draw.SimpleText("Place all apps you want to", "GPMedium", w/2, h/2, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText("upload inside 'gphone/builds/'", "GPMedium", w/2, h, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
			end
		end
		for _,name in pairs(apps) do
			local but = GPnl.AddPanel( scroll )
			but:SetSize( w, 48 * ratio )
			but:SetPos( 0, space )
			but.Name = name
			but.Size = file.Size( "gphone/builds/"..name, "DATA" )
			function but:Paint( x, y, w, h )
				draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
				draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
				
				draw.SimpleText(math.Round(self.Size/1024, 3).." kb", "GPSmall", w - pad, h/2, Color(70, 70, 70), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
				
				draw.SimpleText(self.Name, "GPMedium", pad, h/2, Color(70, 70, 70), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
			function but:OnClick()
				local pnl = frame:GetTab( "editor" )
				pnl:Open( self.Name, file.Read("gphone/builds/"..name, "DATA") )
				frame:OpenTab( "editor", 0.25, "in-right", "out-left" )
			end
			
			space = space + 48 * ratio
		end
	end
	
	
	local header = GPnl.AddPanel( builds )
	header:SetPos( 0, 0 )
	header:SetSize( w, 64 * ratio )
	function header:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText("App Uploader", "GPTitle", w/2, h/2, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	builds:Refresh()
	frame:OpenTab( "builds" )
	
	
	
	local editor = frame:AddTab( "editor", "panel" )
	
	local code = GPnl.AddPanel( editor, "scroll" )
	code:SetPos( 0, 64 * ratio )
	code:SetSize( w, h - 128 * ratio )
	
	local header = GPnl.AddPanel( editor )
	header:SetPos( 0, 0 )
	header:SetSize( w, 64 * ratio )
	function header:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		draw.SimpleText(self.Title or "unnamed.txt", "GPTitle", w/2, h/2, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	function editor:Open( name, text )
		code:Clear()
		header.Title = name
		self.Name = name
		self.Code = text
		for i,t in pairs(string.Explode("\n", text or "")) do
			local line = GPnl.AddPanel( code )
			line:SetSize( w, fontsize )
			line:SetPos( 0, (i - 1) * fontsize )
			line.Text = t
			function line:Paint( x, y, w, h )
				draw.SimpleText(self.Text, "GPMedium", 0, h/2, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
		end
	end
	
	local back = GPnl.AddPanel( header )
	back:SetPos( 0, 0 )
	back:SetSize( 64 * ratio, 64 * ratio )
	function back:OnClick()
		local pnl = frame:GetTab( "builds" )
		pnl:Refresh()
		frame:OpenTab( "builds", 0.25, "in-left", "out-right" )
	end
	function back:Paint( x, y, w, h )
		draw.SimpleText("<", "GPTitle", w/2, h/2, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	local footer = GPnl.AddPanel( editor )
	footer:SetPos( 0, h - 64 * ratio )
	footer:SetSize( w, 64 * ratio )
	function footer:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, 2, Color( 80, 80, 80, 255 ) )
		draw.RoundedBox( 0, 0, 2, w, h-2, Color( 255, 255, 255, 255 ) )
	end
	
	
	local run = GPnl.AddPanel( footer )
	run:SetPos( pad, pad )
	run:SetSize( size, 64 * ratio - pad * 2 )
	function run:Paint( x, y, w, h )
		draw.RoundedBox( 8, 0, 0, w, h, Color( 255, 0, 0, 255 ) )
		draw.SimpleText("Run", "GPMedium", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	function run:OnClick()
		local str = RunString( "APP = {}\n"..editor.Code, "Workshop", false )
		if !str then
			editor.Frame = GPhone.CreateRootPanel()
			GPhone.DebugFunction( APP.Run, editor.Frame, GPhone.Width, GPhone.Height - GPhone.Desk.Offset, GPhone.Resolution )
			GPhone.CurrentFrame = editor.Frame
		else
			GPhone.Debug("[ERROR] in app '"..editor.Name.."': "..str, false, true)
		end
		APP = nil
	end
	
	local publish = GPnl.AddPanel( footer )
	publish:SetPos( w - size - pad, pad )
	publish:SetSize( size, 64 * ratio - pad * 2 )
	function publish:Paint( x, y, w, h )
		draw.RoundedBox( 8, 0, 0, w, h, Color( 0, 255, 0, 255 ) )
		draw.SimpleText("Publish", "GPMedium", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	function publish:OnClick()
		if editor.Code == "" then return end
		local f = vgui.Create( "DFrame" )
		f:SetSize(ScrW() * 0.7, ScrH() * 0.7)
		f:SetTitle("Please log in using your Steam account and press Upload App")
		f:SetDraggable( false )
		f:ShowCloseButton( true )
		f:SetSizable( false )
		f:MakePopup()
		f:Center()
		
		local html = vgui.Create("DHTML", f)
		html:Dock(FILL)
		html:OpenURL( "http://gphone.icu/appcreator" )
		function html:Think()
			if self:IsLoading() then
				if !self.b_loading then
					local text = string.gsub(editor.Code, "\\", "\\\\")
					local text = string.gsub(text, "\r\n", "\\r\\n")
					local text = string.gsub(text, "\"", "\\\"")
					self.b_loading = true
					self:RunJavascript([[var content = document.getElementsByName("content")[0];
					if (content) {
						content.value = "]]..text..[[";
						
						var but = document.getElementById("submit");
						if (but) {
							but.click();
						}
					}]])
				end
			else
				if self.b_loading then
					local text = string.gsub(editor.Code, "\\", "\\\\")
					local text = string.gsub(text, "\r\n", "\\r\\n")
					local text = string.gsub(text, "\"", "\\\"")
					self.b_loading = false
					self:RunJavascript([[var content = document.getElementsByName("content")[0];
					if (content) {
						content.value = "]]..text..[[";
						
						var but = document.getElementById("submit");
						if (but) {
							but.click();
						}
					}]])
				end
			end
		end
	end
end