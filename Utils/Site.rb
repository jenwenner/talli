require_relative '../Utils/MongoHelper'

class Site

  def initialize
    @mongo = MongoHelper.new('52.10.61.212',27017,'talli')
    Watir::always_locate = true
    Watir::default_timeout = 10
    @browser = Watir::Browser.new(:chrome)
    @browser.driver.manage.timeouts.implicit_wait = 10
  end

  def open_url(url)
    @browser.goto url
  end

  def read_sitemap file
    urls = Array.new
    File.open(file, 'r') do |f|
      f.each_line do |line|
        urls << line
      end
    end
    urls
  end

end