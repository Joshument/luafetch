local function cyanify(text)
    return "\27[36m"..text.."\27[39m"
end

local function boldify(text)
    return "\27[1m"..text.."\27[22m"
end

local function labelify(text)
    return cyanify(boldify(text))
end

local checkShell

-- Get the user name and system name
local shell = io.popen("whoami")
local username = shell:read("*a"):sub(1, -2)
shell:close()

local input = io.input("/proc/sys/kernel/hostname")
local hostname = io.read("*all"):sub(1, -2)

-- Get the operating system name
shell = io.popen("(ls /etc/*-release && echo yes) || echo no")
local isDebian = shell:read("*a"):find("no")

if isDebian then
    shell = io.popen("cat /etc/*_version | grep \'Description\'")
else
    shell = io.popen("cat /etc/*-release | grep \'PRETTY_NAME\'")
end

local osname = shell:read("*a"):sub(1, -2)

-- Removing all of the surrounding information
if isDebian then
    osname = osname:gsub('Description:.', ''):sub(1, -2)
else
    osname = osname:gsub('PRETTY_NAME=\"', ''):sub(1, -2)
end

-- Get CPU architecture
-- Architecture:                    x86_64
shell = io.popen("uname -m")
local architecture = shell:read("*a"):sub(1, -2)

-- Get host machine
shell = io.input("/sys/devices/virtual/dmi/id/product_name")
local hostMachine = io.read("*a"):sub(1, -2)

-- Get kernel version
shell = io.popen("uname -r")
local kernelVersion = shell:read("*a"):sub(1, -2)

-- CPU information
local foundInfo = false

input = io.input("/proc/cpuinfo")
local cpuInfo = io.read("*all")

-- The start of the model name info
local i = select(1, cpuInfo:find("model name"))

-- Get everything aftwards
local cpuName = cpuInfo:sub(i, -1)

-- Look for the newline and get substring
local j = select(2, cpuName:find('\n'))
cpuName = cpuName:sub(1, j - 1):gsub("model name.: ", '')

-- Get the CPU clock speed using the same method
local i = select(1, cpuInfo:find("cpu MHz"))
local cpuMHz = cpuInfo:sub(i, -1)
local j = select(2, cpuMHz:find('\n'))
-- For some stupid reason string.gsub() doesn't want to work on cpu MHz??? This is the last resort
cpuMHz = cpuMHz:sub(12, j - 1)

-- Get the number of occurences using cpuName
local coreCount = select(2, cpuInfo:gsub("model name.:", ''))

if cpuName:find('@') then
    cpuName = cpuName:gsub(" @.+", '')
end

-- Get the shell
local defaultShell = os.getenv("SHELL")

-- Get the total amount of Memory, using the same method as getting the cpuName
input = io.input("/proc/meminfo")
local meminfo = io.read("*all")
local i = select(1, meminfo:find("MemTotal:"))
local memTotal = meminfo:sub(i, -1)
local j = select(2, memTotal:find('\n'))
local memTotal = memTotal:sub(1, j):gsub("MemTotal:%s+", ''):gsub(" kB\n", '')

shell = io.popen("free | grep Mem")
local usedMem = shell:read("*a")
usedMem = usedMem:gsub("[%a%p]+%s+%d+%s+%d+%s+", '')
local i, j = usedMem:find("%d+")
usedMem = usedMem:sub(i, j)

-- Final output
print(labelify(string.format("%s", username))..'@'..labelify(string.format( "%s",hostname)))
print(boldify("--------------------"))
print(string.format(labelify("OS:").." %s", osname))
print(string.format(labelify("Architecture:").." %s", architecture))
print(string.format(labelify("Host Machine:").." %s", hostMachine))
print(string.format(labelify("Kernel:").." %s", kernelVersion))
print(string.format(labelify("CPU:").." %s x%d @ %.3fGHz", cpuName, coreCount, tonumber(cpuMHz) / 1000))
--print(string.format(labelify("CPU:").." %s x%d", cpuName, coreCount))
print(string.format(labelify("Shell:").." %s", defaultShell))
print(string.format(labelify("Memory: ").."%.0f/%.0f", tonumber(usedMem) / 1024, tonumber(memTotal) / 1024).."MiB")