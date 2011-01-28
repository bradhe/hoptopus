module Hoptopus
  module Has
    module Formatter
      def self.included(base)
        base.extend AddHasFormatter
      end
         
      module AddHasFormatter
        def has_formatter
          class_eval <<-END
            include Hoptopus::Has::Formatter::InstanceMethods
          END
        end
      end
      
      module InstanceMethods
        def self.included(cls)
          # If we wanted to extend class methods it would go here
        end
        
        def formatter=(formatter)
          @formatter = formatter
          @formatter.event = self
          self.formatter_type = formatter.class.to_s.demodulize
        end
        
        def formatter
          if @formatter.nil? and self.formatter_type
            @formatter = Object.const_get(self.formatter_type).new
            @formatter.event = self
          end
          
          @formatter
        end
      end
    end
	end
end
	