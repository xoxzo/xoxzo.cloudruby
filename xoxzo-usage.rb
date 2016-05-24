#!/usr/bin/env ruby

require 'pp'

sid = ENV['XOXZO_API_SID']
token = ENV['XOXZO_API_AUTH_TOKEN']
xc = XoxzoClient.new(sid,token)
res = xc.send_sms(message: "Hello! This is Xoxzo!", recipient: "+818054695209", sender: "8108012345678")
if res.errors != nil
  pp res
  return
end

msgid = res.messages[0]['msgid']
res = xc.get_sms_delivery_status(msgid: msgid)
pp res
