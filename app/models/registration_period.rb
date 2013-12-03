class RegistrationPeriod < ActiveRecord::Base
  default_scope order('start_date ASC')

  validates :start_date, :end_date, :competitor_expense_item, :noncompetitor_expense_item, :presence => true

  translates :name
  accepts_nested_attributes_for :translations

  belongs_to :competitor_expense_item, :class_name => "ExpenseItem"
  belongs_to :noncompetitor_expense_item, :class_name => "ExpenseItem"

  validates :onsite, :inclusion => { :in => [true, false] } # because it's a boolean

  after_initialize :init

  def init
    self.onsite = false if self.onsite.nil?
  end


  # We allow registrations to arrive 1 day _after_ the end date,
  # to account for timezone differences, and 'last minute' shoppers.
  def last_day
    self.end_date + 1.day
  end

  def current_period?(date = Date.today)
    return (self.start_date <= date and date <= last_day)
  end

  def past_period?(date = Date.today)
    return (self.last_day < date)
  end

  def self.last_online_period
    last_period = nil
    RegistrationPeriod.all.each do |rp|
      next if rp.onsite
      last_period = rp
    end
    last_period
  end

  def self.relevant_period(date)
    RegistrationPeriod.all.each do |rp|
      if rp.current_period?(date)
        return rp
      end
    end
    return nil
  end

  def self.paid_for_period(competitor, paid_items)
    RegistrationPeriod.includes(:noncompetitor_expense_item).includes(:competitor_expense_item).each do |rp|
      if competitor
        if paid_items.include?(rp.competitor_expense_item)
          return rp
        end
      else
        if paid_items.include?(rp.noncompetitor_expense_item)
          return rp
        end
      end
    end
    nil
  end
end
