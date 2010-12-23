class Answer
  include Mongoid::Document
  include Mongoid::Timestamps
  field :body
  validates_presence_of :body
  referenced_in :user, :inverse_of => :answers
  referenced_in :question, :inverse_of => :answers
  references_many :comments
end
