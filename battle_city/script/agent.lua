
package.path = "./examples/?.lua;./script/?.lua;" .. package.path
local skynet = require "skynet"
local netpack = require "netpack"
local socket = require "socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local protobuf = require "protobuf"

local WATCHDOG
local host
local send_request

local CMD = require "message_handler" 
local REQUEST = {}
local client_fd

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
    return skynet.tostring(msg, sz)
	end,
	dispatch = function (session, address, buffer, ...)
    local p = protobuf.decode("Package", buffer)
    print("recieve package",p.name)
    local pp = protobuf.decode(p.name, p.data)
    local f = CMD[p.name]
    if not f then
      print("message handler not exist. Package:"..p.name)
      return
    end
    f(pp)
	end
}

function CMD.start(conf)
  local fd = conf.client
	local gate = conf.gate
	WATCHDOG = conf.watchdog
	client_fd = fd
  send_hello()
 
	skynet.call(gate, "lua", "forward", fd)
end

function send_hello()
  skynet.fork(function()
    while true do
      send_package("S2C_Hello",{b = "s2c"})
      skynet.sleep(500)
    end
  end)
end

protobuf.register_file "../battle_city/proto/msg.pb"  
function send_package(message, t)
  buffer = protobuf.encode(message, t)
  socket.write(client_fd, protobuf.encode("Package",{name = message, data = buffer}))
end

function CMD.disconnect()
	-- todo: do something before exit
	skynet.exit()
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)
