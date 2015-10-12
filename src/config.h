#/*  CONFIG.H 
# *
# * (c) 2002 by Max Artemev aka Bert Raccoon
# */


# The script assumes that DCC32.EXE are present on the current search path
# if this is not the case, modify the DCC and RCC macro to reflect the location 
# of this executable.
# ----------------------------------------------------------------------------
# ::>> Set up the Delphi Console Compiler (DCC). 
# ----------------------------------------------------------------------------
# Heh, so strange to looking here DCC instead of GCC, right? :)
DCC          = dcc32.exe

#
# Path to HTML Help Console compiler.
#
HHC	     = "C:\\Program Files\\HTML Help Workshop\\hhc.exe" 

# ----------------------------------------------------------------------------
# ::>> Delphi global flags for compiling.
# ----------------------------------------------------------------------------
!ifdef DEBUG
DFLAGS       = -Q -B -$$O- -$$A+ -$$H+ -$$D+ -$$Y+ -$$Q+ -$$I+ -$$L+ -W -V
!else
DFLAGS       = -Q -B -$$O+ -$$A+ -$$H+ -$$D- -$$Y- -$$Q- -$$I- -$$L- -W
!endif


# ----------------------------------------------------------------------------
# ::>> Folders for source code, include, and unit lookups
# ----------------------------------------------------------------------------
SRC_DIR      = freecap
INJECT       = inject
PROXY32	     = proxy32

!ifdef RUS
HELPDIR=rus
!else
HELPDIR=eng
!endif
