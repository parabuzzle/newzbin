#!/usr/bin/env ruby
#
#  Created by Jon Maddox on 2007-02-10.
#  Copyright (c) 2007. All rights reserved.

require 'newzbin'

newz = Newzbin::Connection.new("RKTU0McXx%24Uc4e4KXP1L0sl4O1U9YOchO%2B0DA%3D", "a0fed567eb1a3e6e95c8a3d46fe0c6e7", 'seven5', 'pass')
nzbs = newz.search(:q => 'independence day', :ps_rb_video_format => 16, "category"=>"6", "commit"=>"search")
# 1073741824
#puts nzbs.inspect

puts nzbs.first.title
puts nzbs.first.attributes.inspect







#newz.get_nzb(nzbs.first.id)


# http://v3.newzbin.com/search/?q=casino+royale&searchaction=Search&fpn=p&category=-1&area=-1&u_nfo_posts_only=0&u_url_posts_only=0&u_comment_posts_only=0&u_v3_retention=5184000&ps_rb_source=64&ps_rb_video_format=16&sort=ps_edit_date&order=desc&areadone=-1&feed=rss&fauth=MjIwNTk1LTJkZWM4Yjk3NGU4Mjg2ODc2ODRiZmI5ZWVkMjE2NjNkNTIwMDA4MmI%3D
# http://v3.newzbin.com/search/?q=casino+royale&searchaction=Search&fpn=p&category=-1&area=-1&u_nfo_posts_only=0&u_url_posts_only=0&u_comment_posts_only=0&u_v3_retention=5184000                &ps_rb_video_format=13&sort=ps_edit_date&order=desc&areadone=-1&feed=rss&fauth=MjIwNTk1LTZmMmM2ZmI3Y2NiOWQwYjJlNDEyMWVhYTU2ZDEyMWE2ZjY4ZTQ1ZDk%3D

# q=casino+royale
# searchaction=Search
# fpn=p
# category=-1
# area=-1
# u_nfo_posts_only=0
# u_url_posts_only=0
# u_comment_posts_only=0
# u_v3_retention=5184000
# ps_rb_video_format=131072
# sort=ps_edit_date
# order=desc
# areadone=-1
# feed=rss
# fauth=MjIwNTk1LTZmMmM2ZmI3Y2NiOWQwYjJlNDEyMWVhYTU2ZDEyMWE2ZjY4ZTQ1ZDk%3D