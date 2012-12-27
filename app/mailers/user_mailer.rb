class UserMailer < ActionMailer::Base
  default from: 'info@assets.com'
  
  def signup_email(user)
    @url = "http://localhost:3000/users/#{user.id}/confirm/#{user.confirmation_code}"
    @user = user
    mail(:to => user.email, :subject => "Benvingut a Assets !")

  end
end
