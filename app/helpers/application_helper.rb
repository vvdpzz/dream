module ApplicationHelper



    def find_user_by(topic)
        dl = []
        generation = []
        hash = {}
        dl.push(find_topic(topic))
        generation.push 1
        hash[topic] = true
        i = 0
        while i <= dl.size
            topic = dl[i]
            topic.parents.each do |parent|
                if not hash[parent]
                    dl.push parent
                    generation.push generation[i]+1
                    hash[topic] = true
                end
            end
            i+=1
        end
        
        # get users
        i = 0
        while i < generation.size
            
            # get the same generation
            j = i
            while generation[j] == generation[j+1]
                j+=1
            end
            
            # calc the same generation's users total size
            i.upto(j) do |k|
                sum += dl[k].users.count
            end
            
            
            
        end
    end

end
