module SessionHelper
  
  CookieExpireTime = 10 # years

  # Logs in the given user.
  def log_in(unoem, pwd)
    user = User.wide_query(unoem)
    if user && user.authenticate(pwd)
      user.update_login_time
      return user
    end
  end

  def set_user(user)
    return unless user
    session[:user_id] = user.id
  end

  # Logs out the current user.
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end

  # Remembers a user in a persistent session.
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = {
      value: user.remember_token,
      expires: CookieExpireTime.years.from_now.utc
    }
  end

  # Forgets a persistent session.
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # Returns the user corresponding to the remember token cookie.
  def current_user
    return @current_user if @current_user
    if (uid = session[:user_id])
      return @current_user = User.find(uid)
    elsif (uid = cookies.signed[:user_id])
      user = User.find(uid)
      if user && user.authenticated?(cookies[:remember_token])
        set_user(user)
        return @current_user = user
      end
    end
  end

end
