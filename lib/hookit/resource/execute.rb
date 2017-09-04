require 'timeout'
require 'open3'

module Hookit
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
      field :on_stdout
      field :on_stderr
      field :on_exit
      field :validator
      field :ignore_exit

      actions :run
      default_action :run

      def initialize(name)
        command name unless command
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
            print_error(name, {
              command: cmd,
              failure: "failed validation"
            })
          end
        else
          res
        end
      end

      def run!
        timeout = timeout || 3600
        stream!
      end

      def stream!
        exit_status = 0
        result = ""

        STDOUT.sync = STDERR.sync = true # don't buffer stdout/stderr
        
        Open3.popen3 cmd do |stdin, stdout, stderr, wait_thr|
          begin
            Timeout::timeout(timeout) do
              stdout_eof = false
              stderr_eof = false

              until stdout_eof and stderr_eof do
                (ready_pipes, dummy, dummy) = IO.select([STDIN, stdout, stderr])
                ready_pipes.each_with_index do |socket|
                  if socket == stdout
                    begin
                      chunk = socket.readpartial(4096)
                      if on_data and on_data.respond_to? :call
                        on_data.call(chunk)
                      end
                      if on_stdout and on_stdout.respond_to? :call
                        on_stdout.call(chunk)
                      end
                    rescue EOFError
                      stdout_eof = true
                    end
                    result << chunk.to_s
                  elsif socket == stderr
                    begin
                      chunk = socket.readpartial(4096)
                      if on_data and on_data.respond_to? :call
                        on_data.call(chunk)
                      end
                      if on_stderr and on_stderr.respond_to? :call
                        on_stderr.call(chunk)
                      end
                    rescue EOFError
                      stderr_eof = true
                    end
                    result << chunk.to_s
                  elsif socket == STDIN
                    # write what we got on STDIN right into the process' stdin
                    chunk = socket.readpartial(4096)
                    stdin.write(chunk)
                  end
                end
              end
            end
          rescue Timeout::Error => e
            Process.kill 9, wait_thr[:pid]

            print_error(name, {
              command: cmd,
              failure: "failed to return within #{timeout} seconds"
            })
            exit 1
          end


          exit_status = wait_thr.value.to_s.match(/exit (\d+)/)[1].to_i
        end

        if on_exit and on_exit.respond_to? :call
          on_exit.call(exit_status)
        else
          unexpected_exit(exit_status, result) unless exit_status == returns
        end

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
        (env == '')? env : "#{env} "
      end

      def env_string(key, val)
        key = key.to_s if not key.is_a? String
        val = val.to_s if not val.is_a? String
        %Q{export #{key.upcase}="#{escape(val)}";}
      end
      
      def unexpected_exit(res, output="")
        return if ignore_exit
        
        print_error(name, {
          exit: "#{res}",
          command: cmd,
          output: output
        })
      end

    end
  end
end
