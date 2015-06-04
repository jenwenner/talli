require_relative '../../Utils/Site'

class Jcrew < Site

  PRODUCT_NUMBER = 'item-num' unless const_defined?(:PRODUCT_NUMBER)
  PRODUCT_DESCRIPTION = 'product_desc' unless const_defined?(:PRODUCT_DESCRIPTION)
  PRODUCT_SIZES = 'size-box' unless const_defined?(:PRODUCT_SIZES)
  PRODUCT_COLOR_LABEL = 'color-name' unless const_defined?(:PRODUCT_COLOR_LABEL)
  PRODUCT_COLORS = 'color-box' unless const_defined?(:PRODUCT_COLORS)
  PRODUCT_PRICE = 'full-price' unless const_defined?(:PRODUCT_PRICE)
  PRODUCT_IMAGES = 'product-detail-images' unless const_defined?(:PRODUCT_IMAGES)

  def initialize file
    super()
    @urls = read_sitemap file
  end

  def product_name
    p_name = @browser.section :class => 'description'
    p_name.wait_until_present
    p_name.h1.text
  end

  def product_number
    p_num = @browser.span(:class => PRODUCT_NUMBER).span
    p_num.wait_until_present
    p_num.text
  end

  def product_description
    p_desc = @browser.div :class => PRODUCT_DESCRIPTION
    p_desc.text
  end

  def product_price
    begin
      p_price = @browser.div(:class => PRODUCT_PRICE).span
      p_price.text
    rescue
      p_price = @browser.span(:class => PRODUCT_PRICE)
      p_price.text
    end

  end

  def product_colors
    begin
      colors = Hash.new
      p_colors = @browser.divs(:class => PRODUCT_COLORS)
      p_colors.each { |item|
        c = item.img
        c.when_present.click
        id = item.attribute_value 'data-color'
        img = c.attribute_value 'src'
        color = @browser.span(:class => PRODUCT_COLOR_LABEL).text
        colors[id] = [color,img]
      }
      colors
    rescue
      nil
    end
  end

  def product_images
    begin
      images = Hash.new
      p_images = @browser.imgs(:class => PRODUCT_IMAGES)
      p_images.each { |img|
        img_w = img.attribute_value 'width'
        img_h = img.attribute_value 'height'
        img_thumbnail = img.attribute_value 'src'
        img_full = img.attribute_value 'data-imgurl'
        tmp = [img_w,img_h,img_full,img_thumbnail]
        images[Zlib.crc32(img_thumbnail).to_s] = tmp
      }
      images
    rescue
      nil
    end
  end

  def product_sizes
    begin
      sizes = Array.new
      p_sizes = @browser.divs(:class => PRODUCT_SIZES)
      p_sizes.each { |size|
        s = size.attribute_value 'data-size'
        sizes.push s
      }
      sizes
    rescue
      nil
    end
  end

  def scrape
    @urls.each{ |url|
      begin
        puts url
        open_url url

        if @browser.div(:class => 'sold-out').exists?
          next
        end

        unless url.include? 'PRDOVR'
          next
        end

        t = Hash.new
        t['name'] = product_name
        t['colors'] =  product_colors
        t['description'] = product_description
        t['product_id'] = product_number
        t['images'] = product_images
        t['price'] = product_price
        t['sizes'] = product_sizes
        puts t
        id = @mongo.modify('ingested',t['product_id'],t)
        puts id

      rescue Exception => e
        puts e.message
        next
      end
    }
  end

end