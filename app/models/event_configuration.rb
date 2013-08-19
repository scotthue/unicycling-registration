class EventConfiguration < ActiveRecord::Base
  attr_accessible :artistic_closed_date, :contact_email, :currency, :dates_description, :event_url, :iuf, :location, :logo_image, :long_name, :short_name, :standard_skill, :standard_skill_closed_date, :start_date, :tshirt_closed_date, :test_mode, :usa, :waiver, :waiver_url, :comp_noncomp_url

  validates :short_name, :long_name, :presence => true
  validates :event_url, :format => URI::regexp(%w(http https)), :unless => "event_url.nil?"
  validates :comp_noncomp_url, :format => URI::regexp(%w(http https)), :unless => "comp_noncomp_url.nil? or comp_noncomp_url.empty?"
  

  validates :test_mode, :inclusion => { :in => [true, false] } # because it's a boolean
  validates :waiver, :inclusion => { :in => [true, false] } # because it's a boolean
  validates :usa, :inclusion => { :in => [true, false] } # because it's a boolean
  validates :iuf, :inclusion => { :in => [true, false] } # because it's a boolean
  validates :standard_skill, :inclusion => { :in => [true, false] } # because it's a boolean
  
  if EventConfiguration.first.standard_skill
    validates :standard_skill_closed_date, :presence => true
  end

  after_initialize :init

  def init
    self.test_mode = true if self.test_mode.nil?
  end

  def logo_image=(input_data)
    self.logo_filename = input_data.original_filename
    self.logo_type = input_data.content_type.chomp
    self.logo_binary = input_data.read
  end

  def self.paypal_base_url
    paypal_test_url = "https://www.sandbox.paypal.com"
    paypal_live_url = "https://www.paypal.com"

    if ENV['PAYPAL_TEST'].nil? or ENV['PAYPAL_TEST'] == "true"
      paypal_test_url
    else
      paypal_live_url
    end
  end

  def self.contact_email
    ec = EventConfiguration.first
    if ec.nil?
      ""
    else
      ec.contact_email
    end
  end

  def self.short_name
    ec = EventConfiguration.first
    if ec.nil?
      ""
    else
      ec.short_name
    end
  end

  def self.long_name
    ec = EventConfiguration.first
    if ec.nil?
      ""
    else
      ec.long_name
    end
  end

  def self.start_date
    ec = EventConfiguration.first
    if ec.nil?
      nil
    else
      ec.start_date
    end
  end

  def self.closed_date
    last_online_rp = RegistrationPeriod.last_online_period
    last_online_rp.end_date unless last_online_rp.nil?
  end

  def self.closed?(today = Date.today)
    last_online_rp = RegistrationPeriod.last_online_period

    if last_online_rp.nil?
      false
    else
      last_online_rp.last_day < today
    end
  end

  def self.standard_skill
    ec = EventConfiguration.first
    if ec.nil? or ec.standard_skill.nil?
      nil
    else
      ec.waiver
    end
  end

  def self.standard_skill_closed?(today = Date.today)
    ec = EventConfiguration.first
    if ec.nil?
      false
    else
      ec.standard_skill_closed_date <= today
    end
  end


  def self.waiver_url
    ec = EventConfiguration.first
    if ec.nil? or ec.waiver_url.nil? or  ec.waiver_url.empty?
      nil
    else
      ec.waiver_url
    end
  end

  def self.waiver
    ec = EventConfiguration.first
    if ec.nil? or ec.waiver.nil?
      nil
    else
      ec.waiver
    end
  end

  def self.usa
    ec = EventConfiguration.first
    if ec.nil? or ec.usa.nil?
      nil
    else
      ec.usa
    end
  end

  def self.iuf
    ec = EventConfiguration.first
    if ec.nil? or ec.iuf.nil?
      nil
    else
      ec.iuf
    end
  end

  def self.comp_noncomp_url
    ec = EventConfiguration.first
    if ec.nil? or ec.comp_noncomp_url.nil? or  ec.comp_noncomp_url.empty?
      nil
    else
      ec.comp_noncomp_url
    end
  end

  def self.configuration_exists?
    !EventConfiguration.first.nil?
  end

  def self.event_url
    ec = EventConfiguration.first
    if ec.nil? or ec.event_url.nil? or  ec.event_url.empty?
      nil
    else
      ec.event_url
    end
  end

  def as_json(options={})
    super(:except => [:logo_binary, :logo_type, :logo_filename])
  end

end
