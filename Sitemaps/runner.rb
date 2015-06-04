require_relative '../Utils/SitemapScraper'

sitemaps = Array.new

File.open 'sitemaps.txt' do |f|
  puts 'Scanning sitemaps.txt...'
  f.each_line { |line| sitemaps << line }
  puts 'Done scanning!'
  puts 'Found: ' + sitemaps.size.to_s + ' sitemaps to crawl'
  puts
end

sitemaps.each { |sitemap|
  SitemapScraper.new(sitemap,'../Sitemaps/Sites')
}

puts
puts 'Done crawling sitemaps!'