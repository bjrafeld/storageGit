class JenkinsBuildController < ApplicationController

	def new
		@JenkinsBuild = JenkinsBuild.new
	end

	def create
		@JenkinsBuild = JenkinsBuild.new(create_params)
	end

	private

		def create_params
			params.require(:@JenkinsBuild).permit(:url, :username, :password, :jobID, :testname)
		end

end
