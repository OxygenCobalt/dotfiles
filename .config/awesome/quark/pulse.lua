local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")

local function new(args)
	local ret = wibox.widget {
		{
			{
		        {
		        	id = "vol_icon",
		        	image = args.icons .. "audio-volume-high-symbolic.svg",
	                resize = true,
	                widget = wibox.widget.imagebox,
	                valign = "center"
		        },
		        margins = 0,
		        layout = wibox.container.margin  
		    },
		    {
			    {
			    	id = "vol_bar",
			    	forced_height = 1,
			    	forced_width = 100,
			    	color = beautiful.bar_good,
			    	background_color = beautiful.bar_bg,
			    	widget = wibox.widget.progressbar,
		            max_value = 100,
		            shape = gears.shape.octogon
			    },
			    top = 6,
			    bottom = 6,
			    layout = wibox.container.margin
			},
		    spacing = 8,
		    layout = wibox.layout.fixed.horizontal
		},
        top = 4,
        bottom = 4,
        layout = wibox.container.margin		
    }

    local update = function(widget, stdout)
    	local now = args.get.parse(stdout)
    	local icon = widget:get_children_by_id("vol_icon")[1]
    	local bar = widget:get_children_by_id("vol_bar")[1]

		bar:set_value(now["vol"])

		if now["vol"] <= 0 or now["muted"] then
			bar:set_color(beautiful.bar_poor)
			icon.image = args.icons .. "audio-volume-muted-symbolic.svg"
		elseif now["vol"] > 70 then
			bar:set_color(beautiful.bar_great)
			icon.image = args.icons .. "audio-volume-high-symbolic.svg"
		elseif now["vol"] > 30 then
			bar:set_color(beautiful.bar_good)
			icon.image = args.icons .. "audio-volume-medium-symbolic.svg"
		else
			bar:set_color(beautiful.bar_okay)
			icon.image = args.icons .. "audio-volume-low-symbolic.svg"
		end
    end

    local mutate_update = function(widget, cmd)
    	awful.spawn.easy_async(
    		'bash -c "' .. cmd .. " && " .. args.get.cmd .. '"',
    		function(stdout, _, _, _)
    			update(ret, stdout)
    		end
    	)
    end

    awful.widget.watch(
    	args.get.cmd,
    	1,
    	function(widget, stdout)
    		update(ret, stdout)
    	end,
    	ret
    )

	ret:connect_signal(
	    "button::press",
	    function(_, _, _, button)
	        if button == 1 then
	            awful.spawn(args.open)
	        elseif button == 3 then
	        	mutate_update(ret, args.toggle_cmd)
	        elseif button == 4 then
	        	mutate_update(ret, args.up_cmd)
	        elseif button == 5 then
	        	mutate_update(ret, args.down_cmd)
	        end
	    end
	)

	return ret
end

return new