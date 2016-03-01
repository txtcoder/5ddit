class Reddit
include HTTParty
  
    base_uri 'https://www.reddit.com/r/all/top.json'
    default_params sort: "top", t: "day"
    format :json
    @@lastTime=nil
    @@lastCache=nil

    def self.top5cache
        if @@lastCache.nil?
            return self.top5
        else
            @@lastCache
        end
    end

    def self.top5
        
        time=Time.now.utc
        if @@lastTime.nil? || time-@@lastTime > 600
            @@lastTime=time
        else
            return @@lastCache
        end
        banned_url =["imgur", "facebook", "youtu","meme","wikipedia","self","gfycat","twitter", "docs.google.com", "streamable","reddit"]
        banned_extension=[".gif",".png",".jpg",".pdf", ".gifv"]
        banned_subreddit=["funny","aww","earthporn","gifs","pics","mildlyinteresting","todayilearned","h3h3productions","SandersForPresident"]
        top5title=[]
        lowestscore=9999
        after=""
        loop do
            tquery=get("", query:{after: after})
            after = tquery["data"]["after"]
            tquery["data"]["children"].each do |x|
                lowestscore=x["data"]["score"] if x["data"]["score"] < lowestscore
                next if banned_url.any?{|y| x["data"]["domain"].include?(y)}
                next if banned_extension.any? {|y| x["data"]["url"].end_with?(y)}
                next if banned_subreddit.any? {|y| x["data"]["subreddit"]==y}

                score=x["data"]["score"]-(time-x["data"]["created_utc"].to_i).to_i/36
                origscore=x["data"]["score"]
                title=x["data"]["title"]
                url=x["data"]["url"]
                category=x["data"]["subreddit"]
                domain=URI.parse(url).host
                posted=(time-x["data"]["created_utc"].to_i).to_i/60
                comment="https://www.reddit.com"+x["data"]["permalink"]

                #check duplicates
                skip = false
                top5title.each do |post|
                    if title == post[:title] && url==post[:url] && category==post[:category]
                        skip=true
                    elsif title == post[:title] || url==post[:url]
                        post[:score]+=score/2
                        post[:original_score]+=origscore/2
                        skip = true
                    end
                end
                top5title.push({score: score, original_score: origscore, title: title, url: url, category: category, domain: domain, posted: posted, commet: comment}) unless skip
            end
            top5title.sort!{|x,y| y[:score]<=>x[:score]}
            break if  top5title.size >  4 && lowestscore < top5title[4][:score]
        end
        @@lastCache=top5title[0..4]

    end

end
