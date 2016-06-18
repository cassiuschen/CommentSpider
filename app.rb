#! /usr/bin/env ruby
# coding: utf-8
# Code By Cassius Chen

require './lib/analyzer'
require './lib/ext'
require './spiders/weibo'
require './spiders/dianping'

Weibo.load "朝阳大悦城 会员", "朝悦 会员", "大悦城 会员", "西单大悦城 会员"
Dianping.load 3158110, '会员'
