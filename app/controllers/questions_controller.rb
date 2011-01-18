class QuestionsController < ApplicationController

    def new
        @question = current_user.questions.build
    end

    def create
        
        ask_fee = APP_CONFIG['ask_fee'].to_i
        reward_fee = params[:question][:reward].to_i
        sum_fee = ask_fee + reward_fee
        
        if current_user.afford? sum_fee

            @question = current_user.questions.build(params[:question])
            
            @question.mark_short_and_long_down
            @question.parse_topic_list

            if @question.save
                
                @question.charge(ask = ask_fee, reward = reward_fee)
                
                @question.accounting_for_ask(fee = ask_fee)
                
                @question.accounting_for_reward(fee = reward_fee)
                
                redirect_to(asked_path, :notice => 'Question was successfully created.')
            else
                render :new
            end
        end
    end
    
    def update
        @question = Question.find params[:id]
        new_reward = params[:question][:reward].to_i
        offset = new_reward - @question.reward
        if offset > 0
            @question.accounting_for_reward(fee = offset)
        end
        if offset < 0
            params[:question][:reward] = @question.reward
        end
        
        if @question.update_attributes(params[:question])
            @question.mark_short_and_long_down
            @question.parse_topic_list
            @question.save
            redirect_to @question
        else
            render :edit
        end
    end

    def index
        @questions = Question.all
    end
    
    def show
        @question = Question.find params[:id]
    end
    
    def edit
        @question = Question.find params[:id]
    end

    def asked
        @questions = current_user.questions
    end
    def answered
        @questions = []
        answers = Answer.where(:user_id => current_user.id)
        answers.each {|answer| @questions << answer.question}
    end
    def accepted
        @answer = Answer.find(params[:id])
        if current_user.id == @answer.question.user.id and @answer.question.accepted_answer == nil
            @answer.question.accepted_answer = @answer.id
            
            fee = @answer.question.bucket + @answer.question.reward
            @answer.question.bucket = 0
            @answer.question.reward = 0
            
            if @answer.question.save
                @answer.user.money += fee
                @answer.user.save
                @answer.user.records.create!(
                    :sn => Time.now.to_f.to_s.gsub('.',''),
                    :io => "in",
                    :reason => "accepted",
                    :amount => fee,
                    :model => @answer.question.class.to_s,
                    :instance_id => @answer.question.id,
                    :status => "success"
                )
                redirect_to @answer.question
            end
        end
    end
end
