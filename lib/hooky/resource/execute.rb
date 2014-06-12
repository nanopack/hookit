require 'timeout'

module Hooky
  module Resource
    class Execute < Base
      
      field :command
      field :cwd
      field :environment
      field :user
      field :path
      field :returns
      field :timeout
      field :stream
      field :on_data
      field :validator

      actions :run
      default_action :run

      def initialize(name)
        command name unless command
        timeout 3600
        returns 0
        super
      end

      def run(action)
        case action
        when :run
          if stream
            stream!
          else
            run!
          end
        end
      end

      protected

      def validate!(res)
        if validator.is_a? Proc
          if validator.call(res)
            res
          else
            raise "ERROR: execute resource \"#{name}\" failed validation!"
          end
        else
          res
        end
      end

      def run!
        Timeout::timeout(timeout) do
          res = `#{cmd}`
          code = $?.exitstatus
          unexpected_exit(code) unless code == returns
          validate! res
        end
      end

      def stream!
        result = ""

        STDOUT.sync = STDERR.sync = true # don't buffer stdout/stderr

        ::IO.popen(cmd, :err=>[:child, :out]) do |out|
          eof = false
          until eof do
            begin
              chunck = out.readpartial(4096)
              if on_data.is_a? Proc
                on_data.call(chunk)
              end
            rescue EOFError
              eof = true
            end
            result << chunck.to_s
          end
        end

        code = $?.exitstatus
        unexpected_exit(code) unless code == returns

        validate! result
      end

      def cmd
        com = command

        if environment
          com = "#{env}#{com}"
        end

        if path
          com = "export PATH=\"#{path}\"; #{com}"
        end

        if cwd
          com = "cd #{cwd}; #{com}"
        end

        if user
          com = su(user, com)
        end

       com 
      end

      # strategy:
      # 1- escape the escapes
      # 2- escape quotes
      # 3- escape dollar signs
      def escape(cmd)
        cmd.gsub!(/\\/, "\\\\\\")
        cmd.gsub!(/"/, "\\\"")
        cmd.gsub!(/\$/, "\\$")
        cmd
      end

      def su(user, cmd)
        "su - #{user} -c \"#{escape(cmd)}\""
      end

      def env
        vars = environment || {}
        env = ''
        vars.each do |key, val|
          env += " " if not env == ''
          env += env_string(key, val)
        end
        (env == '')? env : "#{env}"
      end

      def env_string(key, val)
        key = key.to_s if not key.is_a? String
        val = val.to_s if not val.is_a? String
        %Q{export #{key.upcase}="#{escape(val)}";}
      end

      def unexpected_exit(res)
        raise Hooky::Error::UnexpectedExit, "'#{name}' exited with #{res}, expected #{returns}"
      end

    end
  end
end