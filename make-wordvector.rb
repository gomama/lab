#!/usr/bin/env ruby

# make-wordvector.rb
#
# last updated : 2010/05/24-17:30:27

require 'rubygems'
require 'sqlite3'
require 'open-uri'
require 'nokogiri'
require 'Hpricot'
require 'kconv'
require 'MeCab'

db = SQLite3::Database.new("sbm_count.db")
data = Hash.new
c = MeCab::Tagger.new()

# コメントタグの正規表現 refer to http://www.din.or.jp/~ohzaki/perl.htm#HTML_Tag
# Ruby だと使えない・・・？
comment_tag_regex = "<!(?:--[^-]*-(?:[^-]+-)*?-(?:[^>-]*(?:-[^>-]+)*?)??)*(?:>|$(?!\n)|--.*$)"

#comment = RegExp.new(comment_tag_regex)

db.execute("select id,url from ldclip order by id") do |row|
  begin
    doc = Nokogiri(open(URI.parse(row[1])))
    (doc/"body"/"comment()").remove
    txt =
      (doc/"body").inner_text.gsub(/\302\240/, ' ')

    #puts txt

    n = c.parseToNode(txt)
    while n do
      if n.feature =~ /^名詞/
        print n.surface, "\n"
      end
      n = n.next
    end
  rescue => ex
    puts "="*70
    puts "Error:#{ex.message}"
    puts "#{row[0]}:#{row[1]}"
    puts "="*70
  end
end

db.close


