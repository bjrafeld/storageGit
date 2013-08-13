class JenkinsBuild < ActiveRecord::Base

	#Get necessary information from Jenkins and put into database	
	def initialize(params = {})
		super
		@number = params['number']
		@url = params['url']
		@username = params['username']
		@password = params['password']
		@jobID = params['jobID']
		@testname = params['testname']

		puts "python app/models/jenkins_web.py create #{url} #{username} #{password} #{testname}"
		IO.popen("python app/models/jenkins_web.py create #{url} #{username} #{password} #{testname}")
		sleep(5)
		puts "Ran Python Script"
		while !File.exists?("app/models/dashboard_" + testname + ".txt")
			sleep(5)
		end
		puts "About to read file in Rails"
		json = File.read("app/models/dashboard_" + testname + ".txt")
		puts "Read file correctly"
		data = JSON.parse(json)
		puts "Parsed JSON correctly"
		IO.popen("python app/models/jenkins_web.py destroy #{testname}")
		puts "Right before sleep"
		sleep(2)
		puts "Got past clean up"

    	i = 0
    	fileNames = ""
    	if data['artifacts'] != nil
    	 while data['artifacts'][i] != nil do
    		fileNames += data['artifacts'][i]['fileName'] + ", "
    		i += 1
    	 end
    	end
    	write_attribute(:artifacts, fileNames)
    	write_attribute(:result, data['result'])
    	write_attribute(:fullDisplayName, data['fullDisplayName'])
    	write_attribute(:description, data['description'])
    	write_attribute(:builtOn, data['builtOn'])
	end
end




