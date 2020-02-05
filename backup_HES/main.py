import tarfile
import datetime
import os
import ConfigParser
import logging
import shlex, subprocess



__author__ = "	Anatolii Huz"
__license__ = "GPL"
__version__ = "1.0"



def getSetting():


	global logfile
	logfile = 'backup.log'
	logging.basicConfig(format = u'%(levelname)-8s [%(asctime)s] %(message)s', level = logging.DEBUG, filename = logfile)



	path = 'backup.ini' 
	global config
	config = ConfigParser.ConfigParser()
	config.read(path)   
	backup_local_path = config.get('backup-settings', 'backup_local_path')
	
	global user_mysql
	user_mysql = config.get('backup-settings', 'user_mysql')
	global password_mysql
	password_mysql = config.get('backup-settings', 'password_mysql')

	dt = datetime.datetime.now()
	global backupFile
	backupNameFile = backup_local_path + dt.strftime('%Y_%m_%d-%H-%M')  + '.tar.gz'
	global tar
	tar = tarfile.open(backupNameFile, 'w:gz')

	global listSites
	listSites = []
	for site in config.sections():
		if site != 'backup-settings':
			listSites.append(site)

def backupFolder(folder):
	os.chdir(folder)
	tar.add(folder)

def backupFile(file):
	tar.add(file)

def backupdatabase(base_HES):
	fileSQL = '/tmp/' + base_HES + '.sql'
	if os.path.isfile(fileSQL):
		os.remove(fileSQL) 
	command_line = 'mysqldump -u ' + user_mysql + ' -p' + password_mysql +' ' +  base_HES +  ' > ' + fileSQL
	print(command_line)
	args = shlex.split(command_line)

	os.system(command_line)
	os.chdir('/tmp')
	backupFile(fileSQL)


if __name__ == '__main__':

	print('Start')
	getSetting()
	logging.info("================================") 
	logging.info("Start script")

	print(listSites)
	for site in listSites:
		dir_HES = config.get(site, 'dir_HES') 
		backupFolder(dir_HES)
		base_HES = config.get(site, 'base_HES') 
		backupdatabase(base_HES)
	tar.close()

	print('Finish')
	logging.info("================================") 
	logging.info("Finish script (ExitCode = 0)")

