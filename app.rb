#! /usr/bin/env ruby
# coding: utf-8
# Code By Cassius Chen

require 'classifier-reborn'
require './spiders/ext'
require './spiders/weibo'

class TextAnalyzer
  class << self
    def count(array)
      checker = ClassifierReborn::Bayes.new('result','junk')
      result = checker.train("result", array.concat("\n"))
      return result.map {|k,v| {k.to_s.force_encoding('utf-8') => v}}
    end
  end
end

Weibo.load "朝阳大悦城 会员", "朝悦 会员", "大悦城 会员", "西单大悦城 会员"
