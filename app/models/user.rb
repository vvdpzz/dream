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
                    :inverse_of => :users
    
    references_many :answers
    references_many :comments
    
    @@max_depth = 0
    @@result = []

    def remove(topic)
        self.topic_ids.delete topic.id
        self.save
        topic.user_ids.delete self.id
        topic.save
    end
    
    def dfs(topic, current_depth)
        @@result.concat(topic.related_questions_except(self)).uniq!
        if @@result.count < 11
            if current_depth < @@max_depth
                topic.parents.each do |parent|
                    dfs(parent, current_depth + 1)
                end
            end
        else
            return
        end
    end
    
    def related_questions
        1.upto(4) do |@@max_depth|
            self.topics.each do |topic|
                dfs(topic, 1)
                break unless @@result.count < 11
            end
        end
        return @@result
    end
    
    # footprint
    def github
    end
    
    include Rubyoverflow
    def self.stackoverflow
        users = Users.retrieve_all
    end

end
