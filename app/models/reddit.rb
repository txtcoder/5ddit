class Reddit
include HTTParty
  
    base_uri 'https://www.reddit.com'
    default_params sort: "top", t: "day"
    format :json


    def self.top5cache
        if $redis.get("top1").nil?
            return self.top5
        else
            result1 =  JSON.parse($redis.get("top1"))
            result2 =  JSON.parse($redis.get("top2"))
            result3 =  JSON.parse($redis.get("top3"))
            result4 =  JSON.parse($redis.get("top4"))
            result5 =  JSON.parse($redis.get("top5"))
            results = []
            results << result1 << result2 << result3 << result4 << result5
            return results
        end
    end

    def self.top5
        
        time=Time.now.utc
        if $redis.get("top1").nil? ||  $redis.get("lastUpdate").nil? || time-DateTime.iso8601($redis.get("lastUpdate")) > 600
            $redis.set("lastUpdate",time.iso8601(9))
        else
            result1 =  JSON.parse($redis.get("top1"))
            result2 =  JSON.parse($redis.get("top2"))
            result3 =  JSON.parse($redis.get("top3"))
            result4 =  JSON.parse($redis.get("top4"))
            result5 =  JSON.parse($redis.get("top5"))
            results = []
            results << result1 << result2 << result3 << result4 << result5
            return results
        end
        banned_url =["imgur", "facebook", "youtu","meme","wikipedia","gfycat","twitter", "docs.google.com", "streamable","reddituploads","vimeo","liveleak","imgflip","giphy","sli.mg","oddshot.tv","spotify","chzbgr","tumblr","battle.net","twitch.tv","instagram","plus.google","thepoke.co.uk","deviantart","twimg.com","imgfly","imgcert","i.redd.it","google.com","screenpranks","change.org","redd.it","steam","images.duckduckgo"]
        banned_extension=[".gif",".png",".jpg",".pdf", ".gifv",".mp3",".mp4",".mov",".jpeg"]
        banned_subreddit=["funny","aww","earthporn","gifs","pics","mildlyinteresting","todayilearned","h3h3productions","videos","wtf","adviceanimals","woahdude","subredditsimulator","dota2","programming","xboxone","overwatch","pokemongo","globaloffensive","pcgaming","dataisbeautiful","starwars","makingamurderer","leagueoflegends","hearthstone","showerthoughts","tifu","bestof","reddeadredemption","ps4","pokemon","destinythegame","explainlikeimfive","britishproblems","lifeprotips","jokes","askreddit","iama","internetisbeautiful","savedyouaclick","circlejerk","enoughtrumpspam"]
        us_nerfed_subreddit=["news","politics"]
        agenda_nerfed_subreddit=["trees","atheism","conspiracy","twoxchromosomes","lgbt"]
        entertainment_nerfed_subreddit=["movies","music","books","television","comics","gaming","upliftingnews"]
        stupid_nerfed_subreddit=["nottheonion"]
        educational_subreddit=["science","futurology","technology"]
        politics_nerf_title=["donald","trump","hillary","clinton","bernie","sanders","pence"]
        common_words = ["to","for","a", "an", "that", "is", "with", "at", "such", "or", "and", "have", "has", "of", "the", "it's", "are", "be", "in"]
        top5title=[]
        lowestscore=9999
        after=""
        loop do
            tquery=get("/r/all/top.json", query:{after: after}, headers: {"User-Agent" => "5ddit-new"})
            unless tquery.kind_of?(Hash)
                raise "reddit is down"
            end
            if tquery["data"] == nil
                raise "data not found"
            end
            after = tquery["data"]["after"]
            tquery["data"]["children"].each do |x|
                lowestscore=x["data"]["score"] if x["data"]["score"] < lowestscore
                next if banned_url.any?{|y| x["data"]["domain"].include?(y)}
                next if banned_extension.any? {|y| x["data"]["url"].gsub(/\?.*/, '').gsub(/&.*/,'').end_with?(y)}
                next if banned_subreddit.any? {|y| x["data"]["subreddit"].downcase==y}

                next if x["data"]["is_self"]

                score=x["data"]["score"]*(100-1.15*(((time-x["data"]["created_utc"].to_i).to_i/3600)**2)/10)/100.0
                if us_nerfed_subreddit.any? {|y| x["data"]["subreddit"].downcase==y}
                    score=score*0.1
                end
                if agenda_nerfed_subreddit.any? { |y| x["data"]["subreddit"].downcase==y}
                    score=score*0.8
                end
                if entertainment_nerfed_subreddit.any? { |y| x["data"]["subreddit"].downcase==y}
                    score=score*0.5
                end
                if stupid_nerfed_subreddit.any? {|y| x["data"]["subreddit"].downcase==y}
                    score=score*0.1
                end
                if educational_subreddit.any? { |y| x["data"]["subreddit"].downcase==y}
                    score=score*2.0
                end
                if x["data"]["subreddit"].downcase=="technology" && (x["data"]["link_flair_text"].nil? || x["data"]["link_flair_text"] == "Politics" || x["data"]["link_flair_text"] == "Net Neutrality")
                    score=score/2.0
                    score=score*0.8
                end

                if politics_nerf_title.any? { |y| x["data"]["title"].downcase.include? y}
                    score=score*0.3
                end
               
                origscore=x["data"]["score"]
                title=x["data"]["title"]
                url=x["data"]["url"]
                category=x["data"]["subreddit"]
                domain=x["data"]["domain"]
                posted=(time-x["data"]["created_utc"].to_i).to_i/60
                comment=x["data"]["permalink"]
                thumbnail=x["data"]["thumbnail"]
                titleHash=(title.split(" ")-common_words).map{|x| x.downcase.gsub(/[^0-9a-z]/,'')}


            
                #fixes for the_donald
                if x["data"]["subreddit"].downcase=="the_donald"

                   #make all lowercase regardless
                   tmp = title.split(" ")
                   tmp.map!{|x| x.downcase}
                   title=tmp.join(" ")

                   #remove last sentence if last sentence is a smark remark
                   sentence = title.split(".")
                   if sentence[-1].downcase.include?("would be a shame") || sentence[-1].downcase.include?("get this to the top")
                      sentence.pop
                      title=sentence.join(".")
                   end

                   
                end

                #check duplicates
                skip = false
                top5title.each do |post|
                    if title == post[:title] && url==post[:url] && category==post[:category]
                        skip=true
                    elsif ((titleHash - post[:titleHash]).size < titleHash.size/2) || ((post[:titleHash] - titleHash).size < post[:titleHash].size/2) || url==post[:url]
                        post[:score]+=score/2
                        post[:original_score]+=origscore/2
                        skip = true
                    end
                end
                top5title.push({score: score, original_score: origscore, title: title, url: url, category: category, domain: domain, posted: posted, comment: comment, thumbnail: thumbnail, titleHash: titleHash}) unless skip
            end
            top5title.sort!{|x,y| y[:score]<=>x[:score]}
            break if  top5title.size >  4 && lowestscore < top5title[4][:score]
        end
        res = top5title[0..4]
        res.map! {|x| x.merge({comments: self.get_comment(x[:comment],x[:score]/100*5)})}
        $redis.set("top1",res[0].to_json)
        $redis.set("top2",res[1].to_json)
        $redis.set("top3",res[2].to_json)
        $redis.set("top4",res[3].to_json)
        $redis.set("top5",res[4].to_json)
        return res
    end

    def self.get_comment(commentUrl,score=1000)
        topcomments=[]
        comments=get(URI.encode(commentUrl)+".json", headers: {"User-Agent" => "5ddit"})
        if comments.kind_of?(Array)
            start=comments[1] 
            topcomments = self.simplifyJson(start,score)
        end
    end

    
    def self.simplifyJson(json,score)
        return if json["data"]==nil
        json=json["data"]["children"] 
        arr=[]
        json.each do |x|
            if x["data"]["score"] && x["data"]["score"]>score && x["data"]["author"] != "[deleted]"
                replies=simplifyJson(x["data"]["replies"],score)
                arr << {comment: CGI.unescapeHTML(x["data"]["body_html"]), score: x["data"]["score"], author: x["data"]["author"],  replies: replies}
            end
        end
        if arr.empty?
            arr=nil
        end
        arr
    end

end
