APP.Name		= "Messages"
APP.Author		= "Krede"
APP.Negative	= false
APP.Icon		= "asset://garrysmod/materials/gphone/apps/messages.png"
function APP.Run( frame, w, h, ratio )
    function frame:Paint( x, y, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 220, 220, 220, 255 ) )
	end
    
    frame.main = frame:AddTab( "main", "panel" )
    frame.select = frame:AddTab( "select", "panel" )
    frame.chat = frame:AddTab( "chat", "panel" )
    
    function frame.OpenChat( id )
        frame.id = id
		frame.chat:Clear()
        frame:OpenTab( "chat", 0.25, "in-right", "out-left" )
        
		local messages = GPhone.GetAppData("messages") or {}
		local data = messages[id] or {}
        
        local scroll = GPnl.AddPanel( frame.chat, "scroll" )
		scroll:SetPos( 12 * ratio, 64 * ratio )
		scroll:SetSize( w - 24 * ratio, h - 128 * ratio )
        
        local padding = 18 * ratio
        local space = 0
        
        -- Instantiate every message
        for i = #data, 1, -1 do
            local msg = data[i]
            
            local text = GPhone.WordWrap(msg.text, w * 0.75, "GPSmall")
            
            local textHeight = (4 + 36 * #text) * ratio
            local textWidth = 0
            
            surface.SetFont("GPSmall")
            for k,v in pairs(text) do
                local size = surface.GetTextSize(v)
                if size > textWidth then
                    textWidth = size
                end
            end
            
            -- TODO: Only load messages if they are "new", and don't worry about older ones
            
            space = space + 12 * ratio + textHeight
            
            local message = GPnl.AddPanel( scroll )
            message:SetSize( textWidth + padding * 2, textHeight )
            if msg.me then
                message:SetPos( scroll:GetWidth() - message:GetWidth(), scroll:GetHeight() - space )
                message.textColor = Color(255, 255, 255)
                message.backColor = Color(6, 209, 74)
            else
                message:SetPos( 0, scroll:GetHeight() - space )
                message.textColor = Color(70, 70, 70)
                message.backColor = Color(200, 200, 200)
            end
            message.text = text
            function message:Paint( x, y, w, h )
                draw.RoundedBox( padding, 0, 0, w, h, self.backColor )
                
                for k,v in pairs(self.text) do
                    draw.SimpleText(v, "GPSmall", padding, (4 + k * 36 - 36) * ratio, self.textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                end
            end
        end
        
		local input = GPnl.AddPanel( frame, "textentry" )
		input:SetPos( 0, h - 64 * ratio )
        input:SetSize( w, 64 * ratio )
        input:SetFont( "GPSmall" )
        input:SetForeColor( Color(70, 70, 70) )
        input:SetBackColor( Color(255, 255, 255) )
        input:SetAlignment( TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
        function input:OnEnter( val )
            local addUser = false
            for _,ply in pairs(player.GetAll()) do
                if ply:AccountID() == id then
                    addUser = true
                end
            end
            
            if addUser then
                GPhone.SendSharedData(LocalPlayer(), "messenger_send", { val })
                
                local message = {
                    me = true,
                    text = val
                }
                
                local users = GPhone.GetAppData("messages") or {}
                users[id] = users[id] or {}
                table.insert(users[id], message)
                GPhone.SetAppData("messages", users)
                
                frame.OpenChat( frame.id )
            end
        end
		
		local header = GPnl.AddPanel( frame.chat )
		header:SetPos( 0, 0 )
        header:SetSize( w, 64 * ratio )
        header.id = id
		function header:Paint( x, y, w, h )
			draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
            draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
            
            draw.SimpleText(self.id, "GPTitle", w/2, h/2, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		
		local back = GPnl.AddPanel( header )
		back:SetPos( 0, 0 )
		back:SetSize( 64 * ratio, 64 * ratio )
        function back:OnClick()
            frame.id = nil
            frame.Main()
            frame:OpenTab( "main", 0.25, "in-left", "out-right" )
		end
		function back:Paint( x, y, w, h )
			draw.SimpleText("<", "GPTitle", w/2, h/2, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
    
    
    -- Selection
    local header = GPnl.AddPanel( frame.select )
    header:SetPos( 0, 0 )
    header:SetSize( w, 64 * ratio )
    function header:Paint( x, y, w, h )
        draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
        draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
        
        draw.SimpleText("Add phone number", "GPTitle", w/2, h/2, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    local add = GPnl.AddPanel( frame.select, "textentry" )
    add:SetPos( 0, 76 * ratio )
    add:SetSize( w, 60 * ratio )
    add:SetFont( "GPMedium" )
    add:SetForeColor( Color(70, 70, 70) )
    add:SetBackColor( Color(255, 255, 255) )
    add:SetAlignment( TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    function add:OnChange( val )
        self:SetText(val)
    end
    function add:OnEnter( val )
        local id = tonumber(val)
        local addUser = false
        for _,ply in pairs(player.GetAll()) do
            if ply != LocalPlayer() and ply:AccountID() == id then
                addUser = true
            end
        end
        
        if addUser then
            local users = GPhone.GetAppData("messages") or {}
            users[id] = {}
            GPhone.SetAppData("messages", users)
            
            frame.OpenChat(id)
        end
    end
    
    local back = GPnl.AddPanel( header )
    back:SetPos( 0, 0 )
    back:SetSize( 64 * ratio, 64 * ratio )
    function back:OnClick()
        frame.Main()
        frame:OpenTab( "main", 0.25, "in-left", "out-right" )
    end
    function back:Paint( x, y, w, h )
        draw.SimpleText("<", "GPTitle", w/2, h/2, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    
    -- Main page
	function frame.Main()
        frame.main:Clear()
        
        local mar = (64 - 36) / 2 * ratio
        
		local scroll = GPnl.AddPanel( frame.main, "scroll" )
		scroll:SetPos( 0, 64 * ratio )
		scroll:SetSize( w, h - 64 * ratio )
		
		local users = GPhone.GetAppData("messages")
        if users and table.Count(users) > 0 then
            local i = 0
            for id,_ in pairs(users) do
				local user = GPnl.AddPanel( scroll )
				user:SetSize( w, 64 * ratio )
				user:SetPos( 0, (i * 64 + 12) * ratio )
				user.id = id
				function user:Paint( x, y, w, h )
					draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
                    draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
                    
                    draw.SimpleText(self.id, "GPMedium", mar, h/2, Color(70, 70, 70), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end
				function user:OnClick()
					frame.OpenChat( self.id )
				end
				
				local delete = GPnl.AddPanel( user )
				delete:SetPos( w - 64 * ratio, 0 )
				delete:SetSize( 64 * ratio, 64 * ratio )
				function delete:OnClick()
					local users = GPhone.GetAppData("messages")
					users[id] = nil
					GPhone.SetAppData("messages", users)
					frame.Main()
				end
				function delete:Paint( x, y, w, h )
					surface.SetDrawColor( 0, 0, 0 )
					surface.SetTexture( surface.GetTextureID( "gui/html/stop" ) )
					surface.DrawTexturedRect( 0, 0, w, h )
                end
                i = i + 1
            end
        else
            local empty = GPnl.AddPanel( scroll )
            empty:SetSize( w, 64 * ratio )
            empty:SetPos( 0, 12 * ratio )
            function empty:Paint( x, y, w, h )
                draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
                draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
                
                draw.SimpleText("No messages found", "GPMedium", mar, h/2, Color(70, 70, 70), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
            function empty:OnClick()
                frame.Main()
            end
		end
		
		local header = GPnl.AddPanel( frame.main )
		header:SetPos( 0, 0 )
		header:SetSize( w, 64 * ratio )
		function header:Paint( x, y, w, h )
			draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
            draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
            
            draw.SimpleText("Messages", "GPTitle", w/2, h/2, Color(70, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		
		local add = GPnl.AddPanel( header )
		add:SetPos( w - 64 * ratio, 0 )
		add:SetSize( 64 * ratio, 64 * ratio )
		function add:OnClick()
			frame:OpenTab( "select", 0.25, "in-right", "out-left" )
		end
		function add:Paint( x, y, w, h )
			surface.SetDrawColor( 70, 70, 70 )
			surface.SetTexture( surface.GetTextureID( "gphone/write" ) )
			surface.DrawTexturedRect( 8, 8, w-16, h-16 )
		end
	end
	
    frame.Main()
    frame:OpenTab( "main" )
end

GPhone.HookSharedData("messenger_send", function(ply, name, data)
    local message = {
        me = false,
        text = data[1]
    }
    
    local id = ply:AccountID()
    
    local users = GPhone.GetAppData("messages", {}, "messenger")
    users[id] = users[id] or {}
    table.insert(users[id], message)
    GPhone.SetAppData("messages", users, "messenger")
    
    
    local frame = GPhone.Panels["messenger"]
    
    if frame:GetOpenTab() == frame.chat then
        frame.OpenChat( frame.id )
    end
end)