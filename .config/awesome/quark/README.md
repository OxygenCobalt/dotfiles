# quark

`quark` is my highly opinionated widget library for awesomewm that I created mostly for my use.
It prioritizes a flexible implementation and consistency at the cost of customization. 

## How to use

1. Add the following fields to your theme. Some can be omitted if you are not using the specific widget.

```lua
-- all widgets except exit
theme.quark_bar_bg = "#404040"
theme.quark_bar_great = "#00ccff"
theme.quark_bar_good = "#0099cc"
theme.quark_bar_okay = "#006699"
theme.quark_bar_poor = "#6666cc"
theme.quark_bar_critical = "#9999ff"

-- exit widget
theme.quark_exit_icon = chrome_path .. "application-exit-symbolic.svg"
theme.quark_lock_icon = chrome_path .. "system-lock-screen-symbolic.svg"
theme.quark_logout_icon = chrome_path .. "system-log-out-symbolic.svg"
theme.quark_suspend_icon = chrome_path .. "system-suspend-symbolic.svg"
theme.quark_reboot_icon = chrome_path .. "system-reboot-symbolic.svg"
theme.quark_shutdown_icon = chrome_path .. "system-shutdown-symbolic.svg"
```

2. Instantiate the component you want by calling `quark.[COMPONENT]`. **All arguments shown for
the specific widget must be provided. If not, unexpected behavior may occur.**

## Components

#### `quark.cpu` & `quark.mem`

These two widgets show the used CPU and RAM percentages respectively.

```lua
local mywidget = quark.(cpu/mem) {
	open = "mytaskmanager"
}
```

- `open` is the program to open when the meter is clicked.

Internally, these widgets grep `/proc/stat` and `/proc/meminfo` for information, so their
implementation cannot be customized.

#### `quark.net`

This widget shows upload/download load statistics.

```lua
local mynet = quark.net { 
    device = "mywlan",
    unit = {
        name = "kb",
        denom = 1024
    },
    up_max = 32,
    down_max = 512
}
```

- `device` is the device to monitor for usage.
- `unit` is the units to display for network usage.
	- `name` is the name of the unit, such as `kb`.
	- `denom` is the denomination of this unit, such as `1024`
- `up_max` is the minimum upload speed, in `unit`, that will result in a full bar in the widget.
- `down_max` is the minimum download speed, in `unit`, that will result in a full bar in the widgets.

#### `quark.pwr`

This widget shows the remaining battery. When clicked, it will open a popup showing more information
about the battery status.

```lua
local mypwr = quark.pwr {
	get = {
        cmd = 'mybatterycommand',
        parse = function(stdout)
        	-- Parse output into a table
        end
    }
}
```

- `get.cmd` represents the command to be run (Note: The command is not ran in a shell)
- `get.parse` represents a parsing function to be ran with the stdout of `get.cmd`.
It should return a table with the following values. These should be `nil` if they are not available.
	- `status` The current battery status, as a string.
	- `perc` The current battery percentage, as a number.
	- `time` Represents the time until the battery is dead *or* fully charged, as a string.

#### `quark.pulse`

This widget shows a volume meter that can be controlled.

```lua
local mypulse = quark.pulse {
    get = {
        cmd = "myaudiocontrol --get",
        parse = function(stdout)        
        	-- Parse output into a table
        end
    },
    up_cmd = "myaudiocontrol -i",
    down_cmd = "myaudiocontrol -d",
    toggle_cmd = "myaudiocontrol -t",
    open = "myaudiocontrol"
}
```

- `get.cmd` represents the command to be run (Note: The command is not ran in a shell)
- `get.parse` represents a parsing function to be ran with the stdout of `get.cmd`.
It should return a table with the following values. These should be `nil` if they are not available.
	- `vol` The current volume, as a number. This can also be a percentage.
	- `muted` Whether or not the audio is muted, as a boolean.
- `up_cmd` represents the command ran when the widget is scrolled up. This is commonly used to increment/decrement audio.
- `down_cmd` represents the command ran when the widget is scrolled down. This is commonly used to increment/decrement audio.
- `toggle_cmd` represents the command ran when the widget is right clicked. This is commonly used to toggle muting.
- `open` represents the program to open when the widget is clicked.
- This function returns a table with the following:
    - `widget` is a volume widget that can be added to a layout
    - `up` is a function that will run the `up_cmd` command and update the widget accordingly
    - `down` is a function that will run the `down_cmd` command and update the widget accordingly
    - `toggle` is a function that will run the `toggle_cmd` command and update the widget accordingly

#### `quark.exit`

This function returns a menu containing lock, logout, suspend, reboot, and shutdown options.

```lua
local myexit = quark.exit {
    on_lock = function() awful.spawn("mydm --lock") end,
    on_logout = function() awesome.quit() end,
    on_suspend = function() awful.spawn("systemctl suspend") end,
    on_reboot = function() awful.spawn("reboot") end,
    on_shutdown = function() awful.spawn("shutdown now") end
}
```

- `on_lock`, `on_logout`, `on_suspend`, `on_reboot`, and `on_shutdown` are called when
their respective option is selected.
