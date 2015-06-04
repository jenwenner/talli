require_relative '../Utils/Globals'
require_relative '../Utils/MongoHelper'
require_relative '../Scraper/Sites/Jcrew'

def crawl(file)
  runner = Jcrew.new file
  runner.scrape
end

Dir['../Sitemaps/Sites/**/*'].map { |a|
  file = File.basename(a)
  if file == 'urls.txt'
    crawl a
  end
}

