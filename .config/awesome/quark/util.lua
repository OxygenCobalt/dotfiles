local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")
local math = math

local function percent(n)
    return tonumber(math.ceil(n * 100))
end

local function percbar(args)
    local defs = {
        max_value = 100,
        forced_width = 8,
        forced_height = 8,
        color = beautiful.bg_focus,
        background_color = beautiful.bar_bg,
        widget = wibox.widget.progressbar,
        shape = gears.shape.octogon
    }

    return {
        gears.table.join(defs, args),
        forced_width = 8,
        direction = 'east',
        layout = wibox.container.rotate,
    }
end

local function perc_color(perc, reverse)
    local color = ""
    local colors = { beautiful.bar_critical, beautiful.bar_poor, beautiful.bar_okay, beautiful.bar_good }

    if reverse then
    	colors = { beautiful.bar_good, beautiful.bar_okay, beautiful.bar_poor, beautiful.bar_critical }
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

return { percent = percent, percbar = percbar, perc_color = perc_color }