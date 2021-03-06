class ContactForm
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_accessor :feedback, :email, :signed_in
  validates :feedback, presence: true
  validates :email, presence: { message: "can't be empty when not signed in" }, unless: '@signed_in.present?'

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def username=(value)
    @username = value
  end

  def username
    @username || "not-signed-in"
  end

  def registrants=(value)
    @registrants = value
  end

  def registrants
    @registrants || "unknown"
  end

  def update_from_user(user)
    self.username = user.email
    self.registrants = user.registrants.first.name if user.registrants.count > 0
    @signed_in = true
  end

  # Specify an e-mail address to reply to for any feedback received.
  def reply_to_email
     email.presence || username
  end

  def serialize
    YAML.dump(self)
  end

  def self.deserialize(yaml)
    YAML.load(yaml)
  end

  def persisted?
    false
  end
end
