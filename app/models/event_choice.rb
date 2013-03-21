class EventChoice < ActiveRecord::Base
  attr_accessible :cell_type, :event_id, :export_name, :label, :multiple_values, :position, :autocomplete

  belongs_to :event
  has_many :registrant_choices, :dependent => :destroy

  validates :label, {:presence => true}
  validates :export_name, {:presence => true, :uniqueness => true}
  validates :cell_type, :inclusion => {:in => %w(boolean text multiple), :message => "%{value} must be either 'boolean' or 'text' or 'multiple'"}
  validates :position, :uniqueness => {:scope => [:event_id]}
  validates :autocomplete, :inclusion => {:in => [true, false] } # because it's a boolean

  after_initialize :init

  def init
    self.autocomplete = false if self.autocomplete.nil?
  end

  def choicename
    "choice#{id}"
  end

  def values
    multiple_values.split(%r{,\s*})
  end

  def unique_values
    self.registrant_choices.map{|rc| rc.value}.uniq
  end

  def to_s
    self.event.to_s + " - " + self.export_name
  end
end
