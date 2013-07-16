class JenkinsJobController < ApplicationController
  
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

  def addJob
  	@JenkinsJob.addJob(addJob_params)
  	render :create
  end

  def getBuild
    @JenkinsJob.getBuild(getBuildParams)
  end

  private

  	def create_params
  		params.require(:@JenkinsJob).permit(:url, :testname, :username, :password)
  	end

  	def getJob_params
  		params.require(:@JenkinsJob).permit(:testname)
  	end

  	def addJob_params
  		params.require(:@JenkinsJob).permit(:url, :name)
  	end

    def getBuildParams
      params.require(:@JenkinsJob).permit(:number)
    end
end
