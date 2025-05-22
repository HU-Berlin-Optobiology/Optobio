# Stitching Macro
## How it works; How data has to look like
- This macro can process multiple folders. The files have to have a certain naming pattern to be processed by this macro. The python script in this folder can help out with that.
- For every folder, the macro asks about parameters for the grid stitching (amount of rows and columns) and also checks whether provided Folder exists.
- Parameters like overlap, grid pattern and whether a maximum z-projection should be applied are only asked once.
- .nd and .ome files are automatically moved to a separate folder, that is generated, to avoid issues while stitching (folder is called ND and is generated inside folder with data)
- Files have to have a certain naming pattern to be recognised by the macro, while the suffix is the most important part:
  - files have to end with either *w"i""Method""Channel"_s"j""file-type"* (for multi channel) or with *"Method"_s"j""file-type"* (for single channel).
  - "i" is element of [1,4]; "Method" is either *sdc* or *Conf*; "Channel" is a string with length 3, usually representing the excitation laser wavelength (e.g. 488) or something similar to that (e.g. Cy5); "j" is element of [1,♾️) and represents the number of tiles of the scan slide; Supported "file-type" are *.ome.tif*, *.stk*, *.tif*.
- Images can also be either 2D or 3D; it also assumes that #frames are the number of Z-planes if #frames>#slices; usually #slices are the number of Z-planes; if information about frames and/or slices is missing, it should kill itself (line 183-185).
- After folders and parameters are provided by the user, it is recommended to not interfere with Fiji anymore as it may result in unwanted behaviour
- What it does:
  - It generates two folders per detected wavelength plus two additional folder called "Temp" and "TempSmall" which will be deleted afterwards
  - It runs the Grid/Collection stitching command with provided parameters for every wavelength in succession
  - It also renames the generated images the get rid of some zeros inside the name (line 247-300)
  - Afterwards it loads all planes and creates smaller versions of them (10% of original size) (line 304-348)
  - Then it combines the individual channels into one file (for both original size and small one) and saves them into either the "Temp" of "TempSmall" folder; deletes afterwards the channel-folders.
  - In the end it generates two final images with a certain name ("NumberOfChannels"+Channels.tif and "NumberOfChannels"+ChannelsSmall.tif) where "NumberOfChannels is element of [1,4] (amount of detected channels) and deletes the Temp-folders.
  - When it is finished, a small pop-up window with date and time will be displayed.

# Python code for renaming files
## Check whether Python is installed on your system
- first of all, you have to able to execute .py-files (Python needs to be installed in some way on your device)
- Check whether Python is installed: 
    - To check whether Python is installed on your system, open the command prompt (press Win+R, type *cmd* inside the new window and hit Return/Enter)
    - Afterwards type *Python* inside the command prompt (the newly opened window) and hit Return/Enter
    - If Python is installed on your system, something like *Python 3.11.8* will appear afterwards together with other stuff
- If Python is not recognized, before installing it via the Microsoft store, first check, whether Anaconda is installed on your device (sometimes Anaconda together with python is installed on a system but Python is not included in the global PATH environment)
  - If Anaconda is installed, your system should have an *anaconda prompt*. To test that, type into the windows search bar *anaconda prompt*. The *Anaconda Prompt*, if installed, should be suggested to you.
  - Open this Anaconda prompt and inside it type again *python* and hit Return/Enter. This time you should see something like *Python 3.11.8* where the number code is just the version of Python and might differ from this example.
## Adjust script with a text-editor of your choice
Before you launch the script, you should look inside it with a text-editor of your choice and adjust some variables:
- line 12: variable *path*: In-between the "", copy the path to your files you want to rename. Pay attention, that the path needs the */*-separator and not the *\* one. This path can also contain subfolders, as the script goes deep down into every subfolder that can be found in the provided path (also hidden ones).
- line 16-19: variable *ftype*: Very important is to keep only one of the provided variables active while silencing the others with a *#* at the start of the line. This variable is the file-type of the files you want to rename. If none of the provided ones fit your type, you can create your own in line 19 by typing it in-between the "".
- line 23-24: variable *method*: This variable assumes that your file-name contains something like *w1wfRFP* or anything similar to that. If your file-name has nothing like that inside it, create your own variable in line 24. Make it something, that all of your file-names contain once and is not very important to you, as it will be replaced by another variable *Method*.
- line 28-30: variable *Method*: This variable will replace whatever is defined for the variable *method*. For example, in file-name "c1_1_w1wfCy5.ome.tif" with *method*="wf" and *Method*="Conf", *wf* will be replaced by *Conf* resulting in the new name "c1_1_w1ConfCy5.ome.tif".
- Not to change, but important to mention: When your file-name has the word "DAPI" inside, like in "c1_1_w1wfDAPI.ome.tif", "DAPI" will be replaced by "405" resulting in the new name "c1_1_w1Conf405.ome.tif".

## Launch the script
- After you verified, that Python is installed on your system and you adjusted the script, you can launch it from the either command prompt (cmd or anaconda prompt) by typing *path/to/the/script/RenamingFilesForStitching.py*. Don't forget to type out the path to the script and hit Enter/Return afterwards.
  - optionally you can move to the directory first with the *cd* command and then launch the script by typing *python RenamingFilesForStitching.py*.
