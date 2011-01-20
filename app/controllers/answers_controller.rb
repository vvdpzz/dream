class AnswersController < ApplicationController
    def create
        answer_fee = APP_CONFIG['answer_fee'].to_i
        question = Question.find(params[:question_id])
        if current_user.money >= answer_fee
            @answer = question.answers.build(:user => current_user, :body => params[:answer][:body])
            
            # markdown
            @answer.markdown = BlueCloth.new(@answer.body).to_html
            
            if @answer.save
                @answer.accounting_for_answer(answer_fee)
                
                if question.answers.count == 1
                    question.answer_stats = "answered"
                end
                current_user.save
                question.save
            end
        end
    end
end
