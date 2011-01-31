module Hoptopus
  module Acts
    module AsWiki
      def self.included(base)
        #base.send :include, Hoptopus::Acts::AsWiki::AddActsAsWiki::InstanceMethods
        base.extend AddActsAsWiki
      end
      
      module AddActsAsWiki
        def acts_as_wiki
          has_many :wiki, :as => :for, :dependent => :destroy 
        
          class_eval <<-END
            include Hoptopus::Acts::AsWiki::InstanceMethods
          END
        end
      end
      
      module InstanceMethods
        def self.included(cls)
          # If we wanted to extend class methods it would go here
        end
        
        def to_html
          Maruku.new(current_revision.markup).to_html
        end
        
        def markup
          @markup ||= self.wiki.markup
        end
        
        def markup=(markup)
          @markup = markup
          
          # Stick this in the wiki bit too. We need to create a new wiki thinger.
          self.wiki.new :markup => markup
        end
        
        def current_revision
          self.wiki.order('revision').limit(1)
        end
      end
    end
  end
end