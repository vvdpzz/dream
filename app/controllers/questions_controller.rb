class QuestionsController < ApplicationController
    
    def new
        @question = current_user.questions.build
    end
    
    def index
    end
    def create
        @question = current_user.questions.create(params[:question])
        topic = Topic.find_or_create_by(:name => params[:topic])
        @question.topics << topic
        render :text => "Got it!"
    end
    def asked
        @questions = current_user.questions
    end
    def answered
        @questions = []
        answers = Answer.where(:user_id => current_user.id)
        answers.each {|answer| @questions << answer.question}
    end
end
