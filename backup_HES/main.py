import tarfile
import datetime
import os
import logging
import shlex, subprocess
import sys
import glob
import paramiko 


if sys.version_info.major <  3:
        import ConfigParser
else:
        import configparser

__author__ = "Anatolii Huz"
__license__ = "GPL"
__version__ = "1.1"

def getSetting():

	setting_path = os.path.dirname(os.path.abspath(__file__))
	#print (setting_path)

	global logfile
	logfile = setting_path + '/backup.log'
	logging.basicConfig(format = u'%(levelname)-8s [%(asctime)s] %(message)s', level = logging.DEBUG, filename = logfile)

	path = setting_path + '/backup.ini' 
	global config
	if sys.version_info.major <  3:
        	config = ConfigParser.ConfigParser()
	else:
        	config = configparser.ConfigParser()
	
	config.read(path)   
	global backup_local_path
	backup_local_path = config.get('backup-settings', 'backup_local_path')
	#print('backup_local_path = ' +  backup_local_path )	
	global user_mysql
	user_mysql = config.get('backup-settings', 'user_mysql')
	global password_mysql
	password_mysql = config.get('backup-settings', 'password_mysql')
	global count_backup_files
	count_backup_files = int(config.get('backup-settings', 'count_backup_files'))
	#print('count_backup_files = ' + str(count_backup_files))

	global backup_remote_path
	backup_remote_path = config.get('backup-settings', 'backup_remote_path')
 
	global remotehost
	remotehost = config.get('backup-settings', 'remotehost')
        global remoteuser 	
	remoteuser = config.get('backup-settings', 'remoteuser') 
        global remotepassword	
	remotepassword = config.get('backup-settings', 'remotepassword')
        global remoteport	
	remoteport = int(config.get('backup-settings', 'remoteport'))

	# global tar
	# tar = tarfile.open(backupNameFile, arcname=''  'w:gz')
	# tar = tarfile.open(backupNameFile, 'w:gz')

	global listSites
	listSites = []
	for site in config.sections():
		if site != 'backup-settings':
			listSites.append(site)

def backupSite(folder, fileSQL, backupNameFile):
	# for i in os.walk(folder):
	# 	print(i)
	os.chdir(folder)
	command_line = 'tar cfz ' + backupNameFile + ' --exclude ' + folder+'/logs ' + folder + ' ' + fileSQL
	#command_line = 'tar cfz ' + backupNameFile + ' --exclude ' + folder+'/Logs *'
	# print(command_line)
	os.system(command_line)

def backupFile(tar,file):
	tar.add(file)
	#command_line = 'tar rfz ' + backupNameFile + ' ' + file
	#os.system(command_line)

def backupdatabase(base_HES):
	os.chdir('/tmp/')
	fileSQL = base_HES + '.sql'
	if os.path.isfile(fileSQL):
		os.remove(fileSQL) 
	command_line = 'mysqldump -u ' + user_mysql + ' -p' + password_mysql +' ' +  base_HES +  ' > ' + fileSQL
	#print(command_line)
	args = shlex.split(command_line)
	os.system(command_line)
	return fileSQL
	#os.chdir('/tmp')
	
	#backupFile(fileSQL, backupNameFile)


def removeLocalOldFiles(site):
	os.chdir(backup_local_path)
	template_for_delete = site + '-*.tar.gz'
	files = glob.glob(template_for_delete)
	files.sort(key=os.path.getmtime, reverse = True)
	count = 1
	for file in files:
		#print('count = ' + str(count))
        	if (count > count_backup_files):
			os.remove(file)
                	print('deleted old file ' + file)
 		count = count + 1

def connect2Remote():
	ssh = paramiko.SSHClient()
	ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
	ssh.connect(hostname=remotehost, username=remoteuser, password=remotepassword, port=remoteport)
	return ssh

def copy2RemoteHost(ssh, localbackupNameFile, remotebackupNameFile):
	ftp=ssh.open_sftp()
	ftp.put(localbackupNameFile, remotebackupNameFile)


def removeRemoteOldFiles(ssh, site):
        os.chdir(backup_local_path)
        template_for_delete = backup_remote_path + site + '-*.tar.gz'
       	command_line = 'ls -1 -r ' + template_for_delete + ' | tail -n +' + str(count_backup_files+1) + ' | xargs rm -rf'
	#print(command_line)
	stdin, stdout, stderr = ssh.exec_command(command_line)
	

if __name__ == '__main__':

	print('Start')
	getSetting()
	logging.info("================================") 
	logging.info("Start script")

	print(listSites)
	ssh = connect2Remote()

	for site in listSites:
		dir_HES = config.get(site, 'dir_HES') 
		dt = datetime.datetime.now()
		print('site = ' + site)
		template_for_delete = backup_local_path + site + '-*.tar.gz'
		local_backupNameFile =  backup_local_path  + site + '-'+ dt.strftime('%Y_%m_%d-%H%M')  + '.tar.gz'
		remote_backupNameFile = backup_remote_path + site + '-'+ dt.strftime('%Y_%m_%d-%H%M')  + '.tar.gz'
		tar = tarfile.open(local_backupNameFile, 'w:gz')
		#backupFolder(dir_HES, backupNameFile)
		base_HES = config.get(site, 'base_HES') 
		fileSQL = backupdatabase(base_HES)
                os.chdir('/tmp')
		backupFile(tar, fileSQL)
		file_appsettings = dir_HES + '/appsettings.json'
		os.chdir(dir_HES) 
		#backupFile(tar, file_appsettings) 
		backupFile(tar, file_appsettings)
		#backupSite(dir_HES, fileSQL, backupNameFile)
		tar.close()
		removeLocalOldFiles(site)
		copy2RemoteHost(ssh, local_backupNameFile, remote_backupNameFile)
		removeRemoteOldFiles(ssh, site)

	# tar.close()
	ssh.close()

	print('Finish')
	logging.info("================================") 
	logging.info("Finish script (ExitCode = 0)")

