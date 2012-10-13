require 'term/ansicolor'
require 'redcarpet'

module Redcarpet
  module Render
    class Terminal < Base
      C = Term::ANSIColor

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

      def normal_text(text)
        text
      end

      def block_code(code, language)
        color(indent(code, 4), CODE_COLOR)
      end

      def block_quote(text)
        indent(text, 4) + "\n"
      end

      def codespan(code)
        color(code, CODE_COLOR)
      end

      def header(title, level)
        "\n" + color("#{'#'*level} #{title}", C.bold + C.green) + "\n\n"
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

      def list(content, list_type)
        reset_list_count
        content
      end

      def list_item(content, list_type)
        case list_type
        when :ordered
          @ordered_list_count += 1
          "#{@ordered_list_count}. #{content}"
        when :unordered
          "- #{content}"
        end
      end


      # Other methods where the text content is in another argument
      def link(link, title, content)
        content
      end
      private
      def reset_list_count
        @ordered_list_count = 0
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
