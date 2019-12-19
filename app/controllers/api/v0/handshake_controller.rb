module Api
  module V0
    class HandshakeController < ApplicationController

      def index
        render json: {
          status: 'SUCCESS', message: 'Hello World!'}, status: :ok
      end

      def create
        render json: {
          status: 'SUCCESS', message: 'Hello World!'}, status: :ok
      end

      def destroy
        render json: {
          status: 'SUCCESS', message: 'Hello World!'}, status: :ok
      end
    end
  end
end