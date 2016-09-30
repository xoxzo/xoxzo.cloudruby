# Xoxzo::Cloudruby

xoxzo-cloudruby is the API wrapper for Xoxzo telephoney cloud API for Ruby.

## Installation

Add this line to your application's Gemfile:

```
gem 'xoxzo-cloudruby'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install xoxzo-cloudruby

## Usage

## Sample Code 1

### Send SMS

    require 'pp'
    require 'xoxzo/cloudruby'
    include Xoxzo::Cloudruby
    
    sid = ENV['XOXZO_API_SID']
    token = ENV['XOXZO_API_AUTH_TOKEN']
    xc = XoxzoClient.new(sid,token)
    res = xc.send_sms(message: "Hello! This is Xoxzo!", recipient: "+818012345678", sender: "8108012345678")
    if res.errors != nil
      pp res
      exit -1
    end
    
    msgid = res.messages[0]['msgid']
    res = xc.get_sms_delivery_status(msgid: msgid)
    pp res

#### Explanation

+ First, you need to create `XoxzoClient()` object. You must provide xoxzo sid and auth_token when initializing this object. You can get sid and auth_token after you sign up the xoxzo account and access the xoxzo dashboard.

+ Then you can call `send_sms()` method. You need to provide three parameters.

  - message: sms text you want to send.
  - recipient: phone number of the sms recipient. This must start with Japanese country code "+81" and follow the E.164 format.
  - sender: this number will be displayed on the recipient device.

+ This method will return `XoxzoResponse` object. If `XoxzoResponse.errors == nil`, `XoxzoResponse.messages[0]['msgid']` is the meesage id that you can pass to the `get_sms_delivery_status()` call.

+ You can check the sms delivery status by `get_sms_delivery_status()` method. You will provide message-id of the sms you want to check.

## Sample Code 2

### Simple Playback

    sid = ENV['XOXZO_API_SID']
    token = ENV['XOXZO_API_AUTH_TOKEN']
    xc = XoxzoClient.new(sid,token)
    res = xc.call_simple_playback(caller:"810812345678",recipient: "+818012345678",recording_url: "http://example.com/example.mp3")
    if res.errors != nil
      pp res
      exit -1
    end
    
    callid = res.messages[0]['callid']
    pp xc.get_simple_playback_status(callid: callid)
        
#### Explanation

+ You can call `call_simple_playback()` method to playback MP3 files. You need to provide three parameters.

  - caller: this number will be displayed on the recipient device.
  - recording_url: MP3 file URL.
  - recipient: phone number of the sms recipient. This must start with Japanese country code "+81" and follow the E.164 format.

+ This method will return `XoxzoResponse` object. If `XoxzoResponse.errors == nil`, `XoxzoResponse.messages[0]['callid']` is the call id that you can pass to the `get_simple_playback_status()` call.

+ You can check the call status by `get_simple_playback_status()` method. You will provide call-id of the phone call you want to check.


## Sample Code 3

### DIN (Dial in numbers)

### Get list of available DINs.

    sid = ENV['XOXZO_API_SID']
    token = ENV['XOXZO_API_AUTH_TOKEN']
    xc = XoxzoClient.new(sid,token)
    res = xc.get_din_list()
    din_uid = res.message[0]['din_uid'] # get the din unique ID for the frist one for expample

#### Explanation

1. In order to subscribe DIN, you must find available unsubscribed DINs using get_din_list() method.

### Subscribe a DIN. 
  
    res = xc.subscribe_din(din_uid: din_uid)

#### Explanation

1. Then you subscribe a DIN via subscribe_din() method specifying din unique id.

### Set the action url.
    
    dummy_action_url = 'http://example.com/dummy_action'
    res = xc.set_action_url(din_uid: din_uid, action_url: dummy_action_url)

#### Explanation

1. Once you subscribed the DIN, you can set action url to the DIN. This URL will be called in the event of the DIN gets called.
The URL will called by http GET method with the parameters, caller and recipient.

### Get the list of subscriptions.

    res = xc.get_subscription_list()

#### Explanation

1. In order to get the list of current subscription, you can call the method above.
    
### Unsubscribe the DIN.

    res = xc.unsubscribe_din(din_uid: din_uid)

#### Explanation

1. When you no longer use DIN, you can unsubscribe the DIN by specifying the din unique id.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/xoxzo/xoxzo-cloudruby.