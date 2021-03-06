#!/usr/bin/env ruby

require 'jubatus/recommender/client'
require 'json'
require 'yaml'
require 'qiita'
require 'pp'

$cli = Jubatus::Client::Recommender.new "127.0.0.1", 9199
config = Jubatus::Config_data.new "inverted_index", YAML.load_file('num.yaml').to_json
$cli.set_config("a", config)
seed_file = "qiita_stocks_tomy_kaira_uuid.json"

def convert_datum array
  param = array.map{|stock| [stock.to_s, 1.0]}
  Jubatus::Datum.new([],param)
end

seed = JSON.parse(File.read(seed_file))
seed.each{ |user, uuids|
  fv = convert_datum uuids
  $cli.update_row("a", user, fv)
}
puts "update finished."
