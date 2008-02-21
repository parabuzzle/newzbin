require 'newzbin'
include Newzbin


describe Connection, "when first creating without cookies or user/pass" do
  before(:each) do
    @newzbin_conn = Connection.new
  end

  it "should have a host" do
    @newzbin_conn.host.should eql('http://v3.newzbin.com')
  end

  it "should have a search path" do
    @newzbin_conn.search_path.should eql('/search/')
  end

  it "should have a dnzb path path" do
    @newzbin_conn.dnzb_path.should eql('/dnzb')
  end

end


describe Connection, "when first creating with cookies" do
  before(:each) do
    @newzbin_conn = Connection.new(:nzbSmoke => "RKTU0McXx%24Uc4e4KXP1L0sl4O1U9YOchO%2B0DA%3D", :nzbSessionID => "a0fed567eb1a3e6e95c8a3d46fe0c6e7")
  end

  it "should have an nzbsmoke" do
    @newzbin_conn.nzbSmoke.should eql('RKTU0McXx%24Uc4e4KXP1L0sl4O1U9YOchO%2B0DA%3D')
  end

  it "should have an nzbSessionID" do
    @newzbin_conn.nzbSessionID.should eql('a0fed567eb1a3e6e95c8a3d46fe0c6e7')
  end

end


describe Connection, "when first creating with username and pass" do
  before(:each) do
    @newzbin_conn = Connection.new(:username => "jon", :password => "mypass")
  end

  it "should have a username" do
    @newzbin_conn.username.should eql('jon')
  end

  it "should have a password" do
    @newzbin_conn.password.should eql('mypass')
  end

end

describe Connection, "when doing a search without cookies" do
  before(:each) do
    newzbin_conn = Connection.new
    @nzbs = newzbin_conn.search(:q => 'independence day', :ps_rb_video_format => 16, "category"=>"6", "commit"=>"search")
  end

  it "should return an array of items" do
    @nzbs.class.should be(Array)
  end

  it "should return items" do
    @nzbs.size.should have_at_least(1).things
  end

  it "should get attributes for nzbs" do
    @nzbs.first.attributes.size.should eql(0)
  end

end

describe Connection, "when doing a search with cookies" do
  before(:each) do
    newzbin_conn = Connection.new(:nzbSmoke => "RKTU0McXx%24Uc4e4KXP1L0sl4O1U9YOchO%2B0DA%3D", :nzbSessionID => "a0fed567eb1a3e6e95c8a3d46fe0c6e7")
    @nzbs = newzbin_conn.search(:q => 'independence day', :ps_rb_video_format => 16, "category"=>"6", "commit"=>"search")
  end

  it "should return an array of items" do
    @nzbs.class.should be(Array)
  end

  it "should return items" do
    @nzbs.size.should have_at_least(1).things
  end

  it "should get attributes for nzbs" do
    @nzbs.first.attributes.size.should have_at_least(1).things
  end

end



