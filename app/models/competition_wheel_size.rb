# == Schema Information
#
# Table name: competition_wheel_sizes
#
#  id            :integer          not null, primary key
#  registrant_id :integer
#  event_id      :integer
#  wheel_size_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class CompetitionWheelSize < ActiveRecord::Base
  belongs_to :registrant, touch: true
  belongs_to :event
  belongs_to :wheel_size

  validates :event, :registrant, :wheel_size, presence: true

end
