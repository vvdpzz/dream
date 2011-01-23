class User
    include Mongoid::Document
    include Mongoid::Timestamps
    
    after_create :register_gift
    
    # Include default devise modules. Others available are:
    # :token_authenticatable, :confirmable, :lockable and :timeoutable
    devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

    # user's name
    field :name
    validates_presence_of :name
    validates_uniqueness_of :name, :email, :case_sensitive => false
    attr_accessible :name, :email, :password, :password_confirmation
    
    # user's gender(String)
    field :gender
    
    # user's birthday
    field :birthday, :type => Date
    
    # user's headline, a headline is a short self-introduction
    field :headline
    
    # user's money, we give 100 cents as registration gift
    field :money, :type => Integer, :default => 100
    
    attr_accessible :money
    
    # user's role
    field :roles_mask, :type => Integer, :default => 4
    
    attr_accessible :roles_mask
    include RoleModel
    roles_attribute :roles_mask
    
    # declare the valid roles -- do not change the order if you add more roles later, always append them at the end!
    roles :root, :moderator, :author
    
    # gravatar
    include Gravtastic
    gravtastic
    
    embeds_many :messages
    
    embeds_many :records
    
    embeds_many :notifications
    
    references_many :questions
    
    references_many :feedbacks

    references_and_referenced_in_many :topics,
                    :inverse_of => :users,
                    :index => true
    
    references_many :answers
    references_many :comments
    
    def self.find_by_name(name)
        self.where(:name => name).first
    end

    # user.topics >> topic
    def remove_topic(topic)
        self.topic_ids.delete topic.id
        self.save
        topic.user_ids.delete self.id
        topic.save
    end
    
    def related_questions
        questions = []
        self.topics.each do |topic|
            questions.concat(topic.unanswered_questions(self)).uniq!
        end
        return questions
    end
    
    # footprint
    # def github
    # end
    # 
    # include Rubyoverflow
    # def self.stackoverflow
    #     users = Users.retrieve_all
    # end
    
    def afford?(amount)
        if self.money >= amount
            true
        else
            false
        end
    end
    
    def accounting_for_recharge(amount)
        self.money += amount
        self.save
        self.records.create!(
            :sn => Time.stamp,
            :io => "in",
            :reason => "recharge",
            :description => "充值",
            :amount => amount,
            :model => "SYSTEM",
            :status => "success"
        )
    end
    
    protected
        def register_gift
            amount = APP_CONFIG['register_gift'].to_i
            self.records.create!(
                :sn => Time.stamp,
                :io => "in",
                :reason => "recharge",
                :description => "注册赠送",
                :amount => amount,
                :model => "SYSTEM",
                :status => "success"
            )
            user = User.find_by_name("greedy")
            if user
                user.update_attributes(:money => user.money-amount)
                user.records.create!(
                    :sn => Time.stamp,
                    :io => "out",
                    :reason => "client_register",
                    :description => "被注册",
                    :amount => amount,
                    :model => "SYSTEM",
                    :status => "success"
                )
            end
        end

end
