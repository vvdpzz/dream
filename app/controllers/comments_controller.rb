class CommentsController < ApplicationController
    before_filter :who_called_comment
    def new
        @comment = @m0del.comments.build
    end
    def create
        @comment = @m0del.comments.create(:user_id => current_user.id, :body => params[:comment][:body])
    end
    
    protected
        def who_called_comment
            if params[:question_id]
                @name = "question"
                id = params[:question_id]
            else
                @name = "answer"
                id = params[:answer_id]
            end
            @man = @name.classify.constantize
            @m0del = @man.find id
            return @m0del
        end
end
