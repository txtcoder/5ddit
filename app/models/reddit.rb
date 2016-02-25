class Reddit
include HTTParty
  
    base_uri 'https://www.reddit.com/r/all/top.json'
    default_params sort: "top", t: "day"
    format :json
    @@lastTime=nil
    @@lastCache=nil
    def self.top5
        
        time=Time.now.utc
        if @@lastTime.nil? || time-@@lastTime > 60
            @@lastTime=time
        else
            return @@lastCache
        end
        banned_url =["imgur", "facebook", "youtu","makeameme","wikipedia","self","gfycat"]
        banned_extension=[".gif",".png",".jpg"]
        banned_subreddit=["funny","aww","porn","gifs","pics","mildlyinteresting","todayilearned","h3h3productions"]
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
                top5title.push([score,origscore,title,url,category])
            end
            top5title.sort!{|x,y| y[0]<=>x[0]}
            break if  top5title.size >  4 && lowestscore+1000 < top5title[4][0]
        end
        @@lastCache=top5title[0..4]

    end

end
