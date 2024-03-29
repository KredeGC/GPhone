APP.Name	= "StormFox"
APP.Author	= "Krede"
APP.Icon	= "asset://garrysmod/materials/gphone/apps/stormfox.png"
function APP.Run( frame, w, h, ratio )
	function frame:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 220, 220, 220, 255 ) )
	end
	
	if !StormFox && !StormFox2 then
		local header = GPnl.AddPanel( frame )
		header:SetPos( 0, 0 )
		header:SetSize( w, 64 * ratio )
		function header:Paint( x, y, w, h )
			draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
			draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
			
			draw.SimpleText("StormFox not found", "GPTitle", w/2, h/2, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		
		local install = GPnl.AddPanel( frame )
		install:SetPos( 32 * ratio, h/2 - 64 * ratio )
		install:SetSize( w - 64 * ratio, 128 * ratio )
		function install:Paint( x, y, w, h )
			draw.RoundedBox( 8, 0, 0, w, h, Color( 150, 150, 150, 255 ) )
			draw.SimpleText("Get StormFox", "GPTitle", w/2, h/2, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		function install:OnClick()
			gui.OpenURL( "http://steamcommunity.com/sharedfiles/filedetails/?id=1132466603" )
		end
	else
		local scroll = GPnl.AddPanel( frame, "scroll" )
		scroll:SetPos( 0, 64 * ratio )
		scroll:SetSize( w, h - 64 * ratio )
		scroll:SetScrollSpeed( 48 )
        
        local function loadWeather()
            scroll:Clear()
            local weather = StormFox.GetNetworkData("WeekWeather", {})
            local size = 128 * ratio
            
            for k = 1, 7 do
                local data = weather[k]
                if !data then continue end
                local pnl = GPnl.AddPanel( scroll )
                pnl:SetPos( 0, 6 * ratio + (k-1)*size )
                pnl:SetSize( w, size )
                pnl.name = StormFox.GetWeatherType(data.name):GetName()
                pnl.mat = StormFox.GetWeatherType(data.name):GetIcon()
                if GPhone.GetData("imperial", false) then
                    if StormFox2 then
                        pnl.temp = "Temp: "..StormFox2.Temperature.Get(sType = "fahrenheit").."°F"
                    else
                        pnl.temp = "Temp: "..math.Round(StormFox.CelsiusToFahrenheit(data.temp), 1).."°F"
                    end
                else
                    if StormFox2 then
                        pnl.temp = "Temp: "..StormFox2.Temperature.Get(sType = "celsius").."°C"
                    else
                        pnl.temp = "Temp: "..math.Round(data.temp, 1).."°C"
                    end
                end
                pnl.wind = "Wind: "..data.wind.." u/s"
                function pnl:Paint( x, y, w, h )
                    draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
                    draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
                    
                    draw.SimpleText(self.name, "GPTitle", w/2, 54/2, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText(self.temp, "GPMedium", w-8, 54/2, Color(70, 70, 70), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                    draw.SimpleText(self.wind, "GPMedium", w-8, h/2, Color(70, 70, 70), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                    
                    surface.SetDrawColor( 70, 70, 70 )
                    surface.SetMaterial( self.mat )
                    surface.DrawTexturedRect( 8, 8, h-16, h-16 )
                end
            end
        end
        
        loadWeather()
		
		local header = GPnl.AddPanel( frame )
		header:SetPos( 0, 0 )
		header:SetSize( w, 64 * ratio )
		function header:Paint( x, y, w, h )
			draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
			draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
			
			draw.SimpleText("Weather Forecast", "GPTitle", w/2, h/2, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	
        local refresh = GPnl.AddPanel( header )
        refresh:SetPos( w - 64 * ratio, 0 )
        refresh:SetSize( 64 * ratio, 64 * ratio )
        function refresh:Paint( x, y, w, h )
            surface.SetDrawColor(50, 50, 50)
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
            loadWeather()
        end
	end
end