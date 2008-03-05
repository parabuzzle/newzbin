require 'newzbin'
include Newzbin


describe Connection, "when first creating without cookies or user/pass" do
  before(:each) do
    
    newz.search(:q => 'independence day', :ps_rb_video_format => 16, "category"=>"6", "commit"=>"search")
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
