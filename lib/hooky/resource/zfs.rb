module Hooky
  module Resource
    class Zfs < Base

      field :snapshot
      field :dataset
      field :destination
      field :source
      field :ssh_host
      field :validator

      actions :send, :receive, :transmit, :snapshot, :destroy, :rollback, :clone
      default_action :send

      def initialize(name)
        snapshot(name) unless snapshot
        super
      end

      def run(action)
        case action
        when :send
          send!
        when :receive
          receive!
        when :transmit
          transmit!
        when :snapshot
          snapshot!
        when :destroy
          destroy!
        when :rollback
          rollback!
        when :clone
          clone!
        end
      end

      def send!
        run_command! "zfs send #{snapshot} | #{destination}"
      end

      def receive!
        run_command! "#{source.to_s.strip} | zfs receive -F #{dataset}"
      end

      def transmit!
        if ssh_host
          run_command! "zfs send #{snapshot} | ssh -o stricthostkeychecking=no #{ssh_host} zfs receive -F #{dataset}"
        else
          run_command! "zfs send #{snapshot} | zfs receive -F #{dataset}"
        end
      end

      def snapshot!
        destroy!
        run_command! "zfs snapshot #{snapshot}"
      end

      def destroy!
        `zfs list -t snapshot | grep #{snapshot}`
        if $?.exitstatus == 0
          run_command! "zfs destroy #{snapshot}"
        end 
      end

      def rollback!
        run_command! "zfs rollback -r #{snapshot}"
      end

      def clone!
        run_command! "zfs clone #{snapshot} #{dataset}"
      end

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

      def run_command!(cmd, expect_code=0)
        res = `#{cmd}`
        code = $?.exitstatus
        if code != expect_code
          raise Hooky::Error::UnexpectedExit, "#{cmd} failed with exit code '#{code}'"
        end
        return validate!(res)
      end

    end
  end
end
