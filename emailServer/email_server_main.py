# Email server script
# Written by Richard Greenbaum, 6/28/18

from apscheduler.schedulers.blocking import BlockingScheduler
import pika
import os, sys
import sendemail
import traceback
from datetime import datetime
import json
import ast

# Get configurations:
dire = os.path.dirname(os.path.abspath(__file__))
c_file = dire + #config file location
with open(c_file) as json_data_file:
    config_file = json.load(json_data_file)

hour_limit_8 = config_file['hour_limit_8']
hour_limit_16 = config_file['hour_limit_16']
hour_limit_24 = config_file['hour_limit_24']
total_email_limit = config_file['total_email_limit']
alert_threshold = config_file['alert_threshold']

email_archive = {}
current_date = {}
emails_sent_today = 0
limits = [hour_limit_8, hour_limit_16, hour_limit_24]

email_file = os.environ['WORKSPACE'] + #email file path
text = open(email_file,'r')
string = text.read()
email_json = json.loads(string)
overview_log_file_path = os.environ['WORKSPACE'] + #overview log file path
detail_log_file_path = os.environ['WORKSPACE'] + #detail log file path

def send_email(subject, message, ip_address, current_time):
	"""Sends the email specified by subject, message, and ip address if the daily and category limits have not yet been exceeded.

	Parameter subject: subject of the email to be sent (str)
	Parameter message: message of the email to be sent (str)
	Parameter ip_address: the ip address (str)
	"""
	global emails_sent_today
	global total_email_limit

	original_subject = subject
	current_category_limit = limits[int((int(current_time["hour"])-int(current_time["hour"])%8)/8)]
	if (emails_sent_today<total_email_limit) and (int(email_archive[ip_address][original_subject]['emails_sent'])<current_category_limit):
		message_header = ''
		subject_header = ''
		if int(email_archive[ip_address][original_subject]['emails_sent']) == current_category_limit - 1:
			message_header = 'The maximum number of emails for this IP and subject in the current 8-hour time block (' + str(current_category_limit) + ' emails) has been reached. \n\n'
			subject_header = ' (THRESHOLD REACHED)'
		if int(emails_sent_today) == total_email_limit - 1:
			subject_header = ' (MAX DAILY EMAILS REACHED)' + subject_header
			message_header = 'The maximum number of daily emails (' + str(total_email_limit) + ') has been reached. \n\n' + message_header
		subject = subject + subject_header
		post_message = 'time: ' + datetime.utcnow().strftime("%d-%m-%Y-%H-%M-%S") + ', IP address: ' + ip_address + '\n\n'
		if message.find('platform') != -1 and message.find('data source') != -1:
			post_message = message[message.find('platform'):] + ', ' + post_message
			message = message[:message.find('platform')]
		message = message_header + post_message + message 
		#print ('-------\n' + subject)
		#print (message + '\n-------')
		sendemail.sendemail(from_addr = email_json['email'], to_addr_list = email_json['send_emails'], cc_addr_list = [''], 
			subject = subject, message = message, login = email_json['email'], password = email_json['verification_code'] )
		email_archive[ip_address][original_subject]['emails_sent'] = str(int(email_archive[ip_address][original_subject]['emails_sent'])+1)
		emails_sent_today+=1
	if 	emails_sent_today<total_email_limit and int(email_archive[ip_address][original_subject]['errors_received'])%alert_threshold==0:
		subject = 'Email alert threshold reached'
		message = str(email_archive[ip_address][original_subject]['errors_received']) + ' alerts have been received for subject: ' + original_subject + ', IP address: ' + ip_address + ', time: ' + datetime.utcnow().strftime("%d-%m-%Y-%H-%M-%S") + '.'
		#print ('-------\n' + subject)
		#print (message + '\n-------')
		sendemail.sendemail(from_addr = email_json['email'], to_addr_list = email_json['send_emails'], cc_addr_list = [''], 
			subject = subject, message = message, login = email_json['email'], password = email_json['verification_code'] )
		emails_sent_today+=1


