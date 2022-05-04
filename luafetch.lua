local config = require("config")
local Lunacolors = require("Lunacolors")

local function fileToString(fileStr)
    local file = io.open(fileStr)
    if file then
        file:close()
        io.input(fileStr)
        return io.read("*a"):sub(1, -2)
    else
        return nil
    end
end

-- Function calls for specific settings
local configStrings = {}

configStrings["user"] = function()
    local username = io.popen("whoami"):read("*a"):sub(1, -2)

    local hostname = fileToString("/proc/sys/kernel/hostname")
    if not hostname then
        hostname = "unknown"
    end

    return Lunacolors.format(string.format("{bold}{%s}%s", config.primaryColor, username)) 
        .. Lunacolors.format(string.format("{%s}@", config.secondaryColor))
        .. Lunacolors.format(string.format("{bold}{%s}%s", config.primaryColor, hostname))
end

configStrings["os"] = function()
    local isDebian = io.popen("(ls /etc/*-release && echo yes) || echo no"):read("*a"):find("no")

    if isDebian then
        -- If both checks fail, then the OS is unknown
        local isLinux = io.popen("(ls /etc/*_version && echo yes) || echo no"):read("*a"):find("no")

        if not isLinux then
            return "unknown"
        end

        return io.popen("cat /etc/*_version | grep \'Description\'")
            :read("*a"):sub(1, -2)
            :gsub('Description:.', '')
            :sub(1, -2)
    else
        -- -3 gets rid of newline and trailing quotation mark
        return io.popen("cat /etc/*-release | grep \'PRETTY_NAME\'")
            :read("*a")
            :gsub('PRETTY_NAME=\"', '')
            :sub(1, -3)
    end
end

configStrings["architecture"] = function()
    return io.popen("uname -m"):read("*a"):sub(1, -2)
end

configStrings["host"] = function()
    return fileToString("/sys/devices/virtual/dmi/id/product_name")
end

configStrings["kernel"] = function()
    return io.popen("uname -r"):read("*a"):sub(1, -2)
end

configStrings["terminal"] = function()
    -- the gsub is to remove any prefix in the file
    return os.getenv("TERM"):gsub("^.*-", '')
end

configStrings["cpu"] = function()
    local cpuInfo = fileToString("/proc/cpuinfo")
    local cpuName, cpuMHz, coreCount
    
    if cpuInfo then
        -- get the CPU name

        cpuName = cpuInfo:sub(select(1, cpuInfo:find("model name")), -1)
        cpuName = cpuName:sub(1, select(2, cpuName:find('\n')) - 1)
            :gsub("model name.+: ", '')
    
        -- Get the CPU clock speed using the same method
        cpuMHz = cpuInfo:sub(select(1, cpuInfo:find("cpu MHz")), -1)
        -- For some stupid reason string.gsub() doesn't want to work on cpu MHz??? This is the last resort
        cpuMHz = cpuMHz:sub(12, select(2, cpuMHz:find('\n')))
    
        -- Get the number of occurences using cpuName
        coreCount = select(2, cpuInfo:gsub("model name.:", ''))
    
        if cpuName:find('@') then
            cpuName = cpuName:gsub(" @.+", '')
        end
    else
        cpuName = "unknown"
        cpuMHz = "0"
        coreCount = 0
    end

    return string.format("%s x%d @ %.3fGHz", cpuName, coreCount, tonumber(cpuMHz) / 1000)
end

configStrings["gpu"] = function()
    return io.popen("glxinfo | grep -i 'OpenGL renderer string:'"):read("*a"):gsub("OpenGL renderer string: ", ''):sub(1, -2)
end

configStrings["shell"] = function()
    return os.getenv("SHELL")
end

configStrings["memory"] = function()
    local meminfo = fileToString("/proc/meminfo")
    local memTotal, usedMem
    if meminfo then
        memTotal = meminfo:sub(select(1, meminfo:find("MemTotal:")), -1)
        memTotal = memTotal:sub(1, select(2, memTotal:find('\n')))
            :gsub("MemTotal:%s+", '')
            :gsub(" kB\n", '')

        usedMem = io.popen("free | grep Mem"):read("*a"):gsub("[%a%p]+%s+%d+%s+%d+%s+", '')
        local i, j = usedMem:find("%d+")
        usedMem = usedMem:sub(i, j)
    else
        memTotal = 0
        usedMem = 0
    end

    return string.format("%.0f/%.0fMiB", tonumber(usedMem) / 1024, tonumber(memTotal) / 1024)
end

configStrings["lua"] = function()
    return _VERSION
end

for _, item in ipairs(config.order) do
    if(configStrings[item]) then
        if config.showRaw[item] then
            print(configStrings[item]())
        else
            print(Lunacolors.format(string.format("{bold}{%s}%s%s", config.primaryColor, config.prettyOrder[item] or item, config.seperator)) 
                .. Lunacolors.format(string.format("{%s}%s", config.secondaryColor, configStrings[item]())))
        end
    else
        print(Lunacolors.format(item))
    end
end