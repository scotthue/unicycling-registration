# == Schema Information
#
# Table name: standard_skill_entries
#
#  id          :integer          not null, primary key
#  number      :integer
#  letter      :string(255)
#  points      :decimal(6, 2)
#  description :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :standard_skill_entry do
    sequence(:number)
    sequence(:letter) { |n| 
        x = "a"
        n.times do |i|
            x = x.next
        end
        x
    }
    points "1.3"
    description "riding - 8"
  end
end
