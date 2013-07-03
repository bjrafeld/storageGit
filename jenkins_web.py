import urllib2, base64, json, os, sys

def create_JSON_file(url, username, password, testname):

	#URL construction
	complete_url = url + "/api/json"
	print "Complete URL: " + complete_url

	try:
		request = urllib2.Request(complete_url)
		base64string = base64.encodestring('%s:%s' % (username, password)).replace('\n', '')
		request.add_header('Authorization', b'Basic ' + base64.b64encode(username + b':' + password)) 
		result = urllib2.urlopen(request)

	except urllib2.HTTPError as e:
		print e.headers
		print e.headers.has_key('WWW-Authenticate')

	testfile_name = "dashboard_" + testname + ".txt"
	json_file = open(testfile_name, 'w')
	json_file.write(result.read())
	json_file.close()
	print "File written: " + testfile_name

def cleanup_JSON_file(testname):
	filename = "dashboard_" + testname + ".txt"
	if os.path.isfile(filename):
		os.remove(filename)
	else:
		print("Error: %s file not found" % filename)

if sys.argv[1] == "create":
	create_JSON_file(sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5])
elif sys.argv[1] == "destroy":
	cleanup_JSON_file(sys.argv[2])
