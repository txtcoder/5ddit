class RedditController < ApplicationController
  def redirect
    redirect_to "http://reddit.com/"+params[:path]
  end
end
