class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActiveModel::SecurePassword
  has_many :tasks, dependent: :destroy

  UsernameRegex = /\A[[:alnum:]]*\z/
  EmailRegex = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  PhoneRegex = /\+([0-9]{3})-([0-9]+)-([0-9]{8})/

  attr_accessor :remember_token

  field :roles, type: Integer
  field :username, type: String
  field :realname, type: String
  field :email, type: String
  field :phone, type: String
  field :password_digest, type: String
  field :nickname, type: String
  field :last_login_time, type: DateTime
  field :remember_digest, type: String
  field :avatar, type: String
  field :lat, type: Float
  field :lng, type: Float
  field :password_reset_token, type: String
  field :bio, type: String

  validates :roles, numericality: { only_integer: true }
  validates :username, presence: true, length: {in: 6..32}, 
    uniqueness: true, format: {with: UsernameRegex}
  
  validates :email, presence: true, format: {with: EmailRegex}, 
    length: {in: 3..256}, uniqueness: { case_sensitive: false }

  validates :realname, presence: true
  validates :phone, presence: true, uniqueness: true, 
    format: {with: PhoneRegex}

  has_secure_password
  validates :password_digest, presence: true, length: {in: 6..256}

  def self.username_exist?(uname)
    self.where({'username' => uname}).count != 0
  end

  def self.email_exist?(email)
    self.where({'email' => email}).count != 0
  end

  def self.phone_exist?(phone)
    self.where({'phone' => phone}).count != 0
  end

  def self.exist?(params)
    return username_exist?(params[:username]) || 
      email_exist?(params[:email]) || phone_exist?(params[:phone])
  end

  def self.register_param_ok?(params)
    return false if exist?(params)
    return false if (params[:password] || '').length < 6
    return false unless params[:username].match(/^[[:alnum:]]*$/)
    return true
  end

  def self.wide_query(value)
    self.find(self.or(
      {'id' => value || ''},
      {'username' => value || ''},
      {'email' => value || ''},
    ))
  end

  def self.new_token; SecureRandom.urlsafe_base64; end

  def initialize(_params)
    _params[:phone] = Util.format_phone_number(_params[:phone])
    super
  end

  def init_roles
    bt = (@attributes['roles'] || 0) | RoleManager.get_role_bitset(:passenger)
    update_attribute :roles, bt
  end

  def set_roles(*roles, **kwargs)
    bitset = 0
    roles.each do |role|
      bt = RoleManager.get_role_bitset(role) if role.is_a?(Symbol)
      bt = Integer(role) rescue 0
      bitset |= bt
    end
    @attributes['roles'] |= bitset
    save if kwargs[:save]
  end

  def remove_roles(*roles, **kwargs)
    bitset = 0xffff
    roles.each do |role|
      bt = RoleManager.get_role_bitset(role) if role.is_a?(Symbol)
      bt = Integer(role) rescue 0
      bitset &= ~bt
    end
    @attributes['roles'] &= bitset
    save if kwargs[:save]
  end

  def name
    nickname || username
  end

  def public_json_info
    {
      'id'       => id.to_s,
      'username' => username,
      'nickname' => nickname,
      'realname' => realname,
      'phone'    => phone,
      'email'    => email,
      'roles'    => roles,
      'bio'      => bio,
    }
  end

  def authenticated?(remember_token)
    return if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def remember
    @remember_token = User.new_token
    update_attribute(:remember_digest, SecurityManager.hash_digest(@remember_token))
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def require_login
    return true if logged_in?
    flash.now[:danger] = "Please log in"
    redirect_to login_url
  end

  def set_pos(lat, lng)
    update_attribute(:lat, lat)
    update_attribute(:lng, lng)
  end

  def get_pos
    return {
      :lat => self.lat,
      :lng => self.lng
    }
  end

  def generate_reset_token(auth_token)
    token = SecurityManager.sha256(auth_token + self.email + Time.now.to_s)
    update_attribute :password_reset_token, token
    token
  end

  def reset_password(_params)
    self.update(_params)
    update_attribute :password_reset_token, nil
  end

  def update_login_time
    update_attribute :last_login_time, Time.mongoize(Time.now)
  end

  def licensed?
    return false
  end

  def mutex 
    return @mutex if @mutex
    @mutex = Mutex.new
  end
end