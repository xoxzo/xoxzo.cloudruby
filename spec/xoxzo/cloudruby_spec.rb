require 'spec_helper'
require 'pp'
require 'date'

include Xoxzo::Cloudruby

describe Xoxzo::Cloudruby do
  before(:each) do
    sid = ENV['XOXZO_API_SID']
    token = ENV['XOXZO_API_AUTH_TOKEN']
    @test_recipient = ENV['XOXZO_API_TEST_RECIPIENT']
    @test_mp3_url = ENV['XOXZO_API_TEST_MP3']
    @xc = XoxzoClient.new(sid,token)
    end

  it 'has a version number' do
    expect(Xoxzo::Cloudruby::VERSION).not_to be nil
  end

  xit 'test send sms success and get sent status' do
    res = @xc.send_sms(message: "こんにちはRuby Lib です", recipient: @test_recipient, sender: "8108012345678")
    expect(res.errors).to be nil
    expect(res.message).to eq({})
    expect(res.messages[0].key?('msgid')).to be true

    sleep(2)

    msgid = res.messages[0]['msgid']
    res = @xc.get_sms_delivery_status(msgid: msgid)
    expect(res.errors).to be nil
    expect(res.message.key?('msgid')).to be true
    expect(res.message.key?('cost')).to be true
    expect(res.messages).to eq []
  end

  it 'test send sms fail, bad recipient format' do
    res = @xc.send_sms(message: "こんにちはRuby Lib です", recipient: "+0808012345678", sender: "8108012345678")
    expect(res.errors).to eq 400
    expect(res.message.key?('recipient')).to be true
    expect(res.messages).to eq []
  end

  it 'test get sms status fail, bad msgid' do
    res = @xc.get_sms_delivery_status(msgid: "0123456789")
    expect(res.errors).to eq 404
    expect(res.message).to be {}
    expect(res.messages).to eq []
  end

  it 'test get sent sms list all' do
    res = @xc.get_sent_sms_list()
    expect(res.errors).to be nil
    expect(res.message).to eq({}) # this is a bug currently
    expect(res.messages[0].key?('cost')).to be true
    # pp res.messages
  end

  it 'test get sent sms list with specific date' do
    a_month_ago = (Date.today - 30).to_s
    res = @xc.get_sent_sms_list(sent_date: ">=" + a_month_ago)
    expect(res.errors).to be nil
    expect(res.message).to eq({})
    if  res.messages != []
      expect(res.messages[0].key?('cost')).to be true
    end
  end

  xit 'test simple voice playback success' do
    res = @xc.call_simple_playback(caller:"810812345678",recipient: @test_recipient,recording_url: @test_mp3_url)
    expect(res.errors).to be nil
    expect(res.message).to eq({})
    expect(res.messages[0].key?('callid')).to be true

    callid = res.messages[0]['callid']
    res = @xc.get_simple_playback_status(callid: callid)
    expect(res.errors).to be nil
    expect(res.message.key?('callid')).to be true
    expect(res.messages).to eq []
  end

  xit 'test tts playback success' do
    res = @xc.call_tts_playback(caller:"810812345678",recipient: @test_recipient,tts_message:"Hello",tts_lang:"en")
    expect(res.errors).to be nil
    expect(res.message).to eq({})
    expect(res.messages[0].key?('callid')).to be true

    callid = res.messages[0]['callid']
    res = @xc.get_simple_playback_status(callid: callid)
    expect(res.errors).to be nil
    expect(res.message.key?('callid')).to be true
    expect(res.messages).to eq []
  end

  it 'test get simple playback status fail' do
    res = @xc.get_simple_playback_status(callid: "dabd8e76-390f-421c-87b5-57f31339d0c5")
    expect(res.errors).to be 404
    expect(res.message).to eq({})
    expect(res.messages).to eq []
  end

  it 'test get din list success 01' do
    res = @xc.get_din_list()
    expect(res.errors).to be nil
    expect(res.message[0].key?('monthly_cost')).to be true
    expect(res.messages).to eq []
  end

  it 'test get din list success 02' do
    res = @xc.get_din_list(search_string: 'country=JP')
    expect(res.errors).to be nil
    expect(res.message[0].key?('monthly_cost')).to be true
    expect(res.messages).to eq []
  end

  it 'test get din list success 03' do
    res = @xc.get_din_list(search_string: 'prefix=813')
    expect(res.errors).to be nil
    expect(res.message[0].key?('monthly_cost')).to be true
    expect(res.messages).to eq []
  end

  it 'test get din list, subscribe, unsubscribe success' do

    res = @xc.get_subscription_list()
    expect(res.errors).to be nil
    num_of_subscriptions = res.messages.length

    res = @xc.get_din_list()

    din_uid = res.message[0]['din_uid']
    res = @xc.subscribe_din(din_uid: din_uid)
    expect(res.errors).to be nil

    # after subscribe din, num of subscription should be incremented by 1
    res = @xc.get_subscription_list()
    expect(res.errors).to be nil
    num_of_subscriptions_2 = res.messages.length
    expect(num_of_subscriptions_2).to eq (num_of_subscriptions + 1)

    # subscribed din_uid must be in the subscription list
    din_uid_match = false
    res.messages.each {|m|
      if m['din_uid'] == din_uid
        din_uid_match = true
        break
      end
    }
    expect(din_uid_match).to be true

    dummy_action_url = 'http://example.com/dummy_action'
    res = @xc.set_action_url(din_uid: din_uid, action_url: dummy_action_url)
    expect(res.errors).to be nil

    res = @xc.get_subscription_list()
    expect(res.errors).to be nil

    # action url must be set correctly
    action_url_match = false
    res.messages.each {|m|
      if (m['action']['url'] == dummy_action_url) && (m['din_uid'] == din_uid)
        action_url_match = true
        break
      end
    }
    expect(action_url_match).to be true

    res = @xc.unsubscribe_din(din_uid: din_uid)
    expect(res.errors).to be nil

    # after unsubscribe din, num of subscription should be same as before
    res = @xc.get_subscription_list()
    expect(res.errors).to be nil
    num_of_subscriptions_2 = res.messages.length
    expect(num_of_subscriptions_2).to eq (num_of_subscriptions)

    # subscribed din_uid must NOT be in the subscription list
    din_uid_match = false
    res.messages.each {|m|
      if m['din_uid'] == din_uid
        din_uid_match = true
        break
      end
    }
    expect(din_uid_match).to be false

  end
end

