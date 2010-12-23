class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  field :body
  validates_presence_of :body
  referenced_in :user, :inverse_of => :comments
  referenced_in :answer, :inverse_of => :comments
end
