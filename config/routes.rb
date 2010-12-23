Dream::Application.routes.draw do
    
    match '/questions/asked' => "questions#asked", :as => :asked
    match '/questions/answered' => "questions#answered", :as => :answered
    resources :questions do
        resources :answers do
            resources :comments
        end
    end
    
    resources :topics do
        get :autocomplete_topic_name, :on => :collection
    end
    
    resources :messages
        
    devise_for :users
    resources :users

    root :to => "questions#index"
end
