module UsersHelper
  include ApplicationHelper

  private

  UserInitParms    = [:username, :nickname, :password, :password_confirmation, :email]
  UserUpdateParams = [:nickname, :old_password, :password, :password_confirmation, :email, :avatar_url]
  UserUpdateFields = [:nickname, :password, :password_confirmation, :email, :avatar_url]
  UserFindParms    = [:id, :username, :email]
  UserPosParams    = [:lat, :lng]
  SupportedAvatarFormat = [:png, :jpg, :jpeg, :bmp, :webp]

  def user_init_params
    filter_params UserInitParms
  end

  def user_update_params
    filter_params UserUpdateParams
  end

  def user_update_fields
    filter_params UserUpdateFields
  end

  def user_find_params
    filter_params UserFindParms
  end

  def user_pos_params
    filter_params UserPosParams
  end
end