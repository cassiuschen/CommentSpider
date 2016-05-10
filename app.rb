#! /usr/bin/env ruby
# coding: utf-8
# Code By Cassius Chen

require 'uri'
require 'net/http'
require 'json'
require 'classifier-reborn'

module Autohome
  @@comment_ids = []
  @@comments = []
  @@contents = []


  @@export_file = "data.txt"
  @@export_ids = 'id.txt'
  @@export_analyze = "analyze.txt"

  class << self
    def load_files(id_file = @@export_ids, data_file = @@export_file)
      @@comment_ids = IO.read(id_file).split.map {|i| i.to_i}
      @@comment_ids.delete_if {|i| i < 10000}

      @@contents = IO.read(data_file)
      puts "Loaded #{@@comment_ids.size} comments with #{@@contents.length} words."
    end

    def comments_id
      @@comment_ids
    end

    def comments
      @@comments
    end

    def contents
      @@contents
    end

    def set_output(file)
      @@export_file = file
    end

    def set_output_ids(file)
      @@export_ids = file
    end

    def get_ids
      first = get_part_list 1
      page_count = first['pagecount'].to_i
      puts "Found #{page_count} pages! "
      puts "Begin to get IDs :"
      STDOUT.sync = true
      File.open(@@export_ids, 'w') do |file|
        file.write ''
        for i in (1..page_count).to_a do
          data = get_part_list(i)
          ids = data["list"].map {|d| d["specid"]}
          @@comment_ids << ids
          ids.map {|i| i.to_s + "\n"}.each {|id| file << id}

          hashes = '#' * (i * 50 / page_count.to_i)
          spaces = ' ' * (50 - hashes.length).to_i
          print "\rWorking: [#{hashes}#{spaces}](#{i}/#{page_count})  => #{ids.last}"
        end
      end
      STDOUT.sync = false
      puts ''
      @@comment_ids = @@comment_ids.flatten
      @@comment_ids.delete_if {|i| i < 10000}
      puts "Done! #{@@comment_ids.size} comments are ready to get!"
    end

    def get_comments
      puts "=" * 80
      puts "Begin to fetch comment data."
      STDOUT.sync = true
      File.open(@@export_file, 'w') do |file|
        i = 0
        file.write ''
        for id in @@comment_ids
          i += 1
          comment = get_comment id
          @@comments << comment
          @@contents << comment['content'].gsub("\r\n",'').gsub(/【..】|【...】|【....】|【......】|【.......】/, '')
          file << comment['content'].gsub("\r\n",'').gsub(/【..】|【...】|【....】|【......】|【.......】/, '')
          file << "\n"
          hashes = '#' * (i * 50 / @@comment_ids.size)
          spaces = ' ' * (50 - hashes.length).to_i
          print "\rWorking: [#{hashes}#{spaces}](#{i}/#{@@comment_ids.size}) => #{@@contents.length} words"
        end
      end
      STDOUT.sync = false
      puts ''
      puts "Done! Get #{@@contents.size} words totally."
    end

    def get_result(count = 20)
      results = TextAnalyzer.count @@contents
      results = results.sort_by {|r| -r.first.last}
      File.open(@@export_analyze, 'w') do |file|
        file.write ''
        results.each do |i|
          file << "#{i.first.first}\t#{i.first.last}"
          file << "\n"
        end
      end
      return results.first(count)
    end

    private
    def get_part_list(page)
      url = URI("http://112.253.38.239/autov5.5.0/alibi/seriesalibiinfos-pm1-ss66-st0-p#{page}-s20.json")

      http = Net::HTTP.new(url.host, url.port)

      request = Net::HTTP::Get.new(url)
      request["host"] = 'koubei.app.autohome.com.cn'
      request["user-agent"] = 'iPhone 9.3.1 autohome 5.8.1 iPhone'
      request["connection"] = 'keep-alive'
      request["accept-encoding"] = 'uft-8'
      request["cache-control"] = 'no-cache'

      response = http.request(request)
      return JSON.parse(response.body)['result']
    end

    def get_comment(id)
      url = URI("http://101.23.128.10/autov5.5.0/alibi/alibiinfobase-pm1-k#{id}.json")

      http = Net::HTTP.new(url.host, url.port)

      request = Net::HTTP::Get.new(url)
      request["host"] = 'koubei.app.autohome.com.cn'
      request["user-agent"] = 'iPhone 9.3.1 autohome 5.8.1 iPhone'
      request["connection"] = 'keep-alive'
      request["accept-encoding"] = 'uft-8'
      request["cache-control"] = 'no-cache'

      response = http.request(request)
      return JSON.parse(response.body)['result']
    end
  end
end

class TextAnalyzer
  class << self
    def count(array)
      checker = ClassifierReborn::Bayes.new('result','junk')
      result = checker.train("result", array.concat("\n"))
      return result.map {|k,v| {k.to_s.force_encoding('utf-8') => v}}
    end
  end
end

#Autohome.get_ids
#Autohome.get_comments
