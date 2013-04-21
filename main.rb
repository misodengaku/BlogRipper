# -*- coding: utf-8 -*- 
require 'thread'
require 'nokogiri'
require 'open-uri'
require 'parallel'

Article = Struct.new(:title, :url)

def getImageLinks(url, cssSelecter)
	doc = Nokogiri::HTML(open(url))
	images = []
	doc.css(cssSelecter).css("a").map {
		|e|
			if e["href"] != nil then
				if e["href"].end_with?("jpg") then
					images << Article.new(doc.title(), e["href"])
				end
			end
			#doc = Nokogiri::HTML(html)
	}
	return images
end

images = getImageLinks("http://blog.livedoor.jp/vipperchannel41/archives/25154121.html", "div.article-body-inner")#.each{ |item|
#	#puts(item.url)
#	FileUtils.mkdir_p(item.title) unless FileTest.exist?(item.title)
#	Dir::chdir(item.title)
#	open(item.url) do |source|
#		open(File.basename(item.url), "w+b") do |o|
#			o.print source.read
#		end
#	end
#	Dir::chdir("../")
#}

Parallel.map(images, :in_threads => 10) {|item|
	FileUtils.mkdir_p(item.title) unless FileTest.exist?(item.title)
	Dir::chdir(item.title)
	puts "download: #{item.url}"
	open(item.url) do |source|
		open(File.basename(item.url), "w+b") do |o|
			o.print source.read
		end
	end
	puts "downloaded: #{item.url}"
	Dir::chdir("../")
}
