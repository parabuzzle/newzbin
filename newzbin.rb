####### Newzbin API
### http://v3.newzbin.com

# open a new newzbin connection, and search it with the method provided. Pass it vars to narrow the search
# Download the nzb using the provided get_nzb method
#
# newz = Newzbin::Connection.new('username', 'password')
# nzbs = newz.search(:q => 'casino royale', :ps_rb_video_format => 131072)
#
# puts nzbs.inspect
# 
# newz.get_nzb(nzbs.first.id)



require 'rubygems'
require 'net/http'
require 'cgi'
require 'xmlsimple'

module Newzbin
  
  class Connection

    def initialize(username=nil, password=nil)
      @host = 'http://v3.newzbin.com'
      @search = '/search/'
      @dnzb = '/dnzb/'
      @username = username
      @password = password
    end

    def http_get(url)

      Net::HTTP.start('v3.newzbin.com') do |http|
        req = Net::HTTP::Get.new(url)
        req.add_field 'Cookie', 'NzbSmoke=uFZSBnDu0%243PJto1d6yFQMM5scc6KajXscEgw%3D; NzbSessionID=4a93bd5e3e1e53058284ce97b68447a0'
        
        response = http.request(req)
        response.body
      end
      
    end

    def request_url(params)
      params.delete_if {|key, value| (value == nil || value == '') }
      url = "#{@search}?searchaction=Search&fpn=p&area=-1&order=desc&areadone=-1&feed=rss&fauth=MjIwNTk1LTZmMmM2ZmI3Y2NiOWQwYjJlNDEyMWVhYTU2ZDEyMWE2ZjY4ZTQ1ZDk%3D"
      params.each_key do |key| url += "&#{key}=" + CGI::escape(params[key].to_s) end if params
      url
    end

    def search(params)
      nzbs = []
      response = XmlSimple.xml_in(http_get(request_url(params)), { 'ForceArray' => false })
      
      case response["channel"]["item"].class.name
      when "Array"
        response["channel"]["item"].each { |item| nzbs << Nzb.new(item)}
      when "Hash"
        nzbs << Nzb.new(response["channel"]["item"])
      end
      
      nzbs

    end
    
    def get_name(id)
      response = Net::HTTP.post_form(URI.parse("#{@host}#{@dnzb}"),{:username => @username, :password => @password, :reportid => id})

      case response["x-dnzb-rcode"].to_i
      when 200
        response["x-dnzb-name"]
      when 450
        puts "ERROR 450: 5 nzbs per minute please."
        false
      else 
        puts "ERROR #{response["x-dnzb-rcode"]}: #{response["x-dnzb-rtext"]}"
        false
      end

    end

    def get_nzb(id)
      response = Net::HTTP.post_form(URI.parse("#{@host}#{@dnzb}"),{:username => @username, :password => @password, :reportid => id})

      case response["x-dnzb-rcode"].to_i
      when 200
        puts "NZB downloaded OK"
        response.body
      when 450
        puts "ERROR 450: 5 nzbs per minute please."
        false
      else 
        puts "ERROR #{response["x-dnzb-rcode"]}: #{response["x-dnzb-rtext"]}"
        false
      end
    
    end
  end
  
  

  class Nzb
    attr_accessor :pub_date, :size_in_bytes, :category, :attributes, :title, :id

    def initialize(details)
      #puts details.inspect
      @pub_date = details["pubDate"]
      @size_in_bytes = details["size"]["content"]
      @category = details["category"]
      @title = details["title"]
      @id = details["id"]
      @attributes = {}

      details["attributes"]["attribute"].each do |attri|

        case @attributes.has_key? attri["type"]
        when false
          @attributes[attri["type"]] = attri["content"]
        when true
          @attributes[attri["type"]] += ", #{attri["content"]}"
        end

      end




    end
  end
    
end



# 

