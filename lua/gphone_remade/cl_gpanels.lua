GPnl = {}


local function parentPos( frame )
    if frame then
        local px,py = parentPos( frame.parent )
        local x,y = frame.x,frame.y
        return x + px,y + py
    else
        return 0,0
    end
end

local function removeChildren( pnl )
    if pnl.OnRemove then
        pnl:OnRemove()
    end
    for _,child in pairs(pnl.children) do
        removeChildren( child )
    end
end


local gframe = {}

function gframe:new( parent, kind )
    local frame = {
        x = 0,
        y = 0,
        w = 32,
        h = 32,
        parent = parent,
        children = {},
        type = kind or "panel",
        visible = true
    }
    
    function frame:SetVisible( bool )
        self.visible = bool
        return self
    end
    function frame:GetVisible()
        return self.visible
    end
    
    function frame:SetType( str )
        self.type = str
        return self
    end
    function frame:GetType()
        return self.type
    end
    
    function frame:SetPos( x, y )
        self.x = x
        self.y = y
        return self
    end
    function frame:SetWidth( w )
        self.w = w
        return self
    end
    function frame:SetHeight( h )
        self.h = h
        return self
    end
    function frame:SetSize( w, h )
        self.w = w
        self.h = h
        return self
    end
    
    function frame:GetWidth()
        return self.w
    end
    function frame:GetHeight()
        return self.h
    end
    function frame:GetSize()
        return self.w,self.h
    end
    function frame:GetPos()
        return self.x,self.y
    end
    
    function frame:SetParent( parent ) -- Technically you could have an infinite loop if you are not careful
        if self.parent then
            local children = self.parent.children
            if table.HasValue(children, self) then
                table.RemoveByValue(children, self)
            end
        end
        self.parent = parent
        if !table.HasValue(parent.children, self) then
            table.insert(parent.children, self)
        end
        return true
    end
    
    function frame:GetParent()
        return self.parent
    end
    function frame:GetChildren()
        return self.children
    end
    
    function frame:Clear()
        for _,child in pairs(self.children) do
            removeChildren( child )
        end
        self.children = {}
        return self
    end
    function frame:Remove()
        removeChildren( self )
        if self.parent then
            local children = self.parent.children
            if table.HasValue(children, self) then
                table.RemoveByValue(children, self)
            end
        end
        return self
    end
    
    function frame:Paint()
    end
    
    function frame:Hover()
    end
    function frame:StopHover()
    end
    
    if parent and parent.children then
        table.insert(parent.children, frame)
    end
    
    local def = GPnl.GetTypes()[kind]
    if def and type(def) == "function" then
        def( frame )
    end
    
    setmetatable( frame, self )
    
    return frame
end

function gframe:__tostring()
    return "GPnl["..math.Round(self.x, 2)..","..math.Round(self.y, 2)..","..math.Round(self.w, 2)..","..math.Round(self.h, 2).."]["..self.type.."]"
end

function gframe:__add( frame )
    if type(frame) == "table" and getmetatable(frame) then
        frame:SetParent( self )
    end
    
    return self
end

gframe.__index = gframe
setmetatable( gframe, { __call = gframe.new } )


