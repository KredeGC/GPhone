CreateConVar("gphone_csapp", "0", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Allow players to download apps via links and the online AppStore")
CreateConVar("gphone_sync", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Synchronize players data with singleplayer")
CreateConVar("gphone_spawn", "0", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Whether players should spawn with the GPhone")

GPShareData     = true  -- Allow data to be shared between players, via the server
GPDefaultApps	= {"appstore", "settings", "camera", "photos", "messages", "gtunes", "launcher"}   -- Default apps to install
GPDefaultData	= {     -- Default data to be initialized on the client
    apps = table.Copy(GPDefaultApps),
    appdata = {
        gtunes = {
            music = {"sound/music/hl1_song25_remix3.mp3"}
        }
    },
    background = "materials/gphone/backgrounds/sky.jpg",
    icon_css = "background-color: #FFF; border-radius: 32px 32px 32px 32px",
    launcher = "launcher"
}

GPLoadedApps = GPLoadedApps or false
file.CreateDir("gphone/users")
if CLIENT then
    file.CreateDir("gphone/apps")
    file.CreateDir("gphone/builds")
end

function GPLoadApps()
    if !GPLoadedApps then
        print("[GPhone] Adding serverside apps")
        
        local files = file.Find("gpapps/*.lua", "LUA")
        local added = 0
        for _,v in pairs(files) do -- I mean, you really need at least one app before it's usable
            AddCSLuaFile("gpapps/"..v)
            GPLoadedApps = true
            local name = string.sub(v, 0, string.len(v) - 4)
            if SERVER then
                added = added + 1
            else
                APP = {}
                include("gpapps/"..v)
                --local r = file.Read("gpapps/"..v, "LUA")
                --RunString(r, v)
                
                local res = GPhone.AddApp(name, APP)
                if res then
                    added = added + 1
                else
                    print("[GPhone] Could not add serverside app '"..name.."', possibly missing Name field")
                end
            end
        end
        
        if added == 0 then
            if CLIENT then
                GPhone.Debug("[GPhone] Could not load any serverside apps. Apps might not be available on the phone", false, true)
            else
                ErrorNoHalt("[GPhone] Server could not load any apps\n")
            end
        else
            print("[GPhone] Added "..added.." serverside apps")
        end
        
        if CLIENT and GetConVar("gphone_csapp"):GetBool() then
            print("[GPhone] Adding clientside apps")
            
            local files = file.Find("gphone/apps/*.txt", "DATA")
            local added = 0
            for _,v in pairs(files) do
                APP = {}
                
                local name = string.sub(v, 0, string.len(v)-4)
                local r = file.Read("gphone/apps/"..v, "DATA")
                RunString(r, v)
                
                local res = GPhone.AddApp(name, APP)
                if res then
                    added = added + 1
                else
                    print("[GPhone] Could not add clientside app '"..name.."', possibly missing Name field")
                end
            end
            
            print("[GPhone] Added "..added.." clientside apps")
        end
    end
end

-- One idea why Apps might not appear could be because the CLIENT is run before the SERVER. Needs testing
-- Could also be a restriction with garry's mod, not allowing LUA to check filesystems at the start, for whatever reason

-- Make absolutely SURE that this is called, one way or another
timer.Simple(3, function()
    GPLoadApps()
end)

-- Just fucking call it constantly, what do I care?
GPLoadApps()

-- Make sure it is loaded on the server as well
hook.Add("Initialize", "GPhoneInitialize", function()
    GPLoadApps()
end)

local selfietranslate = {}
selfietranslate[ ACT_MP_STAND_IDLE ] 		= ACT_HL2MP_IDLE_PISTOL
selfietranslate[ ACT_MP_WALK ] 				= ACT_HL2MP_WALK_PISTOL
selfietranslate[ ACT_MP_RUN ] 				= ACT_HL2MP_RUN_PISTOL
selfietranslate[ ACT_MP_CROUCH_IDLE ] 		= ACT_HL2MP_IDLE_CROUCH_PISTOL
selfietranslate[ ACT_MP_CROUCHWALK ] 		= ACT_HL2MP_WALK_CROUCH_PISTOL
selfietranslate[ ACT_MP_JUMP ] 				= ACT_HL2MP_JUMP_PISTOL

hook.Add("TranslateActivity", "GPhoneSelfieActivity", function(ply, act)
    local wep = ply:GetActiveWeapon()
    if IsValid(wep) and wep:GetClass() == "gmod_gphone" and ply:GetNWBool("GPSelfie") and selfietranslate[act] then
        return selfietranslate[act]
    end
end)

if SERVER then
    concommand.Add("gphone_reloadapps", function(ply)
        if ply:IsAdmin() then
            GPLoadedApps = false
            GPLoadApps()
            net.Start("GPhone_Load_Apps")
            net.Broadcast()
        else
            net.Start("GPhone_Load_Apps")
            net.Send(ply)
        end
    end)
else
    net.Receive("GPhone_Load_Apps", function(l)
        GPLoadedApps = false
        GPLoadApps()
    end)
    
    list.Add("CursorMaterials", "effects/select_dot")
    list.Add("CursorMaterials", "effects/select_ring")
    list.Add("CursorMaterials", "vgui/minixhair")
    list.Add("CursorMaterials", "gui/faceposer_indicator")
    list.Add("CursorMaterials", "sprites/grip")
    list.Add("CursorMaterials", "vgui/cursors/hand")
    if !Material("sprites/arrow"):IsError() then
        list.Add("CursorMaterials", "sprites/arrow")
    end
    if !Material("vgui/glyph_practice"):IsError() then
        list.Add("CursorMaterials", "vgui/glyph_practice")
    end
    if !Material("vgui/glyph_practice"):IsError() then
        list.Add("CursorMaterials", "vgui/flagtime_full")
    end
    if !Material("vgui/glyph_practice"):IsError() then
        list.Add("CursorMaterials", "vgui/glyph_close_x")
    end
    
    list.Add("CaseMaterials", "none")
    list.Add("CaseMaterials", "models/wireframe")
    list.Add("CaseMaterials", "models/flesh")
    list.Add("CaseMaterials", "debug/env_cubemap_model")
    list.Add("CaseMaterials", "brick/brick_model")
    list.Add("CaseMaterials", "models/props_c17/FurnitureFabric003a")
    list.Add("CaseMaterials", "models/props_c17/paper01")
    list.Add("CaseMaterials", "phoenix_storms/gear")
    list.Add("CaseMaterials", "phoenix_storms/stripes")
    list.Add("CaseMaterials", "models/XQM/LightLinesRed_tool")
    if !Material("models/player/shared/gold_player"):IsError() then
        list.Add("CaseMaterials", "models/player/shared/gold_player")
    end
    
    local gpvars = {
        ["gphone_sharedata"]	= "1",		-- Sharable data
        ["gphone_askdata"]	    = "1",		-- Ask before sharing
        ["gphone_lefthand"]	    = "0",		-- Left-handed
        ["gphone_wepicon"]		= "1",		-- Fancy weapon-icon
        ["gphone_bgblur"]		= "1",		-- Blur when focused
        ["gphone_blur"]			= "1",		-- Blur on ui elements
        ["gphone_bob"]			= "1",		-- Viewbob
        ["gphone_hands"]		= "0",		-- Override hands
        ["gphone_hints"]		= "1",		-- Enable hints
        ["gphone_lighting"]		= "1",		-- Enable dynamic lighting
        ["gphone_airpods"]		= "1",		-- Enable airpods when listening to music
        ["gphone_report"]		= "1",		-- Automatic report on error
        ["gphone_sf"]			= "1",		-- Enable stormfox clock
        ["gphone_thumbnail"]	= "1",		-- Enable screen thumbnails (May cause lag)
        ["gphone_rows"]			= "4",		-- Amount of rows per page
        ["gphone_holdtime"]		= "0.4",	-- Holdtime
        ["gphone_brightness"]	= "0.7",	-- Screen brightness
        ["gphone_volume"]		= "1",		-- Volume
        ["gphone_sensitivity"]	= "4",		-- Cursor sensitivity
        ["gphone_cursorsize"]	= "60",		-- Cursor size
        ["gphone_focus"]		= "0",		-- Up-in-the-face focus
        ["gphone_cursormat"]	= "effects/select_dot", -- Cursor material
        ["gphone_case"]         = "\"\""               -- Case material
    }
    
    for k,v in pairs(gpvars) do
        if GetConVar(k) == nil then
            CreateClientConVar(k, v, true, false)
        end
    end
    
    if GetConVar("gphone_showbounds") == nil then
        CreateClientConVar("gphone_showbounds", "0", false, false, "Whether to show boundaries of all clickable panels")
    end
    
    if GetConVar("gphone_chromium") == nil then
        CreateClientConVar("gphone_chromium", "1", true, false, "Notify user about chromium every time they open the browser")
    end
    
    GPhone.Rows = math.ceil(GetConVar("gphone_rows"):GetInt() * (GPhone.Landscape and GPhone.Resolution or 1)) -- Workaround
    
    cvars.AddChangeCallback("gphone_rows", function(_, _, new)
        GPhone.Rows = math.Round(new)
        
        local launcher = GPhone.GetData("launcher", "launcher")
        if GPhone.CurrentApp == launcher then
            GPhone.FocusHome()
        end
    end)
    
    cvars.AddChangeCallback("gphone_lefthand", function(_, _, new)
        local wep = LocalPlayer():GetActiveWeapon()
        if IsValid(wep) and wep:GetClass() == "gmod_gphone" then
            wep.ViewModelFlip = new != "0"
        end
    end)
    
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
        
        panel:AddControl("CheckBox", {
            Label = "Spawn with the GPhone (Requires restart)",
            Command = "gphone_spawn"
        })
        
        panel:AddControl("Button", {
            Label = "Reload apps",
            Command = "gphone_reloadapps"
        })
    end

    local function GPSettingsPanel(panel)
        panel:ClearControls()
        
        local cmd = ""
        for k,v in pairs(gpvars) do
            cmd = cmd..k.." "..v.."\n"
        end
        
        panel:AddControl("Button", {
            Label = "Reset settings",
            Command = cmd
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable data-sharing",
            Command = "gphone_sharedata"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Ask before sharing data",
            Command = "gphone_askdata"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable fancy Weapon-icon (May cause FPS drops)",
            Command = "gphone_wepicon"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable background blur (May cause FPS drops)",
            Command = "gphone_bgblur"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable UI blur (May cause FPS drops)",
            Command = "gphone_blur"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable dynamic lighting (May cause FPS drops)",
            Command = "gphone_lighting"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable airpods (Requires TF2)",
            Command = "gphone_airpods"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable App thumbnails",
            Command = "gphone_thumbnail"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable automatic bug reporting",
            Command = "gphone_report"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Show clickboxes of panels",
            Command = "gphone_showbounds"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable hints",
            Command = "gphone_hints"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable StormFox clock",
            Command = "gphone_sf"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Override custom hands with placeholder",
            Command = "gphone_hands"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Flip the viewmodel to be left-handed",
            Command = "gphone_lefthand"
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
            Label = "Phone volume",
            Command = "gphone_volume",
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
            Label = "Face-to-phone distance",
            Command = "gphone_focus",
            Type = "Float",
            Min = -5,
            Max = 5
        })
        
        panel:AddControl( "Slider", {
            Label = "Cursor size",
            Command = "gphone_cursorsize",
            Min = 12,
            Max = 90
        })
        
        panel:MatSelect("gphone_cursormat", list.Get( "CursorMaterials" ), true, 0.25, 0.25)
        
        panel:MatSelect("gphone_case", list.Get( "CaseMaterials" ), true, 0.25, 0.25)
    end
    
    local function GPDebugSettingsPanel(panel)
        panel:ClearControls()
        
        GPErrorTextField = vgui.Create("DTextEntry", panel)
        GPErrorTextField:SetText(string.Implode("\n", GPhone.Log))
        GPErrorTextField:SetMultiline(true)
        GPErrorTextField:SetDrawLanguageID(false)
        GPErrorTextField:SetVerticalScrollbarEnabled(true)
        GPErrorTextField:SetTall(512)
        GPErrorTextField:SetPlaceholderText("Nothing logged")
        
        function GPErrorTextField:AllowInput(key)
            return true
        end
        
        panel:AddItem(GPErrorTextField)
        
        panel:AddControl("Button", {
            Label = "Report error",
            Command = "gphone_log_report"
        })
        
        panel:AddControl("Button", {
            Label = "Output log in console",
            Command = "gphone_log_print"
        })
        
        panel:AddControl("Button", {
            Label = "Copy log to clipboard",
            Command = "gphone_log_copy"
        })
        
        panel:AddControl("Button", {
            Label = "Wipe log",
            Command = "gphone_log_wipe"
        })
        
        panel:AddControl("Button", {
            Label = "Redownload images",
            Command = "gphone_redownloadimages"
        })
        
        panel:AddControl("Button", {
            Label = "Clear image cache",
            Command = "gphone_clearcache"
        })
        
        local but = panel:AddControl("Button", {
            Label = "Factory Reset",
            Command = "gphone_reset"
        })
        
        but:SetTextColor(Color(255, 0, 0))
        but:SetToolTip("Warning! Resets all data from the phone")
    end

    hook.Add("PopulateToolMenu", "GPhoneCvarsPanel", function()
        spawnmenu.AddToolMenuOption("Options", "GPhone", "GPhone", "Settings", "", "", GPSettingsPanel)
        spawnmenu.AddToolMenuOption("Options", "GPhone", "GPhoneDebug", "Debugging", "", "", GPDebugSettingsPanel)
        spawnmenu.AddToolMenuOption("Options", "GPhone", "GPhoneAdmin", "Admin Settings", "", "", GPAdminSettingsPanel)
    end)
end