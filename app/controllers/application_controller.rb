class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :all # include all helpers, all the time

private

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default, flash_param={})
    redirect_to((session[:return_to] || default), flash_param)
    session[:return_to] = nil
  end
end
