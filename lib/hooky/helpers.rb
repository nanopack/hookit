module Hooky
  module Helpers

    def is_new?(payload)
      payload[:member][:service_uid] == payload[:new_member][:service_uid]
    end

    def get_tunnel_port(default_port, payload)
      if is_new?(payload)
        @port ||= payload[:old_member][:tunnels].find {|s| s[:to_zone_port] == default_port }[:from_zone_port]
      else
        @port ||= payload[:new_member][:tunnels].find {|s| s[:to_zone_port] == default_port }[:from_zone_port]
      end
    end

    BOB_SUCCESSFUL_POST = Proc.new do |result|
      if result =~ /\{"success":true\}/
        next true
      else
        next false
      end
    end

    def sanitize_network_dirs(payload)
      net_dirs = ensure_format(payload)
      net_dirs.each do |component, dirs|
        net_dirs[component] = clean_writables(dirs)
      end
      return net_dirs
    end

    def ensure_format(payload)
      net_dirs = payload[:boxfile][:network_dirs] || payload[:boxfile][:shared_writable_dirs]
      if net_dirs.kind_of?(Hash)
        return net_dirs
      elsif net_dirs.nil? or net_dirs.empty?
        return {}
      else
        return {payload[:storage].keys.first => net_dirs}
      end
    end

    def clean_writables(dirs)
      dirs = dirs.map(&:to_s)
      dirs = remove_empty(dirs)
      dirs = filter_offensive(dirs)
      dirs = strip_leading_slash(dirs)
      dirs = strip_trailing_slash(dirs)
      dirs = remove_nested(dirs)
      return dirs
    end
   
    def remove_empty(dirs)
      dirs.inject([]) do |res, elem|
        res << elem if elem && elem != ""
        res
      end
    end
   
    def filter_offensive(dirs)
      dirs.inject([]) do |res, elem|
        if elem[0] != '.'
          # ensure not going up a directory
          unless elem =~ /\*|\.?\.\//
            res << elem
          end
        end
        res
      end       
    end
   
    def strip_leading_slash(dirs)
      dirs.inject([]) do |res, elem|
        if elem[0] == '/'
          elem.slice!(0)
        end 
        res << elem
      end
    end
    
    def strip_trailing_slash(dirs)
      dirs.inject([]) do |res, elem|
        if elem[-1] == '/'
          elem.slice!(-1)
        end
        res << elem
      end
    end
   
    # this removes nested mounts like:
    # tmp/
    # tmp/cache/
    # tmp/assets/
    # 
    # and keeps tmp/
    def remove_nested(dirs)
      dirs.sort!
      dirs.inject([]) do |res, elem|
        overlap = false
        # now make sure parents dont contain children
        res.each do |parent|
          if elem =~ /^#{parent}\//
            overlap = true
          end
        end
        res << elem if not overlap
        res
      end
    end

  end
end