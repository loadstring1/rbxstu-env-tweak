local executorEnv=getgenv()
local assert=assert
local typeof=typeof
local rawget=rawget
local setfenv=setfenv
local debug=debug
local table=table
local print=print
local task=task
local getrawmetatable=getrawmetatable
local game=game
local hookfunction=hookfunction
local restorefunction=restorefunction
local protectfunction=protectfunction
local newcclosure=newcclosure
local loadstring=loadstring
local getscriptbytecode=getscriptbytecode
local getscripthash=getscripthash
local game=game
local pcall=pcall
local string=string
local utf8=utf8

--getgenv().Base64=loadstring()()

local sha384=loadstring(game:HttpGet("https://raw.githubusercontent.com/loadstring1/roblox-exploit-script-env-tweaker/refs/heads/main/dependencies/sha384.luau"))()

setfenv(0,table.freeze{})
setfenv(1,table.freeze{})

local funcs={}
funcs.hookmetamethod=newcclosure(function(obj,metamethod,func)
		assert(typeof(metamethod)=="string","arg #2 is not a string")
        assert(typeof(func)=="function","arg #3 is not a function")
		assert(typeof(getrawmetatable(obj))=="table","arg #1 doesn't have valid metatable")
	
		local meta=rawget(getrawmetatable(obj),metamethod)
        
		assert(typeof(meta)=="function","hooking failed. metamethod is not a function")

        return hookfunction(meta,func)
end)

funcs.unhook=newcclosure(function(obj,metamethod)
       assert(typeof(metamethod)=="string","arg #2 is not a string")
       assert(typeof(getrawmetatable(obj))=="table","arg #1 doesn't have valid metatable")
       return restorefunction(rawget(getrawmetatable(obj),metamethod))
end)

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

		realBytecode=` {realBytecode}`
		print(realBytecode)
	
		return sha384(realBytecode)
end)

if protectfunction then
	for i,v in funcs do
			protectfunction(v)
	end
	print("protected successfully")
else
	local oldhookfunc
	oldhookfunc=hookfunction(hookfunction,newcclosure(function(func,func1)
			if typeof(func)~="function" or typeof(func1)~="function" then return oldhookfunc(func,func1) end
			if func==typeof or func==table.find or func==error or table.find(funcs,func) then error("Unable to hook protected functions") return nil end
			
			return oldhookfunc(func,func1)
	end))
	print("doesn't support protectfunction")
end

if getscriptbytecode then
	executorEnv.getscripthash=funcs.getscripthash
	print("getscripthash replaced")
end

if restorefunction and getrawmetatable then
	executorEnv.unhook=funcs.unhook
else
	print("doesnt support unhook")
end

if getrawmetatable and hookfunction then
	executorEnv.hookmetamethod=funcs.hookmetamethod
else
    print("doesn't support hookmetamethod")
end

local lscript=game:GetService("ReplicatedFirst").LocalScript
local hash=funcs.getscripthash(lscript)
print(hash)