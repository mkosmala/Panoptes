class User < ActiveRecord::Base
  extend ControlControl::Resource
  include Nameable
  include Activatable
  include RoleControl::Owner
  include RoleControl::Enrolled
  include Linkable

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:facebook, :gplus]

  has_many :user_groups, through: :active_memberships
  has_many :classifications
  has_many :authorizations
  has_many :user_collection_preferences
  has_many :project_preferences, class_name: "UserProjectPreference"

  has_many :memberships
  has_many :active_memberships, -> { active }, class_name: 'Membership'

  owns :projects
  owns :collections
  owns :subjects
  owns :oauth_applications, class_name: "Doorkeeper::Application"

  enrolled_for :projects, through: :project_preferences
  enrolled_for :collections, through: :user_collection_preferences
  enrolled_for :user_groups, through: :active_memberships

  validates :login, presence: true, uniqueness: true
  validates_length_of :password, within: 8..128, allow_blank: true, unless: :migrated_user?
  validates :admin, inclusion: { in: [ true, false ], message: "must be a boolean value" }

  can :show, proc { |requester| requester.user == self }
  can :update, proc { |requester| requester.user == self }
  can :destroy, proc { |requester| requester.user == self }

  can_be_linked :membership, :all
  can_be_linked :user_group, :all
  can_be_linked :user_subject_queue, :all
  can_be_linked :user_project_preference, :all
  can_be_linked :user_collection_preference, :all

  attr_accessor :migrated_user

  def self.from_omniauth(auth_hash)
    auth = Authorization.from_omniauth(auth_hash)
    auth.user ||= create do |u|
      u.email = auth_hash.info.email
      u.password = Devise.friendly_token[0,20]
      name = auth_hash.info.name
      u.display_name = name
      u.login = StringConverter.downcase_and_replace_spaces(name)
      u.owner_name = OwnerName.new(name: u.login, resource: u)
      u.authorizations << auth
    end
  end

  def password_required?
    super && hash_func != 'sha1'
  end

  def valid_password?(password)
    if hash_func == 'bcrypt'
      super(password)
    elsif hash_func == 'sha1'
      if encrypted_password = sha1_encrypt(password)
        logger.info "User #{id} is using sha1 password. Updating..."
        self.password = password
        self.hash_func = 'bcrypt'
        self.save
        true
      else
        false
      end
    else
      false
    end
  end

  def active_for_authentication?
    !disabled? && super
  end

  def email_required?
    authorizations.blank? && !disabled?
  end

  def email_changed?
    authorizations.blank?
  end

  protected

  def migrated_user?
    !!migrated_user
  end

  def sha1_encrypt(plain_password)
    bytes = plain_password.each_char.inject(''){ |bytes, c| bytes + c + "\x00" }
    concat = Base64.decode64(password_salt).force_encoding('utf-8') + bytes
    sha1 = Digest::SHA1.digest concat
    Base64.encode64(sha1).strip
  end
end
