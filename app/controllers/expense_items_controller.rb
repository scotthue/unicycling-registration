class ExpenseItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_breadcrumbs

  # GET /expense_items/1/details
  def details
    @expense_item = ExpenseItem.find(params[:id])
    authorize current_user, :manage_all_payments?
    @paid_details = @expense_item.paid_items
    @unpaid_details = @expense_item.unpaid_items
    @free_with_registration = @expense_item.free_items
    @refunded_details = @expense_item.refunded_items
  end

  private

  def set_breadcrumbs
    add_payment_summary_breadcrumb
    add_breadcrumb "#{@expense_item} Items"
  end
end
