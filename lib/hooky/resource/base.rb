module Hooky
  module Resource
    class Base

      class << self

        def field(key)
          define_method key do |*args, &block|
            if data = block || args[0]
              instance_variable_set("@#{key}", data)
            else
              instance_variable_get("@#{key}")
            end
          end
        end

        def actions(*actions)
          if actions.any?
            @actions = *actions
          else
            @actions    
          end
        end

        def default_action(action=nil)
          if action
            @default_action = action
          else
            @default_action || :run
          end
        end
        
      end

      attr_accessor :dict

      field :name

      def initialize(name)
        name(name)
      end

      def run(action); end

      def can_run?
        only_if_res = true
        not_if_res  = false

        if only_if and only_if.respond_to? :call
          only_if_res = only_if.call
        end

        if not_if and not_if.respond_to? :call
          not_if_res = not_if.call
        end

        only_if_res and not not_if_res
      end

      def action(*actions)
        if actions.any?
          actions.each do |action|
            if not self.class.actions.include? action
              raise Hooky::Error::UnknownAction, "unknown action '#{action}'"
            end
          end
          @actions = *actions
        else
          @actions || [default_action]
        end
      end

      def default_action
        self.class.default_action
      end

      def not_if(&block)
        if block_given?
          @not_if = block  
        else
          @not_if
        end
      end

      def only_if(&block)
        if block_given?
          @only_if = block  
        else
          @only_if
        end
      end

    end
  end
end