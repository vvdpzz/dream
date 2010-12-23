class AnswersController < ApplicationController
    def create
        question = Question.find(params[:question_id])
        @answer = question.answers.create(:user => current_user, :body => params[:answer][:body])
    end
end
