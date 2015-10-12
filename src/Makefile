!include config.h


# Our targets. MAKE'll call it in this order
all: freecap inject proxy32 help clean

freecap:
	@echo Entering $(SRC_DIR)
	@cd $(SRC_DIR)
	@${MAKE}
	@echo Leaving $(SRC_DIR)
	@cd ..

inject:
	@echo Entering $(INJECT)
	@cd $(INJECT)
	@${MAKE}
	@echo Leaving $(INJECT)
	@cd ..

proxy32:
	@echo Entering $(PROXY32)
	@cd $(PROXY32)
	@${MAKE}
	@echo Leaving $(PROXY32)
	@cd ..

help:
	@cd help
	@${MAKE}
	@cd ..

clean:
	@echo Cleaning up...
	-@del /S *.dcu >NUL
	-@del /S *.~* >NUL
