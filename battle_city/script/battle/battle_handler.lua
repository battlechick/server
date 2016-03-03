

local CMD = {}

function CMD.C2S_Hello(package)
  print("client say hello"..package.a)
end

function CMD.Request_CreateRoom(package, player)
  return {result = true} 
end





































return CMD
