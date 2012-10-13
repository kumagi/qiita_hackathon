#!/usr/bin/env ruby

require 'qiita'
require 'json'
require 'redcarpet'
require './qiita_item'

unless ARGV.count == 1
  puts "Usage: jubafeed.rb YOUR_QIITA_USER_NAME"
  puts "Set your token with export QIITA_TOKEN=[YOUR_TOKEN]"
  exit 1
end

QiitaItem.download_items_to_read.each(&:print)
