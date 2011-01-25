module ApplicationHelper
    def safe_html(text)
      sanitize text, :tags => %w(div span h1 h2 h3 h4 h5 h6 p a b strong em pre img br table th tr td ol ul li),
                     :attributes => %w(class href src width height)
    end
    def excerpt_record(record)
        truncate(record.model.classify.constantize.find(record.instance_id).markdown4short.gsub(/<\/?[^>]*>/,  ""), :length => 30)
    end
    def excerpt_record_description(string)
        truncate(string.gsub(/<\/?[^>]*>/,  ""), :length => 30)
    end
    def excerpt(string)
        truncate(string.gsub(/<\/?[^>]*>/,  ""), :length => 140)
    end
    def cny(money)
        number_to_currency(money.to_f/100)
    end
    def nwp(money)
        number_with_precision(money.to_f/100,:precision => 2)
    end
end
