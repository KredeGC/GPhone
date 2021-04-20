local gpnotfound = false
local noicon = Material("gui/dupe_bg.png", "nocull smooth")
local GPLoadingRT = GetRenderTarget("GPLoadingRT", 512, 512, false)
GPLoadingMT = CreateMaterial(
    "GPLoadMT",
    "UnlitGeneric",
    {
        ["$basetexture"] = GPLoadingRT,
        ["$vertexcolor"] = 1,
        ["$vertexalpha"] = 1
    }
)

cvars.AddChangeCallback("gphone_case", function( con, old, new )
    if old != val then
        net.Start("GPhone_Case")
            net.WriteString(new)
        net.SendToServer()
    end
end, "gphone_stopit")

hook.Add("Think", "GPhoneGlobalThink", function()
    for _,html in pairs(GPhone.HTML) do
        if IsValid(html) then
            if html:IsLoading() then
                if !html.b_loading then
                    html.b_loading = true
                    if GPhone.IsAwesomium then
                        html:QueueJavascript([[window.onerror = function(msg, url, line, col, error) {
                            gmod.print("Line " + line + ": " + msg);
                        };
                        isAwesomium = navigator.userAgent.indexOf("Awesomium") != -1;
                        gmod.getURL( window.location.href );]])
                    end
                end
            else
                if html.b_loading then
                    html.b_loading = false
                    GPhone.UpdateHTMLControl( html ) -- Chromium likes to randomly delete these. Remind it who's boss
                    html:QueueJavascript([[window.onerror = function(msg, url, line, col, error) {
                        gmod.print("Line " + line + ": " + msg);
                    };
                    isAwesomium = navigator.userAgent.indexOf("Awesomium") != -1;
                    gmod.getURL( window.location.href );]])
                    
                    if GPhone.IsAwesomium == nil then
                        html:QueueJavascript([[gmod.isAwesomium( isAwesomium );]])
                    end
                elseif !html.b_keepvolume then
                    local vol = GetConVar("gphone_volume")
                    html:RunJavascript([[var x = [];
                    x.push.apply( x, document.getElementsByTagName("VIDEO") );
                    x.push.apply( x, document.getElementsByTagName("AUDIO") );
                    for (i = 0; i < x.length; i++) {
                        x[i].volume = ]]..(vol and vol:GetFloat() or 1)..[[;
                    }]])
                end
            end
        end
    end
    
    local count = table.Count(GPhone.ImageQueue)
    if count > 0 then
        gpnotfound = false
        render.PushRenderTarget(GPLoadingRT)
        render.Clear(0, 0, 0, 255, true, true)
        cam.Start2D()
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial( noicon )
            surface.DrawTexturedRect( 0, 0, 512, 512 )
            
            surface.SetDrawColor(255, 255, 255)
            surface.SetTexture( surface.GetTextureID("vgui/loading-rotate") )
            surface.DrawTexturedRectRotated( 256, 256, 512, 512, RealTime()*360 )
            
            draw.SimpleText("Loading", "GPLoading", 256, 256, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
            draw.SimpleText(count, "GPLoading", 256, 256, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        cam.End2D()
        render.PopRenderTarget()
        
        GPLoadingMT:SetTexture("$basetexture", GPLoadingRT)
        
        for k,data in pairs(GPhone.ImageQueue) do
            if GPhone.ImageCache[data.URL] then
                GPhone.ImageQueue[k] = nil
                break
            end
            
            if !ImgDownloadTime and !ImgReady and !IsValid(DownloadHTML) then
                DownloadHTML = vgui.Create( "HTML" )
                DownloadHTML:SetPos(ScrW()-1, ScrH()-1)
                DownloadHTML:SetSize(data.Size, data.Size)
                DownloadHTML:SetHTML([[
                    <style type="text/css">
                        html { overflow:hidden; margin: -8px -8px; }
                        img { ]]..(data.Style or "")..[[ }
                    </style>
                    
                    <body>
                        <img src="]]..(data.URL or "")..[[" alt="]]..(data.URL or "")..[[" width="]]..(data.Size or "0")..[[" height="]]..(data.Size or "0")..[[" />
                    </body>
                ]])
            end
            
            local tex = DownloadHTML:GetHTMLMaterial()
            
            if !ImgReady and tex and !DownloadHTML:IsLoading() then
                ImgDownloadTime = CurTime() + 0.1
                ImgReady = true
            end
            
            if ImgReady and ImgDownloadTime < CurTime() then
                ImgReady = nil
                ImgDownloadTime = nil
                local scale_x,scale_y = DownloadHTML:GetWide() / tex:Width(),DownloadHTML:GetTall() / tex:Height()
                local matdata = {
                    ["$basetexture"] = tex:GetName(),
                    ["$basetexturetransform"] = "center 0 0 scale "..scale_x.." "..scale_y.." rotate 0 translate 0 0",
                    ["$vertexcolor"] = 1,
                    ["$vertexalpha"] = 1,
                    ["$nocull"] = 1,
                    ["$model"] = 1
                }
                local id = string.Replace(tex:GetName(), "__vgui_texture_", "")
                GPhone.ImageCache[data.URL] = CreateMaterial("GPhone_CachedImage_"..id, "UnlitGeneric", matdata)
                GPhone.ImageQueue[k] = nil
                DownloadHTML:Remove()
                DownloadHTML = nil
            end
            
            break
        end
    elseif !gpnotfound then -- No need to update if we're not downloading anything
        gpnotfound = true
        render.PushRenderTarget(GPLoadingRT)
        render.Clear(0, 0, 0, 255, true, true)
        cam.Start2D()
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial( noicon )
            surface.DrawTexturedRect( 0, 0, 512, 512 )
            
            draw.SimpleText("Image", "GPLoading", 512/2, 512/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
            draw.SimpleText("Not Found", "GPLoading", 512/2, 512/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        cam.End2D()
        render.PopRenderTarget()
        
        GPLoadingMT:SetTexture("$basetexture", GPLoadingRT)
    end
end)

hook.Add("HUDShouldDraw", "_GPhoneHideWPSelection", function(name)
    local ply = LocalPlayer()
    if IsValid(ply) then
        local wep = ply:GetActiveWeapon()
        if IsValid(wep) and wep:GetClass() == "gmod_gphone" then
            if name == "CHUDQuickInfo" then return false end
            if GPhone.CursorEnabled and name == "CHudWeaponSelection" then return false end
        end
    end
end)

local matflash = Material( "sprites/light_ignorez" )

hook.Add("PostPlayerDraw", "DrawGFlashlight", function(ply)
    local wep = ply:GetActiveWeapon()
    if ply:FlashlightIsOn() and IsValid(wep) and wep:GetClass() == "gmod_gphone" then
        if ply != LocalPlayer() or GetViewEntity() != LocalPlayer() then
            local id = ply:LookupAttachment("anim_attachment_RH")
            if !id then return end
            local attach = ply:GetAttachment(id)
            if !attach then return end
            
            local pos,ang = attach.Pos,attach.Ang
            
            pos = pos + ang:Forward() * wep.WorldModelInfo.pos.x + ang:Right() * wep.WorldModelInfo.pos.y + ang:Up() * wep.WorldModelInfo.pos.z
            pos = pos + ang:Up()*1.9 + ang:Forward()*0.6 + ang:Right()*1.1
            
            local dir = ply:EyeAngles():Forward():Dot( (GetViewEntity():GetPos() - pos):GetNormalized() )
            
            local leng = (GetViewEntity():GetPos() - pos):Length()
            local a = math.max(1000-leng, 0)
            
            if dir > 0.2 then
                render.SetMaterial( matflash )
                render.DrawSprite( pos, dir*(leng/4), dir*(leng/4), Color(255,255,255,a) )
            end
        end
    end
end)

if IsMounted("tf") then
    local earbudpos = Vector(-69.3, 0.3, 0.1)
    local earbudang = Angle(0, -90, -90)

    hook.Add("PostPlayerDraw", "GPhoneAirPods", function(ply)
        if !ply:GetNWBool("GPMusic") then return end
        if !ply:Alive() then return end
        
        render.SetBlend(1)
        
        if !IsValid(ply.EarBuds) then
            local mdl = ClientsideModel("models/player/items/engineer/engineer_earbuds.mdl", RENDERGROUP_OPAQUE)
            mdl:SetNoDraw(true)
            ply.EarBuds = mdl
        end
        
        local pos = Vector()
        local ang = Angle()
        
        local bone_id = ply:LookupBone("ValveBiped.Bip01_Head1")
        if !bone_id then return end
        
        pos,ang = ply:GetBonePosition(bone_id)
        
        pos = pos + ang:Forward() * earbudpos.x + ang:Right() * earbudpos.y + ang:Up() * earbudpos.z
        
        ang:RotateAroundAxis(ang:Up(), earbudang.y)
        ang:RotateAroundAxis(ang:Right(), earbudang.p)
        ang:RotateAroundAxis(ang:Forward(), earbudang.r)
        
        ply.EarBuds:SetRenderOrigin(pos)
        ply.EarBuds:SetRenderAngles(ang)
        
        render.EnableClipping(true)
        
        local normal = -ang:Forward()
        local origin = pos - normal * 0.5
        local distance = normal:Dot( origin )
        
        render.PushCustomClipPlane( normal, distance )
        
        ply.EarBuds:SetupBones()
        ply.EarBuds:DrawModel()
        ply.EarBuds:SetRenderOrigin()
        ply.EarBuds:SetRenderAngles()
        
        render.PopCustomClipPlane()
        
        render.EnableClipping(false)
    end)
end

hook.Add("InputMouseApply", "_GPhoneMouseInput", function( cmd, x, y, angle )
    local wep = LocalPlayer():GetActiveWeapon()
    if IsValid(wep) and wep:GetClass() == "gmod_gphone" and GPhone.CursorEnabled then
        local cv = GetConVar("gphone_sensitivity")
        local sens = cv and cv:GetFloat() or 4
        
        local inv = GPhone.Landscape
        local ychange = (inv and x or y) * sens * 0.2
        local xchange = (inv and -y or x) * sens * 0.2
        
        local x = math.Clamp(GPhone.CursorPos.x + xchange, -40, 1168)
        local y = math.Clamp(GPhone.CursorPos.y + ychange, -380, 2052)
        
        GPhone.CursorPos = {x = x, y = y}
        
        cmd:SetViewAngles( angle )
        
        return true
    end
end)

hook.Add("ShouldDrawLocalPlayer", "_GPhoneDrawSelfiePlayer", function(ply)
    local wep = LocalPlayer():GetActiveWeapon()
    if IsValid(wep) and wep:GetClass() == "gmod_gphone" and GPhone.SelfieEnabled() then
        cam.Start3D()
        cam.End3D()
        if GPSelfieRendering then return true end
    end
end)