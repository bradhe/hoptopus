module Hoptopus
  module Acts
    module EventSource
      def self.included(base)
        base.extend AddActsAsEventSource
      end
      
      module AddActsAsEventSource
        def acts_as_event_source(*attrs)
          has_many :events, :as => attrs[:name] || :events, :polymorphic => true
          
          class_eval <<-END
            include Hoptopus::Acts::EventSource::InstanceMethods
          END
        end
      end
      
      module InstanceMethods
        def self.included(cls)
          # If we wanted to extend class methods it would go here
        end
        
        def render
          "<li=\"#{cls}\">#{msg}</li>"
        end
      end
    end
  end
end