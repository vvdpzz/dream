class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  field :body
  embedded_in :user, :inverse_of => :messages
end
