class RequiredExpenseItemCreator
  attr_accessor :registrant

  def initialize(registrant)
    @registrant = registrant
  end

  def create
    # add the registration_cost expense_item
    unless registrant.reg_paid?
      registrant.build_registration_item(registration_item)
    end

    required_expense_items.each do |ei|
      registrant.build_registration_item(ei)
    end
  end

  private

  def registration_item
    RegistrationCost.relevant_period(registrant.registrant_type, Date.today).try(:expense_item)
  end

  # any items which have a required element, but only 1 element in the group (no choices allowed by the registrant)
  def required_expense_items
    egs = @registrant.registrant_type_model.required_expense_groups

    egs.select { |expense_group| expense_group.expense_items.count == 1 }
       .map{ |expense_group| expense_group.expense_items.first }
  end
end
