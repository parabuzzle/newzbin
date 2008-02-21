require 'rubygems'
require 'net/http'
require 'cgi'
require 'xmlsimple'

module Newzbin
  
  class Connection

    def initialize(NzbSmoke=nil, NzbSessionID=nile, username=nil, password=nil)
      @host = 'http://v3.newzbin.com'
      @search = '/search/'
      @dnzb = '/dnzb'
      @username = username
      @password = password
      @NzbSmoke = NzbSmoke
      @NzbSessionID = NzbSessionID
    end

    def http_get(url)
      Net::HTTP.start('v3.newzbin.com') do |http|
        req = Net::HTTP::Get.new(url)
        req.add_field 'Cookie', "NzbSmoke=#{@NzbSmoke}; NzbSessionID=#{@NzbSessionID}" if @NzbSmoke && @NzbSessionID
        response = http.request(req)
        response.body
      end
      
    end

    def request_url(params)
      params.delete_if {|key, value| (value == nil || value == '') }
      url = "#{@search}?searchaction=Search&fpn=p&area=-1&order=desc&areadone=-1&feed=rss&u_nfo_posts_only=0&sort=ps_edit_date&order=desc&u_url_posts_only=0&u_comment_posts_only=0&u_v3_retention=9504000"
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
      }

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
      @pub_date = details["pubDate"]
      @size_in_bytes = details["size"]["content"]
      @category = details["category"]
      @title = details["title"]
      @id = details["id"]
      @info_url = details["moreinfo"]
      @attributes = {}
      

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
