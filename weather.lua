APP.Name        = "TestApp"                       -- The name of the App
APP.Author      = "TesterChester"                 -- The author's name
APP.Negative    = false                           -- Whether the App should use negative top-colors or not
APP.Icon = "https://raw.githubusercontent.com/KredeGC/GPhone/master/images/weather.png"  -- The icon. Can point to a local file or an online file
function APP.Run( frame, w, h, ratio )            -- Called when the App is first opened (frame, width, height, aspect ratio)
    function frame:Paint( x, y, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 200, 200, 200, 255 ) )
    end
    
    local button = GPnl.AddPanel( frame, "panel" ) -- Creates a panel of type "panel"
    button:SetPos( 32*ratio, 32*ratio )            -- By multiplying with "ratio" we can support all resolutions
    button:SetSize( w - 64*ratio, 64*ratio )
    button.Color = Color( 0, 255, 0 ) -- Green color
    function button:Paint( x, y, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, button.Color ) -- Paint the button using the color
    end
    function button:OnClick() -- Called when we click
        button.Color = Color( 255, 0, 0 ) -- Red color
    end
end
function APP.Think( frame, w, h, ratio ) -- Called every time the SWEP.Think function is called
    print("thonk")
end
function APP.Stop( frame ) -- Called when the App is closed
    print("closed")
end
