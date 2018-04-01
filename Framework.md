# GPhone modding documentation
The GPhone comes with a whole bunch of features that are readily available
for modders and scripters to utilize in creating apps and mods.The framework consists of the APP-framework and the GPhone library.
It is entirely possible to create and App without using the GPhone library,
but the library has some small features that make a few things easier.

## A simple APP
Let's imagine the following code is placed in "gphone/gapps/testapp.lua".
The GPhone addon will automatically add it to the App list once the map loads.
Anyone who has worked with Derma will find that this closely resembles it.

```lua
APP.Name		= "TestApp"							-- The name of the App
APP.Author		= "TesterChester"					-- The author's name
APP.Negative	= false								-- Whether the App should use negative top-colors or not
APP.Fullscreen	= false								-- Whether the App runs in fullscreen or not
APP.Icon		= "https://example.com/icon.png"	-- The icon. Can point to a local file or an online file
APP.Run = (function( frame, w, h ) -- Called when the App is first opened
	function frame.Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 200, 200, 200, 255 ) )
	end
	
	local button = GPnl.AddPanel( frame, "button" )
	button.SetPos( 0, 64 )
	button.SetSize( 64, 64 )
	function general.Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, button.Color or Color( 255, 255, 255, 255 ) )
	end
	function button.OnClick()
		button.Color = Color( 255, 0, 0, 255 )
	end
end)
APP.Think = (function( frame, w, h ) -- Called every time the SWEP.Think function is called
	print("thonk")
end)
APP.Stop = (function( frame ) -- Called when the App is closed
	print("closed")
end)
```

This App obviously doesn't do that much.