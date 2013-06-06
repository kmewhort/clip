class AdminMailer < ActionMailer::Base
  default from: "no-reply@clipol.org"

  def update_notification(licence, licence_yaml)
    @licence = licence
    @licence_yaml = licence_yaml

    mail to: Admin.all.map {|a| a.email}, subject: "[CLIPol] Review pending for update to #{@licence.full_title}"
  end
end