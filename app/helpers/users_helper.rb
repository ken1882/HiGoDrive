module UsersHelper
  include ApplicationHelper

  private

  UserInitParms    = [:username, :password, :password_confirmation, :email, :phone, :realname, :roles]
  UserUpdateParams = [:nickname, :old_password, :password, :password_confirmation, :email, :avatar_url, :bio]
  UserUpdateFields = [:nickname, :password, :password_confirmation, :email, :avatar_url, :bio]
  UserFindParms    = [:id, :username, :email]
  UserPosParams    = [:lat, :lng]
  UserResetParams  = [:username, :token, :password, :password_confirmation]
  UserResetFields  = [:password, :password_confirmation]
  DriverLicenseParams = [:driver_license, :vehicle_license, :exterior, :plate, :model]
  SupportedAvatarFormat = [:png, :jpg, :jpeg, :bmp, :webp]

  ForgotDuration   = 60 * 30

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

  def user_reset_params
    filter_params UserResetParams
  end

  def user_reset_fields
    filter_params UserResetFields
  end

  def driver_license_params
    filter_params DriverLicenseParams
  end
end