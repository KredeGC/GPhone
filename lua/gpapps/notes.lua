APP.Name		= "Notes"
APP.Author		= "Krede"
APP.Negative	= true
APP.Icon		= "asset://garrysmod/materials/gphone/apps/notes.png"
function APP.Run( frame, w, h, ratio )
    function frame:Paint( x, y, w, h )
        draw.RoundedBox( 0, 0, 0, w, 62 * ratio, Color( 77, 54, 41, 255 ) )
		draw.RoundedBox( 0, 0, 62 * ratio, w, 2 * ratio, Color( 80, 80, 80, 255 ) )
        
		draw.RoundedBox( 0, 0, 64 * ratio, w, h - 64 * ratio, Color( 247, 244, 180, 255 ) )
	end
	
	function frame.Open( ind )
		frame:Clear()
		
		local notes = GPhone.GetAppData("notes") or {}
		local num = ind or table.Count(notes) + 1
		local data = notes[ind] or {}
		
		local text = GPnl.AddPanel( frame, "textentry" )
		text:SetPos( 0, 64 * ratio )
        text:SetSize( w, h - 64 * ratio )
        text:SetFont( "GPMedium" )
        text:SetBackColor( Color(0, 0, 0, 0) )
        text:SetText( data.text )
        text:SetAlignment( TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
        function text:OnEnter( val )
            self:SetText(val)
            local notes = GPhone.GetAppData("notes") or {}
            local note = notes[num] or {title = "Untitled", text = ""}
            note.text = val
            notes[num] = note
            GPhone.SetAppData("notes", notes)
        end
		
		local header = GPnl.AddPanel( frame, "textentry" )
		header:SetPos( 0, 0 )
		header:SetSize( w, 64 * ratio )
        header:SetFont( "GPTitle" )
        header:SetForeColor( Color(255, 255, 255) )
        header:SetBackColor( Color(0, 0, 0, 0) )
        header:SetText( data.title or "Untitled" )
        header:SetAlignment( TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        function header:OnEnter( val )
            header:SetText(val)
            local notes = GPhone.GetAppData("notes") or {}
            local note = notes[num] or {title = "", text = ""}
            note.title = val
            notes[num] = note
            GPhone.SetAppData("notes", notes)
        end
		
		local back = GPnl.AddPanel( header )
		back:SetPos( 0, 0 )
		back:SetSize( 64 * ratio, 64 * ratio )
		function back:OnClick()
			frame.Main()
		end
		function back:Paint( x, y, w, h )
			draw.SimpleText("<", "GPTitle", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
	
	function frame.Main()
		frame:Clear()
		
		local scroll = GPnl.AddPanel( frame, "scroll" )
		scroll:SetPos( 0, 64 * ratio )
		scroll:SetSize( w, h - 64 * ratio )
		
		local notes = GPhone.GetAppData("notes")
		if notes then
			for num,data in pairs(notes) do
				local note = GPnl.AddPanel( scroll )
				note:SetSize( w, 40 * ratio )
				note:SetPos( 0, (num*40 - 34) * ratio )
				note.num = num
				note.data = data
				function note:Paint( x, y, w, h )
					draw.RoundedBox( 0, 0, h-2, w, 2, Color( 77, 54, 41, 255 ) )
					
					local title = note.data.title or "Untitled"
					surface.SetFont("GPMedium")
					local s = surface.GetTextSize(title)
					if s > w-40 then
						draw.SimpleText(title, "GPMedium", w-40, h/2, Color(0, 0, 0), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
					else
						draw.SimpleText(title, "GPMedium", 4, h/2, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					end
				end
				function note:OnClick()
					frame.Open( note.num )
				end
				
				local delete = GPnl.AddPanel( note )
				delete:SetPos( w - 40 * ratio, 0 )
				delete:SetSize( 40 * ratio, 40 * ratio )
				function delete:OnClick()
					local notes = GPhone.GetAppData("notes")
					table.remove(notes, delete:GetParent().num)
					GPhone.SetAppData("notes", notes)
					frame.Main()
				end
				function delete:Paint( x, y, w, h )
					surface.SetDrawColor( 0, 0, 0 )
					surface.SetTexture( surface.GetTextureID( "gui/html/stop" ) )
					surface.DrawTexturedRect( 0, 0, w, h )
				end
			end
		end
		
		local header = GPnl.AddPanel( frame )
		header:SetPos( 0, 0 )
		header:SetSize( w, 64 * ratio )
		function header:Paint( x, y, w, h )
			draw.SimpleText("Notes", "GPTitle", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		
		local add = GPnl.AddPanel( header )
		add:SetPos( w - 64 * ratio, 0 )
		add:SetSize( 64 * ratio, 64 * ratio )
		function add:OnClick()
			frame.Open()
		end
		function add:Paint( x, y, w, h )
			surface.SetDrawColor( 255, 255, 255 )
			surface.SetTexture( surface.GetTextureID( "gphone/write" ) )
			surface.DrawTexturedRect( 8, 8, w-16, h-16 )
		end
	end
	
	frame.Main()
end