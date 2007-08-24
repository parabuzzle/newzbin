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
      @dnzb = '/dnzb'
      @username = username
      @password = password
    end

    def http_get(url)

      Net::HTTP.start('v3.newzbin.com') do |http|
        req = Net::HTTP::Get.new(url)
        req.add_field 'Cookie', 'NzbSmoke=1ufqulyHF%24UAMVQTnKpnqJOfA3MH7TDCQ2gPU%3D; NzbSessionID=1d7812a564a222b6f1370e6e68186be7'
        
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
      http = Net::HTTP.new(@host)
      
      http.request_post('/dnzb', "username=#{@username}&password=#{@password}&reportid=#{id}") {|response|
        p response.status
        p response['content-type']
        # response.read_body do |str|   # read body now
        #   print str
        # end
      }
      
      # response = http.post(@dnzb, "username=#{@username}&password=#{@password}&reportid=#{id}")
      
      # response = Net::HTTP.post_form(URI.parse("#{@host}#{@dnzb}"),{:username => @username, :password => @password, :reportid => id})

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
    attr_accessor :pub_date, :size_in_bytes, :category, :attributes, :title, :info_url, :id

    def initialize(details)
      #puts details.inspect
      @pub_date = details["pubDate"]
      @size_in_bytes = details["size"]["content"]
      @category = details["category"]
      @title = details["title"]
      @id = details["id"]
      @info_url = details["moreinfo"]
      @attributes = {}
      
      # puts details["attributes"]["attribute"].class.n

      case details["attributes"]["attribute"].class.name
      when "Array"
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
    
end
