module Api
  module V0
    class HandshakeController < ApplicationController

      def index
        params.each do |key,value|
          puts "Param #{key}: #{value}"
        end
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