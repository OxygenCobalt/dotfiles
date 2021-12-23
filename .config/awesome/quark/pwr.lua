local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local util = require("quark.util")

local function new(args)
	local popup = awful.popup {
		ontop = true,
		visible = false,
		widget = {
			{
				layout = wibox.layout.fixed.vertical,
				spacing = 8,
				{
					id = "pwr_status",
					widget = wibox.widget.textbox
				},
				{
					id = "pwr_time",
					widget = wibox.widget.textbox
				},
			},
			margins = 8,
			widget  = wibox.container.margin,
		},
		border_color = beautiful.border_normal,
		border_width = 2
	}

	local ret, t = awful.widget.watch(
	    args.get.cmd,
	    1,
	    function(widget, stdout)
	    	local now = args.get.parse(stdout)
	    	now["status"] = string.lower(now["status"] or "unknown")
	    	now["perc"] = now["perc"] or 0
	    	now["time"] = now["time"] or "unknown time"

	        local color = ""

	        if now["status"] == "charging" then
	            color = beautiful.bar_great
	        else
	            color = util.perc_color(now["perc"], true)
	        end

	        local prog = widget:get_children_by_id("pwr_prog")[1]
	        prog:set_value(now["perc"])
	        prog:set_color(color)

	        local popup_widget = popup:get_widget()
	        local status = popup_widget:get_children_by_id("pwr_status")[1]
	        local time = popup_widget:get_children_by_id("pwr_time")[1]

	        status:set_markup("Battery is " .. now["status"] .. " (" .. now["perc"] .. "%)")
	        time:set_markup((now["time"]) .. " remaining")
	    end,
	    wibox.widget {
	        {
	            {
	                id = "lbl_prog",
	                markup = "pwr",
	                widget = wibox.widget.textbox
	            },
	            util.percbar {
	                id = "pwr_prog"
	            },
	            spacing = 8,
	            layout = wibox.layout.fixed.horizontal
	        },
	        top = 4,
	        bottom = 4,
	        layout = wibox.container.margin
	    }
	)

	ret:connect_signal(
		"button::press",
		function(_, _, _, button)
			if button == 1 then
				if popup.visible then
					popup.visible = not popup.visible
				else
					popup:move_next_to(mouse.current_widget_geometry)
				end
			end
		end
	)

	return ret
end

return new