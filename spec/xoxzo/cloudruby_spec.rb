require 'spec_helper'

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

  xit 'test send sms success' do
    res = @xc.send_sms(message="こんにちはRuby Lib です", recipient = "+818054695209", sender = "8108054695209")
    expect(res.status).to eq(nil)
    expect(res.message).to be nil
    expect(res.messages[0].key?('msgid')).to be true
  end

  it 'test send sms faile, bad recipient format' do
    res = @xc.send_sms(message="こんにちはRuby Lib です", recipient = "+8108054695209", sender = "8108054695209")
    expect(res.status).to eq(400)
    expect(res.message.key?('recipient')).to be true
    expect(res.messages).to be nil
  end
end
