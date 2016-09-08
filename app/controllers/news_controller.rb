class NewsController < ApplicationController
  def index
    user_agent = request.env['HTTP_USER_AGENT']
    if /Version\/\d\.\d Chrome/.match(user_agent)
        @from_app = true
    else
        @from_app = false
    end
    @cache = params[:cache]
    @debug = params[:debug]
    if @debug
        render text: Reddit.debug
    end
    if @cache
        @news = Reddit.top5
        render :layout => false 
    else
        @news = Reddit.top5cache
    end
  end



  #code not currently in use
  def comment
    @url = params[:comment_url].html_safe

    if @url.nil?
        raise "error"
    end
    @comments = Reddit.get_comment(@url)
  end
end
