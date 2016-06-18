#! /usr/bin/env ruby
# coding: utf-8
# Code By Cassius Chen

require './lib/analyzer'
require './lib/ext'
require './spiders/weibo'
require './spiders/dianping'

@weibo = Weibo.load "朝阳大悦城 会员", "朝悦 会员", "大悦城 会员", "西单大悦城 会员", "朝阳大悦城 app", "朝悦 app"
@dianping = Dianping.load(3158110, '会员').concat(Dianping.load(2373535, '会员')).concat(Dianping.load(3158110, 'app'))

junk_analyzer = JunkAnalyzer.new

$all = @weibo.concat @dianping
puts ''
$good_data = $all.select {|comment| junk_analyzer.classifier.classify(comment) == "Good"}
puts "总数据：#{$all.size}, 有效数据：#{$good_data.size}, 数据有效率：#{$good_data.size * 100 / $all.size}%"

@ranker = ClassifierReborn::Bayes.new Dianping::RATING.values
ranker_data = File.read('./training/rank').split("\n")
ranker_data.each do |rank|
  content = rank.split(':')
  level = content.shift
  @ranker.train level, content.join('')
end

$score = $good_data.map {|comment| Dianping::RATING.invert[@ranker.classify comment]}
puts "服务评价分数：#{$score.sum / $score.size.to_f}"

File.open('./result.txt', 'w') do |file|
  file.write ''
  raw = TextAnalyzer.count $good_data
  raw.each do |r|
    file << "#{r.keys.first}\t#{r.values.first}\n"
  end
end

