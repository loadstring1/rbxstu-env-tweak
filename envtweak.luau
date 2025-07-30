local executorEnv=getgenv()
local assert=assert
local typeof=typeof
local rawget=rawget
local setfenv=setfenv
local table=table
local print=print
local getrawmetatable=getrawmetatable
local game=game
local hookfunction=hookfunction
local restorefunction=restorefunction
local protectfunction=protectfunction
local newcclosure=newcclosure
local loadstring=loadstring
local getscriptbytecode=getscriptbytecode
local game=game
local pcall=pcall
local string=string
local utf8=utf8

local sha384=loadstring(game:HttpGet("https://raw.githubusercontent.com/loadstring1/roblox-exploit-script-env-tweaker/refs/heads/main/dependencies/sha384.luau"))()

setfenv(0,table.freeze{})
setfenv(1,table.freeze{})

local funcs={}

--rbxstu hookmetamethod fix (it didn't hook table metamethods but this fixes it)
funcs.hookmetamethod=newcclosure(function(obj,metamethod,func)
		assert(typeof(metamethod)=="string","arg #2 is not a string")
        assert(typeof(func)=="function","arg #3 is not a function")
		assert(typeof(getrawmetatable(obj))=="table","arg #1 doesn't have valid metatable")
	
		local meta=rawget(getrawmetatable(obj),metamethod)
        
		assert(typeof(meta)=="function","hooking failed. metamethod is not a function")

        return hookfunction(meta,func)
end)

--backwards compatibility (syn v3 func)
funcs.unhook=newcclosure(function(obj,metamethod)
       assert(typeof(metamethod)=="string","arg #2 is not a string")
       assert(typeof(getrawmetatable(obj))=="table","arg #1 doesn't have valid metatable")
       return restorefunction(rawget(getrawmetatable(obj),metamethod))
end)

--getscripthash - it doesn't return same hash as a real in-game exploit (tested on print("hello world") script in ReplicatedFirst)
--that's the only known bug for me with this function
funcs.getscripthash=newcclosure(function(obj)
		assert(typeof(obj)=="Instance","arg #1 is not a roblox instance")
		assert(obj:IsA("LuaSourceContainer"),"arg #2 is not a luasourcecontainer")
		local success,bytecode=pcall(getscriptbytecode,obj)
		assert(success,typeof(bytecode)=="string" and bytecode or "bytecode doesn't exist in this script")
		
		local realBytecode=""
		for i,v in string.split(bytecode,"") do
				local success,func=pcall(utf8.graphemes,v)
				if success==false then continue end
				if typeof(func)~="function" then continue end
				local shit=string.byte(v:sub(1,1))
				if shit >= 32 and shit <= 126 and shit~=64 and shit~=65 then 
					print(shit)
					realBytecode=`{realBytecode}{v}`
				end
		end
		
		return sha384(realBytecode)
end)

for i,v in funcs do
	protectfunction(v)
	executorEnv[i]=v
end

if executorEnv.disableInitPrint then return end
print("ok rbxstu4 env improved (use this script only for rbxstu4 its not meant for real exploits)")

-- local lscript=game:GetService("ReplicatedFirst").LocalScript
-- local hash=funcs.getscripthash(lscript)
-- print(hash)