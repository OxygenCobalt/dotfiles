local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local function new(args)
	local ret = wibox.widget {
		{
			{
	    		id = "cpu_lbl",
                markup = "vol",
                widget = wibox.widget.textbox
		    },
		    {
			    {
			    	id = "vol_bar",
			    	forced_width = dpi(100),
			    	color = beautiful.quark_bar_good,
			    	background_color = beautiful.quark_bar_bg,
			    	widget = wibox.widget.progressbar,
		            max_value = 100,
		            shape = gears.shape.octogon
			    },
			    top = dpi(6),
			    bottom = dpi(6),
			    layout = wibox.container.margin
			},
		    spacing = dpi(4),
		    layout = wibox.layout.fixed.horizontal
		},
        top = dpi(4),
        bottom = dpi(4),
        layout = wibox.container.margin		
    }

    local update = function(widget, stdout)
    	local now = args.get.parse(stdout)
    	local bar = widget:get_children_by_id("vol_bar")[1]

		bar:set_value(now["vol"])

		if now["vol"] <= 0 or now["muted"] then
			bar:set_color(beautiful.quark_bar_poor)
		elseif now["vol"] > 100 then
			-- Programs like pavucontrol allow the user to overamplify the volume.
			-- Reflect that in the volume bar if that's the case.
			bar:set_color(beautiful.quark_bar_critical)
		elseif now["vol"] > 70 then
			bar:set_color(beautiful.quark_bar_great)
		elseif now["vol"] > 30 then
			bar:set_color(beautiful.quark_bar_good)
		else
			bar:set_color(beautiful.quark_bar_okay)
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

	return {
		widget = ret,
		up = function()
			mutate_update(ret, args.up_cmd)
		end,
		down = function()
			mutate_update(ret, args.down_cmd)
		end,
		toggle = function()
			mutate_update(ret, args.toggle_cmd)
		end
	}
end

return new