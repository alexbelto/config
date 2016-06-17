-- Standard awesome library
local awful     =   require("awful")
local gears     =   require("gears")
local wibox     =   require("wibox")
awful.rules     =   require("awful.rules")
require("awful.autofocus")
local beautiful =   require("beautiful")
local naughty   =   require("naughty")
local menubar   =   require("menubar")
local lain      =   require("lain")
local drop      =   require("scratchdrop")

-- {{{ Error handling
 --Check if awesome encountered an error during startup and fell back to
 --another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset     =   naughty.config.presets.critical,
                     title      =   "You fucked up, there were errors during startup!",
                     text       =   awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset     = naughty.config.presets.critical,
                         title      = "You fucked up, an error happened!",
                         text       = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("/home/alexbelto/.config/awesome/themes/musicMary/theme.lua")

-- This is used later as the default terminal and editor to run.
browser     =   "firefox"
terminal    =   "urxvt"
gimp        =   "gimp"
music       =   "spotify"
editor      =   os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey  =   "Mod4"
altkey  =   "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    --awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.top,
    --awful.layout.suit.fair,
    --awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    --awful.layout.suit.max,
    --awful.layout.suit.max.fullscreen,
    --awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ "Main", 2, 3, 4, 5, "Email", "Calendar", "Files", "Web" }, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox

markup = lain.util.markup

-- Battery
baticon = wibox.widget.imagebox(beautiful.widget_batt)
batwidget = lain.widgets.bat({
    settings = function()
	if bat_now.perc == "N/A" then
    	    perc = "AC "
	else
	    perc = bat_now.perc .. "% "
	end
	widget:set_text( perc)
    end
})

-- Create a textclock widget
mytextclock = awful.widget.textclock(markup("#7b0d8f", "%A %d %B ") .. markup("#b08101", " %H:%M "))

-- Calendar
lain.widgets.calendar:attach(mytextclock, { font_size = 10 })

-- Memory
memicon = wibox.widget.imagebox(beautiful.widget_mem)
memwidget = lain.widgets.mem({
    settings = function()
	widget:set_markup(markup("#7b0d8f", mem_now.perc .. "% "))
    end
})

-- CPU
cpuicon = wibox.widget.imagebox()
cpuicon:set_image(beautiful.widget_cpu)
cpuwidget = lain.widgets.cpu({
    settings = function()
	widget:set_markup(markup("#7b0d8f", cpu_now.usage .. "% "))
    end
})
-- / fs
fsicon = wibox.widget.imagebox(beautiful.widget_fs)
fswidget = lain.widgets.fs({
    settings = function()
	widget:set_markup(markup("#7b0d8f", fs_now.used .. "% "))
    end
})

-- Net Up
netupicon = wibox.widget.imagebox(beautiful.widget_netup)
netupwidget = lain.widgets.net({
    settings = function()
	widget:set_markup(markup("#7b0d8f", net_now.sent)) 
    end
})

-- Net Down
netdownicon = wibox.widget.imagebox(beautiful.widget_netdown)
netdownwidget = lain.widgets.net({
    settings = function()
	widget:set_markup(markup("#7b0d8f", net_now.received))
    end
})

-- Coretemp
tempicon = wibox.widget.imagebox(beautiful.widget_temp)
tempwidget = lain.widgets.temp({
    settings = function()
	widget:set_markup(markup("#7b0d8f", coretemp_now .. "°C "))
    end
})

-- ALSA volume
volicon = wibox.widget.imagebox(beautiful.widget_vol)
volumewidget = lain.widgets.alsa({
    settings = function()
	if volume_now.status == "off" then
	    volicon:set_image(beautiful.widget_vol_mute)
	elseif tonumber(volume_now.level) == 0 then
	    volicon:set_image(beautiful.widget_vol_no)
	elseif tonumber(volume_now.level) <= 50 then
	    volicon:set_image(beautiful.widget_vol_low)
	else
	    volicon:set_image(beautiful.widget_vol)
	end
	widget:set_text(" " .. volume_now.level .. "% ")
    end
})

-- Create a wibox for each screen and add it
mytopwibox = {}
mybottomwibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1,        awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3,        awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4,        function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5,        function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1,       function (c)
                                                    if c == client.focus then
                                                        c.minimized = true
                                                    else
                                                        -- Without this, the following
                                                        -- :isvisible() makes no sense
                                                        c.minimized = false
                                                        if not c:isvisible() then
                                                            awful.tag.viewonly(c:tags()[1])
                                                        end
                                                        -- This will also un-minimize
                                                        -- the client, if needed
                                                        client.focus = c
                                                        c:raise()
                                                    end
                                                end),
                     awful.button({ }, 3,       function ()
                                                    if instance then
                                                        instance:hide()
                                                        instance = nil
                                                    else
                                                        instance = awful.menu.clients({
                                                            theme = { width = 250 }
                                                        })
                                                    end
                                                end),
                     awful.button({ }, 4,       function ()
                                                    awful.client.focus.byidx(1)
                                                    if client.focus then client.focus:raise() end
                                                end),
                     awful.button({ }, 5,       function ()
                                                    awful.client.focus.byidx(-1)
                                                    if client.focus then client.focus:raise() end
                                                end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s]        = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s]       = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mytopwibox[s]       = awful.wibox({ position = "top",       screen = s })
    mybottomwibox[s]    = awful.wibox({ position = "bottom",    screen = s })
    
    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
        left_layout         :   add(mytaglist[s]) 
        left_layout         :   add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
        right_layout        :   add(fsicon)
        right_layout        :   add(fswidget)
        right_layout        :   add(cpuicon)
        right_layout        :   add(cpuwidget)
        right_layout        :   add(memicon) 
        right_layout        :   add(memwidget)
        right_layout        :   add(netupicon)
        right_layout        :   add(netupwidget)
        right_layout        :   add(netdownicon)
        right_layout        :   add(netdownwidget) 
        right_layout        :   add(volicon)
        right_layout        :   add(volumewidget)
        right_layout        :   add(baticon)
        right_layout        :   add(batwidget)

    -- Widgets that are aligned to the bottom right
    local bottomright_layout = wibox.layout.fixed.horizontal()
        bottomright_layout  :   add(mytextclock) 
   
    -- Widgets that are aligned to the bottom left
    local bottomleft_layout = wibox.layout.fixed.horizontal()
     
    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
        layout              :   set_left(left_layout)
        layout              :   set_right(right_layout)

    local bottomlayout = wibox.layout.align.horizontal()
        bottomlayout        :   set_left(bottomleft_layout) 
        bottomlayout        :   set_middle(mytasklist[s])
        bottomlayout        :   set_right(bottomright_layout)

    mytopwibox[s]:set_widget(layout)
    mybottomwibox[s]:set_widget(bottomlayout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({              }, 3,           function () mymainmenu:toggle() end),
    awful.button({              }, 4,           awful.tag.viewnext),
    awful.button({              }, 5,           awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,         }, "h",         awful.tag.viewprev       ),
    awful.key({ modkey,         }, "l",         awful.tag.viewnext       ),
    awful.key({ modkey,         }, "Escape",    awful.tag.history.restore),

    awful.key({ modkey,         }, "j",         function ()
                                                    awful.client.focus.byidx( 1)
                                                    if client.focus then client.focus:raise() end
                                                end),
    awful.key({ modkey,         }, "k",         function ()
                                                    awful.client.focus.byidx(-1)
                                                    if client.focus then client.focus:raise() end
                                                end),

    -- Layout manipulation
    awful.key({ modkey, "Shift" }, "j",         function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift" }, "k",         function () awful.client.swap.byidx( -1)    end),
    --awful.key({ modkey, "Control" }, "j",     function () awful.screen.focus_relative( 1) end),
    --awful.key({ modkey, "Control" }, "k",     function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,         }, "u",         awful.client.urgent.jumpto),
    awful.key({ modkey,         }, "Tab",       function ()
                                                    awful.client.focus.history.previous()
                                                    if client.focus then
                                                    client.focus:raise()
                                                    end
                                                end),

    -- Standard program
    awful.key({ modkey,             }, "Return",    function () awful.util.spawn(terminal) end),
    awful.key({ modkey,             }, "i",         function () awful.util.spawn(gimp) end),
    awful.key({ modkey,             }, "m",         function () awful.util.spawn(music) end), 
    awful.key({ modkey,		        }, "w",         function () awful.util.spawn(browser) end),
    awful.key({ modkey, "Control"   }, "r",         awesome.restart),
    awful.key({ modkey, "Control"   }, "q",         awesome.quit),

    awful.key({ modkey, "Shift"     }, "l",         function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey, "Shift"     }, "h",         function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey,             }, "space",     function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"     }, "space",     function () awful.layout.inc(layouts, -1) end),

    --awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey              }, "r",         function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey              }, "x",         function ()
                                                        awful.prompt.run({ prompt = "Run Lua code: " },
                                                        mypromptbox[mouse.screen].widget,
                                                        awful.util.eval, nil,
                                                        awful.util.getdir("cache") .. "/history_eval")
                                                    end),
    -- Menubar
    awful.key({ modkey              }, "p",         function() menubar.show() end),

    -- Spotify control
    awful.key({ modkey, "Control"   }, "space",     function ()
		                                                os.execute(string.format("playerctl play-pause"))
	                                                end),
    awful.key({ modkey, "Control"   }, "Left",      function  ()
                                                        os.execute(string.format("playerctl previous"))
	                                                end),
    awful.key({ modkey, "Control"   }, "Right",     function ()
		                                                os.execute(string.format("playerctl next"))
	                                                end),
    -- Brightness controls
    awful.key({ modkey }, "XF86MonBrightnessDown",  function ()
	                                                    os.execute(string.format("xbacklight -dec 5"))
	                                                end),
    awful.key({ modkey }, "XF86MonBrightnessUp",    function ()
	                                                    os.execute(string.format("xbacklight -inc 5"))
	                                                end),
    -- ALSA volume control
    awful.key({ modkey }, "XF86AudioRaiseVolume",   function ()
	                                                    os.execute(string.format("amixer set Master 1%%+", volumewidget.channel))
	                                                    volumewidget.update()
	                                                end),
    awful.key({ modkey }, "XF86AudioLowerVolume",   function ()
	                                                    os.execute(string.format("amixer set Master 1%%-", volumewidget.channel))
	                                                    volumewidget.update()
	                                                end),
    awful.key({ modkey }, "XF86AudioMute",          function ()
	                                                    os.execute(string.format("amixer set %s toggle", volumewidget.channel))
	                                                    volumewidget.update()
	                                                end)
)
clientkeys = awful.util.table.join( 
    awful.key({ modkey,             }, "f",         function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Control"   }, "c",         function (c) c:kill()                         end),
    awful.key({ modkey, "Control"   }, "space",     awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control"   }, "Return",    function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,             }, "o",         awful.client.movetoscreen                        ),
    awful.key({ modkey,             }, "t",         function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,             }, "n",         function (c)
                                                        -- The client currently has the input focus, so it cannot be
                                                         -- minimized, since minimized clients can't have the focus.
                                                        c.minimized = true
                                                    end),
    awful.key({ modkey, altkey      }, "m",         function (c)
                                                        c.maximized_horizontal = not c.maximized_horizontal
                                                        c.maximized_vertical   = not c.maximized_vertical
                                                    end)
)
-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey          }, "#" .. i + 9,
                                                    function ()
                                                        local screen = mouse.screen
                                                        local tag = awful.tag.gettags(screen)[i]
                                                        if tag then
                                                            awful.tag.viewonly(tag)
                                                        end
                                                    end),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                                                    function ()
                                                        local screen = mouse.screen
                                                        local tag = awful.tag.gettags(screen)[i]
                                                        if tag then
                                                            awful.tag.viewtoggle(tag)
                                                        end
                                                    end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                                                    function ()
                                                        if client.focus then
                                                            local tag = awful.tag.gettags(client.focus.screen)[i]
                                                            if tag then
                                                                awful.client.movetotag(tag)
                                                            end
                                                        end
                                                    end),
        -- Toggle tag.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                                                    function ()
                                                        if client.focus then
                                                            local tag = awful.tag.gettags(client.focus.screen)[i]
                                                            if tag then
                                                                awful.client.toggletag(tag)
                                                            end
                                                        end
                                                    end))
end

clientbuttons = awful.util.table.join(
    awful.button({                  }, 1,           function (c) client.focus = c; c:raise() end),
    awful.button({ modkey           }, 1,           awful.mouse.client.move),
    awful.button({ modkey           }, 3,           awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
            properties = {  border_width        = beautiful.border_width,
                            border_color        = beautiful.border_normal,
                            focus               = awful.client.focus.filter,
		                    size_hints_honor    = false,
		                    raise               = true,
                            keys                = clientkeys,
                            buttons             = clientbuttons } },
     { rule = { class = "Spotify" },
            properties = {  tag                 = tags[1][7] }},
     { rule = { class = "Firefox" },
            properties = {  tag                 = tags[1][9] }},
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
