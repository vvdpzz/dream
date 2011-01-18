class Record
    include Mongoid::Document
    include Mongoid::Timestamps
    embedded_in :user, :inverse_of => :records
    
    # input or output
    field :io
    
    field :model
    field :instance_id
    field :amount, :type => Integer, :default => 0
    
    # Income: recharge, accepted, other reasons
    # Expenditure: ask, answer, featured
    field :reason
    
    field :status
end
