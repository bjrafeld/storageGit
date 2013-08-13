class JenkinsJobController < ApplicationController

  #Controller for creating new jobs, getting and creating new builds, and getting job information  
  def new
  	render :new
  	@JenkinsJob = JenkinsJob.new
  end

  def create
  	@JenkinsJob = JenkinsJob.new(create_params)
  	@JenkinsJob.save
  end

  def getAddParams
  	render :add_job
  end

  def getBuildParams
    @JenkinsJob = JenkinsJob.find(params[:id])
    render :get_build
  end

  def getBuild
    @JenkinsJob = JenkinsJob.find(params[:id])
    @JenkinsJob.getBuild(buildParams)
    render :job_summary
  end

  def jobInfo
    @JenkinsJob = JenkinsJob.find(params[:id])
    render :job_summary
  end

  private

  	def create_params
  		params.require(:@JenkinsJob).permit(:url, :testname, :username, :password)
  	end

  	def getJob_params
  		params.require(:@JenkinsJob).permit(:testname)
  	end

    def buildParams
      params.require(:@JenkinsFactory).permit(:number)
    end
end
