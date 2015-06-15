module Hookit
  module Resource
    class Warning < Base

      field :source
      field :content
      field :stream

      actions :warn
      default_action :warn

      def initialize(name)
        source(name) unless source or content
        stream :stdout unless stream

        @default_header = "\u25BC\u25BC\u25BC\u25BC :: WARNING :: \u25BC\u25BC\u25BC\u25BC"
        @block_width = @default_header.length
      end

      def run(action)
        case action
        when :warn
          warn!
        end
      end

      protected

      def gem
        dict[:template_gem]
      end

      def gem_spec
        Gem::Specification.find_by_name(gem)
      end

      def gem_root
        gem_spec.gem_dir
      end

      def content!
        output_string ||= content or ::File.open("#{gem_root}/messages/#{source}").read
        return output_string
      end

      def header!

        header = @default_header
        padding = "\u25BC"

        longest_line = content!.split.sort_by {|x| x.length}.last

        if longest_line.length > header.length

          difference = longest_line.length - header.length
          padding *= (difference.to_f / 2).ceil

          header = padding + header + padding
        end

        @block_width = header.length

        puts header
      end

      def footer!
        footer = "\u25B2" * @block_width
        puts footer
      end

      def warn!

        header!

        case stream
        when :stdout
          puts content!
        when :stderr
          $stderr.puts content!
        end

        footer!
      end

    end
  end
end