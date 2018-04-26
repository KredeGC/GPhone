GP = GP or {}
GP.Apps = GP.Apps or {}
GP.DefaultApps = GP.DefaultApps or {"appstore", "settings", "camera", "photos", "contacts"}

file.CreateDir("gphone/users")
if CLIENT then
	file.CreateDir("gphone/screens")
	file.CreateDir("gphone/apps")
end

function GP.AddApp( name, tbl )
	GP.GetApps()[name] = tbl
end

function GP.GetApp( name )
	local app = GP.GetApps()[name]
	return app or false
end

function GP.GetApps()
	return GP.Apps
end

local function loadApps()
	print("[GPhone] Loading apps")
	local files = file.Find("gpapps/*.lua", "LUA")
	for _,v in pairs(files) do
		APP = {}
		
		local name = string.sub(v, 0, string.len(v)-4)
		AddCSLuaFile("gpapps/"..v)
		
		local r = file.Read("gpapps/"..v, "LUA")
		RunString(r, v)
		
		GP.AddApp(name, APP)
		
		APP = nil
	end
	
	if CLIENT and GetConVar("gphone_csapp"):GetBool() then
		local files = file.Find("gphone/apps/*.txt", "DATA")
		for _,v in pairs(files) do
			APP = {}
			
			local name = string.sub(v, 0, string.len(v)-4)
			local r = file.Read("gphone/apps/"..v, "DATA")
			RunString(r, v)
			
			GP.AddApp(name, APP)
			
			APP = nil
		end
	end
end
loadApps()
-- hook.Add("PostGamemodeLoaded", "GPhoneInitApps", loadApps)

local selfietranslate = {}
selfietranslate[ ACT_MP_STAND_IDLE ] 		= ACT_HL2MP_IDLE_PISTOL
selfietranslate[ ACT_MP_WALK ] 				= ACT_HL2MP_WALK_PISTOL
selfietranslate[ ACT_MP_RUN ] 				= ACT_HL2MP_RUN_PISTOL
selfietranslate[ ACT_MP_CROUCH_IDLE ] 		= ACT_HL2MP_IDLE_CROUCH_PISTOL
selfietranslate[ ACT_MP_CROUCHWALK ] 		= ACT_HL2MP_WALK_CROUCH_PISTOL
selfietranslate[ ACT_MP_JUMP ] 				= ACT_HL2MP_JUMP_PISTOL

hook.Add("TranslateActivity", "GPhoneSelfieActivity", function(ply, act)
	local wep = ply:GetActiveWeapon()
	if IsValid(wep) and wep:GetClass() == "weapon_gphone" and ply:GetNWBool("GPSelfie") and selfietranslate[act] then
		return selfietranslate[act]
	end
end)

CreateConVar("gphone_csapp", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Allow users to download apps via links")
CreateConVar("gphone_sync", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Synchronize users data with singleplayer")

if SERVER then
	hook.Add("PlayerAuthed", function(ply)
		net.Start("GPhone_LoadApps")
			net.WriteTable({})
		net.Broadcast()
	end)
	
	concommand.Add("gphone_reloadapps", function(ply)
		if !ply:IsAdmin() then return end
		loadApps()
		net.Start("GPhone_Load_Apps")
			net.WriteTable({})
		net.Broadcast()
	end)
else
	net.Receive("GPhone_Load_Apps", function(l)
		local tbl = net.ReadTable()
		loadApps()
	end)
	
	if GetConVar("gphone_wepicon") == nil then
		CreateClientConVar("gphone_wepicon", "1", true, true)
	end
	if GetConVar("gphone_ampm") == nil then
		CreateClientConVar("gphone_ampm", "0", true, true)
	end
	if GetConVar("gphone_blur") == nil then
		CreateClientConVar("gphone_blur", "1", true, true)
	end
	if GetConVar("gphone_hints") == nil then
		CreateClientConVar("gphone_hints", "1", true, true)
	end
	if GetConVar("gphone_sf") == nil then
		CreateClientConVar("gphone_sf", "1", true, true)
	end
	if GetConVar("gphone_holdtime") == nil then
		CreateClientConVar("gphone_holdtime", "0.4", true, true)
	end
	if GetConVar("gphone_sensitivity") == nil then
		CreateClientConVar("gphone_sensitivity", "4", true, true)
	end

	local function GPSettingsPanel(panel)
		panel:ClearControls()
		
		panel:AddControl("CheckBox", {
			Label = "Enable fancy Weapon-icon",
			Command = "gphone_wepicon"
		})
		
		panel:AddControl("CheckBox", {
			Label = "Enable hints",
			Command = "gphone_hints"
		})
		
		panel:AddControl("CheckBox", {
			Label = "Enable background blur",
			Command = "gphone_blur"
		})
		
		panel:AddControl("CheckBox", {
			Label = "Enable AM/PM clock",
			Command = "gphone_ampm"
		})
		
		panel:AddControl("CheckBox", {
			Label = "Enable StormFox clock",
			Command = "gphone_sf"
		})
		
		panel:AddControl( "Slider", {
			Label = "Sensitivity",
			Command = "gphone_sensitivity",
			Type = "Float",
			Min = 0.5,
			Max = 6
		})
		
		panel:AddControl( "Slider", {
			Label = "Hold time",
			Command = "gphone_holdtime",
			Type = "Float",
			Min = 0.1,
			Max = 1.5
		})
	end

	hook.Add("PopulateToolMenu", "GPhoneCvarsPanel", function()
		spawnmenu.AddToolMenuOption("Options", "GPhone", "GPhone", "Settings", "", "", GPSettingsPanel)
	end)
end