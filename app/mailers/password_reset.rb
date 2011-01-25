class PasswordReset < ActionMailer::Base
  default :from => "thehoptopus@hoptopus.com"
  
  def reset_mail(email, security_token, full_host)    
    @security_token = security_token
    @host = full_host
    
    mail(:subject => 'Password Reset Request', :to => email) do |format|
      format.html
    end
  end
end
