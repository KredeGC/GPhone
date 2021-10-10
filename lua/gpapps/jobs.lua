--APP.Name	= "Job Index"
APP.Author	= "Krede"
APP.Icon	= "asset://garrysmod/materials/gphone/apps/furfox.png"
function APP.Run( objects, screen )
    function frame:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50, 255 ) )
	end
    
	frame.Scroll = GPnl.AddPanel( frame, "scroll" )
	frame.Scroll:SetPos( 0, 64 * ratio )
	frame.Scroll:SetSize( w, h - (64 + 140) * ratio )
	
	for _, data in pairs( RPExtraTeams ) do
	
		if not data.team then
			continue
		end	
		
		local requiresVote = data.vote or data.RequiresVote and data.RequiresVote(LocalPlayer(), data.team)
		
		local bgPanel = objects.Layout:Add("DPanel")
		bgPanel:SetSize(screen:GetWide(), 120)
		bgPanel.Paint = function( self, w, h ) 
			draw.RoundedBox(0, 0, 0, w, h, gPhone.colors.whiteBG)	
		end
		
		local jobName = vgui.Create( "DLabel", bgPanel )
		jobName:SetText( data.name )
		jobName:SetTextColor(Color(0,0,0))
		jobName:SetFont("gPhone_20")
		jobName:SizeToContents()
		jobName:SetPos( 10 + playerModel:GetWide() + 10, 15 )
		
		local function getMaxOfTeam(job)
			if not job.max or job.max == 0 then return "∞" end
			if job.max % 1 == 0 then return tostring(job.max) end

			return tostring(math.floor(job.max * #player.GetAll()))
		end
		
		local space = vgui.Create( "DLabel", bgPanel )
		space:SetText( team.NumPlayers(data.team).."/"..getMaxOfTeam(data) )
		space:SetTextColor(Color(0,0,0))
		space:SetFont("gPhone_16")
		space:SizeToContents()
		local x, y = jobName:GetPos()
		space:SetPos( x + 3, y + space:GetTall() + 5 )
		space.Think = function( self )
			self:SetText( team.NumPlayers(data.team).."/"..getMaxOfTeam(data) )
		end
		
		local salary = vgui.Create( "DLabel", bgPanel )
		salary:SetText( "$"..data.salary or "" )
		salary:SetTextColor(Color(0,0,0))
		salary:SetFont("gPhone_16")
		salary:SizeToContents()
		local x, y = space:GetPos()
		salary:SetPos( x, y + space:GetTall() + 3 )
		
		local becomeButton = vgui.Create("DButton", bgPanel )
		becomeButton:SetSize( bgPanel:GetWide()/2, 30 )
		becomeButton:SetPos( 10, bgPanel:GetTall() - becomeButton:GetTall() - 10 )
		becomeButton:SetFont("gPhone_16")
		becomeButton:SetTextColor( color_white )
		becomeButton:SetText( requiresVote and DarkRP.getPhrase("create_vote_for_job") or DarkRP.getPhrase("become_job"))
		becomeButton.Paint = function( self, w, h )
			draw.RoundedBox(0, 0, 0, w, h, Color(140, 0, 0, 250) )
		end
		if requiresVote then
			becomeButton.DoClick = fn.Compose{function()end, fn.Partial(RunConsoleCommand, "darkrp", "vote" .. data.command)}
		else
			becomeButton.DoClick = function()
				LocalPlayer():ConCommand( "darkrp ".. data.command )
			end
		end
	end
end