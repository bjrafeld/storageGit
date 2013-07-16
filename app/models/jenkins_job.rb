class JenkinsJob < ActiveRecord::Base

	def initialize(params = {})
		super
		@url = params['url']
		puts "In init"
		@username = params['username']
		@factoryID = params['id']
		@password = params['password']
		@testname = params['testname']


		puts "python app/models/jenkins_web.py create #{url} #{username} #{password} #{testname}"
		IO.popen("python app/models/jenkins_web.py create #{url} #{username} #{password} #{testname}")
		puts "Ran Python Script"
		sleep(5)
		json = File.read("app/models/dashboard_" + testname + ".txt")
		data = JSON.parse(json)
		puts "Made it to params"
		IO.popen("python app/models/jenkins_web.py destroy #{testname}")
		puts "Destroyed!"
		sleep(2)

		write_attribute(:displayName, data['displayName'])
    	write_attribute(:description, data['description'])
    	write_attribute(:url, data['url'])
    	write_attribute(:LastBuildNum, data['builds'][0]['number'])
    	write_attribute(:LastBuildURL, data['builds'][0]['url'])
    	write_attribute(:status, data['color'])
    	write_attribute(:HealthReportTestStatus, data['healthReport'][0]['description'])
    	write_attribute(:HealthReportBuildStatus, data['healthReport'][1]['description'])
    	write_attribute(:lastSuccessfulBuildNum, data['lastSuccessfulBuild']['number'])

    	#Get the last Successful Build Data and put into Job
    	lastBuildURL = @url + "/lastCompletedBuild/testReport"
    	puts "python app/models/jenkins_web.py create #{lastBuildURL} #{username} #{password} #{testname}"
		IO.popen("python app/models/jenkins_web.py create #{lastBuildURL} #{username} #{password} #{testname}")
		puts "Ran Python Script"
		sleep(5)
		json = File.read("app/models/dashboard_" + testname + ".txt")
		data = JSON.parse(json)
		IO.popen("python app/models/jenkins_web.py destroy #{testname}")

		write_attribute(:failCount, data['failCount'].to_i)
    	write_attribute(:passCount, data['passCount'].to_i)
    	write_attribute(:skipCount, data['skipCount'].to_i)
    	i = 0
    	resultString = ""
    	while (data['suites'][i] != nil)
    		j = 0
    		while (data['suites'][i]['cases'][j] != nil)
    			resultString = resultString + "ClassName: " + data['suites'][i]['cases'][j]['className'] + "\nError Details: " + data['suites'][i]['cases'][j]['errorDetails'] + "\nStack Trace: " + data['suites'][i]['cases'][j]['errorStackTrace'] +"\nFailed Since Build: " + (data['suites'][i]['cases'][j]['failedSince'].to_s) +"\nName: " + data['suites'][i]['cases'][j]['name'] +"\nStatus: " + data['suites'][i]['cases'][j]['status']
    			j += 1
    		end
    		i += 1
    	end
    	write_attribute(:testResults, resultString)
	end

	def getBuild(params = {}) 
		num = params[:number]
		buildURL = url + "#{num}"
		newName = "#{testname}_#{num}"
		puts newName
		if(JenkinsBuild.where(url: buildURL).blank?)
			params = {"url"=>buildURL, "username"=>username, "password"=>password, "jobID"=>self.id, "testname"=>newName}
			JenkinsBuild.create(params)
		end
	ende

end