module ActionController::RequestForgeryProtection
  module ProtectionMethods
    class HttpCode
      def initialize(controller)
        @controller = controller
      end

      def handle_unverified_request
        @controller.unauthorized
      end
    end
  end
end