module Hoptopus
  module Acts
    module AsWiki
      def self.included(base)
        base.extend AddActsAsWiki
      end
      
      module AddActsAsWiki
        def acts_as_wiki(params = {})
          has_many :wiki, :as => :for, :dependent => :destroy 
          
          include Hoptopus::Acts::AsWiki::InstanceMethods
          
          if params[:default_template]
            self.wiki_template = File.open(params[:default_template], 'r').read
          end
        end
      end
      
      module InstanceMethods
        def self.included(cls)
          cls.send :after_save, :save_current_wiki_if_exists
        
          # If we wanted to extend class methods it would go here
          cls.extend ClassMethods
        end

        def markup
          @markup ||= current_revision  ? current_revision.markup : nil
        end
        
        def markup=(markup)
          @markup = markup
          
          # Stick this in the wiki bit too. We need to create a new wiki thinger.
          @current_revision = self.wiki.build :markup => markup, :revision => (current_revision.nil? ? 1 : (current_revision.revision + 1))
        end
        
        def current_revision
          # If it's STILL nil then we need to add one
          if @current_revision.nil? and self.persisted? and not self.wiki.empty?
            @current_revision = self.wiki.order('revision DESC').limit(1).first
          elsif @current_revision.nil? and self.persisted?
            @current_revision = self.wiki.create :revision => 1
          elsif @current_reivision.nil?
            @current_revision = self.wiki.new :revision => 1
          end
          
          @current_revision
        end
        
        def revisions
          self.wiki
        end
        
        def save_current_wiki_if_exists
          if current_revision
            current_revision.save
          end
        end
              
        module ClassMethods
          attr_accessor :wiki_template
        end
      end
    end
  end
end