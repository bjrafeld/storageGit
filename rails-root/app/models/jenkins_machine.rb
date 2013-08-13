class JenkinsMachine < ActiveRecord::Base

	#Machine that Jenkins Job is being built on (Specifies Operating System)
	def initialize (params = {})
		super
		@name = params['name']
		@testname = params['testname']
		@username = params['username']
		@password = params['password']

		builtOnURL = "https://jenkins-1.sfo13.amazon.com/jenkins/computer/#{self.name}/"
		puts builtOnURL
		testname_builtOn = self.testname + "_builtOn"
		IO.popen("python app/models/jenkins_web.py create #{builtOnURL} #{username} #{password} #{testname_builtOn}")

		wait_for_file("app/models/dashboard_" + testname_builtOn + ".txt")
		json_builtOn = File.read("app/models/dashboard_" + testname_builtOn + ".txt")
		data = JSON.parse(json_builtOn)
		IO.popen("python app/models/jenkins_web.py destroy #{testname_builtOn}")
		write_attribute(:OS, data['monitorData']['hudson.node_monitors.ArchitectureMonitor'])
	end

	def wait_for_file(filename)
		while !(File.exists?(filename))
			sleep(1)
		end
	end
end
