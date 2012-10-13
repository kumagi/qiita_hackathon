require 'jubatus/recommender/client'
require 'json'
require 'yaml'
require 'qiita'
require 'pp'

$cli = Jubatus::Client::Recommender.new "127.0.0.1", 9199
user_name = ARGV[0]
seed_file = "tag_result.json"


def convert_datum array
  param = array.map{|stock| [stock.to_s, 1.0]}
  Jubatus::Datum.new([],param)
end

seed = JSON.parse(File.read(seed_file))
result = $cli.complete_row_from_id "a", user_name
tags = result.num_values.map{|k|k[0]} - seed[user_name]
pp tags.slice(0..10)
