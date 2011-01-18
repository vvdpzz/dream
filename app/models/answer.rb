class Answer
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :body
  validates_presence_of :body
  
  field :markdown
  
  
  # Anonymous Answer
  field :anonymous, :type => Boolean, :default => false
  
  referenced_in :user, :inverse_of => :answers
  referenced_in :question, :inverse_of => :answers
  embeds_many :comments
end
