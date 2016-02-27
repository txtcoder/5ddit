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
end
