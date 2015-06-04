require_relative 'Globals'

class SitemapScraper

  def initialize(sitemap,dir)
    @sitemap_dir = dir
    puts 'Scanning - ' + sitemap
    @domain = sitemap.split(/\//)[2]
    create_dir @domain
    xml = fetch sitemap
    unless xml.nil?
      crawl REXML::Document.new(xml)
    end
    puts
  end

  def fetch(sitemap)
    puts 'Fetching sitemap - ' + sitemap
    Net::HTTP.get_response(URI.parse(sitemap)).body
  rescue
    nil
  end

  def crawl(sitemap)
    sub_sitemap sitemap
    fetch_urls sitemap
  end

  def sub_sitemap(sitemap)
    sitemap.elements.each('sitemapindex/sitemap/loc') { |sub_sitemap|
      puts 'Found sub sitemap, ' + sub_sitemap.text + ' beginning crawl...'

      parts = sub_sitemap.text.split(/\//)
      if parts.size < 4
        puts "Discarding Sitemap - #{sub_sitemap.text}"
        next
      else
        @category = parts[3]
        if @category.nil?
          @category = 'products'
        else
          create_dir @domain + '/' + @category
        end
        fetch_urls sub_sitemap.text
      end
    }
  end

  def fetch_urls sitemap
    urls = Array.new

    if sitemap.include? 'xml'
      puts 'Fetching urls from ' + sitemap
      xml = REXML::Document.new(fetch sitemap)
    else
      xml = sitemap
    end

    xml.elements.each('urlset/url/loc') { |url|
      urls.push url.text
    }
    puts 'Scraped ' + urls.size.to_s
    if @category.nil?
      @category = 'products'
      create_dir @domain + '/' + @category
    end
    create_file(@sitemap_dir + '/' + @domain + '/' + @category +'/' + 'urls.txt', urls)
  end

  def create_dir(path)
    unless path.nil?
      Dir.mkdir(@sitemap_dir + '/' + path.to_s) unless File.exists?(@sitemap_dir + '/' + path.to_s)
    end
  end

  def create_file(file,urls)
    puts 'Creating ' + file + ' with ' + urls.size.to_s + ' urls'
    File.open(file,'a') {
        |f| urls.each { |line|
        f << line
        f << "\n"
      }
    }
  end

end