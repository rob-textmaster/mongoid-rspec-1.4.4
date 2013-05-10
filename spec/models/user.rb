class User
  include Mongoid::Document

  ADMIN_RIGHTS = %w(unicorns strawberries)

  field :login
  field :email
  field :role
  field :admin_rights, type: Array
  field :age,          type: Integer

  referenced_in :site, :inverse_of => :users
  references_many :articles, :foreign_key => :author_id
  references_many :comments, :dependent => :destroy, :autosave => true
  references_and_referenced_in_many :children, :class_name => "User"
  references_one :record

  embeds_one :profile

  validates :login, :presence => true, :uniqueness => { :scope => :site }, :format => { :with => /^[\w\-]+$/ }
  validates :email, :uniqueness => { :case_sensitive => false, :scope => :site, :message => "is already taken" }, :confirmation => true
  validates :role, :presence => true, :inclusion => { :in => ["admin", "moderator", "member"]}
  validates :profile, :presence => true, :associated => true

  validates :admin_rights, inclusion: ADMIN_RIGHTS, :if => :admin?
  validates :age, numericality: { only_integer: true, greater_than: 18 }, :unless => :admin?

  def admin?
    false
  end

end
