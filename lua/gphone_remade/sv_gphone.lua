util.AddNetworkString( "GPhone_Change_Data" )
util.AddNetworkString( "GPhone_Share_Data" )
util.AddNetworkString( "GPhone_Reset" )
util.AddNetworkString( "GPhone_Load_Client" )
util.AddNetworkString( "GPhone_Load_Apps" )
util.AddNetworkString( "GPhone_Selfie" )
util.AddNetworkString( "GPhone_SMS_Receive" )

util.AddNetworkString( "GPhone_VoiceCall_Request" )
util.AddNetworkString( "GPhone_VoiceCall_Answer" )
util.AddNetworkString( "GPhone_VoiceCall_Stop" )


resource.AddFile( "materials/vgui/entities/gmod_gphone.vmt" )
resource.AddFile( "materials/vgui/hud/phone.vmt" )

resource.AddFile( "materials/models/weapons/c_garry_phone.vmt" )

resource.AddFile( "models/weapons/c_garry_phone.mdl" )
resource.AddFile( "models/nitro/iphone4.mdl" )

local function addResources(dir)
	local files,dirs = file.Find(dir.."/*", "GAME")
	for _,v in pairs(files) do
		resource.AddSingleFile( dir.."/"..v )
	end
	
	for _,v in pairs(dirs) do
		addResources(dir.."/"..v)
	end
end

addResources("materials/gphone")
addResources("materials/models/nitro")
addResources("sound/gphone")


local function resetGPhoneData( ply, id )
	local data = table.Copy(GPDefaultData)
	file.Write("gphone/users/"..id..".txt", util.TableToJSON(data))
	net.Start( "GPhone_Load_Client" )
		net.WriteTable( data )
	net.Send( ply )
end

hook.Add("PlayerAuthed", "GPhoneLoadClientData", function(ply, stid)
	local id = util.SteamIDTo64( ply:SteamID() )
	if game.SinglePlayer() then
		net.Start( "GPhone_Load_Client" )
			net.WriteTable( {} )
		net.Send( ply )
	elseif file.Exists("gphone/users/"..id..".txt", "DATA") then
		local tbl = util.JSONToTable( file.Read("gphone/users/"..id..".txt", "DATA") )
		local apps = {}
		for _,id in pairs(GPDefaultApps) do -- Fix default apps
			if !table.HasValue(tbl.apps, id) then
				table.insert(apps, id)
			end
		end
		
		if #apps > 0 then
			table.Add(tbl.apps, apps)
			file.Write("gphone/users/"..id..".txt", util.TableToJSON(tbl))
			print("[GPhone] Added "..#apps.." missing default apps for "..ply:Nick())
		end
		
		net.Start( "GPhone_Load_Client" )
			net.WriteTable( tbl )
		net.Send( ply )
	else
		resetGPhoneData( ply, id )
	end
end)

hook.Add("PlayerCanHearPlayersVoice", "GPhonePlayerVoiceChat", function( p1, p2 )
	if p1.VoiceChatter and p2.VoiceChatter and p1 != p2 then
		return p1.VoiceChatter == p2 and p2.VoiceChatter == p1
	elseif p1.VoiceChatter and !p2.VoiceChatter or !p1.VoiceChatter and p2.VoiceChatter then
		return false
	end
end)

net.Receive("GPhone_Change_Data", function(len, ply)
	local cv = GetConVar("gphone_sync")
	if !game.SinglePlayer() and (cv or !cv:GetBool()) then
		local str = net.ReadTable()
		local id = util.SteamIDTo64( ply:SteamID() )
		file.Write("gphone/users/"..id..".txt", util.TableToJSON(str))
	end
end)

net.Receive("GPhone_Share_Data", function(len, ply)
	if true then return end -- For now this is disabled
	local receiver = net.ReadEntity()
	local name = net.ReadString()
	local data = net.ReadTable()
	
	-- if receiver.GPBlacklist[ply] then return end
	-- timer.Simple(receiver.GPConnection + ply.GPConnection, function() end)
	
	net.Start( "GPhone_Share_Data" )
		net.WriteEntity( ply )
		net.WriteString( name )
		net.WriteTable( data )
	net.Send( receiver )
end)

net.Receive("GPhone_Reset", function(len, ply)
	local cv = GetConVar("gphone_sync")
	if !game.SinglePlayer() and (cv or !cv:GetBool()) then
		local id = util.SteamIDTo64( ply:SteamID() )
		resetGPhoneData( ply, id )
	end
end)

net.Receive("GPhone_SMS_Send", function(len, ply)
	local number = net.ReadString()
	local text = net.ReadString()
	
	for k,pl in pairs(player.GetAll()) do
		if tonumber(pl:ShortSteamID()) == tonumber(number) then
			net.Start("GPhone_SMS_Receive")
				net.WriteString(ply:ShortSteamID())
				net.WriteString(text)
			net.Send(pl)
		end
	end
end)

net.Receive("GPhone_VoiceCall_Request", function(len, ply)
	local chatter = net.ReadEntity()
	if !IsValid(chatter) or !chatter:IsPlayer() or chatter == ply then return end
	
	ply.VoiceChatter = chatter
	
	net.Start( "GPhone_VoiceCall_Request" )
		net.WriteEntity( ply )
	net.Send( chatter )
end)

net.Receive("GPhone_VoiceCall_Answer", function(len, ply)
	local chatter = net.ReadEntity()
	local accept = net.ReadBool()
	if !IsValid(chatter) or !chatter:IsPlayer() or chatter == ply or chatter.VoiceChatter != ply then return end
	
	if accept then
		ply.VoiceChatter = chatter
	else
		chatter.VoiceChatter = false
		net.Start( "GPhone_VoiceCall_Stop" )
		net.Send(chatter)
	end
end)

net.Receive("GPhone_Selfie", function(len, ply)
	local bool = net.ReadBool()
	ply:SetNWBool("GPSelfie", bool)
end)

net.Receive("GPhone_VoiceCall_Stop", function(len, ply)
	local chatter = ply.VoiceChatter
	if IsValid(chatter) and chatter:IsPlayer() and chatter != ply and chatter.VoiceChatter == ply then
		chatter.VoiceChatter = false
	end
	
	ply.VoiceChatter = false
end)