local paneltypes = {
    ["panel"] = true,
    ["frame"] = function(frame)
        frame.b_tabs = {}
        frame.b_tab = nil
        
        function frame:AddTab( name, kind )
            if type(kind) == "table" and getmetatable(kind) then
                kind:SetVisible( false )
                self.b_tabs[name] = kind
                return kind
            elseif type(kind) == "string" then
                local pnl = GPnl.AddPanel( self, kind )
                pnl:SetPos( 0, 0 )
                pnl:SetSize( self:GetSize() )
                pnl:SetVisible( false )
                self.b_tabs[name] = pnl
                return pnl
            end
            return false
        end
        
        function frame:RemoveTab( name )
            local pnl = self.b_tabs[name]
            if pnl then
                if self.b_tab == pnl then
                    self.b_tab = nil
                end
                pnl:Remove()
                self.b_tabs[name] = nil
            end
            return self
        end
        
        function frame:GetTabs()
            return self.b_tabs
        end
        
        function frame:GetTab( name )
            return self.b_tabs[name] or false
        end
        
        function frame:GetOpenTab()
            return self.b_tab
        end
        
        function frame:OpenTab( name, time, newanim, oldanim )
            local pnl = self.b_tabs[name]
            if !pnl or self.b_tab == pnl then return false end
            
            if self.b_tab then
                if time and oldanim then
                    GPnl.DoAnimation( self.b_tab, time, oldanim, function(pnl)
                        pnl:SetPos( 0, 0 )
                        pnl:SetVisible( false )
                    end)
                else
                    self.b_tab:SetVisible( false )
                end
            end
            
            pnl:SetVisible( true )
            if time and newanim then
                GPnl.DoAnimation( pnl, time, newanim, function(pnl)
                    pnl:SetPos( 0, 0 )
                end)
            end
            self.b_tab = pnl
            return true
        end
    end,
    ["toggle"] = function(frame)
        frame.b_padding = 4 * GPhone.Resolution
        function frame:Paint( x, y, w, h )
            local bgcol = self.b_negative and Color(80, 80, 80) or Color(200, 200, 200)
            local btcol = self.b_negative and Color(80, 80, 80) or Color(255, 255, 255)
            local atcol = self.b_toggled and Color(0, 255, 0) or self.b_negative and Color(150, 150, 150) or Color(220, 220, 220)
            
            draw.RoundedBox(h/2, 0, 0, w, h, bgcol )
            draw.RoundedBox(h/2, self.b_padding/2, self.b_padding/2, w - self.b_padding, h - self.b_padding, atcol )
            draw.RoundedBox(h/2, self.b_padding + (w - h) * (self.b_toggled and 1 or 0), self.b_padding, h - self.b_padding*2, h - self.b_padding*2, btcol )
        end
        
        function frame:SetToggle( bool )
            self.b_toggled = bool
            return self
        end
        function frame:GetToggle()
            return self.b_toggled or false
        end
        
        function frame:SetNegative( bool )
            self.b_negative = bool
            return self
        end
        function frame:GetNegative()
            return self.b_negative or false
        end
        
        function frame:OnClick()
            local bool = !self.b_toggled
            self.b_toggled = bool
            if self.OnChange then
                self:OnChange( bool )
            end
        end
    end,
    ["scroll"] = function(frame)
        function frame:SetScrollSpeed( num )
            self.i_speed = num
            return self
        end
        function frame:GetScrollSpeed()
            return (self.i_speed or 30) * GPhone.Resolution
        end
        
        function frame:OnScroll( num )
            local height = self:GetHeight()
            local min = height
            local max = 0
            for _,c in pairs(frame.children) do
                min = math.min(min, c.y)
                max = math.max(max, c.y + c.h)
            end
            if num < 0 and max <= height then return end
            if num > 0 and min >= 0 then return end
            for k,c in pairs(frame.children) do
                c.y = c.y + num * self:GetScrollSpeed()
            end
        end
    end,
    ["textentry"] = function(frame)
        frame.b_forecolor = Color(0, 0, 0)
        frame.b_backcolor = Color(220, 220, 220)
        frame.b_selccolor = Color(0, 50, 100, 100)
        frame.b_alignmenth = TEXT_ALIGN_LEFT
        frame.b_alignmentv = TEXT_ALIGN_CENTER
        
        function frame:SetText( val )
            self.b_text = val
            return self
        end
        function frame:GetText()
            return self.b_text or ""
        end
        function frame:SetFont( font )
            self.f_font = font
            return self
        end
        function frame:GetFont()
            return self.f_font or "GPMedium"
        end
        
        function frame:SetAlignment( hor, ver )
            frame.b_alignmenth = hor
            frame.b_alignmentv = ver
            return self
        end
        function frame:GetAlignment()
            return frame.b_alignmenth,frame.b_alignmentv
        end
        
        function frame:SetForeColor( color )
            self.b_forecolor = color
            return self
        end
        function frame:GetForeColor()
            return self.b_forecolor
        end
        function frame:SetBackColor( color )
            self.b_backcolor = color
            return self
        end
        function frame:GetBackColor()
            return self.b_backcolor
        end
        function frame:SetSelectionColor( color )
            self.b_selccolor = color
            return self
        end
        function frame:GetSelectionColor()
            return self.b_selccolor
        end
        
        function frame.Cancel()
            frame.b_typing = false
            frame:OnCancel()
        end
        function frame.Enter( value )
            frame.b_typing = false
            frame:OnEnter( value )
        end
        function frame.Change( value )
            frame:OnChange( value )
        end
        
        function frame:OnCancel()
        end
        function frame:OnEnter()
        end
        function frame:OnChange()
        end
        
        function frame:OnClick()
            self.b_typing = true
            GPhone.InputText( self.Enter, self.Change, self.Cancel, self:GetText() )
        end
        
        function frame:RenderText( x, y, w, h, text, hidecaret )
            if self.b_backcolor.a > 0 then
                draw.RoundedBox( 0, 0, 0, w, h, self.b_backcolor )
            end
            
            surface.SetFont(self:GetFont())
            local start,stop = GPhone.GetSelectedRange()
            local caretindex = GPhone.GetCaretPos()
            
            local sizew,sizeh = surface.GetTextSize(text)
            local sw = surface.GetTextSize(string.sub(text, start + 1, stop))
            local tw = surface.GetTextSize(string.sub(text, 0, caretindex))
            
            local sx = 0
            local cx,cy = 0,0
            local tx,ty = 0,0
            
            if self.b_alignmenth == TEXT_ALIGN_LEFT then
                if tw > w / 2 then
                    if stop > caretindex then
                        sx = w / 2 - 4
                    else
                        sx = w / 2 - sw
                    end
                    cx = w / 2 - 4
                    tx = w / 2 - 4 - tw
                else
                    if stop > caretindex then
                        sx = tw
                    else
                        sx = tw - sw
                    end
                    cx = tw
                    tx = 4
                end
            elseif self.b_alignmenth == TEXT_ALIGN_RIGHT then
                if !self.b_typing or sizew - tw < w / 2 then
                    if stop > caretindex then
                        sx = w - sizew + tw - 4
                    else
                        sx = w - sizew + tw - 4 - sw
                    end
                    cx = w - sizew + tw - 4
                    tx = w - 4
                else
                    if stop > caretindex then
                        sx = w / 2 - 4
                    else
                        sx = w / 2 - 4 - sw
                    end
                    cx = w / 2 - 4
                    tx = w / 2 + sizew - 4 - tw
                end
            else
                if self.b_typing then
                    if stop > caretindex then
                        sx = w / 2
                    else
                        sx = w / 2 - sw
                    end
                    tx = sizew / 2 + w / 2 - tw
                    cx = w / 2
                else
                    tx = w / 2
                end
            end
            
            if self.b_alignmentv == TEXT_ALIGN_TOP then
                cy = 4
                ty = 4
            elseif self.b_alignmentv == TEXT_ALIGN_BOTTOM then
                cy = h - 4 - sizeh
                ty = h - 4
            else
                cy = h / 2 - sizeh / 2
                ty = h / 2
            end
            
            draw.SimpleText(text, self:GetFont(), tx, ty, self.b_forecolor, frame.b_alignmenth, frame.b_alignmentv)
            
            if !hidecaret and self.b_typing then
                draw.RoundedBox( 0, sx, cy, sw, sizeh, self.b_selccolor )
                
                draw.RoundedBox( 0, cx, cy, math.ceil(2 * GPhone.Resolution), sizeh, self.b_forecolor )
            end
        end
        
        function frame:Paint( x, y, w, h )
            local text = self.b_typing and GPhone.GetInputText() or self:GetText()
            self:RenderText( x, y, w, h, text )
        end
    end,
    ["html"] = function(frame)
        function frame:Init( url ) -- Call this after setting the size
            if IsValid(self.d_html) then
                GPhone.CloseHTMLPanel( self.d_html )
            end
            local w,h = self:GetSize()
            self.d_html = GPhone.CreateHTMLPanel( w, h, url )
            return self
        end
        
        function frame:GetHTML()
            return self.d_html
        end
        
        function frame:GetTitle()
            return IsValid(self.d_html) and self.d_html.Title or false
        end
        
        function frame:OnRemove()
            GPhone.CloseHTMLPanel( self:GetHTML() )
        end
        
        function frame:Paint( x, y, w, h )
            surface.SetDrawColor( 255, 255, 255 )
            surface.SetMaterial( GPhone.GetHTMLMaterial( self:GetHTML() ) )
            surface.DrawTexturedRect( 0, 0, w, h )
        end
        
        function frame:OpenURL( url )
            self.d_html:OpenURL( url )
            return self
        end
        
        function frame:OnClick()
            local mx,my = GPhone.GetCursorPos()
            local x,y = GPhone.GetHTMLPos( self, self:GetHTML(), mx, my )
            
            GPhone.PerformHTMLClick( self:GetHTML(), x, y )
        end
        
        function frame:OnScroll( num )
            local val = -num * 75 * GPhone.Resolution
            self.d_html:RunJavascript( [[window.scrollBy(0, ]]..val..[[);]] )
        end
    end,
    ["video"] = function(frame)
        function frame:Open( path )
            local ext = string.GetExtensionFromFilename(path)
            if ext != "mp4" and ext != "webm" then return false end -- Only .mp4 and .webm supported
            if !file.Exists(path, "GAME") then return false end
            local r = file.Read(path, "GAME")
            local data = util.Base64Encode( r ) -- This is very intense, but I don't see any other way
            
            if IsValid(self.d_html) then
                GPhone.CloseHTMLPanel( self.d_html )
            end
            local w,h = self:GetSize()
            self.d_html = GPhone.CreateHTMLPanel( w, h )
            
            self.d_html:SetHTML([[<!doctype html>
            <html>
            <body style="overflow:hidden">
            
            <video id="player" width="100%" height="100%" loop autoplay>
                <source src="data:video/]]..ext..[[;base64,]]..data..[[" type="video/]]..ext..[[">
                Your browser does not support the video tag.
            </video>
            
            <script type="text/javascript">
                var vid = document.getElementById("player");
            </script>
            
            </body>
            </html>]])
            
            return true
        end
        
        function frame:GetHTML()
            return self.d_html
        end
        
        function frame:OnRemove()
            GPhone.CloseHTMLPanel( self:GetHTML() )
        end
        
        function frame:Paint( x, y, w, h )
            surface.SetDrawColor( 255, 255, 255 )
            surface.SetMaterial( GPhone.GetHTMLMaterial( self:GetHTML() ) )
            surface.DrawTexturedRect( 0, 0, w, h )
        end
        
        function frame:OnClick() -- TODO: Pause and play when clicked
            
        end
    end
}

