require 'spec_helper'
require 'pp'

include Xoxzo::Cloudruby

describe Xoxzo::Cloudruby do
  before(:each) do
    sid = ENV['XOXZO_API_SID']
    token = ENV['XOXZO_API_AUTH_TOKEN']
    @xc = XoxzoClient.new(sid,token)
    end

  it 'has a version number' do
    expect(Xoxzo::Cloudruby::VERSION).not_to be nil
  end

  xit 'test send sms success and get sent status' do
    res = @xc.send_sms(message="こんにちはRuby Lib です", recipient = "+818054695209", sender = "8108054695209")
    expect(res.errors).to be nil
    expect(res.message).to eq({})
    expect(res.messages[0].key?('msgid')).to be true

    sleep(2)

    msgid = res.messages[0]['msgid']
    res = @xc.get_sms_delivery_status(msgid=msgid) # this is temprary msgid 2016/05/19
    expect(res.errors).to be nil
    expect(res.message.key?('msgid')).to be true
    expect(res.message.key?('cost')).to be true
    expect(res.messages).to eq []
  end

  it 'test send sms faile, bad recipient format' do
    res = @xc.send_sms(message="こんにちはRuby Lib です", recipient = "+8108054695209", sender = "8108054695209")
    expect(res.errors).to eq 400
    expect(res.message.key?('recipient')).to be true
    expect(res.messages).to eq []
  end

  it 'test get sms status fail, bad msgid' do
    res = @xc.get_sms_delivery_status(msgid="0123456789")
    expect(res.errors).to eq 404
    expect(res.message).to eq [] # this is a bug currently
    # expect(res.message).to be nil
    expect(res.messages).to eq []
  end

  it 'test get sent sms list all' do
    res = @xc.get_sent_sms_list()
    expect(res.errors).to be nil
    expect(res.message).to eq({}) # this is a bug currently
    expect(res.messages[0].key?('cost')).to be true
    # pp res.messages
  end

  it 'test get sent sms list with specifice date' do
    res = @xc.get_sent_sms_list(sent_date: "=2016-05-18")
    expect(res.errors).to be nil
    expect(res.message).to eq({})
    if  res.messages != []
      expect(res.messages[0].key?('cost')).to be true
      #pp res.messages
    end
  end

  it 'test get sent sms list fail, bad date' do
    res = @xc.get_sent_sms_list(sent_date: "=2016-15-45")
    expect(res.errors).to be 400
    expect(res.message.key?('sent_date')).to be true
    expect(res.messages).to eq []
  end
end
