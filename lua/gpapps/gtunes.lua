APP.Name = "GTunes"
APP.Negative = true
APP.Icon = "https://raw.githubusercontent.com/KredeGC/GPhone/master/gphone/music.png"
function APP.Run( frame, w, h )
	function frame:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50, 255 ) )
	end
	
	local scroll = GPnl.AddPanel( frame, "scroll" )
	scroll:SetPos( 0, 64 )
	scroll:SetSize( w, h-64-128 )
	
	local function resetMusic()
		scroll:Clear()
		local music = GPhone.GetData("music")
		if !music then return end
		for num,url in pairs(music) do
			local song = GPnl.AddPanel( scroll )
			song:SetSize( w, 40 )
			song:SetPos( 0, num*40 - 34 )
			song.url = url
			function song:Paint( x, y, w, h )
				draw.RoundedBox( 0, 0, 0, w, h-2, Color( 60, 60, 150, 255 ) )
				draw.RoundedBox( 0, 0, h-2, w, 2, Color( 25, 25, 100, 255 ) )
				
				surface.SetFont("GPMedium")
				local s = surface.GetTextSize(song.url)
				if s > w-40 then
					draw.SimpleText(song.url or "Unknown", "GPMedium", w-40, h/2, Color(255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
				else
					draw.SimpleText(song.url or "Unknown", "GPMedium", 4, h/2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end
			end
			function song:OnClick()
				GPhone.MusicURL = song.url
			end
			
			local delete = GPnl.AddPanel( song )
			delete:SetPos( w - 40, 0 )
			delete:SetSize( 40, 40 )
			function delete:OnClick()
				local music = GPhone.GetData("music")
				if table.HasValue(music, delete:GetParent().url) then
					table.RemoveByValue(music, delete:GetParent().url)
				end
				GPhone.SaveData("music", music)
				resetMusic()
			end
			function delete:Paint( x,y,w,h )
				surface.SetDrawColor(255, 255, 255)
				surface.SetTexture( surface.GetTextureID( "gui/html/stop" ) )
				surface.DrawTexturedRect( 0, 0, w, h )
			end
		end
	end
	
	resetMusic()
	
	local footer = GPnl.AddPanel( frame )
	footer:SetPos( 0, h-120 )
	footer:SetSize( w, 120 )
	function footer:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 2, w, h-2, Color( 45, 45, 125, 255 ) )
		draw.RoundedBox( 0, 0, 0, w, 2, Color( 25, 25, 100, 255 ) )
		
		local text = GPhone.GetInputText() or GPhone.MusicStream.URL or GPhone.MusicURL
		if text then
			surface.SetFont("GPMedium")
			local size = surface.GetTextSize(text)
			
			if size > w then
				draw.SimpleText(text, "GPMedium", w/2 + (size/2-w/2)*math.sin(RealTime()), 4, Color(230,230,230), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			else
				draw.SimpleText(text, "GPMedium", w/2, 4, Color(230,230,230), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			end
		end
	end
	
	local stop = GPnl.AddPanel( footer )
	stop:SetPos( w/2 - 96, 46 )
	stop:SetSize( 48, 48 )
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
	start:SetPos( w/2 - 32, 46 )
	start:SetSize( 48, 48 )
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
	timeslider:SetPos( 4, footer:GetHeight()-12 )
	timeslider:SetSize( footer:GetWidth()-8, 8 )
	function timeslider:OnClick()
		if !GPhone.MusicStream or !GPhone.MusicStream.Channel then return end
		local channel = GPhone.MusicStream.Channel
		local x = CurrentMousePos.x
		local w = timeslider:GetWidth()
		local p = x/w
		channel:SetTime( p * GPhone.MusicStream.Length )
	end
	function timeslider:Paint( x, y, w, h )
		if GPhone.MusicStream and GPhone.MusicStream.Channel then
			local p = (GPhone.MusicStream.Channel:GetTime()/GPhone.MusicStream.Length)
			
			draw.RoundedBox( 0, w*p, 0, w*(1-p), h, Color( 230, 230, 230, 255 ) )
			draw.RoundedBox( 0, 0, 0, w*p, h, Color( 85, 85, 200, 255 ) )
		end
	end
	
	local header = GPnl.AddPanel( frame )
	header:SetPos( 0, 0 )
	header:SetSize( w, 64 )
	function header:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 60, 60, 150, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 25, 25, 100, 255 ) )
		
		draw.SimpleText("GTunes", "GPTitle", w/2, h/2, Color(230, 230, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	local add = GPnl.AddPanel( header )
	add:SetPos( w - 64, 0 )
	add:SetSize( 64, 64 )
	function add:OnClick()
		local function onEnter( val )
			GPhone.MusicURL = val
			local music = GPhone.GetData("music")
			if music and !table.HasValue(music, val) then
				table.insert(music, val)
				GPhone.SaveData("music", music)
			elseif !music then
				GPhone.SaveData("music", {val})
			end
			resetMusic()
			GPhone.StartMusic( GPhone.MusicURL )
		end
		GPhone.InputText( onEnter )
	end
	function add:Paint( x, y, w, h )
		draw.SimpleText("+", "GPTitle", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end