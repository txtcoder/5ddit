class NewsController < ApplicationController
  def index
    @news = Reddit.top5cache
  end

  def comment
    @url = params[:comment_url].html_safe

    if @url.nil?
        raise "error"
    end
    @comments = Reddit.get_comment(@url)
  end
end
