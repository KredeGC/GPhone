APP.Name = "AppStore"
APP.Icon = "https://raw.githubusercontent.com/KredeGC/GPhone/master/gphone/appstore.png"
function APP.Run( frame, w, h )
	function frame:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 220, 220, 220, 255 ) )
	end
	
	local scroll = GPnl.AddPanel( frame, "scroll" )
	scroll:SetPos( 0, 64 )
	scroll:SetSize( w, h-128 )
	
	local function loadapps()
		scroll:Clear()
		local count = 0
		for name,app in pairs(GP.GetApps()) do
			if GP.DefaultApps and table.HasValue(GP.DefaultApps, name) then continue end
			count = count + 1
			
			local but = GPnl.AddPanel( scroll )
			but:SetSize( w, 64 )
			but:SetPos( 0, (count-1)*64 + 6 )
			function but:Paint( x, y, w, h )
				draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
				draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
				
				surface.SetDrawColor( 255, 255, 255 )
				surface.SetMaterial( GPhone.GetImage( app.Icon ) )
				surface.DrawTexturedRect( 4, 4, h-8, h-8 )
				
				draw.SimpleText(app.Name, "GPMedium", h+4, 4, Color(70,70,70), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				draw.SimpleText(app.Author or "The Fern", "GPSmall", h+4, h-6, Color(200,200,200), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
				
				local rate = app.Rating and math.Clamp(app.Rating, 0, 1) or 1
				surface.SetDrawColor( 255*(1-rate), 255*rate, 0 )
				surface.SetTexture( surface.GetTextureID("gphone/dot_empty") )
				surface.DrawTexturedRect( w-80, h/2, 80, h/2-2 )
				surface.SetTexture( surface.GetTextureID("gphone/dot_full") )
				surface.DrawTexturedRectUV( w-80, h/2, 80*rate, h/2-2, 0, 0, rate, 1 )
				
				if !table.HasValue(GPhone.Data.apps, name) then
					local text = (app.Price and app.Price.."$") or "Install"
					draw.SimpleText(text, "GPMedium", w - 4, 0, Color(70,70,70), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
				end
			end
			function but:OnClick()
				if name != "appstore" and name != "settings" then
					if table.HasValue(GPhone.Data.apps, name) then
						GPhone.UninstallApp( name )
					else
						GPhone.InstallApp( name )
					end
				end
			end
		end
	end
	
	loadapps()
	
	local header = GPnl.AddPanel( frame )
	header:SetPos( 0, 0 )
	header:SetSize( w, 64 )
	function header:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
		
		local text = GPhone.GetInputText() or "ModStore"
		if text then
			surface.SetFont("GPTitle")
			local size = surface.GetTextSize(text)
			
			if size > w-8-128 then
				draw.SimpleText(text, "GPTitle", w-4-64, h/2, Color(0, 0, 0), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			else
				draw.SimpleText(text, "GPTitle", w/2, h/2, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
	end
	
	if GetConVar("gphone_csapp"):GetBool() then
		local add = GPnl.AddPanel( header )
		add:SetPos( w - 64, 0 )
		add:SetSize( 64, 64 )
		function add:OnClick()
			local function onEnter( value )
				GPhone.DownloadApp( value )
				timer.Simple(1, function()
					loadapps()
				end)
			end
			
			GPhone.InputText( onEnter, nil, nil )
		end
		function add:Paint( x, y, w, h )
			draw.SimpleText("+", "GPTitle", w/2, h/2, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
end