desc "Update top 5 reddit news"
task :update_top => :environment do
    puts "start updating"
    Reddit.top5
    puts "done"
end

