class JenkinsFactoryController < ApplicationController

  #Controller for Main Page, adding jobs, updating jobs, and ccreating new Projects
  def new
  	render :new
  	@JenkinsFactory = JenkinsFactory.new
  end

  def create
  	@JenkinsFactory = JenkinsFactory.new(create_params)
  	@JenkinsFactory.save
  end

  def deleteJob
    @job = JenkinsJob.find(params[:id])
    @job.attached = false
  end

  def updateJob
    @JenkinsFactory = JenkinsFactory.find(params[:id])
    @job = JenkinsJob.find(params[:jobID])
    @job.update
    render :info
  end

  def home
    render :create
  end

  def getAddParams
  	render :add_job
  end

  def addJob
    @JenkinsFactory = JenkinsFactory.find(params[:id])
  	@JenkinsFactory.addJob(addJob_params)
  	render :info
  end

  def getInfo
    @JenkinsFactory = JenkinsFactory.find(params[:id])
    render :info
  end

  def update
    @JenkinsFactory = JenkinsFactory.find(params[:id])
    i = 1
    while !(JenkinsJob.where(id: i).blank?) do 
      if JenkinsJob.find(i).factoryID == @JenkinsFactory.id
        if params[:"#{JenkinsJob.find(i).testname}"] != nil
          JenkinsJob.find(i).setAttached(true)
        else
          JenkinsJob.find(i).setAttached(false)
        end
        i += 1
      end
    end
    render :info
  end

  private
  	def create_params
  		params.require(:@JenkinsFactory).permit(:factoryName, :username, :password)
  	end

  	def getJob_params
  		params.require(:@JenkinsFactory).permit(:testname)
  	end

  	def addJob_params
  		params.require(:@JenkinsFactory).permit(:url, :name)
  	end
end
