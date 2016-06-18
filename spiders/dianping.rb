require 'uri'
require 'net/http'
require 'json'
require 'nokogiri'

module Dianping
  @@export_folder = "./data/dianping-"
  COOKIE = <<-COOKIE
    _T_WM=56d2dc3b40a2332b80f390840f81eb1c; SUB=_2A256ZvLyDeTxGeRI4lIS8yzJzzuIHXVZqJ66rDV6PUJbkdBeLW37kW08IcmdPM9tISJ7bI8lOepCsBXukA..; SUHB=0d4_JEgZjXR5jM; SSOLoginState=1466073762; gsid_CTandWM=4uaLCpOz50y2caF4pKIXsbhSs8P; M_WEIBOCN_PARAMS=fid%3D100103type%253D1%2526q%253D%25E6%259C%259D%25E9%2598%25B3%25E5%25A4%25A7%25E6%2582%25A6%25E5%259F%258E%26uicode%3D10000011; _T_WM=56d2dc3b40a2332b80f390840f81eb1c; SUB=_2A256ZvLyDeTxGeRI4lIS8yzJzzuIHXVZqJ66rDV6PUJbkdBeLW37kW08IcmdPM9tISJ7bI8lOepCsBXukA..; SUHB=0d4_JEgZjXR5jM; SSOLoginState=1466073762; _T_WM=56d2dc3b40a2332b80f390840f81eb1c; SUB=_2A256ZvLyDeTxGeRI4lIS8yzJzzuIHXVZqJ66rDV6PUJbkdBeLW37kW08IcmdPM9tISJ7bI8lOepCsBXukA..; SUHB=0d4_JEgZjXR5jM; SSOLoginState=1466073762; gsid_CTandWM=4u7oCpOz588psL1mFLoCTbhSs8P; M_WEIBOCN_PARAMS=luicode%3D10000011%26lfid%3D100103type%253D1%2526q%253D%25E6%259C%259D%25E9%2598%25B3%25E5%25A4%25A7%25E6%2582%25A6%25E5%259F%258E%26fid%3D100103type%253D1%2526q%253D%25E8%25A5%25BF%25E5%258D%2595%25E5%25A4%25A7%25E6%2582%25A6%25E5%259F%258E%26uicode%3D10000011
  COOKIE

  class << self
    def load(*words)
      @all = []
      @shop_id = words.shift
      words.each do |word|
        file_name = @@export_folder + @shop_id.to_s + '-' + word.gsub(' ', '+') + '.txt'
        puts "------ 处理 #{word} 中 -------"
        if File.exist? file_name
          comments = IO.read(file_name).split("\n====\n")
          @all += comments
          puts "已通过缓存点评加载 #{comments.size} 条"
        else
          @all += search @shop_id, word
        end
        puts "-------------"
      end
      @all
    end

    def search(shop_id, key_word)
      puts "Begin to fetch Dianping shop #{shop_id} about #{key_word}."
      STDOUT.sync = true
      page_count = result_page_count(shop_id, key_word)
      @results = []
      File.open(@@export_folder + "#{shop_id}-#{key_word.gsub(' ', '+')}.txt", 'w') do |file|
        file.write ''
        (1..page_count).to_a.each do |i|
          hashes = '#' * (i * 50 / page_count);
          spaces = ' ' * (50 - hashes.length).to_i;
          data = get_search_result(shop_id, key_word, i);
          file << data.join("\n====\n")
          @results << data 
          print "\rWorking: [#{hashes}#{spaces}]#{key_word}(#{i}/#{page_count})"
        end
      end
      STDOUT.sync = false
      puts ''
      puts "Done! Get #{@results.flatten.size} comments totally. Data have saved at #{@@export_folder}#{shop_id}-#{key_word.gsub(' ', '+')}.txt"
      return @results.flatten.uniq
    end

    private
    def get_search_result(shop_id, key_word, page_no)
      page = get_search_page shop_id, key_word, page_no
      return page.css('.J_brief-cont').map {|c| c.content.remove_html_tag!.gsub(' ','')}
    end

    def get_search_page(shop_id, key_word, page_no = 1)
      url = URI("http://www.dianping.com/shop/#{shop_id}/review_search_#{URI.encode key_word}")

      http = Net::HTTP.new(url.host, url.port)

      request = Net::HTTP::Get.new(url)
      request["upgrade-insecure-requests"] = '1'
      request["x-devtools-emulate-network-conditions-client-id"] = '8FC9B0A8-100C-4E57-AE30-32DAFEBFB7FE'
      request["user-agent"] = 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.76 Mobile Safari/537.36'
      request["accept"] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
      request["dnt"] = '1'
      request["accept-encoding"] = 'utf-8'
      request["accept-language"] = 'zh-CN,zh;q=0.8,en-US;q=0.6,en;q=0.4'
      request["cookie"] = '_hc.v=2beeab14-a8bd-475c-9397-3ff015b844c5.1466262006; PHOENIX_ID=0a650e71-1556406af47-f25e3b1; JSESSIONID=EC17C30C50DEEBE8BDD9150D616ED414; aburl=1; cy=2; cye=beijing'
      request["cache-control"] = 'no-cache'
      request["postman-token"] = '5d2fa076-1a7c-33d9-8855-c98fddb9a90e'

      response = http.request(request)
      page = Nokogiri::HTML response.read_body
      return page
    end


    def result_page_count(shop_id, key_word)
      page = get_search_page(shop_id, key_word)
      if page.css('.Pages>a').size > 1
        return page.css('.Pages>a')[-2].content.to_i
      else
        return 1
      end
    end
  end
end
