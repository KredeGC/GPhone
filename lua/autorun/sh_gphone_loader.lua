local files = file.Find("gphone/*.lua", "LUA")
for _,v in pairs(files) do
	if string.sub(v, 0, 3) == "sv_" then
		include("gphone/"..v)
	elseif string.sub(v, 0, 3) == "cl_" then
		if SERVER then
			AddCSLuaFile("gphone/"..v)
		else
			include("gphone/"..v)
		end
	else
		if SERVER then
			AddCSLuaFile("gphone/"..v)
		end
		include("gphone/"..v)
	end
end