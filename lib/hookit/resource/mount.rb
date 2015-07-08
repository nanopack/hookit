module Hookit
  module Resource
    class Mount < Base

      field :device
      # field :device_type
      # field :dump
      field :fstype
      field :mount_point
      field :options
      field :pass
      field :supports

      actions :mount, :umount, :remount, :enable, :disable
      default_action :mount

      def initialize(name)
        mount_point(name) unless mount_point
        pass('-') unless pass
        super
      end

      def run(action)
        case action
        when :mount
          mount!
        when :umount
          umount!
        when :remount
          umount!
          mount!
        when :enable
          disable!
          enable!
        when :disable
          disable!
        end
      end

      protected

      def mount!
        ::FileUtils.mkdir_p(mount_point)
        case platform.name
        when 'smartos'
          run_command! "mount -O -F #{fstype} -o retry=5,timeo=300 #{options!(as_arg=true)} #{device} #{mount_point}"
        when 'ubuntu'
          run_command! "mount -t #{fstype} -o retry=5,timeo=300 #{options!(as_arg=true)} #{device} #{mount_point}"
        end
      end

      def umount!
        run_command! "umount #{mount_point}"
      end

      def enable!
        entry = "#{device}\t#{device =~ /^\/dev/ ? device : "-"}\t#{mount_point}\t#{fstype}\t#{pass}\tyes\t#{options!}"
        case platform.name
        when 'smartos'
          `echo "#{entry}" >> /etc/vfstab`
        when 'ubuntu'
          `echo "#{entry}" >> /etc/fstab`
        end
      end

      def disable!
        case platform.name
        when 'smartos'
          `egrep -v "#{device}.*#{mount_point}" /etc/vfstab > /tmp/vfstab.tmp; mv -f /tmp/vfstab.tmp /etc/vfstab`
        when 'ubuntu'
          `egrep -v "#{device}.*#{mount_point}" /etc/fstab > /tmp/vfstab.tmp; mv -f /tmp/vfstab.tmp /etc/vfstab`
        end
      end

      def options!(as_arg=false)
        options = self.options.kind_of?(Array) ? self.options.join(',') : self.options
        if as_arg
          options ? (return "-o #{options}") : (return "")
        end
        options != "" ? (return "#{options}") : (return "-")
      end

      def run_command!(cmd, expect_code=0)
        `#{cmd}`
        code = $?.exitstatus
        if code != expect_code
          raise Hookit::Error::UnexpectedExit, "#{cmd} failed with exit code '#{code}'"
        end
      end
    end
  end
end