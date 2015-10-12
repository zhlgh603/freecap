#
# Makefile for Freecap
#
!include "../config.h"

# ----------------------------------------------------------------------------
# ::>> Folders for source code, include, and unit lookups
# ----------------------------------------------------------------------------
INCLUDE_DIRS = .;..\Components\HH;..\Components\WinXP;..\Components\Trayicon;..\Components\xmlconf;..\Components\OleListView;..\Components\ICS
OUT_DIR      = ..\..\exe\

# ----------------------------------------------------------------------------
# ::>> Main project filename
# ----------------------------------------------------------------------------
PROJECT  = freecap.dpr


# ----------------
# Console version
# ----------------
PROJECTCON  = freecapCon.dpr
PROJECTCONW = freecapConW.dpr

all: freecap freecapcon freecapconw

# ----------------------------------------------------------------------------
# ::>> Main project
# ----------------------------------------------------------------------------
freecap:
	@echo ***************************************************************
	@echo **  Compiling the $(PROJECT)...
	@echo ***************************************************************
	$(DCC) $(DFLAGS) -R$(INCLUDE_DIRS) -U$(INCLUDE_DIRS) -I$(INCLUDE_DIRS) -E$(OUT_DIR) $(PROJECT)
	@echo The executable was placed to $(OUT_DIR)


freecapcon:
	@echo ***************************************************************
	@echo **  Compiling the $(PROJECTCON)...
	@echo ***************************************************************
	$(DCC) $(DFLAGS) -U$(INCLUDE_DIRS) -I$(INCLUDE_DIRS) -E$(OUT_DIR) $(PROJECTCON)
	@echo The executable was placed to $(OUT_DIR)
	
freecapconw:
	@echo ***************************************************************
	@echo **  Compiling the $(PROJECTCON)...
	@echo ***************************************************************
	$(DCC) $(DFLAGS) -U$(INCLUDE_DIRS) -I$(INCLUDE_DIRS) -E$(OUT_DIR) $(PROJECTCONW)
	@echo The executable was placed to $(OUT_DIR)
	