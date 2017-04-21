etip

将ip库或者手机号码库导入到内存，然后通过接口获取

说明

通过脚本将ip库里面的内容导入到内存中，通过ngx_lua进行访问提供高性能查询

#请求案例 导入ip库到内存 @example : http://www.ip.com/*** 查询ip所在区域 @example : http://www.ip.com/getip?ip=114.114.114.114 批量查询ip所在区域(json格式返回) @example : http://www.ip.com/getip?ip=114.114.114.114,114.114.114.115,114.114.114.116,114.114.114.117&datetype=json

#请求说明 请求：http://www.ip.com/getip?ip=60.173.220.116 返回：中国|华东|安徽省|合肥市|巢湖市|电 信| 0 |300000|340000| 340100 | 341400 |100017 说明：国家|区域|省 份|城 市|区 县|运营商|国家区号|区域号|省编码|城市编码|区县编码|运营商编码 注意：各个项目用“|”分开，没有的将会为空，匹配的时候严格按照对应项目匹配，否则会乱。 如：中国|华东|江苏省|南京市|||0|300000|320000|320100|-1|-1 区县和运营商都为空

请求：http://www.ip.com/getip?ip=114.114.114.114,114.114.114.115,114.114.114.116,114.114.114.117&datatype=json 返回：{"code":0,"data":[{"city":"南京市","province":"江苏省","county":" ","region":"华东","ispCode":"-1","country":"中国","isp":" ","regionCode":"300000","countyCode":"-1","provinceCode":"320000","cityCode":"320100","countryCode":"0"},{"city":"南京市","province":"江苏省","county":" ","region":"华东","ispCode":"-1","country":"中国","isp":" ","regionCode":"300000","countyCode":"-1","provinceCode":"320000","cityCode":"320100","countryCode":"0"}]} 说明：国家|区域|省 份|城 市|区 县|运营商|国家区号|区域号|省编码|城市编码|区县编码|运营商编码 code为"0"表示数据正常否则code为"1",data为请求顺序的返回结果，并做了解析和对应

#注意事项 1.数据库中ip存储是十进制，转化方式是将四段地址转化为十六进制然后组成相连的十六进制，然后将十六进制转化为十进制 例如192.168.1.1转化为十六进制为C0.A8.01.01，合并十六进制为C0A80101，再转化为十进制是3232235777 简单的算法是 ipnum = ipa16777216 + ipb65536 + ipc*256 + ipd = 3232235777 2.导入内存的时候先将ipnum翻转后得到ipa，将ipa设为索引存储在内存中，当查询的时候先查索引，然后查询ip所在的ip段 3.重启nginx的时候内存库就会消失，需要重新导入到内存。
