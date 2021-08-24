TOP=../..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE
#=============================

#=============================
# Build an ioc application
# Use PROD_IOC_RTEMS for RTEMS only
# Use PROD_IOC_Linux for Linux only
PROD_IOC_Linux = setra

# setra.dbd will be created and installed
DBD += setra.dbd

setra_DBD += base.dbd
setra_DBD += iocAdmin.dbd
setra_DBD += asSupport.dbd
setra_DBD += asyn.dbd
setra_DBD += stream.dbd
setra_DBD += modbus.dbd
setra_DBD += modbusSupport.dbd
setra_DBD += caPutLog.dbd

# <name>_registerRecordDeviceDriver.cpp will be created from <name>.dbd
setra_SRCS += setra_registerRecordDeviceDriver.cpp
setra_SRCS_DEFAULT += setraMain.cpp

# Add locally compiled object code
#setra_SRCS += dbSubExample.c

setra_LIBS += stream
#setra_LIBS += calc

setra_LIBS += autosave
setra_LIBS += devIocStats
setra_LIBS += modbus
setra_LIBS += caPutLog
setra_LIBS += asyn
setra_LIBS += $(EPICS_BASE_IOC_LIBS)

#===========================

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

