require 'qiita'
require 'json'
require 'redcarpet'
require 'redcarpet/render_strip'
require 'term/ansicolor'

C = Term::ANSIColor

# articles = ["d2893476d39b4d120c57","1a3fcfb9cdb60745fead","a4e494fef27e477ecad3","2fa140c93c9ef2b0a7c4","72ada26499a3c182b47a","b586818e60b8fc7ce68f","bf47e254d662af1294d8","c686397e4a0f4f11683d","e84f5aad7757afce82ba","f41b492203b6136ba77a"]

# QIITA = Qiita.new token: "40e0577f4c5446d3a71564186def9963"

# objects = articles.map { |uuid| QIITA.item(uuid) }
# puts objects.to_json

objects = JSON.parse(File.read("item_jsons.json"))

objects.each do |d|
  puts "#{C.blue + C.bold}%s [%3s] %s [ %s ]#{C.reset}" % [d["user"]["url_name"].ljust(10), d["stock_count"], d["title"], "http://qiita.com/items/" + d["uuid"]]
  puts Redcarpet::Markdown.new(Redcarpet::Render::StripDown.new).render(d["raw_body"]).
    split("\n").
    take(5).
    map{ |l| "    " + l }.
    join("\n")
end
