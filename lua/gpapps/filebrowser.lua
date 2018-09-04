APP.Name		= "FileManager"
APP.Author		= "Krede"
APP.Negative	= false
APP.Icon 		= "https://raw.githubusercontent.com/KredeGC/GPhone/master/images/contacts.png"
function APP.Run( frame, w, h, ratio )
	function frame:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 220, 220, 220 ) )
	end
	
	frame.Path = ""
	
	local folder	= Material("icon16/folder.png")
	local page		= Material("icon16/page_white.png")
	local txt		= Material("icon16/page_white_text.png")
	local lua		= Material("icon16/script.png")
	local film		= Material("icon16/film.png")
	local snd		= Material("icon16/sound.png")
	local pic		= Material("icon16/picture.png")
	
	local scroll = GPnl.AddPanel( frame, "scroll" )
	scroll:SetPos( 0, 64 * ratio )
	scroll:SetSize( w, h - 64 * ratio )
	
	function frame:OpenVideo( path )
		frame.File = table.remove(string.Explode("/", path))
		local ext = string.EndsWith(path, ".mp4") and "mp4" or string.EndsWith(path, ".webm") and "webm"
		if !ext then return false end
		local r = file.Read(path, "GAME")
		local data = util.Base64Encode( r )
		
		scroll:Clear()
		
		frame.Video = GPnl.AddPanel( scroll, "video" )
		frame.Video:SetPos( 0, 0 )
		frame.Video:SetSize( scroll:GetSize() )
		frame.Video:Open( path )
	end
	
	function frame:SetPath( path )
		scroll:Clear()
		local noslash = path == "" or string.EndsWith(path, "/")
		frame.Path = path..(noslash and "" or "/")
		local files,dirs = {},{"backgrounds", "data", "lua", "maps", "materials", "screenshots", "sound", "videos"}
		if frame.Path != "" then
			files,dirs = file.Find(frame.Path.."*", "GAME")
		end
		local num = 0
		for _,dir in pairs(dirs) do
			local fileinfo = GPnl.AddPanel( scroll )
			fileinfo:SetPos( 0, num * 64 * ratio )
			fileinfo:SetSize( w, 64 * ratio )
			fileinfo.Dir = dir
			function fileinfo:Paint( x, y, w, h )
				draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
				draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
				
				local text = self.Dir
				surface.SetFont("GPMedium")
				local size = surface.GetTextSize(text)
				
				if size > w then
					draw.SimpleText(text, "GPMedium", w, h/2, Color(70, 70, 70), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
				else
					draw.SimpleText(text, "GPMedium", h, h/2, Color(70, 70, 70), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end
				
				surface.SetDrawColor(255, 255, 255)
				surface.SetMaterial( folder )
				surface.DrawTexturedRect( 0, 0, h, h )
			end
			function fileinfo:OnClick()
				frame:SetPath( frame.Path..self.Dir )
			end
			num = num + 1
		end
		for _,name in pairs(files) do
			local fileinfo = GPnl.AddPanel( scroll )
			fileinfo:SetPos( 0, num * 64 * ratio )
			fileinfo:SetSize( w, 64 * ratio )
			fileinfo.File = name
			fileinfo.Extension = string.GetExtensionFromFilename( name )
			function fileinfo:Paint( x, y, w, h )
				draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
				draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
				
				local text = self.File
				surface.SetFont("GPMedium")
				local size = surface.GetTextSize(text)
				
				if size > w then
					draw.SimpleText(text, "GPMedium", w, h/2, Color(70, 70, 70), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
				else
					draw.SimpleText(text, "GPMedium", h, h/2, Color(70, 70, 70), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end
				
				surface.SetDrawColor(255, 255, 255)
				if self.Extension == "lua" then
					surface.SetMaterial( lua )
				elseif self.Extension == "mp4" or self.Extension == "webm" then
					surface.SetMaterial( film )
				elseif self.Extension == "png" or self.Extension == "jpg" or self.Extension == "jpeg" or self.Extension == "vmt" then
					surface.SetMaterial( pic )
				elseif self.Extension == "mp3" or self.Extension == "wav" or self.Extension == "ogg" then
					surface.SetMaterial( snd )
				elseif self.Extension == "txt" then
					surface.SetMaterial( txt )
				else
					surface.SetMaterial( page )
				end
				surface.DrawTexturedRect( 0, 0, h, h )
			end
			function fileinfo:OnClick()
				local ext = self.Extension
				local path = frame.Path..self.File
				if ext == "mp4" or ext == "webm" then
					frame:OpenVideo( path )
				elseif ext == "mp3" or ext == "wav" then
					local app = GPhone.RunApp( "gtunes" )
					if app then
						app:Open( path )
					end
				elseif ext == "png" or ext == "jpg" or ext == "jpeg" or ext == "vmt" then
					local app = GPhone.RunApp( "photos" )
					if ext == "vmt" then
						local parts = string.Explode("/", path)
						table.remove(parts, 1)
						path = string.StripExtension( table.concat(parts, "/") )
					end
					if app then
						app:Open( path, Material(path) )
					end
				end
			end
			num = num + 1
		end
	end
	
	function frame:GoBack()
		if self.Path == "" then return end
		if self.File then
			self.File = nil
			self:SetPath( self.Path )
		else
			local tbl = string.Explode("/", self.Path)
			table.remove(tbl)
			table.remove(tbl)
			self:SetPath( table.concat(tbl, "/") )
		end
	end
	
	local header = GPnl.AddPanel( frame )
	header:SetPos( 0, 0 )
	header:SetSize( w, 64 * ratio )
	function header:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h-2, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h-2, w, 2, Color( 80, 80, 80, 255 ) )
	end
	
	local back = GPnl.AddPanel( header )
	back:SetPos( 0, 0 )
	back:SetSize( 64 * ratio, 64 * ratio )
	function back:OnClick()
		frame:GoBack()
	end
	function back:Paint( x, y, w, h )
		if frame.Path != "" then
			draw.SimpleText("<", "GPTitle", w/2, h/2, Color(0, 160, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
	
	local path = GPnl.AddPanel( header )
	path:SetPos( 64 * ratio, 0 )
	path:SetSize( w - 128 * ratio, 64 * ratio )
	function path:Paint( x, y, w, h )
		local text = frame.File or "garrysmod/"..(frame.Path or "")
		surface.SetFont("GPTitle")
		local size = surface.GetTextSize(text)
		
		if size > w then
			draw.SimpleText(text, "GPTitle", w, h/2, Color(70, 70, 70), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText(text, "GPTitle", 0, h/2, Color(70, 70, 70), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	end
	
	frame:SetPath( "" )
end