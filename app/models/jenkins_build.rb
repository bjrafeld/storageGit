class JenkinsBuild < ActiveRecord::Base
	
	def initialize(params = {})
		super
		@url = params['url']
		@username = params['username']
		@password = params['password']
		@jobID = params['jobID']
		@testname = params['testname']

		puts "python app/models/jenkins_web.py create #{url} #{username} #{password} #{testname}"
		IO.popen("python app/models/jenkins_web.py create #{url} #{username} #{password} #{testname}")
		puts "Ran Python Script"
		sleep(5)
		puts "About to read file in Rails"
		json = File.read("app/models/dashboard_" + testname + ".txt")
		puts "Read file correctly"
		data = JSON.parse(json)
		puts "Parsed JSON correctly"
		IO.popen("python app/models/jenkins_web.py destroy #{testname}")
		puts "Right before sleep"
		sleep(2)
		puts "Got past clean up"

		write_attribute(:causeDescription, data['actions'][0]['causes'][0]['shortDescription'])
    	i = 0
    	fileNames = ""
    	while data['artifacts'][i] != nil do
    		fileNames += data['artifacts'][i]['fileName'] + ", "
    		i += 1
    	end
    	write_attribute(:artifacts, fileNames)
    	write_attribute(:result, data['result'])
    	write_attribute(:fullDisplayName, data['fullDisplayName'])
    	write_attribute(:description, data['description'])
    	write_attribute(:builtOn, data['builtOn'])
	end
end




