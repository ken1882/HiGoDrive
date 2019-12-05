module UsersHelper

  UserInitParms    = [:username, :nickname, :password, :password_confirmation, :email]
  UserUpdateParams = [:nickname, :old_password, :new_password, :email]
  UserFindParms    = [:id, :username, :email]

  # Never trust parameters from the scary internet, only allow the white list through.
  def filter_params(param_set)
    begin
      params.require(:user).permit(*param_set)
    rescue Exception
      params.permit(*param_set)
    end
  end

  def user_init_params
    filter_params UserInitParms
  end

  def user_update_params
    filter_params UserUpdateParams
  end

  def user_find_params
    filter_params UserFindParms
  end
end