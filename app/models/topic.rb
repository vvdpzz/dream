class Topic
    include Mongoid::Document
    field :name
    index(
      [
        [ :name, Mongo::ASCENDING ]
      ],
      :unique => true,
      :background => true
    )

    references_many :neighbors,
                    :class_name => 'Topic',
                    :stored_as => :array,
                    :inverse_of => :neighbors,
                    :index => true

    references_many :users,
                    :stored_as => :array,
                    :inverse_of => :topics,
                    :index => true
    
    references_many :questions,
                    :stored_as => :array,
                    :inverse_of => :topics,
                    :index => true
                    
    # find topic by name
    def self.find_by_name(name)
        Topic.where(:name => name).first
    end

    # delete the relational association between topic and user
    def remove(user)
        self.user_ids.delete user.id
        self.save
        user.topic_ids.delete self.id
        user.save
    end

    # return the particular topic's all users, self and his children's
    def all_users
        users = []
        users.concat self.users
        self.children.each do |child|
            users.concat child.users
        end
        return users.uniq
    end
    
    # return unanswered questions
    # not I asked and no answer was accepted
    # currently only not I asked
    def unanswered_questions(user)
        return related_questions_except(user)
    end
    
    # return the particular topic's all questions
    def related_questions_except(user)
        questions = []
        self.questions.each do |question|
            # make sure that this question's author is not current_user and current_user hasn't answered this question
            if question.user != user and !question.answers.where(:user_id => user.id).present?
                questions << question
            end
        end
        return questions
    end

end