class PagesController < ApplicationController
  def index
    return home if logged_in?
    render 'welcome'
  end

  def home
    return login unless logged_in?
    render 'main'
  end

  def login
    return home if logged_in?
    render 'login'
  end

  def signup
    return home if logged_in?
    render 'signup'
  end

  def passwordForget
  end

  def passwordReset
  end

  def search
    flash.now[:danger] = 'Please log in first' unless logged_in?
    return login unless logged_in?
    render 'search'
  end

  def task
    flash.now[:danger] = 'Please log in first' unless logged_in?
    return login unless logged_in?
    render 'task'
  end

  def userInfo
    flash.now[:danger] = 'Please log in first' unless logged_in?
    return login unless logged_in?
    render 'userInfo'
  end
end
