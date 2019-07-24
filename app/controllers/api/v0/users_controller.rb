module Api
  module V0
    class UsersController < ApplicationController
      before_action :validate
      before_action :set_user, only: [:show, :edit, :update]
    
      # GET /users
      # GET /users.json
      def index
        render json: {size: User.all.size}, status: :ok
      end
    
      # GET /users/1
      # GET /users/1.json
      def show
        puts SPLIT_LINE, params
        render json: {id: User.find(params[:id])}, status: :ok
      end
    
      # GET /users/new
      def new
        not_acceptable
      end
    
      # GET /users/1/edit
      def edit
        not_acceptable
      end
    
      # POST /users
      # POST /users.json
      def create
        not_acceptable
      end
    
      # PATCH/PUT /users/1
      # PATCH/PUT /users/1.json
      def update
        not_acceptable
      end
    
      # DELETE /users/1
      # DELETE /users/1.json
      def destroy
        not_acceptable
      end
    
      private
        # Use callbacks to share common setup or constraints between actions.
        def set_user
          @user = User.find(params[:id])
        end
    
        def validate
          bad_request unless User.validate(params)
        end

    end    
  end
end