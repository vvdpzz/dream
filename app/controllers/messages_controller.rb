class MessagesController < ApplicationController
    def new
        @message = current_user.messages.build
    end
    def create
        @message = current_user.messages.build(params[:message])
        @message.markdown = BlueCloth.new(@message.body).to_html
        @message.save
        redirect_to(messages_path, :notice => 'Message was successfully created.')
    end
    def edit
        @message = current_user.messages.find(params[:id])
    end
    def update
        @message = current_user.messages.find(params[:id])
        if @message.update_attributes(params[:message])
            @message.markdown = BlueCloth.new(@message.body).to_html
            @message.save
            redirect_to(messages_path, :notice => 'Message was successfully updated.')
        else
            render :edit
        end
    end
    def destroy
        @message = current_user.messages.find(params[:id])
        @message.destroy
    end
    def index
        @messages = current_user.messages
    end
end
