class WelcomeController < ApplicationController
  def index
  end
end

private 
	def app_params 
		params.require(:JenkinsFactory).permit(:username, :password)
	end
