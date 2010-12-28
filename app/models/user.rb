class User
    include Mongoid::Document
    include Mongoid::Timestamps
    # Include default devise modules. Others available are:
    # :token_authenticatable, :confirmable, :lockable and :timeoutable
    devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

    field :name
    validates_presence_of :name
    validates_uniqueness_of :name, :email, :case_sensitive => false
    attr_accessible :name, :email, :password, :password_confirmation

    embeds_many :messages
    
    references_many :questions

    references_many :topics,
                    :stored_as => :array,
                    :inverse_of => :users,
                    :index => true
    
    references_many :answers
    references_many :comments
    
    @@max_depth = 0
    @@result = []

    # user.topics >> topic
    def remove(topic)
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
    def github
    end
    
    include Rubyoverflow
    def self.stackoverflow
        users = Users.retrieve_all
    end

end
