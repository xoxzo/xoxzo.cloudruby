require "xoxzo/cloudruby/version"

require "httparty"
require 'json'

module Xoxzo
  module Cloudruby

    # Return object class for Xoxzo Cloud API
    class XoxzoRespose
      def initialize(errors: nil, message: Hash.new, messages: [])
        # error status, nil if no errors
        @errors = errors
        # return informaint in hash
        @message = message
        # retrun information in array
        @messages = messages
      end
      attr_accessor :errors,:message,:messages
    end

    # API obejet class Xoxzo service
    class XoxzoClient
      # initialize xoxzo api client
      # sid :: your api sid of Xoxzo account
      # token :: your api token of Xoxzo account
      # retrun :: XoxzoRespose
      def initialize(sid,token)
          @auth = {:username => sid, :password => token}
          api_host = "https://api.xoxzo.com"
          @xoxzo_api_sms_url = api_host + "/sms/messages/"
          @xoxzo_api_voice_simple_url = api_host + "/voice/simple/playback/"
          @xoxzo_api_dins_url = api_host + "/voice/dins/"
      end

      # send sms method
      # messages :: sms text message
      # recipient :: sms recipient phone numner eg. "+818012345678", remove first 0 in front of area number
      # sender :: sem sender phone number. This value may not be displayed as is for some operators.
      # retrun :: XoxzoRespose
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

      # get sms delivery status method
      # msgid :: message id of in the return value of the send_sms method.
      # retrun :: XoxzoRespose
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

      # get setn sms list method
      # send_data :: query string. eg. "=2016-05-18"
      # retrun :: XoxzoRespose
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

      # call simple palyback method
      # caller :: caller phone number displayed on the recipient hand set
      # recipient :: sms recipient phone numner eg. "+818012345678", remove first 0 in front of area number
      # recording_url :: URL of the mp3 file to playback. eg. "http://example.com/example.mp3"
      # retrun :: XoxzoRespose
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

      # get simple plaback status method
      # callid :: call id in the return value of the call_simple_playback method
      # retrun :: XoxzoRespose
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

      def get_din_list(search_string: nil)
        if search_string == nil
          url = @xoxzo_api_dins_url
        else
          url = @xoxzo_api_dins_url + '?' + search_string
        end
        res = HTTParty.get(url, :basic_auth => @auth)
        if res.code == 200
          xr = XoxzoRespose.new(message: json_safe_parse(res.body))
        else
          xr = XoxzoRespose.new(errors: res.code,message: json_safe_parse(res.body))
        end
        return xr
      end

      def subscribe_din(din_uid:)
        url = @xoxzo_api_dins_url + 'subscriptions/'
        body = {"din_uid" => din_uid }
        res = HTTParty.post(url, :basic_auth => @auth,
                            :body => body.to_json,
                            :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json'})
        if res.code == 201
          xr = XoxzoRespose.new(messages: json_safe_parse(res.body))
        else
          xr = XoxzoRespose.new(errors: res.code,message: json_safe_parse(res.body))
        end
        return xr
      end

      def unsubscribe_din(din_uid:)
        url = @xoxzo_api_dins_url + 'subscriptions/' + din_uid + '/'
        res = HTTParty.delete(url, :basic_auth => @auth)
        if res.code == 200
          xr = XoxzoRespose.new(messages: json_safe_parse(res.body))
        else
          xr = XoxzoRespose.new(errors: res.code,message: json_safe_parse(res.body))
        end
        return xr
      end

      def get_subscription_list()
        url = @xoxzo_api_dins_url + 'subscriptions/'
        res = HTTParty.get(url, :basic_auth => @auth)
        if res.code == 200
          xr = XoxzoRespose.new(messages: json_safe_parse(res.body))
        else
          xr = XoxzoRespose.new(errors: res.code,message: json_safe_parse(res.body))
        end
        return xr
      end

      def set_action_url(din_uid:, action_url:)
        url = @xoxzo_api_dins_url + 'subscriptions/' + din_uid + '/'
        body = {'action_url': action_url}
        res = HTTParty.post(url, :basic_auth => @auth,
                            :body => body.to_json,
                            :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json'})
        if res.code == 200
          xr = XoxzoRespose.new(messages: json_safe_parse(res.body))
        else
          xr = XoxzoRespose.new(errors: res.code,message: json_safe_parse(res.body))
        end
        return xr
      end

      private
      def json_safe_parse(s)
        return JSON.parse(s)
      rescue JSON::ParserError => e
        return {}
      end
    end
  end
end
