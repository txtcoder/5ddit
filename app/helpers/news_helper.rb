module NewsHelper
    def showComments(json, i=0)
       res=""
        return "" if json.nil?
       json.each do |x|
            res << "<li class='#{if i%2==0 then "even" else "odd" end}'>"
            res << "<div class ='commentTitle'>"
            res << "Posted by: " + "<span>" + x[:author] << "</span>"
            res << " Score:" + "<span>" + x[:score].to_s
            res << "</span>"
            res << "</div>"
            res << "<div class ='commentContent'>"
            res <<  x[:comment]
            res << "</div>"
            if x[:replies]!=nil
                res << "<ul>"
                res << showComments(x[:replies], i+1)
                res << "</ul>"
            end
            res << "</li>"
        end
        res
    end
end
