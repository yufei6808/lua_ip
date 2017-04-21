local args  = ngx.req.get_query_args()
local ip    = args["ip"]
local phone    = args["phone"]
local datatype = args["datatype"] or args["dataType"]

function string.split(self,sep)
    self=self or ""
    local sep, fields = sep or "\t", {}
    local pattern = string.format("([^%s]+)", sep)
    string.gsub(self,pattern, function(c) fields[#fields+1] = c end)
    return fields
end

if datatype == "setip" then
    local function run()
        local cjson = require "cjson.safe"
        local ipdb = ngx.shared.ipdb
        --ip
        local ipTab = {}
        for i=0, 255 do
            ipTab[i] = {}
        end

        for item in io.lines("/tmp/ip_nn.txt") do
            startIpnum = string.match(item, "(%d+)|")
            endIpnum = string.match(item, "%d+|(%d+)|")
            diqu = string.match(item, "%d+|%d+|(.*)")
            startIpa = string.format("%d",string.sub(string.format("%#x",startIpnum),0,4))
            table.insert(ipTab[tonumber(startIpa or 0)],{tonumber(startIpnum), tonumber(endIpnum), diqu})
        end

        for i=0, 255 do
            local setInfo =  cjson.encode(ipTab[i])
            ipdb:set("group:"..i, setInfo)
        end
        ngx.say("ip ok")

        --phone
        local phoneTab = {}
        for i=0, 255 do
            phoneTab[i] = {}
        end

        for item in io.lines("/tmp/wk_phone.txt") do
            startnum = string.match(item, "(%d+)|")
            middlenum = string.match(item, "%d+|(%d+)|")
            content = string.match(item, "%d+|%d+|(.*)")
            table.insert(phoneTab[tonumber(startnum or 0)],{tonumber(startnum), tonumber(middlenum), content})
        end

        for i=0, 255 do
            local setInfo =  cjson.encode(phoneTab[i])
            ipdb:set("group_phone:"..i, setInfo)
        end
        ngx.say("phone ok")
    end
    local code,err=pcall(run)
    if not code then
        ngx.print("error"..err)
        ngx.exit(200)
    end

elseif ip ~= nil then
    local ip_table = string.split(ip, ",")
    local res_table = {}
    local res = "none"
    local cjson        = require "cjson"

    for i=1,#ip_table do
        local ip = ip_table[i]
        local cjson = require "cjson.safe"
        local ipdb = ngx.shared.ipdb
        _, _, ipa, ipb, ipc, ipd = string.find(ip, "(%d+).(%d+).(%d+).(%d+)")
        ipnum = ipa*16777216 + ipb*65536 + ipc*256 + ipd
        groupId = tonumber(ipa)
        ipGroup = cjson.decode(ipdb:get("group:"..groupId))
        groupTot = table.getn(ipGroup)

        for i = 1, groupTot do
            if (ipnum >= ipGroup[i][1]) and (ipnum <= ipGroup[i][2]) then
                res = ipGroup[i][3]
                break
            end
        end
        table.insert(res_table,res)
    end

    if datatype == "json" then
        datatable = {}
        data = {}

        if res_table[1] ~= "none" then
            for k,v in pairs(res_table) do
                a = string.split(v,"|")
                b = {"country","region","province","city","county","isp","countryCode","regionCode","provinceCode","cityCode","countyCode","ispCode"}
                c = {}
                for i=1,12 do
                    c[b[i]] = a[i]
                end
                table.insert(data,c)
            end
        end
        if #ip_table == #data and data[1] ~= "none" then
            datatable["code"] = 0
        else
            datatable["code"] = 1
        end
        datatable["data"] = data

        ngx.print(cjson.encode(datatable))
    else
        ngx.say(cjson.encode(res_table))
        ngx.exit(200)
    end

elseif phone ~= nil then
    local cjson = require "cjson.safe"
    local ipdb = ngx.shared.ipdb
    local res = "none"
    groupId = tonumber(string.sub(phone,1,3))
    ipnum = tonumber(string.sub(phone,4,7))
    ipGroup = cjson.decode(ipdb:get("group_phone:"..groupId))
    groupTot = table.getn(ipGroup)

    for i = 1, groupTot do
        if (ipnum == ipGroup[i][2]) then
            res = ipGroup[i][3]
            break
        end
    end

    if datatype == "json" then
        ngx.say("hello")

    else

        --ngx.say(res)
        ngx.print(cjson.encode(res))
    end

end