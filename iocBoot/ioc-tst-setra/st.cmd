#!/reg/g/pcds/epics-dev/mlandrum/setra/current/bin/linux-x86_64/setra

< envPaths
epicsEnvSet( "ENGINEER",  "Jeremy Lorelli" )
epicsEnvSet( "LOCATION",  "TECH-AQM-TEST" )
epicsEnvSet( "IOCSH_PS1", "tst-setra-01> " )
epicsEnvSet( "IOC_PV",    "TST:SETRA:01")
epicsEnvSet( "IOCTOP", "/reg/g/pcds/epics-dev/mlandrum/setra/current")

cd( "$(IOCTOP)" )

# Run common startup commands for linux soft IOC's
< /reg/d/iocCommon/All/pre_linux.cmd

# Register all support components
dbLoadDatabase("dbd/setra.dbd")

setra_registerRecordDeviceDriver(pdbbase)

# Set this to enable LOTS of stream module diagnostics
#var streamDebug 1

# Configure each device


drvAsynIPPortConfigure( "SETRA1", "setra-1:502 TCP", 0, 0, 1 )

modbusInterposeConfig("SETRA1",0,5000,0)


# Register definitions are From Setra modbus datasheet go as followed
#
# Setra_set_reg- writes to device a register #8000. Used to read snapshot of Setra_read_register records

#Setra_samp_reg- ReadWrite device registers #5000-#5032.

#Setra_read_reg- ReadWrite device registers #9000-#9085. 
 

# drvModbusAsynConfigure(modbusPort,  asynPort,  slave address, modbus_function, offset, data_length, data_type, timeout, debug name)

drvModbusAsynConfigure(  "Setra_set_reg",  "SETRA1",  247,  16,  8000,  4,  0,  1000, "SETRA1_Set")

drvModbusAsynConfigure(  "Setra_samp_reg", "SETRA1",  247, 16,  5000,  32,  0,  1000, "SETRA1_Samp")


drvModbusAsynConfigure(  "Setra_read_reg", "SETRA1",  247,  3,  9000,  85,  0,  3000, "SETRA1_Read")


# USED As DEBUGGING TOOL
#asynSetTraceMask("Setra_set_reg", 0, 9)
#asynSetTraceMask("Setra_read_register", 0, 9)
#asynSetTraceIOMask("SETRA1", 0, 4)
#asynSetTraceMask("SETRA1", 0, 9) 



# Load record instances




dbLoadRecords( "db/iocSoft.db",         "IOC=$(LOCATION)" )
dbLoadRecords( "db/save_restoreStatus.db",      "P=$(LOCATION):" )
dbLoadRecords( "db/setra.db",            "DEV=TST:SETRA:01,PORT=Setra_set_reg" )
#dbLoadRecords( "db/asynRecord.db", "Dev=NAME, PORT=PORT")

# Send trace output to motor specific log files
#asynSetTraceFile(   "$(SETRA1)", 0, "/reg/d/iocData/$(IOC)/logs/$(SETRA1).log" )

#asynSetTraceFile(   "$(SETRA1_Read)", 0, "/reg/d/iocData/$(IOC)/logs/$(SETRA1_Read).log" )
# Setup autosave
set_savefile_path( "$(IOC_DATA)/$(IOC)/autosave")
set_requestfile_path( "$(TOP)/autosave")
save_restoreSet_status_prefix( "$(IOC_PV)" )
save_restoreSet_IncompleteSetsOk( 1 )
save_restoreSet_DatedBackupFiles( 1 )


# Just restore the settings
set_pass0_restoreFile( "$(IOC).sav" )
set_pass1_restoreFile( "$(IOC).sav" )

# Initialize the IOC and start processing records
iocInit()

# Start autosave backups
create_monitor_set( "$(IOC).req", 5, "" )

# All IOCs should dump some common info after initial startup.
< /reg/d/iocCommon/All/post_linux.cmd



