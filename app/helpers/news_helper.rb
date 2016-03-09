module NewsHelper
    def showComments(json)
       res=""
        return "no comments" if json.nil?
       json.each do |x|
            res << "<li>"
            res << "Posted by: " + "<span>" + x[:author] << "</span>"
            res << " Score:" + "<span>" + x[:score].to_s
            res << "</span>"
            res << "<div>"
            res <<  x[:comment]
            res << "</div>"
            if x[:replies]!=nil
                res << "<ul>"
                res << showComments(x[:replies])
                res << "</ul>"
            end
            res << "</li>"
        end
        res
    end
end
