class CommentsController < ApplicationController
    def new
        answer = Answer.find(params[:answer_id])
        @comment = answer.comments.build
    end
    def create
        answer = Answer.find(params[:answer_id])
        @comment = answer.comments.create(:user => current_user, :body => params[:comment][:body])
    end
end
