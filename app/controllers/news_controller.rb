class NewsController < ApplicationController
  def index
    @news = Reddit.top5
  end
end
