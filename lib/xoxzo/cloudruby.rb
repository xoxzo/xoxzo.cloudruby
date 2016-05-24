require "xoxzo/cloudruby/version"

require "httparty"
require 'json'

module Xoxzo
  module Cloudruby

    class XoxzoRespose
      def initialize(errors: nil, message: Hash.new, messages: [])
        @errors = errors
        @message = message
        @messages = messages
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

      def send_sms(message:, recipient:, sender:)
        body = {"message" => message , "recipient" => recipient , "sender" => sender}
        res = HTTParty.post(@xoxzo_api_sms_url, :basic_auth => @auth,
                            :body => body.to_json,
                            :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json'})
        if res.code == 201
          xr = XoxzoRespose.new(messages: json_safe_parse(res.body))
        else
          xr = XoxzoRespose.new(errors: res.code,message: json_safe_parse(res.body))
        end
        return xr
      end

      def get_sms_delivery_status(msgid:)
        url = @xoxzo_api_sms_url + msgid
        res = HTTParty.get(url, :basic_auth => @auth)
        if res.code == 200
          xr = XoxzoRespose.new(message: json_safe_parse(res.body))
        else
          xr = XoxzoRespose.new(errors: res.code,message: json_safe_parse(res.body))
        end
        return xr
      end

      def get_sent_sms_list(sent_date: nil)
        if sent_date == nil
          url = @xoxzo_api_sms_url
        else
          url = @xoxzo_api_sms_url + "?sent_date" + sent_date
        end
        res = HTTParty.get(url, :basic_auth => @auth)
        if res.code == 200
          xr = XoxzoRespose.new(messages: json_safe_parse(res.body))
        else
          xr = XoxzoRespose.new(errors: res.code, message: json_safe_parse(res.body))
        end
        return xr
      end

      def call_simple_playback(caller:, recipient:, recording_url:)
        body = {"caller" => caller , "recipient" => recipient , "recording_url" => recording_url}
        res = HTTParty.post(@xoxzo_api_voice_simple_url, :basic_auth => @auth,
                            :body => body.to_json,
                            :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json'})
        if res.code == 201
          xr = XoxzoRespose.new(messages: json_safe_parse(res.body))
        else
          xr = XoxzoRespose.new(errors: res.code,message: json_safe_parse(res.body))
        end
        return xr
      end

      def get_simple_playback_status(callid:)
        url = @xoxzo_api_voice_simple_url + callid
        res = HTTParty.get(url, :basic_auth => @auth)
        if res.code == 200
          xr = XoxzoRespose.new(message: json_safe_parse(res.body))
        else
          xr = XoxzoRespose.new(errors: res.code,message: json_safe_parse(res.body))
        end
        return xr
      end

      def json_safe_parse(s)
        return JSON.parse(s)
      rescue JSON::ParserError => e
        return {}
      end
    end
  end
end
