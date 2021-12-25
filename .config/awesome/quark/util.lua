local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local math = math

local function percent(n)
    return math.min(tonumber(math.ceil(n * 100)), 100)
end

local function percbar(args)
    local defs = {
        max_value = 100,
        forced_width = dpi(8),
        forced_height = dpi(8),
        color = beautiful.bg_focus,
        background_color = beautiful.quark_bar_bg,
        widget = wibox.widget.progressbar,
        shape = gears.shape.octogon
    }

    return {
        gears.table.join(defs, args),
        forced_width = dpi(8),
        direction = 'east',
        layout = wibox.container.rotate,
    }
end

local function perc_color(perc, reverse)
    local color = ""
    local colors = { 
        beautiful.quark_bar_critical, 
        beautiful.quark_bar_poor, 
        beautiful.quark_bar_okay, 
        beautiful.quark_bar_good 
    }

    if reverse then
    	colors = { 
            beautiful.quark_bar_good, 
            beautiful.quark_bar_okay, 
            beautiful.quark_bar_poor, 
            beautiful.quark_bar_critical
        }
    end

    if perc > 75 then
        color = colors[1]
    elseif perc > 50 then
        color = colors[2]
    elseif perc > 25 then
        color = colors[3]
    else
        color = colors[4]
    end

    return color
end

local function new_popup(widget)
    return awful.popup {
        ontop = true,
        visible = false,
        widget = widget,
        border_color = beautiful.border_normal,
        border_width = dpi(2)
    }
end

local function more_popup(id_top, id_bottom)
    return new_popup {
        {
            layout = wibox.layout.fixed.vertical,
            spacing = dpi(8),
            {
                id = id_top,
                widget = wibox.widget.textbox
            },
            {
                id = id_bottom,
                widget = wibox.widget.textbox
            },
        },
        margins = dpi(8),
        widget  = wibox.container.margin
    }
end

local function attach_popup(popup, to)
    local grabber = nil

	grabber = function(_, key, event)
		if event == "press" and key == "Escape" then
			popup.visible = false
			awful.keygrabber.stop(grabber)
		end
	end

    to:connect_signal(
        "button::press",
        function(_, _, _, button)
            if button == 1 then
                if popup.visible then
                    popup.visible = not popup.visible
                    awful.keygrabber.stop(grabber)
                else
                    popup:move_next_to(mouse.current_widget_geometry)
                    awful.keygrabber.run(grabber)
                end
            end
        end
    )
end

return { 
    percent = percent, 
    percbar = percbar, 
    perc_color = perc_color, 
    new_popup = new_popup, 
    more_popup = more_popup, 
    attach_popup = attach_popup
}
