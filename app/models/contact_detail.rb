# == Schema Information
#
# Table name: contact_details
#
#  id                      :integer          not null, primary key
#  registrant_id           :integer
#  address                 :string(255)
#  city                    :string(255)
#  state                   :string(255)
#  zip                     :string(255)
#  country_residence       :string(255)
#  country_representing    :string(255)
#  phone                   :string(255)
#  mobile                  :string(255)
#  email                   :string(255)
#  club                    :string(255)
#  club_contact            :string(255)
#  usa_member_number       :string(255)
#  emergency_name          :string(255)
#  emergency_relationship  :string(255)
#  emergency_attending     :boolean
#  emergency_primary_phone :string(255)
#  emergency_other_phone   :string(255)
#  responsible_adult_name  :string(255)
#  responsible_adult_phone :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#

class ContactDetail < ActiveRecord::Base

  belongs_to :registrant, :inverse_of => :contact_detail

  validates :address, :city, :country_residence, :zip, :presence => true
  validates :state, :presence => true, :unless => "EventConfiguration.usa == false"

  # contact-info block
  validates :emergency_name, :emergency_relationship, :emergency_primary_phone, :presence => true
  validates :responsible_adult_name, :responsible_adult_phone, :presence => true, :if => :minor?

  def minor?
    registrant && registrant.age < 18
  end

  def country_code
    if self.country_representing.nil? or self.country_representing.empty?
      self.country_residence
    else
      self.country_representing
    end
  end

  def country
    Carmen::Country.coded(self.country_code).try(:name)
  end
end