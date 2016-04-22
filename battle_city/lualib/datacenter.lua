local skynet = require "skynet"

local datacenter = {}

function datacenter.create()
    local service = skynet.newservice "datacenterd"
    skynet.name("DATACENTER", service)
end

function datacenter.get(...)
    return skynet.call("DATACENTER", "lua", "QUERY", ...)
end

function datacenter.set(...)
    return skynet.call("DATACENTER", "lua", "UPDATE", ...)
end

function datacenter.wait(...)
    return skynet.call("DATACENTER", "lua", "WAIT", ...)
end

function datacenter.get_cluster(cluster_name, ...)
    return cluster.call(cluster_name, "DATACENTER", "lua", "QUERY", ...)
end

function datacenter.set_cluster(cluster_name, ...)
    return cluster.call(cluster_name, "DATACENTER", "lua", "UPDATE", ...)
end

function datacenter.wait_cluster(cluster_name, ...)
    return cluster.call(cluster_name, "DATACENTER", "lua", "WAIT", ...)
end
return datacenter
