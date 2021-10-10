APP.Name        = "Launcher"
APP.Author      = "Krede"
APP.Launcher    = true
APP.Icon        = "asset://garrysmod/materials/gphone/apps/camera.png"
function APP.Run(frame, w, h, ratio)
    frame:SetFullScreen(true)
    
    local dotemat = Material("gphone/dot_empty")
    local dotfmat = Material("gphone/dot_full")
    
    function frame:OnScroll(num)
        if GPhone.MoveMode then
            GPhone.Page = math.max(GPhone.Page - num, 1)
        else
            GPhone.Page = math.Clamp(GPhone.Page - num, 1, #GPhone.GetAppPos())
        end
        
        self:Reload(self, w, h, ratio)
    end
    function frame:OnClick(long)
        if !GPhone.MoveMode and long then
            GPhone.MoveMode = true
        else
            GPhone.MoveMode = false
        end
    end
    
    function frame:Paint(x, y, w, h)
        hook.Run("GPhonePreRenderBackground", w, h)
        
        local mat = GPhone.BackgroundMat
        if mat and !mat:IsError() then
            local rw,rh = mat:GetFloat("$realwidth") or mat:Width(), mat:GetFloat("$realheight") or mat:Height()
            local rt = rw / rh
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial( mat )
            if GPhone.Landscape then
                local s = w / rt
                surface.DrawTexturedRect(0, h/2 - s/2, w, s)
            else
                local s = h * rt
                surface.DrawTexturedRect(w/2 - s/2, 0, s, h)
            end
        end
        
        hook.Run("GPhonePostRenderBackground", w, h)
        
        local pages = #GPhone.GetAppPos()
        if pages > 1 or GPhone.MoveMode then
            for i = 1, pages do
                surface.SetDrawColor(255, 255, 255, 255)
                if GPhone.Page == i then
                    surface.SetMaterial(dotfmat)
                else
                    surface.SetMaterial(dotemat)
                end
                surface.DrawTexturedRect(w/2 - (pages*32)/2 + i*32 - 32, h-32, 24, 24)
            end
        end
	end
    
    function frame:Reload(frame, w, h, ratio)
        frame:Clear()
        
        for k,data in pairs(GPhone.GetPage()) do
            local posx,posy,size,appid = data.x,data.y,data.size,data.app
            local app = GPhone.GetApp(appid)
            
            local but = GPnl.AddPanel( frame )
            but:SetSize(size, size)
            but:SetPos(posx, posy)
            but.AppID = appid
            function but:Paint(x, y, w, h)
                if GPhone.MoveMode then
                    if GPhone.MovingApp != self.AppID then
                        local ran = math.Rand(-3,3)
                        
                        surface.SetDrawColor(255, 255, 255, 255)
                        surface.SetMaterial(GPhone.GetImage(app.Icon))
                        surface.DrawTexturedRectRotated(w / 2, h / 2, w, h, ran)
                    end
                else
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.SetMaterial(GPhone.GetImage(app.Icon))
                    surface.DrawTexturedRect(0, 0, w, h)
                end
            end
            function but:OnClick(long)
                if long then
                    GPhone.MovingApp = self.AppID
                    GPhone.MoveMode = true
                else
                    if GPhone.MoveMode then
                        GPhone.MoveMode = false
                    else
                        local res = GPhone.FocusApp(self.AppID)
                        if !res then
                            GPhone.RunApp(self.AppID)
                        end
                    end
                end
            end
            
            if !table.HasValue(GPDefaultApps, appid) then
                local rwid = size / 3
                local xwid = rwid * 0.6
                
                local remove = GPnl.AddPanel(frame)
                remove:SetSize(rwid, rwid)
                remove:SetPos(posx - rwid / 2, posy - rwid / 2)
                remove.AppID = appid
                function remove:Paint(x, y, w, h)
                    if GPhone.MoveMode and GPhone.MovingApp != self.AppID then
                        draw.RoundedBox(w/2, 0, 0, w, h, Color(190, 190, 190))
                        
                        surface.SetDrawColor(0, 0, 0)
                        surface.SetTexture(surface.GetTextureID("gui/html/stop"))
                        surface.DrawTexturedRect(w/2 - xwid/2, h/2 - xwid/2, xwid, xwid)
                    end
                end
                function remove:OnClick()
                    if GPhone.MoveMode then
                        GPhone.UninstallApp(self.AppID)
                    end
                end
            end
            
            surface.SetFont("GPAppName"..GPhone.Rows)
            local tw,th = surface.GetTextSize(app.Name)
            
            local name = GPnl.AddPanel( frame )
            name:SetSize(tw + 2, th + 2)
            name:SetPos(posx + size / 2 - tw / 2, posy + size)
            name.AppID = appid
            name.Font = "GPAppName"..GPhone.Rows
            function name:Paint(x, y, w, h)
                if GPhone.MoveMode then
                    if GPhone.MovingApp != self.AppID then
                        local ran = math.Rand(-1,1)
                        
                        draw.SimpleText(app.Name, self.Font, ran + w/2 + 2, ran + 2, Color(0,0,0), TEXT_ALIGN_CENTER)
                        draw.SimpleText(app.Name, self.Font, ran + w/2, ran, Color(255,255,255), TEXT_ALIGN_CENTER)
                    end
                else
                    draw.SimpleText(app.Name, self.Font, w/2 + 2, 2, Color(0,0,0), TEXT_ALIGN_CENTER)
                    draw.SimpleText(app.Name, self.Font, w/2, 0, Color(255,255,255), TEXT_ALIGN_CENTER) 
                end
            end
        end
    end
    
    frame:Reload(frame, w, h, ratio)
end

function APP.Think(frame, w, h, ratio)
    if GPhone.MovingApp then
        local leftDown = GPhone.TriggerDown()
        
        if !leftDown then
            local rows = GPhone.GetRows()
            local columns = math.floor(rows * GPhone.Resolution)
            local offset = GPhone.Desk.Offset
            local cellsize = GPhone.Width / rows
            local x,y = GPhone.GetCursorPos()
            local apps = GPhone.GetData("apps", {})
            
            local page = (GPhone.Page - 1) * rows * columns
            
            x = math.floor(x / cellsize)
            y = math.floor((y - offset) / cellsize)
            
            local replaceindex = page + 1 + x + y * rows
            local appid = apps[replaceindex]
            
            local moveindex = 0
            for k,v in pairs(apps) do
                if v == GPhone.MovingApp then
                    moveindex = k
                end
            end
            
            apps[replaceindex] = GPhone.MovingApp
            apps[moveindex] = appid
            GPhone.SetData("apps", apps)
            
            GPhone.MovingApp = nil
            
            frame:Reload(frame, w, h, ratio)
        end
    end
end