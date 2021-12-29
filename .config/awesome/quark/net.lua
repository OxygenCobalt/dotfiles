local awful = require("awful")
local wibox = require("wibox")
local util = require("quark.util")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local math = math

local function new(args)
	local device_dir = "/sys/class/net/" .. args.device .. "/"

	local last = {
		t = 0,
		r = 0
	}

	local popup = util.more_popup("net_status", "net_load")

	local ret, t = awful.widget.watch(
	    'cat ' 
	    .. device_dir .. 'statistics/tx_bytes' .. ' ' 
	    .. device_dir .. 'statistics/rx_bytes' .. ' ' 
	    .. device_dir .. 'operstate',
	    1,
	    function(widget, stdout)
	    	local i = 1

			local now = {}

	    	for w in string.gmatch(stdout, "%w+") do
	    		if i == 1 then
	    			now.t = tonumber(w)
	    		elseif i == 2 then
	    			now.r = tonumber(w)
	    		elseif i == 3 then
	    			now.state = w
	    		else
	    			break
	    		end

	    		i = i + 1
	    	end

	    	if last.t == 0 and last.r == 0 then
	    		last.t = now.t
	    		last.r = now.r
	    	end

	    	now.up = (now.t - last.t) / args.unit.denom
	    	now.down = (now.r - last.r) / args.unit.denom

	    	local popup_widget = popup:get_widget()
	        local up_lbl = popup_widget:get_children_by_id("net_status")[1]
	        up_lbl:set_markup(args.device .. ": " .. now.state)
	        
	        local down_lbl = popup_widget:get_children_by_id("net_load")[1]
	        down_lbl:set_markup(
	        	"up: " .. string.format("%.1f", now.up) .. " " 
	        	.. args.unit.name .. " down: " .. string.format("%.1f", now.down)
	        	.. " " .. args.unit.name
	        )

	    	now.up_perc = util.percent(now.up / args.up_max)
	    	now.down_perc = util.percent(now.down / args.down_max)

	    	local up_prog = widget:get_children_by_id("net_up")[1]
	    	up_prog:set_color(util.perc_color(now.up_perc))
	    	up_prog:set_value(now.up_perc)

	    	local down_prog = widget:get_children_by_id("net_down")[1]
	    	down_prog:set_color(util.perc_color(now.down_perc))
	    	down_prog:set_value(now.down_perc)

	    	last.t = now.t
	    	last.r = now.r
	    end,
	    wibox.widget {
            {
                id = "net_lbl",
                markup = "net",
                widget = wibox.widget.textbox
            },
            {
	            util.percbar {
	                id = "net_up"
	            },
	            util.percbar {
	            	id = "net_down"
	            },
	            spacing = dpi(2),
	            layout = wibox.layout.fixed.horizontal
            },
            spacing = dpi(4),
            layout = wibox.layout.fixed.horizontal
	    }
	)

	util.attach_popup(popup, ret)

	return ret
end

return new