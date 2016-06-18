module Weibo
  @@export_folder = "./data/"
  @@export_ids = 'id.txt'
  @@export_analyze = "analyze.txt"
  COOKIE = <<-COOKIE
    _T_WM=56d2dc3b40a2332b80f390840f81eb1c; SUB=_2A256ZvLyDeTxGeRI4lIS8yzJzzuIHXVZqJ66rDV6PUJbkdBeLW37kW08IcmdPM9tISJ7bI8lOepCsBXukA..; SUHB=0d4_JEgZjXR5jM; SSOLoginState=1466073762; gsid_CTandWM=4uaLCpOz50y2caF4pKIXsbhSs8P; M_WEIBOCN_PARAMS=fid%3D100103type%253D1%2526q%253D%25E6%259C%259D%25E9%2598%25B3%25E5%25A4%25A7%25E6%2582%25A6%25E5%259F%258E%26uicode%3D10000011; _T_WM=56d2dc3b40a2332b80f390840f81eb1c; SUB=_2A256ZvLyDeTxGeRI4lIS8yzJzzuIHXVZqJ66rDV6PUJbkdBeLW37kW08IcmdPM9tISJ7bI8lOepCsBXukA..; SUHB=0d4_JEgZjXR5jM; SSOLoginState=1466073762; _T_WM=56d2dc3b40a2332b80f390840f81eb1c; SUB=_2A256ZvLyDeTxGeRI4lIS8yzJzzuIHXVZqJ66rDV6PUJbkdBeLW37kW08IcmdPM9tISJ7bI8lOepCsBXukA..; SUHB=0d4_JEgZjXR5jM; SSOLoginState=1466073762; gsid_CTandWM=4u7oCpOz588psL1mFLoCTbhSs8P; M_WEIBOCN_PARAMS=luicode%3D10000011%26lfid%3D100103type%253D1%2526q%253D%25E6%259C%259D%25E9%2598%25B3%25E5%25A4%25A7%25E6%2582%25A6%25E5%259F%258E%26fid%3D100103type%253D1%2526q%253D%25E8%25A5%25BF%25E5%258D%2595%25E5%25A4%25A7%25E6%2582%25A6%25E5%259F%258E%26uicode%3D10000011
  COOKIE

  class << self
    def load_files(id_file = @@export_ids, data_file = @@export_file)
      @@comment_ids = IO.read(id_file).split.map {|i| i.to_i}
      @@comment_ids.delete_if {|i| i < 10000}

      @@contents = IO.read(data_file)
      puts "Loaded #{@@comment_ids.size} comments with #{@@contents.length} words."
    end

#    def comments_id
#      @@comment_ids
#    end#

#    def comments
#      @@comments
#    end#

#    def contents
#      @@contents
#    end#

#    def set_output(file)
#      @@export_file = file
#    end#

#    def set_output_ids(file)
#      @@export_ids = file
#    end#

#    def get_ids
#      first = get_part_list 1
#      page_count = first['pagecount'].to_i
#      puts "Found #{page_count} pages! "
#      puts "Begin to get IDs :"
#      STDOUT.sync = true
#      File.open(@@export_ids, 'w') do |file|
#        file.write ''
#        for i in (1..page_count).to_a do
#          data = get_part_list(i)
#          ids = data["list"].map {|d| d["specid"]}
#          @@comment_ids << ids
#          ids.map {|i| i.to_s + "\n"}.each {|id| file << id}#

#          hashes = '#' * (i * 50 / page_count.to_i)
#          spaces = ' ' * (50 - hashes.length).to_i
#          print "\rWorking: [#{hashes}#{spaces}](#{i}/#{page_count})  => #{ids.last}"
#        end
#      end
#      STDOUT.sync = false
#      puts ''
#      @@comment_ids = @@comment_ids.flatten
#      @@comment_ids.delete_if {|i| i < 10000}
#      puts "Done! #{@@comment_ids.size} comments are ready to get!"
#    end

#    def get_comments
#      puts "=" * 80
#      puts "Begin to fetch comment data."
#      STDOUT.sync = true
#      File.open(@@export_file, 'w') do |file|
#        i = 0
#        file.write ''
#        for id in @@comment_ids
#          i += 1
#          comment = get_comment id
#          @@comments << comment
#          @@contents << comment['content'].gsub("\r\n",'').gsub(/【..】|【...】|【....】|【......】|【.......】/, '')
#          file << comment['content'].gsub("\r\n",'').gsub(/【..】|【...】|【....】|【......】|【.......】/, '')
#          file << "\n"
#          hashes = '#' * (i * 50 / @@comment_ids.size)
#          spaces = ' ' * (50 - hashes.length).to_i
#          print "\rWorking: [#{hashes}#{spaces}](#{i}/#{@@comment_ids.size}) => #{@@contents.length} words"
#        end
#      end
#      STDOUT.sync = false
#      puts ''
#      puts "Done! Get #{@@contents.size} words totally."
#    end

#    def get_result(count = 20)
#      results = TextAnalyzer.count @@contents
#      results = results.sort_by {|r| -r.first.last}
#      File.open(@@export_analyze, 'w') do |file|
#        file.write ''
#        results.each do |i|
#          file << "#{i.first.first}\t#{i.first.last}"
#          file << "\n"
#        end
#      end
#      return results.first(count)
#    end
    def search_word(key_word)
      puts "Begin to fetch Weibo about #{key_word}."
      STDOUT.sync = true
      page_count = result_page_count(key_word)
      @results = []
      File.open(@@export_folder + "#{key_word}.txt", 'w') do |file|
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
      puts "Done! Get #{@results.flatten.size} Weibo totally. Data have saved at #{@@export_folder}#{key_word}.txt"
      return @results.flatten
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