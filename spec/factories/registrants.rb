# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :registrant do
    first_name "FirstMyString"
    middle_initial "MMyString"
    last_name "LastMyString"
    birthday Date.new(1990,11,10)
    gender "Male"
    state "StateMyString"
    country "CountMyString"
    phone "PhoMyString"
    mobile "IMobMyString"
    email "EmailMyString"
    user # FactoryGirl
    competitor true
    club "TCUC"
    club_contact "Connie Cotter"
    usa_member_number "00001"
    emergency_name "Caitlin Goeres"
    emergency_relationship "SO"
    emergency_attending false
    emergency_primary_phone "306-555-1212"
    emergency_other_phone nil
    responsible_adult_name nil
    responsible_adult_phone nil

    factory :competitor do
      competitor true
    end
    factory :noncompetitor do
      competitor false
    end
  end
end
