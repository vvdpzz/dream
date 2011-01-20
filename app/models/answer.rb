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
  
  
  def accounting_for_answer(answer_fee)
      self.user.records.create!(
          :sn => Time.now.to_f.to_s.gsub('.',''),
          :io => "out",
          :reason => "answer",
          :description => excerpt_record_description(self.markdown),
          :amount => answer_fee,
          :model => self.class.to_s,
          :instance_id => self.id,
          :status => "success"
      )
      self.user.money -= answer_fee
      self.question.bucket += answer_fee
  end
  
  def accounting_for_accept(fee)
      self.user.records.create!(
          :sn => Time.now.to_f.to_s.gsub('.',''),
          :io => "in",
          :reason => "accepted",
          :description => excerpt_record_description(self.question.markdown4short),
          :amount => fee,
          :model => self.question.class.to_s,
          :instance_id => self.question.id,
          :status => "success"
      )
  end
  
  def excerpt_record_description(string)
      truncate(string.gsub(/<\/?[^>]*>/,  ""), :length => 30)
  end
  
  def truncate(text, options = {})
      options.reverse_merge!(:length => 30)
      text.truncate(options.delete(:length), options) if text
  end
end
