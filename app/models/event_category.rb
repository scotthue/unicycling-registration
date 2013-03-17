class EventCategory < ActiveRecord::Base
  attr_accessible :name, :event_id, :position, :age_group_type_id

  belongs_to :event
  belongs_to :age_group_type
  has_many :registrant_choices

  validates :name, {:presence => true, :uniqueness => {:scope => [:event_id]} }
  validates :position, :uniqueness => {:scope => [:event_id]}

  def to_s
    self.name
  end
end
