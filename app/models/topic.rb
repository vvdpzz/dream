class Topic
    include Mongoid::Document
    field :name

    references_many :parents,
                    :class_name => 'Topic',
                    :stored_as => :array,
                    :inverse_of => :children

    references_many :children,
                    :class_name => 'Topic',
                    :stored_as => :array,
                    :inverse_of => :parents

    references_many :users,
                    :stored_as => :array,
                    :inverse_of => :topics
    
    references_many :questions,
                    :stored_as => :array,
                    :inverse_of => :topics
                    
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
    
    # return the particular topic's all questions
    def related_questions_except(user)
        questions = []
        self.questions.each do |question|
            # make sure that this question's author is not current_user and current_user hasn't answered this question
            if question.user != user and !question.answers.where(:user_id => user.id).present?
                questions << question
            end
        end
        self.children.each do |child|
            child.questions.each do |question|
                if question.user != user and !question.answers.where(:user_id => user.id).present?
                    questions << question
                end
            end
        end
        return questions
    end
    
    # return all the related users
    def related_users
        dl = []
        users = []
        hash = {}
        i = 0
        
        dl.push self
        users.concat self.users
        hash[self] = true
                
        while i < dl.size
            topic = dl[i]
            # puts "TOPIC #{topic.name}"
            topic.parents.each do |parent|
                if not hash[parent]
                    # puts "      #{parent.name}"
                    dl.push parent
                    users.concat(parent.all_users).uniq!
                    hash[parent] = true
                end
            end
            i+=1
        end
        return users
    end
    
    # return topic's brothers
    def brothers
        brothers = []
        self.parents.each do |parent|
            brothers.concat parent.children
        end
        return brothers.uniq
    end

end