local awful = require("awful")
local wibox = require("wibox")
local util = require("quark.util")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local function new(args)
	local popup = util.more_popup("pwr_status", "pwr_time")

	local ret, t = awful.widget.watch(
	    args.get.cmd,
	    1,
	    function(widget, stdout)
	    	local now = args.get.parse(stdout)
	    	now["status"] = string.lower(now["status"] or "unknown")
	    	now["perc"] = now["perc"] or 0
	    	now["time"] = now["time"] or "00:00:00"

	        local color = ""

	        if now["status"] == "charging" then
	            color = beautiful.quark_bar_great
	        else
	            color = util.perc_color(now["perc"], true)
	        end

	        local prog = widget:get_children_by_id("pwr_prog")[1]
	        prog:set_value(now["perc"])
	        prog:set_color(color)

	        local popup_widget = popup:get_widget()
	        local status = popup_widget:get_children_by_id("pwr_status")[1]
	        local time = popup_widget:get_children_by_id("pwr_time")[1]

	        status:set_markup("battery is " .. now["status"] .. " (" .. now["perc"] .. "%)")
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
	            spacing = dpi(4),
	            layout = wibox.layout.fixed.horizontal
	        },
	        top = dpi(4),
	        bottom = dpi(4),
	        layout = wibox.container.margin
	    }
	)

	util.attach_popup(popup, ret)

	return ret
end

return new