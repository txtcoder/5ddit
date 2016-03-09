class NewsController < ApplicationController
  def index
    @cache = params[:cache]
    
    if @cache
        @news = Reddit.top5
        render :layout => false 
    else
        @news = Reddit.top5cache
    end
  end

  def comment
    @url = params[:comment_url].html_safe

    if @url.nil?
        raise "error"
    end
    @comments = Reddit.get_comment(@url)
  end
end