local panelanims = {
    ["in-right"] = function(frame, delta, x, y)
        frame:SetPos( x + frame:GetWidth() * (1-delta), y )
    end,
    ["in-left"] = function(frame, delta, x, y)
        frame:SetPos( x + frame:GetWidth() * (delta-1), y )
    end,
    ["in-bottom"] = function(frame, delta, x, y)
        frame:SetPos( x, y + frame:GetHeight() * (1-delta) )
    end,
    ["in-top"] = function(frame, delta, x, y)
        frame:SetPos( x, y + frame:GetHeight() * (delta-1) )
    end,
    ["out-right"] = function(frame, delta, x, y)
        frame:SetPos( x + frame:GetWidth() * delta, y )
    end,
    ["out-left"] = function(frame, delta, x, y)
        frame:SetPos( x - frame:GetWidth() * delta, y )
    end,
    ["out-bottom"] = function(frame, delta, x, y)
        frame:SetPos( x, y + frame:GetHeight() * delta )
    end,
    ["out-top"] = function(frame, delta, x, y)
        frame:SetPos( x, y - frame:GetHeight() * delta )
    end
}


function GPnl.GetTypes()
    return paneltypes
end

function GPnl.GetAnims()
    return panelanims
end


function GPnl.AddType(name, func)
    paneltypes[name] = func
