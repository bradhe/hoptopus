class Notifications < ActionMailer::Base
  add_template_helper(ApplicationHelper)
  default :from => "thehoptopus@hoptopus.com"
  
  def cellar_comment(cellar, comment)
    @cellar = cellar
    @commenter = comment.user
    @comment = comment
    @return_url = "http://hoptopus.com" + (cellar_path @cellar.user.username)

    mail(:subject => 'New comment on your cellar!', :to => cellar.user.email) do |format|
      format.html
    end
  end
  
  def user_registered(user)
    @registered_user = user
    
    mail(:subject => "New user registration: #{user.username}", :to => 'brad.heller@gmail.com') do |format|
      format.html
    end
  end
end
