class JenkinsFactory < ActiveRecord::Base

	def initialize (params = {})
		super
		@username = params["username"]
		@password = params["password"]
		@jobs = Array.new
	end

	def addJob(params = {})
		url = params[:url]
		testname = params[:name]
		if (JenkinsJob.where(testname: params[:name]).blank?)
			params = {"url"=>url, "username"=>username, "password"=>password, "testname"=>testname, "factoryID"=>self.id}
			puts params
			@jobs.push((JenkinsJob.create(params)).id)
			return
		else 
			puts "Already exists"
		end
	end

	def jobs
		@jobs
	end

	def getJob(testname)
		#try to get job is exists, create otherwise, and check to see if even exists in URL
		if @jobs[testname] == nil
			puts "This Job has not been configured"
		else
			return @jobs[testname]
		end
	end
end