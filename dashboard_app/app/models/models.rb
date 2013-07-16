class TestSiteFactory

end

class JenkinsFactory < TestSiteFactory
	def initialize(username, password)
		@username =  username
		@password = password
		@jobs = Hash.new
	end

	def addJob(url, testname)
		if @jobs[testname] == testname
			complete_url = url + "/api/json"
			IO.popen("python test.py create #{complete_url} #{@username} #{@password} #{testname}")
			json = File.read("dashboard+" + testname + ".txt")
			contents = JSON.parse(json)
			@job[testname] = JenkinsJob.new(contents, url, @username, @password, testname)
			IO.popen("python test.py destroy #{testname}")
		end
	end

	def getJob(testname)
		#try to get job is exists, create otherwise, and check to see if even exists in URL
		return @jobs[testname]
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
		json = File.read("dashboard_" + testname + "_") + num + ".txt")
		contents = JSON.parse(json)
		@builds[num] = contents
		#call python script to delete file
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
