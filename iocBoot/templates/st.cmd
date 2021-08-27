#!$$IOCTOP/bin/rhel7-x86_64/setra

# Required subs: 
#  IOCNAME - Name of the IOC
#  ENGINEER - Name of the engineer to pester if something goes wrong
#  LOCATION - Physical location of the device 
#  IOC_PV - PV used for logging IOC stats
#  IOCTOP - TOP location of the IOC 
#  TOP - TOP location
#  DEVICE_IP - IP of the setra 5000 device (No port, either hostname or ip4)
#  DEVICE_PV_BASE - Used as the base PV name for each added PV

epicsEnvSet("IOCNAME", "$$IOCNAME")
epicsEnvSet("ENGINEER",  "$$ENGINEER" )
epicsEnvSet("LOCATION",  "$$LOCATION" )
epicsEnvSet("IOCSH_PS1", "$(IOCNAME)> " )
epicsEnvSet("IOC_PV",    "$$IOC_PV")
epicsEnvSet("IOCTOP", "$$IOCTOP")

< envPaths
epicsEnvSet("TOP", "$$TOP")
cd( "$(IOCTOP)" )

# Run common startup commands for linux soft IOC's
< /reg/d/iocCommon/All/pre_linux.cmd

# Register all support components
dbLoadDatabase("dbd/setra.dbd")

setra_registerRecordDeviceDriver(pdbbase)

# Set this to enable LOTS of stream module diagnostics
#var streamDebug 1

# Configure each device


drvAsynIPPortConfigure( "SETRA1", "$$DEVICE_IP:502 TCP", 0, 0, 1 )

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

# Load record instances

dbLoadRecords("db/iocSoft.db",         "IOC=$(LOCATION)")
dbLoadRecords("db/save_restoreStatus.db",      "P=$(LOCATION):")
dbLoadRecords("db/setra.db",            "DEV=$$DEVICE_PV_BASE,PORT=Setra_set_reg")
#dbLoadRecords("db/asynRecord.db", "Dev=NAME, PORT=PORT")

# Setup autosave
set_savefile_path( "$(IOC_DATA)/$(IOC)/autosave")
set_requestfile_path( "$(TOP)/autosave")
save_restoreSet_status_prefix("$(IOC_PV)")
save_restoreSet_IncompleteSetsOk(1)
save_restoreSet_DatedBackupFiles(1)

# CD into the correct dir
cd "${TOP}/iocBoot/${IOC}"

# Just restore the settings
set_pass0_restoreFile("$(IOC).sav")
set_pass1_restoreFile("$(IOC).sav")

# Initialize the IOC and start processing records
iocInit()

# Start autosave backups
create_monitor_set("$(IOC).req", 5, "")

# All IOCs should dump some common info after initial startup.
< /reg/d/iocCommon/All/post_linux.cmd


