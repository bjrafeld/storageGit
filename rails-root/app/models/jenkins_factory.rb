class JenkinsFactory < ActiveRecord::Base

	#Create Project with Jenkins credentials. Factory acts as standalone project (i.e. Morpho)
	def initialize (params = {})
		super
		@factoryName = params['factoryName']
		@username = params["username"]
		@password = params["password"]

	end

	#Add Jobs to this factory/project
	def addJob(params = {})
		url = params[:url]
		testname = params[:name]
		if (JenkinsJob.where(testname: params[:name]).blank?)
			params = {"url"=>url, "username"=>username, "password"=>password, "testname"=>testname, "factoryID"=>self.id}
			JenkinsJob.create(params)
			return
		else 
			puts "Already exists"
		end
	end

	#return the total number of tests passed for all jobs associated with this project
	def numTestsPassed
		i = 1
		testsPassed = 0
		while !(JenkinsJob.where(id: i).blank?) do
			if JenkinsJob.find(i).factoryID == self.id and JenkinsJob.find(i).attached
				testsPassed += JenkinsJob.find(i).passCount
			end
			i+=1
		end
		return testsPassed
	end

	#return the total number of tests failed for all jobs associated with this project
	def numTestsFailed
		i = 1
		testsFailed = 0
		while !(JenkinsJob.where(id: i).blank?) do
			if JenkinsJob.find(i).factoryID == self.id and JenkinsJob.find(i).attached
				testsFailed += JenkinsJob.find(i).failCount
			end
			i+=1
		end
		return testsFailed
	end

	#return the total number of tests skipped for all jobs associated with this project
	def numTestsSkipped
		i = 1
		testsSkipped = 0
		while !(JenkinsJob.where(id: i).blank?) do
			if JenkinsJob.find(i).factoryID == self.id and JenkinsJob.find(i).attached
				testsSkipped += JenkinsJob.find(i).skipCount
			end
			i+=1
		end
		return testsSkipped
	end

	#return the total percentage of tests passed for all jobs associated with this project
	def passedPercentage
		total = 1.0 * (self.numTestsSkipped + self.numTestsFailed + self.numTestsPassed)
		percentage = 100 * ((1.0 * self.numTestsPassed) / total)
		if(percentage.to_s == 'NaN')
			return "0.0"
		end
		return (percentage.to_s[0, 5])
	end
end