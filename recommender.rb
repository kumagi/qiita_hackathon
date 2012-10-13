require 'jubatus/recommender/client'
require 'json'
require 'yaml'
require 'qiita'
require 'pp'

module Recommender
  class << self
    def convert_datum array
      param = array.map{|stock| [stock.to_s, 1.0]}
      Jubatus::Datum.new([],param)
    end

    def recommend user
      cli = Jubatus::Client::Recommender.new "127.0.0.1", 9199
      qiita = Qiita.new token: "05d1694574e340b39498dffa651474d6"
      inverse_map = "inverse_map.json"
      abort "put the user name" if user.nil?

      already_stocks = qiita.user_stocks(user, per_page: 100).map(&:uuid)

      result = cli.complete_row_from_id "a",user
      items_name = result.num_values.map{|k| k[0]} - already_stocks

      inverse = JSON.parse(File.read(inverse_map))
      posts = items_name.map{ |id| [id,inverse[id].to_i] }.sort{|r,l| l[1]<=>r[1] }.map{ |x| x[0]}
      posts
    end
  end
end
