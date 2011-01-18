Dream::Application.routes.draw do
    
    match '/questions/asked' => "questions#asked", :as => :asked
    match '/questions/answered' => "questions#answered", :as => :answered
    match '/questions/accepted/:id' => "questions#accepted", :as => :accept_answer
    resources :questions do
        resources :answers
        resources :comments
    end
    resources :answers do
        resources :comments
    end
    
    match '/topics/neighborhood' => "topics#neighborhood", :via => "post"
    match '/topics/:id/add' => "topics#add", :as => :add, :via => "get"
    
    resources :topics do
        get :autocomplete_topic_name, :on => :collection
    end
    
    resources :messages
        
    devise_for :users
    resources :users
    
    match '/superusers/user' => "superusers#user", :as => :superusers_users
    match '/superusers' => "superusers#index", :as => :superusers_index
    match '/superusers/question' => "superusers#question", :as => :superusers_questions
    match '/superusers/question/:id' => "superusers#show", :as => :superusers_show
    match '/superusers/topic' => "superusers#topic", :as => :superusers_topic
    match '/superusers/neighbor' => "superusers#neighbor", :as => :superusers_neighbor
    match '/superusers/destroy/:one_id/:another_id' => "superusers#destroy", :as => :superusers_destroy

    root :to => "questions#index"
end
