require 'newzbin'
include Newzbin


# describe Connection, "when first creating without cookies or user/pass" do
#   before(:each) do
#     @newzbin_conn = Connection.new
#   end
# 
#   it "should have a host" do
#     @newzbin_conn.host.should eql('http://v3.newzbin.com')
#   end
# 
#   it "should have a search path" do
#     @newzbin_conn.search_path.should eql('/search/')
#   end
# 
#   it "should have a dnzb path path" do
#     @newzbin_conn.dnzb_path.should eql('/dnzb')
#   end
# 
# end

describe Connection do

  before(:each) do
    @newzbin_conn = Connection.new('mustache', 'newzbin')
  end

  describe "when creating" do

    describe "sets initial vars and" do 
      it "should have a host" do
        @newzbin_conn.host.should == 'http://v3.newzbin.com'
      end

      it "should have a search_path" do
        @newzbin_conn.search_path.should == '/search/'
      end

      it "should have a dnzb_path" do
        @newzbin_conn.dnzb_path.should == '/dnzb'
      end

      it "should have a username" do
        @newzbin_conn.username.should == 'mustache'
      end

      it "should have a password" do
        @newzbin_conn.password.should == 'newzbin'
      end
    end

    describe "logs in and" do
      it "should have cookies" do
        @newzbin_conn.agent.cookies.size.should_not == 0
      end

      it "should have an nzbsmoke and nzbsessionid" do
        @newzbin_conn.agent.cookies.map{|o| o.name}.should include("NzbSmoke", "NzbSessionID")
      end
    end

  end

  describe "when doing a search" do
    before(:each) do
      @nzbs = @newzbin_conn.search(:q => 'no country for old men', :ps_rb_video_format => 16, :category => 6)
    end
  
    it "should return an array of items" do
      @nzbs.class.should be(Array)
    end
  
    it "should return items" do
      @nzbs.size.should have_at_least(1).things
    end
      
    it "should get attributes for nzbs" do
      @nzbs.first.attributes.should have_at_least(1).things
    end
  
  end

end




