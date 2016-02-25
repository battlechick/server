local skynet = require "skynet"
local mongo = require "mongo"
local bson = require "bson"

local host, db_name = ... 

function test_insert_without_index()
  local db = mongo.client({host = host})

  db[db_name].testdb:dropIndex("*")
  db[db_name].testdb:drop()

  local ret = db[db_name].testdb:safe_insert({test_key = 1});
  assert(ret and ret.n == 1)

  local ret = db[db_name].testdb:safe_insert({test_key = 1});
  assert(ret and ret.n == 1)
end

function test_insert_with_index()
  local db = mongo.client({host = host})

  db[db_name].testdb:dropIndex("*")
  db[db_name].testdb:drop()

  db[db_name].testdb:ensureIndex({test_key = 1}, {unique = true, name = "test_key_index"})

  local ret = db[db_name].testdb:safe_insert({test_key = 1})
  assert(ret and ret.n == 1)

  local ret = db[db_name].testdb:safe_insert({test_key = 1})
  assert(ret and ret.n == 0)
end

function test_find_and_remove()
  local db = mongo.client({host = host})

  db[db_name].testdb:dropIndex("*")
  db[db_name].testdb:drop()

  db[db_name].testdb:ensureIndex({test_key = 1}, {unique = true, name = "test_key_index"})

  local ret = db[db_name].testdb:safe_insert({test_key = 1})
  assert(ret and ret.n == 1)

  local ret = db[db_name].testdb:safe_insert({test_key = 2})
  assert(ret and ret.n == 1)

  local ret = db[db_name].testdb:findOne({test_key = 1})
  assert(ret and ret.test_key == 1)

  local ret = db[db_name].testdb:find({test_key = {['$gt'] = 0}}):sort({test_key = -1}):skip(1):limit(1)
  assert(ret:count() == 2)
  assert(ret:count(true) == 1)
  if ret:hasNext() then
    ret = ret:next()
  end
  assert(ret and ret.test_key == 1)

  db[db_name].testdb:delete({test_key = 1})
  db[db_name].testdb:delete({test_key = 2})

  local ret = db[db_name].testdb:findOne({test_key = 1})
  assert(ret == nil)
end


function test_expire_index()
  local db = mongo.client({host = host})

  db[db_name].testdb:dropIndex("*")
  db[db_name].testdb:drop()

  db[db_name].testdb:ensureIndex({test_key = 1}, {unique = true, name = "test_key_index", expireAfterSeconds = 1, })
  db[db_name].testdb:ensureIndex({test_date = 1}, {expireAfterSeconds = 1, })

  local ret = db[db_name].testdb:safe_insert({test_key = 1, test_date = bson.date(os.time())})
  assert(ret and ret.n == 1)

  local ret = db[db_name].testdb:findOne({test_key = 1})
  assert(ret and ret.test_key == 1)

  for i = 1, 1000 do
    skynet.sleep(11);

    local ret = db[db_name].testdb:findOne({test_key = 1})
    if ret == nil then
      return
    end
  end

  assert(false, "test expire index failed");
end

local CMD = {}
function collection(name)
  local db = mongo.client({host = host})
  return db[db_name][name]
end

function CMD.query_account(account_name, account_pwd)
  local col = collection("account")
  local ret = col:findOne({name = account_name})
  if not ret then
    col.safe_insert({name = account_name, pwd = account_pwd})
    ret = col:findOne({name = account_name})
  end
  return ret
end

skynet.start(function()
  skynet.dispatch("lua", function(_,_, command, ...)
    local f = CMD[command]
    skynet.ret(skynet.pack(f(...)))
  end)
end)
