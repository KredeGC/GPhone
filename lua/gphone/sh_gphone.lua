CreateConVar("gphone_csapp", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Allow players to download apps via links")
CreateConVar("gphone_sync", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Synchronize players data with singleplayer")

file.CreateDir("gphone/users")
if CLIENT then
	file.CreateDir("gphone/screens")
	file.CreateDir("gphone/apps")
end

local function loadApps()
	if SERVER then
		print("[GPhone] Adding serverside apps")
	else
		print("[GPhone] Loading serverside apps")
	end
	
	local files = file.Find("gpapps/*.lua", "LUA")
	for _,v in pairs(files) do
		local name = string.sub(v, 0, string.len(v)-4)
		
		if SERVER then
			AddCSLuaFile("gpapps/"..v)
		else
			APP = {}
			local r = file.Read("gpapps/"..v, "LUA")
			RunString(r or "", v)
			
			local res = GPhone.AddApp(name, APP)
			if !res then
				print("[GPhone] Could not add app '"..name.."', possibly missing Name or Icon")
			end
			
			APP = nil
		end
	end
	
	if CLIENT then
		if GetConVar("gphone_csapp"):GetBool() then
			print("[GPhone] Loading clientside apps")
			
			local files = file.Find("gphone/apps/*.txt", "DATA")
			for _,v in pairs(files) do
				APP = {}
				
				local name = string.sub(v, 0, string.len(v)-4)
				local r = file.Read("gphone/apps/"..v, "DATA")
				RunString(r, v)
				
				local res = GPhone.AddApp(name, APP)
				if !res then
					print("[GPhone] Could not add app '"..name.."', possibly missing Name or Icon")
				end
				
				APP = nil
			end
		end
		
		print("[GPhone] App loading finished")
	else
		print("[GPhone] Serverside apps initialized")
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

if SERVER then
	hook.Add("PlayerAuthed", function(ply)
		--[[net.Start("GPhone_LoadApps")
			net.WriteTable({})
		net.Broadcast()]]
	end)
	
	concommand.Add("gphone_reloadapps", function(ply)
		if !ply:IsAdmin() then return end
		loadApps()
		net.Start("GPhone_Load_Apps")
			net.WriteTable({})
		net.Broadcast()
	end)
else
	list.Add( "CursorMaterials", "effects/select_dot" )
	list.Add( "CursorMaterials", "vgui/minixhair" )
	list.Add( "CursorMaterials", "effects/wheel_ring" )
	list.Add( "CursorMaterials", "gui/faceposer_indicator" )
	list.Add( "CursorMaterials", "sprites/grip" )
	
	net.Receive("GPhone_Load_Apps", function(l)
		local tbl = net.ReadTable()
		loadApps()
	end)
	
	if GetConVar("gphone_wepicon") == nil then
		CreateClientConVar("gphone_wepicon", "1", true, false, "Whether the phone should use a fancy weapon icon")
	end
	if GetConVar("gphone_blur") == nil then
		CreateClientConVar("gphone_blur", "1", true, false, "Whether to use blur when focused")
	end
	if GetConVar("gphone_bob") == nil then
		CreateClientConVar("gphone_bob", "1", true, false, "Amount of viewmodel bobbing")
	end
	if GetConVar("gphone_hints") == nil then
		CreateClientConVar("gphone_hints", "1", true, false, "Enable or disable hints")
	end
	if GetConVar("gphone_ampm") == nil then
		CreateClientConVar("gphone_ampm", "0", true, false, "Whether to use AM/PM or 24-hour clock")
	end
	if GetConVar("gphone_sf") == nil then
		CreateClientConVar("gphone_sf", "1", true, false, "Enable StormFox support")
	end
	if GetConVar("gphone_rows") == nil then
		CreateClientConVar("gphone_rows", "4", true, false, "Amount of rows per homescreen page")
	end
	if GetConVar("gphone_holdtime") == nil then
		CreateClientConVar("gphone_holdtime", "0.4", true, false, "Left-click hold-time (in seconds)")
	end
	if GetConVar("gphone_brightness") == nil then
		CreateClientConVar("gphone_brightness", "1", true, false, "Screen brightness (0-1)")
	end
	if GetConVar("gphone_sensitivity") == nil then
		CreateClientConVar("gphone_sensitivity", "4", true, false, "Cursor sensitivity")
	end
	if GetConVar("gphone_cursorsize") == nil then
		CreateClientConVar("gphone_cursorsize", "30", true, false, "Cursor size")
	end
	if GetConVar("gphone_cursormat") == nil then
		CreateClientConVar("gphone_cursormat", "effects/select_dot", true, false, "Cursor material")
	end
	
	local function GPAdminSettingsPanel(panel)
		panel:ClearControls()
		
		panel:AddControl("CheckBox", {
			Label = "Allow players to download custom apps",
			Command = "gphone_csapp"
		})
		
		panel:AddControl("CheckBox", {
			Label = "Enable singleplayer synchronization",
			Command = "gphone_sync"
		})
		
		panel:AddControl("Button", {
			Label = "Reload apps",
			Command = "gphone_reloadapps"
		})
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
			Label = "Viewmodel bobbing",
			Command = "gphone_bob",
			Type = "Float",
			Min = 0,
			Max = 4
		})
		
		panel:AddControl( "Slider", {
			Label = "Homescreen rows",
			Command = "gphone_rows",
			Min = 1,
			Max = 6
		})
		
		panel:AddControl( "Slider", {
			Label = "Screen brightness",
			Command = "gphone_brightness",
			Type = "Float",
			Min = 0,
			Max = 1
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
		
		panel:AddControl( "Slider", {
			Label = "Cursor size",
			Command = "gphone_cursorsize",
			Min = 2,
			Max = 60
		})
		
		panel:MatSelect( "gphone_cursormat", list.Get( "CursorMaterials" ), true, 0.25, 0.25 )
		
		panel:AddControl("Button", {
			Label = "Redownload images",
			Command = "gphone_redownloadimages"
		})
		
		panel:AddControl("Button", {
			Label = "Clear image cache",
			Command = "gphone_clearcache"
		})
	end

	hook.Add("PopulateToolMenu", "GPhoneCvarsPanel", function()
		spawnmenu.AddToolMenuOption("Options", "GPhone", "GPhone", "Settings", "", "", GPSettingsPanel)
		spawnmenu.AddToolMenuOption("Options", "GPhone", "GPhoneAdmin", "Admin Settings", "", "", GPAdminSettingsPanel)
	end)
end