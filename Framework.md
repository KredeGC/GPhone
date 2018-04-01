# GPhone modding documentation
The GPhone comes with a whole bunch of features that are readily available
for modders and scripters to utilize in creating apps and mods.
Anyone with knowledge of Derma will probably find the App structure familiar.

## The GPnl library
The GPnl library contains the default functions for creating panels for an App.
Currently the only function in the GPnl library is `GPnl.AddPanel(parent, type)`.
This will create a panel with the specified type. Currently there are 6 types of panels:
* `frame` is the most basic panel and has no default Paint function. This is the best panel to use if you want to customize it fully.
* `panel` is good for creating simple panels.
* `scroll` is used when creating scrollable objects.
* `button` has a default Paint function with specified text inside.
* `textentry` is mostly used instead of writing a bunch of code. Also has a few callback functions.
* `html` has a custom scroll function designed for HTML panels.

### Panel structure
A panel is basically a table of variables and functions.
This means that you can also store your own functions and variables if needed.
There are a few default functions that a panel has once created, these should not be overriden.
```lua
Panel.SetVisible( bool )      -- Whether the panel should be visible or not (chil panels won't be drawn)
bool = Panel.GetVisible()     -- Whether the panel is currently visible or not

Panel.SetPos( x, y )          -- Sets the x and y coordinates of the panel
x,y = Panel.GetPos()          -- Returns the x and y coordinates of the panel

Panel.SetWidth( w )           -- Sets the width of the panel
w = Panel.GetWidth()          -- Returns the width of the panel

Panel.SetHeight( h )          -- Sets the height of the panel
h = Panel.GetHeight()         -- Returns the height of the panel

Panel.SetSize( w, h )         -- Sets the width and height of the panel
w,h = Panel.GetSize()         -- Returns the width and height of the panel

Panel.Clear()                 -- Removes all children from the panel

parent = Panel.Getparent()    -- Returns the parent of the panel
child = Panel.GetChildren()   -- Returns all the children from the panel
```
There are also some functions that you can override:
```lua
Panel.Paint( x, y, w, h )     -- Function to draw on the panel (x and y are not needed unless you change the viewport)
Panel.OnClick()               -- Called when the user left-clicks on this panel
Panel.OnScroll( num )         -- Called when the user scrolls with his mouse (only works on scroll-type panels)

Panel.Hover()                 -- Called when the cursor moves over this panel
Panel.StopHover()             -- Called when the cursor moves out of this panel

Panel.Remove()                -- Removes this panel
```

### A simple APP using GPnl
Let's imagine the following code is placed in "gphone/gapps/testapp.lua".
The GPhone will automatically add it to the App-list once the map loads.

```lua
APP.Name        = "TestApp"                       -- The name of the App
APP.Author      = "TesterChester"                 -- The author's name
APP.Negative    = false                           -- Whether the App should use negative top-colors or not
APP.Fullscreen  = false                           -- Whether the App runs in fullscreen or not
APP.Icon        = "https://example.com/icon.png"  -- The icon. Can point to a local file or an online file
APP.Run = (function( frame, w, h ) -- Called when the App is first opened
	function frame.Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 200, 200, 200, 255 ) )
	end
	
	local button = GPnl.AddPanel( frame, "button" ) -- Creates a panel of "button" type
	button.SetPos( 0, 64 )
	button.SetSize( 64, 64 )
	function general.Paint( x, y, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, button.Color or Color( 255, 255, 255, 255 ) ) -- Paint the button using the color or white
	end
	function button.OnClick() -- When we click, change the Color property
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

This App obviously doesn't do that much, so the next sections will go into more detail on different features.

## The GPhone library
The GPhone library is primarily used to make it easier developers when creating Apps.
Listed below are a few useful functions you can use inside or outside an App.
```lua
GPhone.Vibrate()                                  -- Makes the phone physically vibrate

GPhone.SaveData( key, value )                     -- Save the data with the specific key
GPhone.GetData( key, def )                        -- Retrieve the data with the specific key or def if nothing was found

GPhone.RunApp( name )                             -- Run the app with the specific name
GPhone.StopApp( name )                            -- Stop the app with the specific name

GPhone.FocusApp( name )                           -- Focus the app with the specific name
GPhone.FocusHome()                                -- Focus the home screen

GPhone.InstallApp( name )                         -- Install the specific app
GPhone.UninstallApp( name )                       -- Uninstalls the app

GPhone.InputText( enter, change, cancel, text )   -- Start a text-input with enter, change and cancel functions
GPhone.CloseInput()                               -- Close the text-input (doesn't call the cancel function)
string = GPhone.GetInputText()                    -- Get the text from the text-input

GPhone.StartMusic( url )                          -- Start playing music from the URL
GPhone.StopMusic()                                -- Stop any playing music
GPhone.ToggleMusic( play )                        -- Pause or play music
GPhone.ChangeVolume( vol )                        -- Change the music volume (0-1)
table = GPhone.GetMusic()                         -- Returns a table containing data for the music

GPhone.DownloadImage( url, size, hack, css )      -- Downloads an image from the provided URL with size
GPhone.GetImage( url )                            -- Gets the downloaded image or a callback texture if not found
```