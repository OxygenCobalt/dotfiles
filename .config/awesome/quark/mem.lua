local awful = require("awful")
local wibox = require("wibox")
local util = require("quark.util")

local function new(args)
	local ret, t = awful.widget.watch(
	    'bash -c "grep -oP \\"(^MemTotal: *\\K[0-9]+)|(^MemFree: *\\K[0-9]+)\\" /proc/meminfo | head -n 2"',
	    1,
	    function(widget, stdout)
	        local i = 1
	        local ram = {}

	        for n in string.gmatch(stdout, "%d+") do
	            if i == 1 then
	                ram["total"] = tonumber(n)
	            elseif i == 2 then
	                ram["free"] = tonumber(n)
	            else
	                break
	            end

	            i = i + 1
	        end

	        ram["used"] = ram["total"] - ram["free"]
	        ram["perc"] = util.percent(ram["used"] / ram["total"])

	        local prog = widget:get_children_by_id("mem_prog")[1]
	        prog:set_value(ram["perc"])
	        prog:set_color(util.perc_color(ram["perc"], false))
	    end,
	    wibox.widget {
	        {
	            {
	                id = "mem_lbl",
	                markup = "mem",
	                widget = wibox.widget.textbox
	            },
	            util.percbar {
	                id = "mem_prog"
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
	            awful.spawn("lxtask")
	        end
	    end
	)

	return ret
end

return new