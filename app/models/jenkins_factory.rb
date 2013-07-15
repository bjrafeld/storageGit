class JenkinsFactory < ActiveRecord::Base

	@@factories = Hash.new

	def initialize (params = {})
		super
		@username = params["username"]
		@password = params["password"]
		@jobs = Hash.new
		@@factories[params['id']] = self
	end

	def self.addJob(params = {})
		puts params['id']
		factory = @@factories[params['id']]
		url = params['url']
		testname = params['name']
		factory.addJob_inst(url, testname)
	end

	def addJob_inst(url, testname)
		if jobs[testname] == nil
			puts "Running python..."
			puts "python app/models/jenkins_web.py create #{url} #{username} #{password} #{testname}"
			IO.popen("python app/models/jenkins_web.py create #{url} #{username} #{password} #{testname}")
			puts "Ran Python Script"
			sleep(5)
			json = File.read("./app/models/dashboard_" + testname + ".txt")
			contents = JSON.parse(json)
			@jobs[testname] = JenkinsJob.new(contents, url, @username, @password, testname)
			#IO.popen("python app/models/jenkins_web.py destroy #{testname}")
		end
	end

	def jobs
		@jobs
	end

	def self.factories
		@@factories
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

class JenkinsJob
	def initialize(json_data, url, username, password, testname)
		@data = json_data
		@url = url
		@username = username
		@password = password
		@testname = testname
		@builds = Hash.new
	end

	def initBuild(num)
		complete_url = @url + "#{num}/api/json"
		IO.popen("python test.py create #{complete_url} #{@username} #{@password} #{@testname}")
		json = File.read(("dashboard_" + testname + "_") + num + ".txt")
		contents = JSON.parse(json)
		@builds[num] = contents
		#call python script to delete file
	end

	def data
		@data
	end

	def getBuild(num) 
		#try to get the build from JSON, if doesn't exist throw error, and create it if it doesn exist in JSON but not in code yet
		return @builds[num]
	end

	def getDisplayName()
		return @data['displayName']
	end

	def getActions()
		return @data['actions']
	end

	def getDescription()
		return @data['description']
	end

	def getURL()
		return @data['url']
	end

	def getBuilds()
		#return Build objects

	end

	def getStatus()
		return @data['color']
	end

	def getHealthReport()
		return @data['healthReport']
	end
end

class JenkinsBuild

	def initialize(json_data, url, username, password)
		@data = json_data
		@url = url
		@username = username
		@password = password
	end

	def data
		@data
	end

	def getActions()
		return @data['actions']
	end

	def getDescription()
		return @data['description']
	end

	def getBuildNumber()
		return @data['number']
	end

	def getName()
		return @data['fullDisplayName']
	end

end

