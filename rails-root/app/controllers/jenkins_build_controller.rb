class JenkinsBuildController < ApplicationController

	#Controller for getting build and getting build information
	def new
		@JenkinsBuild = JenkinsBuild.new
	end

	def create
		@JenkinsBuild = JenkinsBuild.new(create_params)
	end

	def buildInfo
		@JenkinsBuild = JenkinsBuild.find(params[:id])
		render :build_summary
	end

	private
		def create_params
			params.require(:@JenkinsBuild).permit(:url, :username, :password, :jobID, :testname)
		end
end
