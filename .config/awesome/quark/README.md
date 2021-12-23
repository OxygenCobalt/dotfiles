# quark

`quark` is my highly opinionated widget library for awesome that I created mostly for my use.
It prioritizes a flexible implementation and consistency at the cost of customization. 

## How to use

1. Add the following fields to your theme. These are used to color any progress bars used by the widget.

```lua
theme.bar_bg = "#XXXXXX"
theme.bar_great = "#XXXXXX"
theme.bar_good = "#XXXXXX"
theme.bar_okay = "#XXXXXX"
theme.bar_poor = "#XXXXXX"
theme.bar_critical = "#XXXXXX"
```

2. Instantiate the component you want by calling `quark.[COMPONENT]`. **All arguments shown for
the specific widget must be provided. If they are not, then unexpected behavior may occur.**

## Components

#### `quark.cpu` & `quark.mem`

These two widgets show the used CPU and RAM percentages respectively.
They are both instantiated with the following code:

```lua
local mywidget = quark.(cpu/mem) {
	open = "mytaskmanager"
}
```

Internally, these widgets grep `/proc/stat` and `/proc/meminfo` for information, so their
implementation cannot be customized.

#### `quark.pwr`

This widget shows the remaining battery. When clicked, it will open a popup showing more information
about the battery status. The widget is instantiated with the following code:

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

This widget shows a volume meter that can be controlled. This widget is instantiated with the following
code:

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
    open = "myaudiocontrol",
    icons = "/usr/share/icons/path/to/symbolic/icons"
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
- `icons` represents the icon directory to use for volume icons. The widget expects the following icons:
	- `audio-volume-high-symbolic.svg`
	- `audio-volume-medium-symbolic.svg`
	- `audio-volume-low-symbolic.svg`
	- `audio-volume-muted-symbolic.svg`