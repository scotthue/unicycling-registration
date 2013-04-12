class AdditionalRegistrantAccess < ActiveRecord::Base
  attr_accessible :accepted_readonly, :declined, :registrant_id, :user_id

  belongs_to :registrant
  belongs_to :user
  validates :user, :registrant, :presence => true
  validates :registrant_id, :uniqueness => {:scope => [:user_id]}

  scope :permitted, where(:accepted_readonly => true)

  after_initialize :init

  def init
    self.accepted_readonly = false if self.accepted_readonly.nil?
    self.declined = false if self.declined.nil?
  end

  def status
    return "Declined" if declined
    return "Accepted" if accepted_readonly
    "New"
  end
end
