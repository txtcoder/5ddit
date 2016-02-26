class NewsController < ApplicationController
  def index
    @cache = params[:cache]
    
    if @cache
        @news = Reddit.top5
    else
        @news = Reddit.top5cache
    end
  end
end
