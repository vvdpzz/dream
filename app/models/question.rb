class Question
  include Mongoid::Document
  include Mongoid::Timestamps
  field :body
  referenced_in :user, :inverse_of => :questions
  
  references_many :topics,
                  :stored_as => :array,
                  :inverse_of => :questions
                  
  references_many :answers
end
