require File.join(File.dirname(__FILE__), 'factories')

module RSpec
  module SignInAs
    module ClassMethods
      def sign_in
        sign_in_as(new_user)
      end

      def sign_out
        sign_in_as(nil)
      end

      def sign_in_as(user)
        before do
          @current_user = user
          controller.send(:current_user=, user)
        end
      end
    end

    module InstanceMethods
      def sign_in
        sign_in_as(new_user)
      end

      def sign_out
        sign_in_as(nil)
      end

      def sign_in_as(user)
        @current_user = user
        controller.send(:current_user=, user)
      end
    end
  end
end
