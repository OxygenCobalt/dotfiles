local awful = require("awful")
local wibox = require("wibox")
local util = require("quark.util")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local function new(args)
	local ret, t = awful.widget.watch(
	    'grep "cpu " /proc/stat',
	    1,
	    function(widget, stdout)
	        local i = 1
	        local stats = {}

	        for n in string.gmatch(stdout, "%d+") do
	            if i < 5 then
	                table.insert(stats, n)
	            else
	            	break
	            end

	            i = i + 1
	        end

	        local perc = util.percent((stats[1] + stats[3]) / (stats[1] + stats[3] + stats[4]))
	        local prog = widget:get_children_by_id("cpu_prog")[1]
	        prog:set_value(perc)
	        prog:set_color(util.perc_color(perc, false))
	    end,
	    wibox.widget {
	        {
	            {
	                id = "cpu_lbl",
	                markup = "cpu",
	                widget = wibox.widget.textbox
	            },
	            util.percbar {
	                id = "cpu_prog"
	            },
	            spacing = dpi(4),
	            layout = wibox.layout.fixed.horizontal
	        },
	        top = dpi(4),
	        bottom = dpi(4),
	        layout = wibox.container.margin
	    }
	)

	ret:connect_signal(
	    "button::press",
	    function(_, _, _, button)
	        if button == 1 then
	            awful.spawn(args.open)
	        end
	    end
	)

	return ret
end

return new