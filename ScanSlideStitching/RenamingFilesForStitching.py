# -*- coding: utf-8 -*-
"""
Created on Thu May 22 11:15:51 2025

@author: Erich
"""
import os

# Path to files to be renamed; needs the / separator and not the windows \ one!
# Path can also contain subfolders containing files to be renamed
# important is, that file type and method for acquisition is the same
path = ""

# boolean; whether you want to view first how the renaming looks like
# True: show how the renaming looks like without renaming files
# False: rename files
printing = False

# file type of files to be renamed; activate one that fits your type or make your own
# Keep only one of them active and silence the others with a # at the beginning of the line
# Silencing/Activating line of code can be done using hotkey Ctrl+1
ftype = ".ome.tif"
# ftype = ".stk"
# ftype = ".tif"
# ftype = ""

# Method used to acquire your data; activate your method or make it
# Keep only one of them active and silence the others with hotkey Ctrl+1
method = "wf"
# method = ""

# Method to replace method used to acquire data
# Keep only one of them active and silence the others with hotkey Ctrl+1
Method = "Conf" # HH_SDC
# Method = "sdc" # SDC
# Method = "" # Whatever you want

#####################################################################################################################
### End of user input
#####################################################################################################################

files = [os.path.join(root, file) for root, dirs, files in os.walk(path) for file in files]
WL = str(405) # To replace DAPI with 405

for f in files:
    if f.endswith(ftype):
        old = f
        new = f.replace(method, Method)
        if "DAPI" in new:
            new = new.replace("DAPI", WL)
        if printing:
            print(f"Old: {old}\n New: {new}\n\n") # Testing before renaming stuff without knowing output
        elif not printing:
            os.rename(old, new)
