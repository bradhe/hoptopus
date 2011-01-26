class Notifications < ActionMailer::Base
  default :from => "thehoptopus@hoptopus.com"
  
  def cellar_comment(cellar, comment)
    @cellar = cellar
    @commenter = user.comment
    @comment = comment
    
    mail(:subject => 'New comment on your cellar!', :to => cellar.user.email) do |format|
      format.html
    end
  end
end
