# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :expense_item do
    sequence(:name) {|n| "T-Shirt Size ##{n}" }
    description "TShirt Small"
    cost "9.99"
    export_name "t_shirt_small"
    position 1
    expense_group # FactoryGirl
    has_details false
    has_custom_cost false
    details_label nil
    maximum_available nil
    maximum_per_registrant 0
  end
end
