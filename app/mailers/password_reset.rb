class PasswordReset < ActionMailer::Base
  default :from => "thehoptopus@hoptopus.com"
  
  def reset_mail(user, security_token, full_host)    
    @security_token = security_token
    @host = full_host
    @receiving_user = user
    
    mail(:subject => 'Password Reset Request', :to => user.email) do |format|
      format.html
    end
  end
end
