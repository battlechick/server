local skynet = require "skynet"
local sprotoloader = require "sprotoloader"
local protobuf = require "protobuf"

local max_client = 64

function test()
  protobuf.register_file "proto/msg.pb"
  
  data = {b =  666}
  
  buffer = protobuf.encode("hello",data)
  print("encode:"..buffer)

  decode = protobuf.decode("hello", buffer)
  print("decode"..decode.b)

end

skynet.start(function()
	print("Server start!!")
  --local test = skynet.newservice("testservice")
  --skynet.call(test, "lua", "test")
  
	--skynet.uniqueservice("protoloader")
	local console = skynet.newservice("console")
	skynet.newservice("debug_console",8000)
	--skynet.newservice("simpledb")
	local watchdog = skynet.newservice("watchdog")
	skynet.call(watchdog, "lua", "start", {
		port = 10000,
		maxclient = max_client,
		nodelay = true,
	})
	print("Watchdog listen on ", 10000)

  --local db = skynet.newservice("db")

	skynet.exit()
end)
