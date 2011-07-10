class Notifications < ActionMailer::Base
  add_template_helper(ApplicationHelper)
  default :from => "thehoptopus@hoptopus.com"
  layout 'mailer'

  def cellar_comment(cellar, comment)
    @cellar = cellar
    @commenter = comment.user
    @comment = comment
    @return_url = "http://hoptopus.com" + (cellar_path @cellar.user.username)

    mail(:subject => 'New comment on your cellar!', :to => cellar.user.email) do |format|
      format.html
    end
  end

  def watched(watching, watched)
    @watching = watching
    @watched = watched

    mail(:subject => "#{watching.username} has started watching your cellar!", :to => watched.email) do |format|
      format.html
    end
  end

  def user_registered(user)
    @registered_user = user

    # Default title value.
    title = user.username ? "New user registration: #{user.username}" : "New Facebook registration"

    mail(:subject => title, :to => 'alerts@hoptopus.com') do |format|
      format.html
    end
  end

  def contact_request(request_model)
    @request_model = request_model

    mail(:subject => "[Contact Request] " + request_model.subject, :to => 'contact@hoptopus.com', :reply_to => request_model.email) do |format|
      format.html
    end
  end
  
  def newsletter_signup(email)
    @email = email
    
    mail(:subject => "[Newsletter Signup] " + email, :to => 'alerts@hoptopus.com', :reply_to => email) do |format|
      format.html
    end
  end

  def send_confirmation_request(confirmation_request)
    @confirmation_request = confirmation_request
    
    mail(:subject => "Confirm your Hoptopus account!", :to => confirmation_request.user.email) do |format|
      format.html
    end
  end
end
