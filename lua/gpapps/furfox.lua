APP.Name	= "Fur Fox"
APP.Author	= "Krede"
APP.Icon	= "asset://garrysmod/materials/gphone/apps/furfox.png"
function APP.Run( frame, w, h, ratio )
	function frame:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 220, 220, 220, 255 ) )
	end
	
	local size = 64 * ratio
	
	frame.content = GPnl.AddPanel( frame, "html" )
	frame.content:SetPos( 0, size )
	frame.content:SetSize( w, h - size * 2 )
	frame.content:Init( "https://www.google.com" )
	
	function frame:OpenURL( url )
		frame.content:OpenURL( url )
	end
	
	local header = GPnl.AddPanel( frame, "panel" )
	header:SetPos( 0, 0 )
	header:SetSize( w, size )
	function header:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
	end
	
	local extend = GPnl.AddPanel( header )
	extend:SetPos( 0, 0 )
	extend:SetSize( size, size )
	function extend:Paint( x, y, w, h )
		surface.SetDrawColor(80, 80, 80)
		surface.SetTexture( surface.GetTextureID( "gui/html/home" ) )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
	function extend:OnClick()
		local html = frame.content:GetHTML()
		if IsValid(html) then
			gui.OpenURL( html.URL )
		end
	end
	
	local refresh = GPnl.AddPanel( header )
	refresh:SetPos( w - size, 0 )
	refresh:SetSize( size, size )
	function refresh:Paint( x, y, w, h )
		surface.SetDrawColor(80, 80, 80)
		surface.SetTexture( surface.GetTextureID( "gui/html/refresh" ) )
		local ct = CurTime()
		
		if (self.Delay or 0) < ct then
			surface.DrawTexturedRect( 0, 0, w, h )
		else
			local p = (self.Delay - ct)*720
			surface.DrawTexturedRectRotated( w/2, h/2, w, h, p )
		end
	end
	function refresh:OnClick()
		self.Delay = CurTime() + 0.5
		local html = frame.content:GetHTML()
		if IsValid(html) then
			html:Refresh( true )
		end
	end
	
	local url = GPnl.AddPanel( header, "textentry" )
	url:SetPos( 6 * ratio + size, 6 * ratio )
	url:SetSize( w - size*2 - 12 * ratio, size - 12 * ratio )
	function url:Paint( x, y, w, h )
		draw.RoundedBox( 4, 0, 0, w, h, Color( 220, 220, 220, 255 ) )
		
		local text = self.b_typing and GPhone.GetInputText() or frame.content:GetTitle()
		if text then
			surface.SetFont("GPMedium")
			local size = surface.GetTextSize(text)
			
			if size > w-8 then
				draw.SimpleText(text, "GPMedium", w-4, h/2, Color(0, 0, 0), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			elseif self.b_typing then
				draw.SimpleText(text, "GPMedium", 4, h/2, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			else
				draw.SimpleText(text, "GPMedium", w/2, h/2, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
	end
	function url:OnClick()
		self.b_typing = true
		local html = frame.content:GetHTML()
		local text = IsValid(html) and html.URL or ""
		GPhone.InputText( self.Enter, self.Change, self.Cancel, text )
	end
	function url:OnEnter( link )
		frame:OpenURL( link )
	end
	
	local footer = GPnl.AddPanel( frame, "panel" )
	footer:SetPos( 0, h - 64 * ratio )
	footer:SetSize( w, 64 * ratio )
	function footer:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, 2, Color( 80, 80, 80, 255 ) )
		draw.RoundedBox( 0, 0, 2, w, h-2, Color( 255, 255, 255, 255 ) )
	end
	
	
	local left = GPnl.AddPanel( footer )
	left:SetPos( w/2 - 64 * ratio, 0 )
	left:SetSize( 64 * ratio, 64 * ratio )
	function left:Paint( x, y, w, h )
		surface.SetDrawColor(80, 80, 80)
		surface.SetTexture( surface.GetTextureID( "gui/html/back" ) )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
	function left:OnClick()
		local html = frame.content:GetHTML()
		if IsValid(html) then
			html:QueueJavascript( [[window.scrollBy(-75, 0);]] )
		end
	end
	
	local right = GPnl.AddPanel( footer )
	right:SetPos( w/2, 0 )
	right:SetSize( 64 * ratio, 64 * ratio )
	function right:Paint( x, y, w, h )
		surface.SetDrawColor(80, 80, 80)
		surface.SetTexture( surface.GetTextureID( "gui/html/forward" ) )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
	function right:OnClick()
		local html = frame.content:GetHTML()
		if IsValid(html) then
			html:QueueJavascript( [[window.scrollBy(75, 0);]] )
		end
	end
	
	
	local bkwd = GPnl.AddPanel( footer )
	bkwd:SetPos( 0, 0 )
	bkwd:SetSize( 64 * ratio, 64 * ratio )
	function bkwd:Paint( x, y, w, h )
		surface.SetDrawColor(80, 80, 80)
		surface.SetTexture( surface.GetTextureID( "gui/html/back" ) )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
	function bkwd:OnClick()
		local html = frame.content:GetHTML()
		if IsValid(html) then
			html:GoBack()
		end
	end
	
	local fwd = GPnl.AddPanel( footer )
	fwd:SetPos( w - 64 * ratio, 0 )
	fwd:SetSize( 64 * ratio, 64 * ratio )
	function fwd:Paint( x, y, w, h )
		surface.SetDrawColor(80, 80, 80)
		surface.SetTexture( surface.GetTextureID( "gui/html/forward" ) )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
	function fwd:OnClick()
		local html = frame.content:GetHTML()
		if IsValid(html) then
			html:GoForward()
		end
	end
end

function APP.Rotate( old, new )
	if old.content and new.content then
		new.content:OpenURL( old.content:GetHTML().URL )
	end
end