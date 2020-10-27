module Serbea
  module Helpers
    def self.included(mod)
      Serbea::Pipeline.deny_value_method %i(escape h prepend append assign_to)
    end

    def capture(obj = nil, &block)
      previous_buffer_state = @_erbout
      @_erbout = Serbea::Buffer.new

      # For compatibility with ActionView, not used by Bridgetown normally
      previous_ob_state = @output_buffer
      @output_buffer = Serbea::Buffer.new

      result = instance_exec(obj, &block)
      if @output_buffer != ""
        # use Rails' ActionView buffer if present
        result = @output_buffer
      end
      @_erbout = previous_buffer_state
      @output_buffer = previous_ob_state

      result.respond_to?(:html_safe) ? result.html_safe : result
    end
  
    def pipeline(context, value)
      Pipeline.new(context, value)
    end
  
    def helper(name, &block)
      self.class.send(:define_method, name, &block)
    end
  
    def h(input)
      result = Erubi.h(input)
      result.respond_to?(:html_safe) ? result.html_safe : result
    end
    alias_method :escape, :h

    def prepend(old_string, new_string)
      "#{new_string}#{old_string}"
    end

    def append(old_string, new_string)
      "#{old_string}#{new_string}"
    end

    def assign_to(input, varname, preserve: false)
      self.instance_variable_set("@#{varname}", input)
      preserve ? input : nil
    end
  end
end
