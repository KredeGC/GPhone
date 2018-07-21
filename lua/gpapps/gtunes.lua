APP.Name = "GTunes"
APP.Negative = true
APP.Icon = "https://raw.githubusercontent.com/KredeGC/GPhone/master/images/music.png"
function APP.Run( frame, w, h, ratio )
	function frame:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50, 255 ) )
	end
	
	frame.Scroll = GPnl.AddPanel( frame, "scroll" )
	frame.Scroll:SetPos( 0, 64 * ratio )
	frame.Scroll:SetSize( w, h - (64 + 140) * ratio )
	
	function frame.ResetMusic()
		frame.Scroll:Clear()
		local music = GPhone.GetData("music", {})
		for num,url in pairs(music) do
			local song = GPnl.AddPanel( frame.Scroll )
			song:SetSize( w, 42 * ratio )
			song:SetPos( 0, (num*42 - 36) * ratio )
			song.url = url
			function song:Paint( x, y, w, h )
				if GPhone.MusicURL == song.url then
					draw.RoundedBox( 0, 0, 0, w, h-2, Color( 100, 100, 200, 255 ) )
				else
					draw.RoundedBox( 0, 0, 0, w, h-2, Color( 60, 60, 150, 255 ) )
				end
				draw.RoundedBox( 0, 0, h-2, w, 2, Color( 25, 25, 100, 255 ) )
				
				if !song.url then return end
				surface.SetFont("GPMedium")
				local s = surface.GetTextSize(song.url)
				if s > w + h then
					draw.SimpleText(song.url, "GPMedium", w - h, h/2, Color(255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
				else
					draw.SimpleText(song.url, "GPMedium", 4, h/2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end
			end
			function song:OnClick( held )
				if held then
					local _,y = GPhone.RootToLocal( song, GPhone.GetCursorPos() )
					frame.b_move = song
					frame.b_rel = y
				else
					GPhone.MusicURL = song.url
				end
			end
			
			local size = 42 * ratio
			
			local delete = GPnl.AddPanel( song )
			delete:SetPos( w - size, 0 )
			delete:SetSize( size, size )
			function delete:OnClick()
				local music = GPhone.GetData("music")
				if table.HasValue(music, delete:GetParent().url) then
					table.RemoveByValue(music, delete:GetParent().url)
				end
				GPhone.SetData("music", music)
				frame.ResetMusic()
			end
			function delete:Paint( x,y,w,h )
				surface.SetDrawColor(255, 255, 255)
				surface.SetTexture( surface.GetTextureID( "gui/html/stop" ) )
				surface.DrawTexturedRect( 0, 0, w, h )
			end
		end
	end
	
	frame.ResetMusic()
	
	local footer = GPnl.AddPanel( frame )
	footer:SetPos( 0, h - 140 * ratio )
	footer:SetSize( w, 140 * ratio )
	function footer:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 2, w, h-2, Color( 45, 45, 125, 255 ) )
		draw.RoundedBox( 0, 0, 0, w, 2, Color( 25, 25, 100, 255 ) )
		
		local music = GPhone.MusicStream
		if music and music.Channel and music.Length then
			local mx,my = GPhone.GetCursorPos()
			if mx >= x and my >= y and mx <= x + w and my <= y + h then
				local p = math.Clamp((mx - 4 * ratio) / (w - 8 * ratio), 0, 1)
				local time = p * music.Length
				
				draw.SimpleText(string.FormattedTime( time, "%02i:%02i" ), "GPSmall", mx - (p*2-1) * 20 * ratio, h - 16 * ratio, Color(230, 230, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
				
				draw.SimpleText(string.FormattedTime( music.Channel:GetTime(), "%02i:%02i" ), "GPSmall", 4 * ratio, h - 16 * ratio, Color(230, 230, 230, 255*p), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
				draw.SimpleText(string.FormattedTime( music.Length, "%02i:%02i" ), "GPSmall", w - 4 * ratio, h - 16 * ratio, Color(230, 230, 230, 255*(1-p)), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
			else
				draw.SimpleText(string.FormattedTime( music.Channel:GetTime(), "%02i:%02i" ), "GPSmall", 4 * ratio, h - 16 * ratio, Color(230, 230, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
				draw.SimpleText(string.FormattedTime( music.Length, "%02i:%02i" ), "GPSmall", w - 4 * ratio, h - 16 * ratio, Color(230, 230, 230), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
			end
		end
		
		local text = GPhone.GetInputText() or music.URL or GPhone.MusicURL
		if text then
			surface.SetFont("GPMedium")
			local size = surface.GetTextSize(text)
			
			if size > w then
				draw.SimpleText(text, "GPMedium", w/2 + (size/2 - w/2 + 4 * ratio)*math.sin(RealTime()), 4, Color(230,230,230), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			else
				draw.SimpleText(text, "GPMedium", w/2, 4, Color(230,230,230), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			end
		end
	end
	
	local stop = GPnl.AddPanel( footer )
	stop:SetPos( w/2 - 96 * ratio, 46 * ratio )
	stop:SetSize( 48 * ratio, 48 * ratio )
	function stop:OnClick()
		GPhone.StopMusic()
	end
	function stop:Paint( x, y, w, h )
		if GPhone.MusicStream and GPhone.MusicStream.Channel then
			surface.SetDrawColor(255, 255, 255)
			surface.SetTexture( surface.GetTextureID( "gphone/stop" ) )
			surface.DrawTexturedRect( 0, 0, w, h )
		end
	end
	
	local start = GPnl.AddPanel( footer )
	start:SetPos( w/2 - 32 * ratio, 46 * ratio )
	start:SetSize( 48 * ratio, 48 * ratio )
	function start:OnClick()
		if GPhone.MusicStream and GPhone.MusicStream.Channel then
			GPhone.ToggleMusic()
		elseif GPhone.MusicURL then
			GPhone.StartMusic( GPhone.MusicURL )
		end
	end
	function start:Paint( x, y, w, h )
		if GPhone.MusicStream and type(GPhone.MusicStream) == "table" and GPhone.MusicStream.Playing then
			surface.SetDrawColor(255, 255, 255)
			surface.SetTexture( surface.GetTextureID( "gphone/pause" ) )
			surface.DrawTexturedRect( 0, 0, w, h )
		else
			surface.SetDrawColor(255, 255, 255)
			surface.SetTexture( surface.GetTextureID( "gphone/play" ) )
			surface.DrawTexturedRect( 0, 0, w, h )
		end
	end
	
	local timeslider = GPnl.AddPanel( footer )
	timeslider:SetPos( 4 * ratio, footer:GetHeight() - 12 * ratio )
	timeslider:SetSize( footer:GetWidth() - 8 * ratio, 8 * ratio )
	function timeslider:OnClick()
		local music = GPhone.MusicStream
		if !music or !music.Channel then return end
		local channel = music.Channel
		local x = GPhone.GetCursorPos()
		local w = timeslider:GetWidth()
		local p = (x - ratio * 4) / w
		channel:SetTime( p * music.Length )
	end
	function timeslider:Paint( x, y, w, h )
		local music = GPhone.MusicStream
		if music and music.Channel then
			local p = (music.Channel:GetTime()/music.Length)
			
			draw.RoundedBox( 0, w*p, 0, w*(1-p), h, Color( 230, 230, 230, 255 ) )
			draw.RoundedBox( 0, 0, 0, w*p, h, Color( 85, 85, 200, 255 ) )
		end
	end
	
	local header = GPnl.AddPanel( frame )
	header:SetPos( 0, 0 )
	header:SetSize( w, 64 * ratio )
	function header:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 60, 60, 150, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 25, 25, 100, 255 ) )
		
		draw.SimpleText("GTunes", "GPTitle", w/2, h/2, Color(230, 230, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	local rep = GPnl.AddPanel( header )
	rep:SetPos( 0, 0 )
	rep:SetSize( 64 * ratio, 64 * ratio )
	function rep:OnClick()
		frame.Repeat = !(frame.Repeat or false)
	end
	function rep:Paint( x, y, w, h )
		if frame.Repeat then
			surface.SetDrawColor(0, 255, 0)
		else
			surface.SetDrawColor(255, 255, 255)
		end
		surface.SetTexture( surface.GetTextureID( "gui/html/refresh" ) )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
	
	local add = GPnl.AddPanel( header )
	add:SetPos( w - 64 * ratio, 0 )
	add:SetSize( 64 * ratio, 64 * ratio )
	function add:OnClick()
		local function onEnter( val )
			GPhone.MusicURL = val
			local music = GPhone.GetData("music") or {}
			if !table.HasValue(music, val) then
				table.insert(music, val)
				GPhone.SetData("music", music)
			end
			frame.ResetMusic()
			GPhone.StartMusic( GPhone.MusicURL )
		end
		GPhone.InputText( onEnter )
	end
	function add:Paint( x, y, w, h )
		draw.SimpleText("+", "GPTitle", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

function APP.Think( frame, w, h, ratio )
	local music = GPhone.GetMusic()
	if frame.Repeat and music then
		local channel = music.Channel
		if channel:GetTime() >= music.Length then
			channel:Play()
		end
	end
	
	if frame.b_move then
		local _,my = GPhone.RootToLocal( frame.b_move, GPhone.GetCursorPos() )
		local _,cy = frame.b_move:GetPos()
		local y = math.Clamp(my + cy - (frame.b_rel or 0), 0, frame.b_move:GetParent():GetHeight() - frame.b_move:GetHeight())
		frame.b_move:SetPos( 0, y )
		
		if !input.IsMouseDown( MOUSE_LEFT ) then
			local music	= GPhone.GetData("music", {})
			local pos	= 0
			local last	= 1
			local children = frame.Scroll:GetChildren()
			for k,v in pairs(children) do
				if v == frame.b_move then pos = k end
				local _,py = v:GetPos()
				if y > py then
					last = k
				end
			end
			
			if pos > 0 and pos != last then
				local song = music[pos]
				table.remove(music, pos)
				table.insert(music, last, song)
				GPhone.SetData("music", music)
			end
			
			frame.ResetMusic()
			
			frame.b_move = nil
			frame.b_rel = nil
		end
	end
end

hook.Add("GPhonePreRenderTopbar", "GTunesVisualizer", function(w, h)
	local music = GPhone.GetMusic()
	if music then
		local fft = {}
		local mid = math.Round(w / 2)
		local frag = 2
		
		music.Channel:FFT( fft, FFT_256 )
		
		for k = 1, mid, frag do
			local v = fft[math.ceil((k/mid) * #fft)]
			if !v then continue end
			local val = math.Clamp(math.Round(v * h ^ 2), 0, h)
			if val == 0 then continue end
			local col = HSVToColor(360 * (k/mid), 1, 1)
			surface.SetDrawColor(col.r, col.g, col.b, 255)
			surface.DrawRect(mid + (k-1), 0, frag, val)
			
			surface.SetDrawColor(col.r, col.g, col.b, 255)
			surface.DrawRect(mid - (k-1), 0, frag, val)
		end
	end
end)