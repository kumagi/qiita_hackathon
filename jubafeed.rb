require 'jubatus/recommender/client'
require 'json'
require 'yaml'
require 'qiita'
require 'pp'

cli = Jubatus::Client::Recommender.new "127.0.0.1", 9199
config = Jubatus::Config_data.new "inverted_index", YAML.load_file('num.yaml').to_json
cli.set_config("a", config)

def convert_datum array
  param = array.map{|stock| [stock.to_s, 1.0]}
  Jubatus::Datum.new([],param)
end

TARGET_FILE = "result.txt"
QIITA = Qiita.new token: "05d1694574e340b39498dffa651474d6"
CONTINUATION = "continuation.txt"

def init
  $searched_users = []
  $user_stack = []
  $result = {}
end

def jubafeed_user_stocks(user)
  $searched_users << user
  response = QIITA.user_stocks(user, per_page: 100)
  uuids = response.map(&:uuid)
  $result[user] = uuids
  cli.update_row("a", user, convert_datum(uuids))
  p ({ user: user, uuids: uuids })
  $user_stack += (response.map(&:stock_users).flatten - $searched_users - $user_stack)
end

def run
  until $user_stack.empty?
    jubafeed_user_stocks $user_stack.shift
  end
end
init
$user_stack << "tomy_kaira"

if File.exist?(CONTINUATION)
  json = JSON.parse(File.read(CONTINUATION))
  $searched_users = json["searched_users"]
  $user_stack     = json["user_stack"]
  $result         = json["result"]
end

begin
  loop do
    begin
      run
      seed = $searched_users.pop
      init
      $user_stack << seed
    rescue => e
      pp e
    ensure
      sleep 5
    end
  end
rescue => e
  puts "error!"
  pp e
ensure
  puts "finish"
  pp $result
  File.open(TARGET_FILE, 'w') do |f|
    f.write $result.to_json
  end
  File.open(CONTINUATION, 'w') do |f|
    f.write({ searched_users: $searched_users, user_stack: $user_stack, result: $result }.to_json)
  end
end
