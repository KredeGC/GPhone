-- APP.Name = "GMail"
APP.Icon = "https://raw.githubusercontent.com/KredeGC/GPhone/master/images/gmail.png"
function APP.Run( frame, w, h )
	function frame:Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 200, 200, 255 ) )
	end
end