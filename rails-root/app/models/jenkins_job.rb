class JenkinsJob < ActiveRecord::Base
	
	def initialize(params = {})
		super
		@url = params['url']
		puts "In init"
		@username = params['username']
		@factoryID = params['id']
		@password = params['password']
		@testname = params['testname']

		#Grab all data from Jenkins
		update()
	end

	#Get Build number is does not already exist
	def getBuild(params = {}) 
		num = params[:number]
		buildURL = url + "#{num}"
		newName = "#{testname}_#{num}"
		if(JenkinsBuild.where(url: buildURL).blank?)
			params = {"url"=>buildURL, "username"=>username, "password"=>password, "jobID"=>self.id, "testname"=>newName, 'number' => num}
			return JenkinsBuild.create(params)
		else
			puts "Already Exists"
			return JenkinsBuild.find_by(url: buildURL)
		end
	end

	#Grab all data from Jenkins using script
	def update
		#grab all data at once
		IO.popen("python app/models/jenkins_web.py create #{url} #{username} #{password} #{testname}")
		puts "Ran Python Script"
		lastBuildURL = url + "/lastCompletedBuild/testReport"
    	testname_build = testname + "_build"
		IO.popen("python app/models/jenkins_web.py create #{lastBuildURL} #{username} #{password} #{testname_build}")
		sleep(3)
		puts "Past sleep"

		#parse all data and destroy files
		wait_for_file("app/models/dashboard_" + testname + ".txt")
		json_build = File.read("app/models/dashboard_" + testname + ".txt")
		data_main = JSON.parse(json_build)
		IO.popen("python app/models/jenkins_web.py destroy #{testname}")

		update_attribute(:displayName, data_main['displayName'])
    	update_attribute(:description, data_main['description'])
    	update_attribute(:url, data_main['url'])
    	update_attribute(:LastBuildNum, data_main['builds'][0]['number'])
    	if (data_main['builds'][1]['number'] != nil)
    		update_attribute(:buildNum1, data_main['builds'][1]['number'])
    	end
    	if (data_main['builds'][2]['number'] != nil)
    		update_attribute(:buildNum2, data_main['builds'][2]['number'])
    	end
    	update_attribute(:LastBuildURL, data_main['builds'][0]['url'])
    	update_attribute(:status, getStatus(data_main['color']))
    	update_attribute(:HealthReportTestStatus, data_main['healthReport'][0]['description'])
    	if (data_main['healthReport'][1] != nil)
    		update_attribute(:HealthReportBuildStatus, data_main['healthReport'][1]['description'])
    	end
    	update_attribute(:lastSuccessfulBuildNum, data_main['lastSuccessfulBuild']['number'])
    	update_attribute(:attached, true)

    	#Get the last Successful Build Data and put into Job
    	wait_for_file("app/models/dashboard_" + testname_build + ".txt")
		json = File.read("app/models/dashboard_" + testname_build + ".txt")
		data_build = JSON.parse(json)
		IO.popen("python app/models/jenkins_web.py destroy #{testname_build}")

		update_attribute(:failCount, data_build['failCount'].to_i)
    	update_attribute(:passCount, data_build['passCount'].to_i)
    	update_attribute(:skipCount, data_build['skipCount'].to_i)
    	i = 0
    	resultString = ""
    	if(data_build['suites'] != nil)
    	  while (data_build['suites'][i] != nil)
    		j = 0
    		while (data_build['suites'][i]['cases'][j] != nil)
    			className = errorDetails = stackTrace = lastFailedBuild = name = status = ""
    			boldFlag = false;
    			italicsFlag = false;
    			if data_build['suites'][i]['cases'][j]['className'] != ""
    				className = (data_build['suites'][i]['cases'][j]['className'].to_s)
    			end
    			if data_build['suites'][i]['cases'][j]['errorDetails'] != nil
    				errorDetails = "<br>&emsp;Error Details: " + (data_build['suites'][i]['cases'][j]['errorDetails'].to_s)
    			end
    			if data_build['suites'][i]['cases'][j]['errorStackTrace'] != nil
    				stackTrace = "<br>&emsp;Stack Trace: " + (data_build['suites'][i]['cases'][j]['errorStackTrace'].to_s)
    			end
    			if data_build['suites'][i]['cases'][j]['failedSince'] != nil
    				lastFailedBuild = "<br>&emsp;Failed Since Build: " + (data_build['suites'][i]['cases'][j]['failedSince'].to_s)
    			end
    			if data_build['suites'][i]['cases'][j]['name'] != nil
    				name = "<br>&emsp;Name: " + (data_build['suites'][i]['cases'][j]['name'].to_s)
    			end
    			if data_build['suites'][i]['cases'][j]['status']
    				status = "<br>&emsp;Status: " + (data_build['suites'][i]['cases'][j]['status'].to_s)
    				if (data_build['suites'][i]['cases'][j]['status'] == "FAILED" or data_build['suites'][i]['cases'][j]['status']=="REGRESSION" )
    					boldFlag = true;
    					italicsFlag = true;
    				elsif (data_build['suites'][i]['cases'][j]['status'] == "FIXED")
    					boldFlag = true;
    				end
    			end
    			if boldFlag
    				resultString = resultString + "<b>"
    			elsif italicsFlag
    				resultString = resultString + "<i>"
    			end
    			resultString = resultString + "<br>" + className + errorDetails + stackTrace + lastFailedBuild + name + status
    			if boldFlag
    				resultString = resultString + "</b>"
    			elsif italicsFlag
    				resultString = resultString + "</i>"
    			end
    			j += 1
    		end
    		i += 1
    	  end
    	end
    	update_attribute(:testResults, resultString)

    	lastBuild = self.getBuild({number: self.LastBuildNum})
    	getBuild(number: self.buildNum1)
    	getBuild(number: self.buildNum2)
		update_attribute(:builtOn, lastBuild.builtOn)
		machine = getMachine(self.builtOn, testname, username, password)
		update_attribute(:OS, machine.OS)
		update_attribute(:lastUpdate, Time.now.to_s)
	end

	#Return the color for background in table depending on status
	def getColor
		if self.status == 'Success'
			return "LimeGreen"
		elsif self.status == 'Disabled'
			return "DarkGray" 
		elsif self.status == 'Unstable'
			return "Yellow"
		elsif self.status == 'Failed'
			return "Red"
		elsif self.status == "Building"
			return "Blue"
		else
			return "White"
		end
	end

	#Get status based on color returned form Jenkins JSON
	def getStatus(color)
		if color == 'blue'
			return "Success"
		elsif color == 'disabled'
			return "Disabled" 
		elsif color == 'yellow'
			return "Unstable"
		elsif color == 'red'
			return "Failed"
		elsif color == 'blue_anime'
			return "Building"
		else
			return color
		end
	end

	#Return the tests passed percentage for all tests in this Jenkins Job
	def passedPercentage
		total = 1.0 * (self.failCount + self.passCount + self.skipCount)
		percentage = 100 * ((1.0 * self.passCount) / total)
		if(percentage.to_s == 'NaN')
			return "0.0"
		end
		return (percentage.to_s[0, 5])
	end

	#Make sure that file exists before it is read
	def wait_for_file(filename)
		while !(File.exists?(filename))
			sleep(1)
			puts "Waiting for file..."
		end
	end

	#Check database to see if machine that job is built on exists already
	def getMachine(name, testname, username, password)
		if JenkinsMachine.find_by(name: name).blank?
			return JenkinsMachine.create({name: name, username: username, password: password, testname: testname})
		else
			return JenkinsMachine.find_by(name: name)
		end
	end

	#sets attached to true or false. This tells controller whether or not to apply this job to pass bar on main page
	def setAttached(boolean)
		update_attribute(:attached, boolean)
	end

	def getPreviousBuildNum
		return buildNum1
	end

	def getPreviousBuildResult
		if !(JenkinsBuild.where(jobID: self.id, number: buildNum1).blank?)
			JenkinsBuild.find_by(jobID: self.id, number: buildNum1).result
		else
			return "Does not Exist"
		end
	end

	def getThirdBuildNum
		return buildNum2
	end

	def getThirdBuildResult
		if !(JenkinsBuild.where(jobID: self.id, number: buildNum2).blank?)
			JenkinsBuild.find_by(jobID: self.id, number: buildNum2).result
		else
			return "Does not Exist"
		end
	end
end