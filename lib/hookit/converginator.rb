module Hookit
  class Converginator
    
    def initialize(map, list)
      @map = map
      @list = list
    end

    def converge!
      output = {}
      @map.each do |key, template|
        if @list.key? key
          output[key] = converge_value template, @list[key]
        else
          output[key] = template[:default]
        end
      end
      output
    end

    def converge_hash(template, value)
      temp = {}
      template.each do |k, t|
        if value.key? k
          temp[k] = converge_value t, value[k]
        else
          temp[k] = t[:default]
        end
      end
      temp
    end

    def converge_value(template, value)
      if template[:type] == :array
        value = sanitize_array(template, value)
      end

      if template[:type] == :array and template[:of] == :hash and template[:template]
        value.map! {|v| converge_hash(template[:template], v)}
      end

      if template[:type] == :hash and template[:template]
        value = converge_hash(template[:template], value)
      end

      if valid? template, value
        value
      else
        template[:default]
      end
    end

    def sanitize_array(template, value)

      case template[:of]
      when :byte
        value = [value] if ( valid_byte? value )
      when :file
        value = [value] if ( valid_file? value )
      when :folder
        value = [value] if ( valid_folder? value )
      when :hash
        value = [value] if ( valid_hash? value )
      when :integer
        value = [value] if ( valid_integer? value )
      when :on_off
        value = [value] if ( valid_on_off? value )
      when :string
        value = [value] if ( valid_string? value )
      end
      value
    end

    def valid?(template, value)
      valid_type?(template, value) and valid_value?(template, value)
    end

    def valid_type?(template, value)
      case template[:type]
      when :array
        valid_array? template, value
      when :byte
        valid_byte? value
      when :file
        valid_file? value
      when :folder
        valid_folder? value
      when :hash
        valid_hash? value
      when :integer
        valid_integer? value
      when :on_off
        valid_on_off? value
      when :string
        valid_string? value
      end
    end

    def valid_value?(template, value)

      return true if not template.key? :from

      if template[:type] == :array
        !( value.map {|element| template[:from].include? element} ).include? false
      else
        template[:from].include? value
      end
    end

    def valid_string?(element)
      element.is_a? String
    end
   
    def valid_array?(template, value)

      return false if not value.is_a? Array

      return true if not template.key? :of

      case template[:of]
      when :byte
        !( value.map {|element| valid_byte? element} ).include? false
      when :file
        !( value.map {|element| valid_file? element} ).include? false
      when :folder
        !( value.map {|element| valid_folder? element} ).include? false
      when :integer
        !( value.map {|element| valid_integer? element} ).include? false
      when :hash
        !( value.map {|element| valid_hash? element} ).include? false
      when :on_off
        !( value.map {|element| valid_on_off? element} ).include? false
      when :string
        !( value.map {|element| valid_string? element} ).include? false
      else
        true
      end
    end
   
    def valid_hash?(value)
      value.is_a? Hash
    end
   
    def valid_integer?(value)
      value.is_a? Integer || (value.to_i.to_s == value.to_s)
    end
   
    def valid_file?(value)
      value =~ /^\/?[^\/]+(\/[^\/]+)*$/
    end
   
    def valid_folder?(value)
      value =~ /^\/?[^\/]+(\/[^\/]+)*\/?$/
    end
   
    def valid_on_off?(value)
      ['true', 'false', 'On', 'on', 'Off', 'off', '1', '0'].include? value.to_s
    end
   
    def valid_byte?(value)
      value.to_s =~ /^\d+[BbKkMmGgTt]?$/
    end

  end
end