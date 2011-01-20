class UsersController < ApplicationController
    
    autocomplete :user, :name, :full => true
    
    def index
        @users = User.all
    end
    def show
        @user = User.find(params[:id])
        @records = @user.records
    end
end
