class TopicsController < ApplicationController
    autocomplete :topic, :name
    def create
        @topic = Topic.find_or_create_by(:name => params[:topic])
        current_user.topics << @topic
    end
    def destroy
        @topic = Topic.find(params[:id])
        @topic.remove(current_user)
    end
end
