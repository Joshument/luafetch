local config = {}

-- The colour of the labels
config.primaryColor = "cyan"
-- The color of the information
config.secondaryColor = "white"

--[[ 
    The order of the labels to display

    Supported labels: user, os, architecture, host, kernel, cpu, gpu, shell, memory, lua
    Other labels will be displayed raw
    For raw labels, you may use the Lunacolours formatting. Check https://github.com/Rosettea/Lunacolors/blob/master/init.lua for list of options.
]]--
config.order = {
    "user",
    "{white}--------------------",
    "os",
    "architecture",
    "host",
    "kernel",
    "cpu",
    "gpu",
    "shell",
    "memory",
    "lua"
}

-- Values shown here will be displayed as their raw return value, rather than having things appended to it
config.showRaw = {
    ["user"] = true,
}

-- Use this table if you wish to change the way that a certain value is displayed
config.prettyOrder = {
    ["user"] = "User",
    ["os"] = "OS",
    ["architecture"] = "Architecture",
    ["host"] = "Host",
    ["kernel"] = "Kernel",
    ["cpu"] = "CPU",
    ["gpu"] = "GPU",
    ["shell"] = "Shell",
    ["memory"] = "Memory",
    ["lua"] = "Lua Version",
}


-- Seperator between the label and the value of an item
config.seperator = ": "

return config