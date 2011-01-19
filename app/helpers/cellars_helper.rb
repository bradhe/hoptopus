module CellarsHelper
	def is_users_cellar?
		return @cellar.user == @user
	end
	
	def cellar_url
		return "http://" + full_host + "/cellars/" + @cellar.user.username
	end
end
