-- local cjson = require "cjson"
local firewall = require "waf"
firewall:firewall()

local redis = require "resty.redis"
local red = redis:new()

red:set_timeout(1000)

local ok, err = red:connect("127.0.0.1", 6379)
if not ok then
        ngx.log("failed to connect: ", err)
        return
end

local backend_gid, err = red:get("kefu_default_gray")

if backend_gid == ngx.null then
  ngx.log(ngx.ERR, 'backend_gid not exist in redis.')
else
   ngx.log(ngx.ERR, 'backend_gid default value is' .. backend_gid)
   ngx.var.backend_gid = backend_gid
end

if not ngx.var.cookie_tenantid then
    ngx.log(ngx.ERR, '2')
    return
end

if not ngx.var.cookie_tenantid or string.len(ngx.var.cookie_tenantid) == 0 then
        ngx.log(ngx.ERR, '2')
	return
end

local tenantid = ngx.var.cookie_tenantid
-- local route_key = ngx.var.cookie_tenantid

local backend_gid, err = red:get("route:tenantid:" .. ngx.var.cookie_tenantid)
if not backend_gid then
      ngx.log(ngx.ERR,"failed to get backend_gid: ")
   return
end

if backend_gid == ngx.null then
        ngx.log(ngx.NOTICE,"tenantid ".. ngx.var.cookie_tenantid .. " not found in redis")
        ngx.var.backend_gid = "a"
else
	ngx.log(ngx.NOTICE, "tenantid ".. ngx.var.cookie_tenantid .. " found in redis")
	ngx.var.backend_gid = "b"
end

local ok, err = red:set_keepalive(10000, 1000)
if not ok then
    ngx.say("failed to set keepalive: ", err)
    return
end
