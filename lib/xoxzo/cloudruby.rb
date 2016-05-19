require "xoxzo/cloudruby/version"

require "httparty"
require 'json'

module Xoxzo
  module Cloudruby

    class XoxzoRespose
      def initalize
        @errors = nil
        @message = Hash.new
        @messages = []
      end
      attr_accessor :errors,:message,:messages
    end

    class XoxzoClient
      def initialize(sid,token)
          @auth = {:username => sid, :password => token}
          api_host = "https://api.xoxzo.com"
          @xoxzo_api_sms_url = api_host + "/sms/messages/"
          @xoxzo_api_voice_simple_url = api_host + "/voice/simple/playback/"
      end

      def send_sms(message, recipient, sender)
        body = {"message" => message , "recipient" => recipient , "sender" => sender}
        res = HTTParty.post(@xoxzo_api_sms_url, :basic_auth => @auth,
                            :body => body.to_json,
                            :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json'})
        if res.code == 201
          xr = XoxzoRespose.new
          xr.errors = nil
          xr.messages = JSON.parse(res.body)
        else
          xr = XoxzoRespose.new
          xr.errors = res.code
          xr.message = JSON.parse(res.body)
        end
        return xr
      end

      def get_sms_delivery_status(msgid)
        url = @xoxzo_api_sms_url + msgid
        res = HTTParty.get(url, :basic_auth => @auth)
        if res.code == 200
          xr = XoxzoRespose.new
          xr.errors = nil
          xr.message = JSON.parse(res.body)
        else
          xr = XoxzoRespose.new
          xr.errors = res.code
          xr.message = JSON.parse(res.body)
        end
        return xr
      end
    end
  end
end
