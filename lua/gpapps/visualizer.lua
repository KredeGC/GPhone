APP.Name		= "Visualizer"
APP.Author		= "Krede"
APP.Negative	= true
APP.Icon		= "https://raw.githubusercontent.com/KredeGC/GPhone/master/images/music.png"
function APP.Run( frame, w, h, ratio )
	function frame:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50, 255 ) )
	end
	
	local scroll = GPnl.AddPanel( frame, "scroll" )
	scroll:SetPos( 0, 64 * ratio )
	scroll:SetSize( w, h - 64 * ratio )
	
	local space = 12 * ratio
	
	local enable = GPnl.AddPanel( scroll, "panel" )
	enable:SetSize( w, 64 * ratio )
	enable:SetPos( 0, space )
	function enable:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 60, 60, 150, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 25, 25, 100, 255 ) )
		
		draw.SimpleText("Enable Visualizer", "GPMedium", (64-36) * ratio, h/2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	
	local pad = 8 * ratio
	local size = 64 * ratio - pad*2
	local toggle = GPnl.AddPanel( enable, "toggle" )
	toggle:SetSize( size*2, size )
	toggle:SetPos( w - size*2 - pad, pad )
	toggle:SetToggle( GPhone.GetAppData("enable", false) )
	toggle:SetNegative( true )
	function toggle:OnChange( bool )
		GPhone.SetAppData("enable", bool)
	end
	
	local space = space + 64 * ratio
	
	local header = GPnl.AddPanel( frame )
	header:SetPos( 0, 0 )
	header:SetSize( w, 64 * ratio )
	function header:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 60, 60, 150, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 25, 25, 100, 255 ) )
		
		draw.SimpleText("Music Visualizer", "GPTitle", w/2, h/2, Color(230, 230, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

hook.Add("GPhonePreRenderTopbar", "GTunesVisualizer", function(w, h)
	if !GPhone.GetAppData("enable", false, "visualizer") then return end
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
			local col = HSVToColor(360 * (k/mid) + 180 * math.sin(RealTime()), 1, 1)
			surface.SetDrawColor(col.r, col.g, col.b, 255)
			surface.DrawRect(mid + (k-1), 0, frag, val)
			
			surface.SetDrawColor(col.r, col.g, col.b, 255)
			surface.DrawRect(mid - (k-1), 0, frag, val)
		end
	end
end)