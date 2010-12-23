class MessagesController < ApplicationController
    def create
       @message = current_user.messages.create(params[:message]) 
    end
end
