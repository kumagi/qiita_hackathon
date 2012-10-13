require 'jubatus/recommender/client'
require 'json'
require 'yaml'
require "ap"
require 'qiita'
cli = Jubatus::Client::Recommender.new "127.0.0.1", 9199

def convert_datum array
  param = array.map{|stock| [stock.to_s, 1.0]}
  Jubatus::Datum.new([],param)
end


config = Jubatus::Config_data.new "inverted_index", YAML.load_file('num.yaml').to_json
cli.set_config("a", config)
user_stocks = JSON.parse(File.read("qiita_stocks_tomy_kaira_uuid.json"))

user_names = user_stocks.map{ |k,v| k}

user_stocks.each{ |user, stocks|
  fv = convert_datum stocks
  cli.update_row("a", user, fv)
}

#from = convert_datum(user_stocks["tomy_kaira"])
#good_items = cli.complete_row_from_data("a", from)

result = cli.complete_row_from_id "a","tomy_kaira"
items_name = result.num_values.map{|k| k[0]} - user_stocks["tomy_kaira"]

#items_name = good_items.num_values.map{|k| k[0] } - user_stocks["tomy_kaira"]

#ap items_name

inverse = {  }
user_stocks.each { |user, ids|
  ids.each { |id|
    inverse[id] ||= []
    inverse[id] << user
  }
}

#ap inverse


posts = items_name.map{ |id| [id,inverse[id].size] }.sort{|r,l| l[1]<=>r[1]}.slice(0..4).map{ |x| x[0]}
posts.each{ |post|
  puts Qiita.item(post).title + " "
}

#pp inverse

