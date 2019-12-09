class PagesController < ApplicationController
  def index
    return home if logged_in?
    render 'welcome'
  end

  def home
    return index unless logged_in?
    render 'main'
  end

  def login
    return home if logged_in?
  end

  def signup
    return home if logged_in?
  end

  def passwordForget
  end

  def passwordReset
  end
end
