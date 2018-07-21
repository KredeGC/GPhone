local path = "gphone_remade"
local files = file.Find(path.."/*.lua", "LUA")
for _,v in pairs(files) do
	if string.StartWith(v, "sv_") then
		if SERVER then
			include(path.."/"..v)
		end
	else
		AddCSLuaFile(path.."/"..v)
		if CLIENT or !string.StartWith(v, "cl_") then
			include(path.."/"..v)
		end
	end
end