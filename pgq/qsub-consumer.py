import sys, os, pgq, skytools, subprocess, time

class QsubConsumer(pgq.Consumer):
	def __init__(self, args):
		pgq.Consumer.__init__(self, "qsub-consumer", "src_db", args)

	def process_event(self, src_db, ev):
		# logutriga event fields:
		#	ev_type: I/U/D ':' pkey_column_list
		#	ev_data: column values urlencoded, to decode
		#		d = skytools.db_urldecode(ev.ev_data)
		#	ev_extra1: table name
		p = "qsub -v"
		p += " db_host=%s" % (src_db.host)
		p += ",db_port=%s" % (src_db.port)
		p += ",db_name=%s" % (src_db.dbname)
		if ( ev.ev_extra1 == 'blast_run'):
			p = "qsub ~/pgq/blastc.sh '%s'" % (ev.ev_data) # all SGE params are in the script
		elif (ev.ev_extra1 == 'mg_traits_jobs'):
			p = "qsub ~/pgq/traits_calc.sh '%s'" % (ev.ev_data) # all SGE params are in the script
		else:
			self.log.error ("table '%s' is not supported by qsub consumer\n" % (ev.ev_extra1))
			p = "echo"
		output = subprocess.Popen(p, shell=True, executable="/bin/bash", stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()
		self.log.info ("Executing...\n%s\nSTDOUT: %s\nSTDERR: %s\n" % (p,output[0],output[1]))
		ev.tag_done()


if __name__== '__main__':
	script=QsubConsumer(sys.argv[1:])
	script.start()
