class Notifications < ActionMailer::Base
  add_template_helper(ApplicationHelper)

  def send_feedback(form_details)
    @contact_form = form_details

    binding.pry
    mail to: EventConfiguration.singleton.contact_email.presence,
      cc: Rails.application.secrets.error_emails, subject: 'Feedback'
  end

  def request_registrant_access(target_registrant_id, requesting_user_id)
    target_registrant = Registrant.find(target_registrant_id)
    requesting_user = User.find(requesting_user_id)

    @target_registration = target_registrant.to_s
    @requesting_user_email = requesting_user.email

    mail to: target_registrant.user.email, subject: 'Requesting access to your Registration'
  end

  def registrant_access_accepted(target_registrant_id, requesting_user_id)
    target_registrant = Registrant.find(target_registrant_id)
    requesting_user = User.find(requesting_user_id)

    @target_registration = target_registrant.to_s

    mail to: requesting_user.email, subject: 'Registrantion Access Granted'
  end

  def send_mass_email(email, addresses)
    @body = email.body

    mail bcc: addresses, subject: email.subject
  end

  ######### ADMIN
  def updated_current_reg_period(old_period_name, new_period_name)
    @old_period_description = old_period_name || "Unspecified"

    @new_period_description = new_period_name || "Unspecified"

    mail to: Rails.application.secrets.error_emails, subject: "Updated Registration Period"
  end

  def missing_old_reg_items(bib_numbers)
    @bib_numbers = bib_numbers

    mail to: Rails.application.secrets.error_emails, subject: "Registration Items Missing!"
  end
end