def receive(input_structure):
	"""Takes in the subject, message, and ip address of the email to be sent. Adds the current time and date as a json and 
	passes the email in [subject, message, current time, ip address] form to be archived. If this is the first email request of the
	day, the day variable is updated and the emails_sent_today variable is reset to 0.   

	Parameter subject: the subject of the email to be sent (str)
	Parameter message: the message of the email to be sent (str)
	Parameter ip_address: the ip address of the input instace (Which instance sent the alert) (str)
	"""
	global current_date
	global emails_sent_today
	global email_archive

	# Extract parameters from input json:
	subject = input_structure['subject']
	message = input_structure['message']
	ip_address = input_structure['ip_address']

	#extract global values from log file
	try:
		log_file = open(overview_log_file_path,"r")
		lines = log_file.readlines()
		log_file.close()
		email_archive_temp = ''
		date_temp = ''
		emails_sent_today_temp = ''
		num_blanks_reached = 0
		date = True
		for line in lines:
			if num_blanks_reached != 2:
				if line == '\n':
					num_blanks_reached += 1
				elif num_blanks_reached == 0:
					email_archive_temp += line
				elif num_blanks_reached == 1 and date:
					date = False
					date_temp = line
				elif num_blanks_reached == 1 and not date:
					emails_sent_today_temp = line
		email_archive = ast.literal_eval(email_archive_temp)
		current_date = ast.literal_eval(date_temp)
		emails_sent_today = ast.literal_eval(emails_sent_today_temp)
	except:
		#set day value to an impossible value so all globals will be reset 
		current_date = {'day':50}

	new_time = {}
	new_time["year"] = datetime.utcnow().strftime("%Y")
	new_time["month"] = datetime.utcnow().strftime("%m")
	new_time["day"] = datetime.utcnow().strftime("%d")
	new_time["hour"] = datetime.utcnow().strftime("%H")
	new_time["minute"] = datetime.utcnow().strftime("%M")
	new_time["second"] = datetime.utcnow().strftime("%S")
	
	if new_time["day"] != current_date["day"]:
		current_date = {"year": new_time["year"], "month":new_time["month"], "day":new_time["day"]}
		emails_sent_today = 0
		email_archive = {}
	email = [subject, message, new_time, str(ip_address)]
	archive(email)
	send_to_log_file(email)


def archive(email):
	"""Archives the email and passes it on to send_email. 

	Parameter email: the email to be archived
	"""
	global emails_sent_today
	global total_email_limit
	global email_archive


	current_time = email[2]
	if not email[3] in email_archive:
		email_archive[email[3]] = {}
	if not email[0] in email_archive[email[3]]:
		email_archive[email[3]][email[0]] = {"errors_received":"1", "emails_sent":"0"}
		send_email(email[0], email[1], email[3], current_time)
	else:
		email_archive[email[3]][email[0]]["errors_received"] = str(int(email_archive[email[3]][email[0]]["errors_received"])+1)
		send_email(email[0], email[1], email[3], current_time)


def send_to_log_file(email):
	"""Updates the current_date entry of the log file.
	"""
	global overview_log_file_path
	global detail_log_file_path
	global email_archive
	global emails_sent_today
	global current_date

	#overview_log_file
	stop_writing = False
	try:
		log_file = open(overview_log_file_path,"r")
		lines = log_file.readlines()
		log_file.close()
		log_file = open(overview_log_file_path, "w")
		log_file.write(str(email_archive) + '\n\n' + str(current_date) + '\n' + str(emails_sent_today) + '\n\n')
		num_blanks_reached = 0
		for line in lines:
			if num_blanks_reached > 2:
				if line == str(current_date["year"]) + '-' + str(current_date["month"]) + '-' + str(current_date["day"]) + '\n':
					stop_writing = True
				if not stop_writing:
					log_file.write(line)
			if line == '\n':
				num_blanks_reached += 1
		log_file.close
		log_file = open(overview_log_file_path, 'a')
	except:
		log_file = open(overview_log_file_path, 'w')
		log_file.write(str(email_archive) + '\n\n' + str(current_date) + '\n' + str(emails_sent_today) + '\n\n')
	log_file.write(str(current_date["year"]) + '-' + str(current_date["month"]) + '-' + str(current_date["day"]) + '\n')
	for ip in email_archive.keys():
		log_file.write('\t' + ip + '\n')
		for subject in email_archive[ip]:
			log_file.write('\t\t' + subject + ': ' + str(email_archive[ip][subject]) + '\n')
	log_file.write('\n')
	log_file.close()

	#detail_log_file
	try:
		log_file = open(detail_log_file_path,'a')
	except:
		log_file = open(detail_log_file_path,'w')
	log_file.write('<' + datetime.utcnow().strftime("%d-%m-%Y-%H-%M-%S") + '> Subject: ' + email[0] + ', Message: ' + email[1] + ', IP: ' + email[3] + '.\n\n')

	
#Used for testing
if __name__ == '__main__':
	pass

	


