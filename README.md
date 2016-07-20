# Xoxzo::Cloudruby

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/xoxzo/cloudruby`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

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

Sample Code 1

Send SMS

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

Sample Code 2

Simple Playback

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
        
    msgid = res.messages[0]['msgid']
    res = xc.get_sms_delivery_status(msgid: msgid)
    pp res
    
Sample Code 3

Get list of available DINs.

    sid = ENV['XOXZO_API_SID']
    token = ENV['XOXZO_API_AUTH_TOKEN']
    xc = XoxzoClient.new(sid,token)
    res = xc.get_din_list()
    din_uid = res.message[0]['din_uid'] # get the din unique ID for the frist one for expample

Subscribe a DIN. 
  
    res = xc.subscribe_din(din_uid: din_uid)

Set the action url.
    
    dummy_action_url = 'http://example.com/dummy_action'
    res = xc.set_action_url(din_uid: din_uid, action_url: dummy_action_url)

Get the list of subscriptions.

    res = xc.get_subscription_list()
    
Unsubscribe the DIN.

    res = xc.unsubscribe_din(din_uid: din_uid)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/xoxzo/xoxzo-cloudruby.