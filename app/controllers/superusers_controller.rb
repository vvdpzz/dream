class SuperusersController < ApplicationController
    
    before_filter :auth
    
    def user
        @users = User.all
    end
    def question
        @questions = Question.all
    end
    def index
        
    end
    def show
        @question = Question.find(params[:id])
    end
    def topic
        @topics = Topic.all
    end
    def neighbor
        @topics = Topic.all
    end
    def destroy
        @one = Topic.find(params[:one_id])
        @another = Topic.find(params[:another_id])
        @one.remove_neighbor(@another)
    end
    
    protected
        def auth
            if !(current_user.has_role? :root)
                redirect_to root_path
            end
        end
end
