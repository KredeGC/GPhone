APP.Name		= "Notes"
APP.Author		= "Krede"
APP.Negative	= true
APP.Icon		= "https://raw.githubusercontent.com/KredeGC/GPhone/master/images/notes.png"
function APP.Run( frame, w, h, ratio )
	function frame:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 247, 244, 180, 255 ) )
	end
	
	function frame.Open( ind )
		frame:Clear()
		
		local notes = GPhone.GetAppData("notes") or {}
		local num = ind or table.Count(notes) + 1
		local data = notes[ind] or {}
		
		local text = GPnl.AddPanel( frame )
		text:SetPos( 0, 64 * ratio )
		text:SetSize( w, h - 64 * ratio )
		text.text = data.text or ""
		function text:OnClick()
			text.b_typing = true
			local function onEnter( val )
				text.b_typing = false
				local notes = GPhone.GetAppData("notes") or {}
				local note = notes[num] or {title = "", text = ""}
				note.text = val
				text.text = val
				notes[num] = note
				GPhone.SetAppData("notes", notes)
			end
			function onCancel()
				text.b_typing = false
			end
			GPhone.InputText( onEnter, onEnter, onCancel, text.text )
		end
		function text:Paint( x, y, w, h )
			if text.b_typing then
				draw.SimpleText(GPhone.GetInputText(), "GPMedium", 4, 4, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			else
				draw.SimpleText(text.text, "GPMedium", 4, 4, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			end
		end
		
		local header = GPnl.AddPanel( frame )
		header:SetPos( 0, 0 )
		header:SetSize( w, 64 * ratio )
		header.title = data.title or "Untitled"
		function header:OnClick()
			header.b_typing = true
			local function onEnter( val )
				header.b_typing = false
				local notes = GPhone.GetAppData("notes") or {}
				local note = notes[num] or {title = "", text = ""}
				note.title = val
				header.title = val
				notes[num] = note
				GPhone.SetAppData("notes", notes)
			end
			function onCancel()
				header.b_typing = false
			end
			GPhone.InputText( onEnter, onEnter, onCancel, header.title )
		end
		function header:Paint( x, y, w, h )
			draw.RoundedBox( 0, 0, 0, w, h-2, Color( 77, 54, 41, 255 ) )
			draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
			
			if header.b_typing then
				draw.SimpleText(GPhone.GetInputText(), "GPTitle", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			else
				draw.SimpleText(header.title, "GPTitle", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
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
			draw.RoundedBox( 0, 0, 0, w, h-2, Color( 77, 54, 41, 255 ) )
			draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
			
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