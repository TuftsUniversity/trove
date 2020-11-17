require_dependency Hyrax::Engine.root.join('app', 'models', 'hyrax', 'contact_form').to_s

module Hyrax
  class ContactForm
    include ActiveModel::Model
    validates :email, :name, :subject, :message, presence: true

    def headers
      {
          subject: "#{Hyrax.config.subject_prefix} #{subject}",
          to: Hyrax.config.contact_email,

          # Send email from the admin contact inbox to itself. E.g. if configured to repo-admin@example.ac.uk, email
          # will come from that address and also go to that address. Send on behalf of the actual user's email address
          # (the `email` variable) will only be successful if we have permission to send email on behalf of that user.
          # If the user enters a @gmail.com or @btinternet.com address, we have no chance of obtaining permission and
          # SMTP servers will reject the message, causing the form to fail to send anything.
          # The message body (see the contact_mailer view in Hyrax) still contains the user's email address for admins to see.
          from: Hyrax.config.contact_email  # use `email` as the value instead to try to send on behalf of the user
      }
    end
  end
end