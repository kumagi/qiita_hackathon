#!/usr/bin/env ruby

require 'qiita'
require 'json'
require 'redcarpet'
require './qiita_item'

QiitaItem.download_items_to_read.each(&:print)
