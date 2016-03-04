
local skynet = require "skynet"
local netpack = require "netpack"
local socket = require "socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local protobuf = require "protobuf"

require "player.player"

local WATCHDOG
local host
local send_request

local player_handler = require "player.player_handler"
local CMD = {}
local REQUEST = {}
local client_fd
local player

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
    local f = CMD[p.name] or player_handler[p.name]
    if not f then
      print("message handler not exist. Package:"..p.name)
      return
    end
    local ret = f(pp, player)
    if p.rpcId ~= 0 then
      send_package("Response"..string.sub(p.name, 8, -1), ret, p.rpcId)
    end
	end
}

function CMD.login_start(conf)
  local fd = conf.client
  local gate = conf.gate
  WATCHDOG = conf.watchdog
  client_fd = fd
  print("login start")

  skynet.call(gate, "lua", "forward", fd)
end

function CMD.master_start(conf)
  local fd = conf.client
  local gate = conf.gate
  WATCHDOG = conf.watchdog
  client_fd = fd
  print("master start")

  skynet.call(gate, "lua", "forward", fd)
  send_package("S2C_LoadScene", {name = "Lobby"})
  send_hello()
end

function CMD.battle_start(conf)
  local fd = conf.client
  local gate = conf.gate
  WATCHDOG = conf.watchdog
  client_fd = fd
  print("battle start")

  skynet.call(gate, "lua", "forward", fd)
  send_hello()
end

function CMD.C2S_Login(p)
  print("client login")
  local result, address, port, player_id = skynet.call(".login","lua","login",p.accountName, p.accountPwd)
  send_package("S2C_Login", {result = result, address = address, port = port, playerId = player_id})
  skynet.call(WATCHDOG, "lua", "close", client_fd)
  skynet.exit()
end

function CMD.C2S_Online(p)
  local player_id = p.playerId
  player = skynet.call(".db", "lua", "query_player", player_id)
  if not player then
    player = player_new()
  end
  player.send_func = function(message_type, tbl)
    buffer = protobuf.encode(message_type, tbl)
    socket.write(client_fd, protobuf.encode("Package",{name = message_type, data = buffer}))
  end
  send_package("S2C_Online", {result = true, playerName = player.player_name})
end

function send_hello()
  skynet.fork(function()
    while true do
      send_package("S2C_Ping",{time = os.time()})
      --send_package("S2C_LoadScene", {name = "Lobby"})
      skynet.sleep(500)
    end
  end)
end

protobuf.register_file "../battle_city/proto/msg.pb"  
function send_package(message_type, tbl, rpc_id)
  --print("send_package:"..message_type)
  rpc_id = rpc_id or 0
  buffer = protobuf.encode(message_type, tbl)
  socket.write(client_fd, protobuf.encode("Package",{name = message_type, rpcId = rpc_id, data = buffer}))
end

function CMD.disconnect()
	-- todo: do something before exit
  if player then
    player_save(player)
  end
	skynet.exit()
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)
