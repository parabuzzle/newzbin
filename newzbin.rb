require 'rubygems'
require 'net/http'
require 'cgi'
require 'xmlsimple'
require "mechanize"

module Newzbin
  class NZBLimitError < StandardError
  end
  
  class Connection

    attr_accessor :agent, :host, :search_path, :dnzb_path, :username, :password
    

    def initialize(username, password)
      self.agent = WWW::Mechanize.new
      self.host = 'http://v3.newzbin.com'
      self.search_path = '/search/'
      self.dnzb_path = '/dnzb'
      self.username = username
      self.password = password
      log_in
    end

    def http_get(path)
      self.agent.get(self.host + path).body
    end

    def request_url(params)
      params.delete_if {|key, value| (value == nil || value == '') }
      url = "#{self.search_path}?searchaction=Search&fpn=p&area=-1&order=desc&areadone=-1&feed=rss&u_nfo_posts_only=0&sort=ps_edit_date&order=desc&u_url_posts_only=0&u_comment_posts_only=0&u_v3_retention=9504000&commit=search"
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
      http = Net::HTTP.new(self.host)
      
      http.request_post(self.dnzb_path, "username=#{self.username}&password=#{self.password}&reportid=#{id}") {|response|
        p response.status
        p response['content-type']
      }

      case response["x-dnzb-rcode"].to_i
      when 200
        response["x-dnzb-name"]
      when 450
        puts "ERROR 450: 5 nzbs per minute please."
        raise NZBLimitError
      else 
        puts "ERROR #{response["x-dnzb-rcode"]}: #{response["x-dnzb-rtext"]}"
        false
      end

    end

    def get_nzb(id)
      response = Net::HTTP.post_form(URI.parse("#{self.host}#{self.dnzb_path}"),{:username => self.username, :password => self.password, :reportid => id})

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
    
    private
    
    def log_in
      login_page = self.agent.get('http://v3.newzbin.com/')
      login_form = login_page.forms.action('/account/login/').first

      login_form.username = self.username
      login_form.password = self.password

      self.agent.submit(login_form)
      
    end
  end
  
  

  class Nzb
    attr_accessor :pub_date, :size_in_bytes, :category, :attributes, :title, :info_url, :id

    def initialize(details)
      self.pub_date = details["pubDate"]
      self.size_in_bytes = details["size"]["content"]
      self.category = details["category"]
      self.title = details["title"]
      self.id = details["id"]
      self.info_url = details["moreinfo"]
      self.attributes = {}
      

      case details["attributes"]["attribute"].class.name
      when "Array"
        details["attributes"]["attribute"].each do |attri|

          case self.attributes.has_key? attri["type"]
          when false
            self.attributes[attri["type"]] = attri["content"]
          when true
            self.attributes[attri["type"]] += ", #{attri["content"]}"
          end

        end
      end


    end
  end
    
end
