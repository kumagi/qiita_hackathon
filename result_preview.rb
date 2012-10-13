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

module Redcarpet
  module Render
    class Terminal < Base
      CODE_COLOR = C.cyan

      [
        # block-level calls
        :block_code, :block_quote,
        :block_html, :header, :list,
        :list_item, :paragraph,

        # span-level calls
        :autolink, :codespan, :double_emphasis,
        :emphasis, :raw_html, :triple_emphasis,
        :strikethrough, :superscript,

        # low level rendering
        :entity, :normal_text
      ].each do |method|
        define_method method do |*args|
          args.first
        end
      end

      # def initialize
      #   reset_list_count
      # end

      def normal_text(text)
        text
      end

      def block_code(code, language)
        "\n#{color(indent(code, 4), CODE_COLOR)}\n"
      end

      def codespan(code)
        block_code(code, nil)
      end

      def header(title, level)
        "\n" + color("#{'#'*level} #{title}", C.bold + C.green) + "\n"
      end

      def double_emphasis(text)
        color(text, C.bold + C.red)
      end

      def emphasis(text)
        color(text, C.bold)
      end

      def linebreak
        "\n"
      end

      def paragraph(text)
        "\n#{text}\n"
      end

      # def list(content, list_type)
      #   "\n#{content}\n"
      #   reset_list_count
      # end

      # def list_item(content, list_type)
      #   case list_type
      #   when :ordered
      #     "#{@ordered_list_count}. #{content}\n"
      #     @ordered_list_count += 1
      #   when :unordered
      #     "- #{content}\n"
      #   end
      # end


      # Other methods where the text content is in another argument
      def link(link, title, content)
        content
      end
      private
      def reset_list_count
        @ordered_list_count = 1
      end

      def indent(text, indent = 4)
        text.split(/\r\n|\r|\n/).map{ |l| (' ' * indent) + l }.join("\n")
      end

      def color(text, color)
        color + text + C.reset
      end
    end
  end
end

objects.each do |d|
  puts "#{C.blue + C.bold}%s [%3s] %s [ %s ]#{C.reset}" % [d["user"]["url_name"].ljust(10), d["stock_count"], d["title"], "http://qiita.com/items/" + d["uuid"]]
  puts Redcarpet::Markdown.new(Redcarpet::Render::Terminal.new).render(d["raw_body"]).
    split("\n").
    # take(5).
    map{ |l| "    " + l }.
    join("\n")
end
