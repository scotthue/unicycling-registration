# == Schema Information
#
# Table name: competitors
#
#  id                       :integer          not null, primary key
#  competition_id           :integer
#  position                 :integer
#  custom_name              :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  status                   :integer          default(0)
#  lowest_member_bib_number :integer
#  geared                   :boolean          default(FALSE), not null
#  riding_wheel_size        :integer
#  notes                    :string(255)
#  wave                     :integer
#  riding_crank_size        :integer
#
# Indexes
#
#  index_competitors_event_category_id  (competition_id)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

require 'rspec/mocks/standalone'

FactoryGirl.define do
  factory :event_competitor, class: Competitor do
    competition # FactoryGirl

    transient do
      bib_number nil
    end

    after(:create) do |comp, evaluator|
      member = FactoryGirl.create(:member, competitor: comp)
      reg = member.registrant
      reg.update(bib_number: evaluator.bib_number) if evaluator.bib_number.present?
      reg.reload.touch_members # propagate bib_number to competitor
      comp.reload
    end

    after(:stub) do |competitor|
      allow(competitor).to receive(:members).and_return([FactoryGirl.build_stubbed(:member, competitor: competitor)])
    end
  end

  factory :member, class: Member do
    registrant
    association :competitor, factory: :event_competitor
  end
end
