require 'qiita'
require './recommender'
require './redcarpet_render_terminal'

class QiitaItem
  READ_ARTICLE_IDS_FILE = "read_article_ids.txt"
  C = Term::ANSIColor

  def initialize(item)
    @item = item
  end

  def print
    puts "#{C.blue + C.bold}%s [%3s] %s\n[ %s ]#{C.reset}" % [d["user"]["url_name"].ljust(10), d["stock_count"], d["title"], "http://qiita.com/items/" + d["uuid"]]
    puts Redcarpet::Markdown.new(Redcarpet::Render::Terminal.new).render(d["raw_body"]).
      gsub(/\n\n\n/, "\n\n").
      split("\n").
      take(10).
      map{ |l| "    " + l }.
      join("\n").rstrip + "\n    (Cont.)"
    puts ""
  end

  class << self
    def download_items_to_read
      uuids = recommended_uuids
      mark_read_articles(uuids)
      puts "Downloading articles to read..."
      uids.map { |uuid| puts "Dowloading #{uuid}"; qiita.item(uuid) }
    end

    def read_articles
      if File.exist?(READ_ARTICLE_IDS_FILE)
        File.readlines(READ_ARTICLE_IDS_FILE).map(&:strip)
      else
        []
      end
    end

    def mark_read_articles(ids)
      File.open(READ_ARTICLE_IDS_FILE, 'a') { |f| f.puts(ids.join("\n")) }
    end

    def recommended_uuids
      (recommend("tomy_kaira") - read_articles)
    end

    def qiita
      Qiita.new token: ENV['QIITA_TOKEN']
    end
  end
end
