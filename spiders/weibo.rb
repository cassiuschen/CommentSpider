require 'uri'
require 'net/http'
require 'json'

module Weibo
  @@export_folder = "./data/weibo-"

  class << self
    def search(*words)
      words.each do |ward|
        search_word(words)
      end
    end

    def load(*words)
      @all = []
      words.each do |word|
        file_name = @@export_folder + word.gsub(' ', '+') + '.txt'
        puts "------ 处理 #{word} 中 -------"
        if File.exist? file_name

          weibo = IO.read(file_name).split("\n====\n")
          @all += weibo
          puts "已通过缓存微博加载 #{weibo.size} 条"
        else
          @all += search_word word
        end
        puts "-------------"
      end
      @all
    end

    def search_word(key_word)
      puts "Begin to fetch Weibo about #{key_word}."
      STDOUT.sync = true
      page_count = result_page_count(key_word)
      @results = []
      File.open(@@export_folder + "#{key_word.gsub(' ', '+')}.txt", 'w') do |file|
        file.write ''
        (1..page_count).to_a.each do |i|
          hashes = '#' * (i * 50 / page_count);
          spaces = ' ' * (50 - hashes.length).to_i;
          data = get_search_page(key_word, i);
          file << data.join("\n====\n")
          @results << data 
          print "\rWorking: [#{hashes}#{spaces}]#{key_word}(#{i}/#{page_count})"
        end
      end
      STDOUT.sync = false
      puts ''
      puts "Done! Get #{@results.flatten.size} Weibo totally. Data have saved at #{@@export_folder}#{key_word.gsub(' ', '+')}.txt"
      return @results.flatten.uniq
    end

    private
    def get_search_result(key_word, page = 1)
      params = {
        containerid: "100103type=7&q=#{key_word}&weibo_type=filter_hasori",
        title: "原创微博-#{key_word}",
        cardid: 'weibo_page',
        uid: 2690332547,
        luicide: 10000011,
        lfid: "100103type=42&q=#{key_word}&t=",
        v_p: 11,
        ext: '',
        fid:"100103type=42&q=#{key_word}&t=",
        uicode: 10000011,
        page: page
      }

      url = URI("http://m.weibo.cn/page/pageJson?#{params.to_url_params}")
      http = Net::HTTP.new(url.host, url.port)
      request = Net::HTTP::Get.new(url)
      response = http.request(request)
      $response = response.body
      return JSON.parse response.body
    end

    def get_search_page(key_word, page = 1)
      data = get_search_result(key_word, page)
      return data["cards"].map {|d| d["card_group"]}.flatten.map {|c| c["mblog"]["text"].remove_html_tag!}
    end

    def result_page_count(key_word)
      return get_search_result(key_word, 1)["maxPage"].to_i
    end
  end
end