end

function GPnl.AddAnimation(name, func)
    panelanims[name] = func
end


function GPnl.AddPanel( parent, kind )
    local frame = gframe( parent, kind )
    return frame
end

function GPnl.DoAnimation( frame, time, func, stop )
    if panelanims[func] then
        func = panelanims[func]
    elseif type(func) != "function" then
        return false
    end
    
    local x,y = frame:GetPos()
    
    GPhone.DebugFunction( func, frame, 0, x, y )
    
    frame.f_anim = {
        start = CurTime(),
        pos = {x = x, y = y},
        max = time,
        func = func,
        stop = stop
    }
    return true
end


hook.Add("PlayerBindPress", "_PlayerScrollGPanel", function(ply, bind, pressed)
    local wep = ply:GetActiveWeapon()
    if IsValid(wep) and wep:GetClass() == "gmod_gphone" and GPhone.CursorEnabled and pressed then
        if bind == "invprev" or bind == "invnext" then
            local frame = GPhone.CurrentFrame
            local num = (bind == "invprev" and 1 or -1)
            if GPhone.AppScreen and GPhone.AppScreen.Enabled then
                local max = table.Count(GPhone.Panels) - 1
                GPhone.AppScreen.Scroll = math.Clamp(GPhone.AppScreen.Scroll + num, -max, 0)
                return true
            elseif frame and frame.visible then
                local x,y = GPhone.GetCursorPos()
                
                local children = {}
                local function scrollChildren( pnl )
                    local px,py = parentPos( pnl )
                    local bx,by,bw,bh = px,py,pnl.w,pnl.h
                    if x < bx or x > bx + bw or y < by or y > by + bh or !pnl.visible then return end
                    table.insert(children, pnl)
                    for _,child in pairs(pnl.children) do
                        scrollChildren( child )
                    end
                end
                
                scrollChildren( frame )
                
                local function scrollParent( pnl )
                    if pnl.OnScroll then
                        pnl:OnScroll( num )
                    elseif pnl.parent then
                        scrollParent( pnl.parent )
                    end
                end
                
                local pnl = children[#children]
                if pnl then
                    scrollParent( pnl )
                end
                return true
            else
                GPhone.Page = math.Clamp(GPhone.Page - num, 1, #GPhone.GetAppPos())
                return true
            end
        end
    end
end)