class Question
    
    # FIXME: short's length should within 10..140
    
    
    # include ActionView::Helpers::TextHelper

    include Mongoid::Document
    include Mongoid::Timestamps

    # description of question, long is optional
    field :short
    validates_presence_of :short
    validates_length_of :short, :within => 1..140, :on => :create, :message => "must be present"
    field :long

    # markdown
    field :markdown4short
    field :markdown4long
    
    # excerpt
    field :excerpt

    # topic list
    field :topic_list
        

    # Money
    field :bucket, :type => Integer, :default => 0
    field :reward, :type => Integer, :default => 0
        validates_numericality_of :reward
    field :sum, :type => Integer, :default => 0
    field :max, :type => Integer, :default => 0

    # Viewed Times
    field :viewed, :type => Integer, :default => 0

    # Anonymous Question
    field :anonymous, :type => Boolean, :default => false

    # Accepted Answer id
    field :accepted_answer
    
    # unanswered, answered, accepted
    field :answer_stats, :default => "unanswered"

    embeds_many :comments

    referenced_in :user, :inverse_of => :questions
    references_many :topics, :stored_as => :array, :inverse_of => :questions
    references_many :answers

    def mark_short_and_long_down
        self.markdown4short = BlueCloth.new(self.short).to_html
        self.markdown4long  = BlueCloth.new(self.long).to_html
        excerpt_short_markdown
    end

    def parse_topic_list
        taglist = ActsAsTaggableOn::TagList.from self.topic_list
        self.topic_list = taglist.to_s
        taglist.each do |tag|
            topic = Topic.find_or_create_by(:name => tag)
            self.topics << topic
            self.user.topics << topic
        end
    end

    def accounting_for_ask(fee)
        self.user.records.create!(
        :sn => Time.stamp,
        :io => "out",
        :reason => "ask",
        :description => excerpt_record_description(self.markdown4short),
        :amount => fee,
        :model => self.class.to_s,
        :instance_id => self.id,
        :status => "success"
        )
        user = User.find_by_name("greedy")
        user.money = user.money + fee
        user.records.create!(
        :sn => Time.stamp,
        :io => "in",
        :reason => "ask",
        :description => excerpt_record_description(self.markdown4short),
        :amount => fee,
        :model => self.class.to_s,
        :instance_id => self.id,
        :status => "success"
        )
        user.save
    end

    def accounting_for_reward(fee)
        self.user.records.create!(
        :sn => Time.stamp,
        :io => "out",
        :reason => "reward",
        :description => excerpt_record_description(self.markdown4short),
        :amount => fee,
        :model => self.class.to_s,
        :instance_id => self.id,
        :status => "pending"
        )
    end
    
    def accounting_for_destroy_question(fee)
        self.user.records.create!(
            :sn => Time.stamp,
            :io => "in",
            :reason => "delete_q",
            :description => "问题被删除",
            :amount => fee,
            :model => self.class.to_s,
            :status => "success"
        )
    end

    def charge(ask, reward)
        user_give ask+reward
        self_receive reward
        calc_sum_and_update_max
    end

    def user_give(amount)
        charged = self.user.money - amount
        self.user.update_attributes(:money => charged) if charged >= 0
    end

    def self_receive(reward)
        self.update_attributes(:reward => reward)
    end


    def calc_sum_and_update_max
        current_sum = self.bucket + self.reward
        if self.sum != current_sum
            self.update_attributes(:sum => current_sum)
            if self.sum > self.max
                self.update_attributes(:max => current_sum)
            end
        end
    end
    
    def excerpt_short_markdown
        excerpt = truncate(self.markdown4short.gsub(/<\/?[^>]*>/,  ""), :length => 140)
        self.update_attributes(:excerpt => excerpt)
    end
    
    def excerpt_record_description(string)
        truncate(string.gsub(/<\/?[^>]*>/,  ""), :length => 30)
    end
    
    def truncate(text, options = {})
        options.reverse_merge!(:length => 30)
        text.truncate(options.delete(:length), options) if text
    end

end
