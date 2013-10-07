import sys, os, pgq, skytools, subprocess, time, shlex

class QsubConsumer(pgq.Consumer):
	def __init__(self, args):
		pgq.Consumer.__init__(self, "qsub-consumer", "src_db", args)

	def process_event(self, src_db, ev):
		# logutriga event fields:
		#	ev_type: I/U/D ':' pkey_column_list
		#	ev_data: column values urlencoded, to decode
		#		d = skytools.db_urldecode(ev.ev_data)
		#	ev_extra1: table name

		# extract connection parameters from src_db, src_db is configured in the consumer .conf file
        	connection_parameters = dict(token.split('=') for token in shlex.split(src_db.dsn))

		# pass connection parameters to submitted script
		p = "qsub -v"
		p += " db_host=%s" % (connection_parameters['host'])
		p += ",db_port=%s" % (connection_parameters['port'])
		p += ",db_name=%s" % (connection_parameters['dbname'])

		# the table that triggered the event decides which script to submit
		# all SGE params are in the script
		if ( ev.ev_extra1 == 'core.blast_run'):
			self.log.info ("Consuming event triggered by INSERT on 'blast_run' table")
			p = "qsub ~/pgq/blastc.sh '%s'" % (ev.ev_data) 
		elif (ev.ev_extra1 == 'mg_traits.mg_traits_jobs'):
			self.log.info ("Consuming event triggered by INSERT on 'mg_traits_jobs' table")
			p = "qsub ~/pgq/traits_calc.sh '%s'" % (ev.ev_data) # all SGE params are in the script
		else:
			self.log.info ("table '%s' is not supported by qsub consumer. Event will be ignored.\n" % (ev.ev_extra1))
			p = "echo"

		# submit script
		output = subprocess.Popen(p, shell=True, executable="/bin/bash", stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()
		self.log.info ("Executing...\n%s\nSTDOUT: %s\nSTDERR: %s\n" % (p,output[0],output[1]))
		ev.tag_done()


if __name__== '__main__':
	script=QsubConsumer(sys.argv[1:])
	script.start()
