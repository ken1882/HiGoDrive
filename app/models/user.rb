class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActiveModel::SecurePassword

  has_many :tasks, dependent: :destroy
  has_many :push_notifications, dependent: :destroy

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
  field :avatar_url, type: String
  field :lat, type: Float
  field :lng, type: Float
  field :password_reset_token, type: String
  field :bio, type: String
  field :tasks_engaging, type: Array
  field :tasks_history, type: Array
  field :forgot_timestamp, type: DateTime
  field :endpoint, type: String           # notification
  field :p256dh, type: String             # notification
  field :auth, type: String               # notification
  field :driver_license, type: String
  field :vehicle_license, type: String
  field :exterior, type: String
  field :plate, type: String
  field :model, type: String
  field :unaccepted_preorders, type: Array
  field :accepted_preorders, type: Array
  field :verified_driver, type: Boolean

  # validates :roles, numericality: { only_integer: true }
  # validates :username, presence: true, length: {in: 6..32},
  #   uniqueness: true, format: {with: UsernameRegex}

  # validates :email, presence: true, format: {with: EmailRegex},
  #   length: {in: 3..256}, uniqueness: { case_sensitive: false }

  # validates :realname, presence: true
  # validates :phone, presence: true, uniqueness: true,
  #   format: {with: PhoneRegex}

  has_secure_password
  validates :password_digest, presence: true, length: {in: 6..256}

  def self.setup
    $unlicensed_drivers = []
    self.all.each do |user|
      next unless RoleManager.match?(user.roles, :driver)
      next if user.driver_license.nil? || user.licensed?
      $unlicensed_drivers << user.id.to_s
    end
  end

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
    return false unless params[:username].match(/^([[:alnum:]]|\_)*$/)
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
    _params[:roles] = _params[:roles].to_i
    super
  end

  def init_roles
    bt = (@attributes['roles'] || 0) | RoleManager.get_role_bitset(:passenger)
    update_attribute :roles, bt
  end

  def set_roles(*roles, **kwargs)
    bitset = 0
    roles.each do |role|
      bt = RoleManager.get_bitset(role) if role.is_a?(Symbol)
      bt = Integer(role) rescue 0
      bitset |= bt
    end
    @attributes['roles'] |= bitset
    save if kwargs[:save]
  end

  def remove_roles(*roles, **kwargs)
    bitset = 0xffff
    roles.each do |role|
      bt = RoleManager.get_bitset(role) if role.is_a?(Symbol)
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
      'id'         => id.to_s,
      'username'   => username,
      'nickname'   => nickname,
      'realname'   => realname,
      'phone'      => phone,
      'email'      => email,
      'roles'      => roles,
      'bio'        => bio,
      'avatar_url' => get_gravatar_url,
      'verified_driver' => verified_driver
    }
  end

  def driver_json_info
    {
      :id => id.to_s,
      :username => username,
      :driver_license   => driver_license,
      :vehicle_license  => vehicle_license,
      :exterior         => exterior,
      :plate            => plate,
      :model            => model
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

  def get_gravatar_url(size = 360)
    return "https://s.gravatar.com/avatar/" + SecurityManager.md5(email) + "?s=#{size}"
  end

  def generate_reset_token(auth_token)
    token = SecurityManager.sha256(auth_token + self.email + Time.now.to_s)
    self.update(
      :password_reset_token => token,
      :forgot_timestamp     => Time.mongoize(Time.now)
    )
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
    return self.verified_driver || false
  end

  def mutex
    return @mutex if @mutex
    @mutex = Mutex.new
  end

  def engage_task(tid)
    self.add_to_set(tasks_engaging: tid)
    self.add_to_set(tasks_history: tid)
  end

  def engage_preorder(tid)
    self.add_to_set(tasks_engaging: tid)
  end

  def resolve_task(tid)
    self.pull(tasks_engaging: tid)
    self.pull(accepted_preorders: tid)
    self.pull(unaccepted_preorders: tid)
  end

  def add_preorder(tid)
    self.add_to_set(unaccepted_preorders: tid)
  end

  def accept_preorder(tid)
    self.pull(unaccepted_preorders: tid)
    self.add_to_set(accept_preorders: tid)
    self.add_to_set(tasks_history: tid)
  end

  def all_tasks
    ret  = self.tasks.collect{|t| t.public_json_info}
    ret += Task.find(self.tasks_history || []).collect{|t| t.public_json_info}
    ret
  end

  def accept_license
    update_attribute :verified_driver, true
  end

  def revoke_license
    self.update({
      :driver_license   => nil,
      :vehicle_license  => nil,
      :exterior         => nil,
      :plate            => nil,
      :model            => nil,
      :verified_driver  => false
    })
  end
end
