# == Schema Information
#
# Table name: event_configurations
#
#  id                                    :integer          not null, primary key
#  short_name                            :string(255)
#  long_name                             :string(255)
#  location                              :string(255)
#  dates_description                     :string(255)
#  event_url                             :string(255)
#  start_date                            :date
#  contact_email                         :string(255)
#  artistic_closed_date                  :date
#  standard_skill_closed_date            :date
#  event_sign_up_closed_date             :date
#  created_at                            :datetime
#  updated_at                            :datetime
#  test_mode                             :boolean          default(FALSE), not null
#  comp_noncomp_url                      :string(255)
#  standard_skill                        :boolean          default(FALSE), not null
#  usa                                   :boolean          default(FALSE), not null
#  iuf                                   :boolean          default(FALSE), not null
#  currency_code                         :string(255)
#  rulebook_url                          :string(255)
#  style_name                            :string(255)
#  custom_waiver_text                    :text
#  music_submission_end_date             :date
#  artistic_score_elimination_mode_naucc :boolean          default(TRUE), not null
#  usa_individual_expense_item_id        :integer
#  usa_family_expense_item_id            :integer
#  logo_file                             :string(255)
#  max_award_place                       :integer          default(5)
#  display_confirmed_events              :boolean          default(FALSE), not null
#  spectators                            :boolean          default(FALSE), not null
#  usa_membership_config                 :boolean          default(FALSE), not null
#  paypal_account                        :string(255)
#  waiver                                :string(255)      default("none")
#  validations_applied                   :integer
#  italian_requirements                  :boolean          default(FALSE), not null
#  rules_file_name                       :string(255)
#  accept_rules                          :boolean          default(FALSE), not null
#  paypal_mode                           :string(255)      default("disabled")
#  offline_payment                       :boolean          default(FALSE), not null
#

require 'spec_helper'

# so that I can test print_item_cost_currency
include ApplicationHelper

describe EventConfiguration do
  before(:each) do
    @ev = FactoryGirl.build(:event_configuration, :standard_skill_closed_date => Date.new(2013, 5, 5))
  end

  it "is valid from factoryGirl" do
    expect(@ev.valid?).to eq(true)
  end

  it "has a short name" do
    @ev.short_name = nil
    @ev.apply_validation(:name_logo)
    expect(@ev.valid?).to eq(false)
  end

  it "does not allows a blank style_name" do
    @ev.style_name = nil
    @ev.apply_validation(:base_settings)
    expect(@ev.valid?).to eq(false)
  end

  it "doesn't allow an unknown currency code" do
    @ev.currency_code = "Robin"
    expect(@ev).to be_invalid
  end

  context "when in EUR format" do
    before :each do
      @ev.update_attribute(:currency_code, "EUR")
    end

    it "returns the EUR symbol" do
      expect(@ev.currency_unit).to eq("€")
    end

    it "converts from EUR to Symbol" do
      expect(print_item_cost_currency(10)).to eq("10.00€")
    end
  end

  it "has a list of style_names" do
    expect(EventConfiguration.style_names.count).to be > 0
  end

  it "style_name must be a valid_style_name" do
    @ev.style_name = "fake"
    @ev.apply_validation(:base_settings)
    expect(@ev.valid?).to eq(false)

    @ev.style_name = EventConfiguration.style_names.first[1]
    expect(@ev.valid?).to eq(true)
  end

  it "has a style_name even without having any entries" do
    expect(EventConfiguration.new.style_name).to eq("naucc_2013")
  end

  it "has a long name" do
    @ev.long_name = nil
    @ev.apply_validation(:name_logo)
    expect(@ev.valid?).to eq(false)
  end

  it "event_url can be nil" do
    @ev.event_url = nil
    @ev.apply_validation(:name_logo)
    expect(@ev.valid?).to eq(true)
  end

  it "event_url must be url" do
    @ev.event_url = "hello"
    expect(@ev.valid?).to eq(false)

    @ev.event_url = "http://www.google.com"
    expect(@ev.valid?).to eq(true)
  end

  it "can have a blank comp_noncomp_url" do
    @ev.comp_noncomp_url = ""
    expect(@ev.valid?).to eq(true)
  end

  it "must have a test_mode" do
    @ev.test_mode = nil
    @ev.apply_validation(:important_dates)
    expect(@ev.valid?).to eq(false)
  end

  it "defaults test_mode to false" do
    ev = EventConfiguration.new
    expect(ev.test_mode).to eq(false)
  end

  it "should be open if no periods are defined" do
    expect(EventConfiguration.closed?).to eq(false)
  end

  it "should NOT have standard_skill_closed by default " do
    expect(EventConfiguration.singleton.standard_skill_closed?(Date.new(2013, 1, 1))).to eq(false)
  end

  describe "with the standard_skill_closed_date defined" do
    it "should be closed on the 5th" do
      @ev.save!
      expect(EventConfiguration.singleton.standard_skill_closed?(Date.new(2013, 5, 4))).to eq(false)
      expect(EventConfiguration.singleton.standard_skill_closed?(Date.new(2013, 5, 5))).to eq(true)
      expect(EventConfiguration.singleton.standard_skill_closed?(Date.new(2013, 5, 6))).to eq(true)
    end
  end

  describe "with a registration period" do
    before(:each) do
      @rp = FactoryGirl.create(:registration_period, :start_date => Date.new(2012, 11, 03), :end_date => Date.new(2012, 11, 07))
    end
    it "should be open on the last day of registration" do
      expect(EventConfiguration.closed?(Date.new(2012, 11, 07))).to eq(false)
    end
    it "should be open as long as the registration_period is current" do
      d = Date.new(2012, 11, 07)
      expect(@rp.current_period?(d)).to eq(true)
      expect(EventConfiguration.closed?(d)).to eq(false)

      e = Date.new(2012, 11, 8)
      expect(@rp.current_period?(e)).to eq(true)
      expect(EventConfiguration.closed?(e)).to eq(false)

      f = Date.new(2012, 11, 9)
      expect(@rp.current_period?(f)).to eq(false)
      expect(EventConfiguration.closed?(f)).to eq(true)
    end
  end

  it "returns the live paypal url when TEST is false" do
    @ev.update_attribute(:paypal_test, false)
    expect(EventConfiguration.paypal_base_url).to eq("https://www.paypal.com")
  end
  it "returns the test paypal url when TEST is true" do
    @ev.update_attribute(:paypal_test, true)
    expect(EventConfiguration.paypal_base_url).to eq("https://www.sandbox.paypal.com")
  end

  describe "when doing partial_model validations" do
    it "allows waiver nil when not validated" do
      @ec = FactoryGirl.build :event_configuration
      @ec.validations_applied = 0
      @ec.waiver = nil
      expect(@ec).to be_valid

      @ec.apply_validation(:base_settings)
      expect(@ec).to be_invalid
    end
  end
end
