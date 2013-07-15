class JenkinsFactoryController < ApplicationController

  def new
  	render :new
  	@JenkinsFactory = JenkinsFactory.new
  end

  def create
  	JenkinsFactory.factories[params["id"]] = JenkinsFactory.new(create_params)
  	@JenkinsFactory = JenkinsFactory.factories[params["id"]]
  	@JenkinsFactory.save
  end

  def getAddParams
  	render :add_job
  end

  def addJob
  	JenkinsFactory.addJob(addJob_params)
  	render :create
  end

  private

  	def create_params
  		params.require(:@JenkinsFactory).permit(:username, :password)
  	end

  	def getJob_params
  		params.require(:@JenkinsFactory).permit(:testname)
  	end

  	def addJob_params
  		params.require(:@JenkinsFactory).permit(:url, :name, :jobs, :id)
  	end

  	def getJob(testname)
  		@JenkinsFactory.getJob(getJob_params)
  	end

end
