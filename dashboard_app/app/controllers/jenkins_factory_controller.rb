class JenkinsFactoryController < ApplicationController

  def new
  	render :new
  	@JenkinsFactory = JenkinsFactory.new
  end

  def create
  	@JenkinsFactory = JenkinsFactory.new(create_params)
  	@JenkinsFactory.save
  end

  def getAddParams
  	render :add_job
  end

  def addJob
  	@JenkinsFactory.addJob(addJob_params)
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
  		params.require(:@JenkinsFactory).permit(:url, :name)
  	end


end
