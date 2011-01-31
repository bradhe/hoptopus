module Hoptopus
  module Acts
    module AsWiki
      def self.included(base)
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
          cls.send :before_save, :save_current_wiki_if_exists
        end
        
        def to_html
          Maruku.new(current_revision.markup).to_html
        end
        
        def markup
          @markup ||= current_revision  ? current_revision.markup : nil
        end
        
        def markup=(markup)
          @markup = markup
          
          # Stick this in the wiki bit too. We need to create a new wiki thinger.
          @current_revision = self.wiki.new :markup => markup, :revision => (current_revision.nil? ? 1 : (current_revision.revision + 1))
        end
        
        def current_revision
          if @current_revision.nil?
            @current_revision = self.wiki.order('revision DESC').limit(1).first
          end
          
          @current_revision
        end
        
        def save_current_wiki_if_exists
          if current_revision
            current_revision.save
          end
        end
      end
    end
  end
end