# Stitching Macro
## How it works; How data has to look like
- This macro can process multiple folders. The files have to have a certain naming pattern to be processed by this macro.
- For every folder, the macro asks about parameters for the grid stitching (amount of rows and columns) and also checks whether provided Folder exists.
- Parameters like overlap, grid pattern and whether a maximum z-projection should be applied are only asked once.
- .nd and .ome files are automatically moved to a separate folder, that is generated, to avoid issues while stitching (folder is called ND and is generated inside folder with data)
- Files have to have a certain naming pattern to be recognised by the macro, while the suffix is the most important part:
  - files have to end with either *w"i""Method""Channel"_s"j""file-type"* (for multi channel) or with *"Method"_s"j""file-type"* (for single channel).
  - "i" is element of [1,4]; "Method" is either *sdc* or *Conf*; "Channel" is a three digit number, usually representing the excitation laser wavelength (i.e. 488); "j" is element of [1,♾️) and represents the number of tiles of the scan slide; Supported "file-type" are *.ome.tif*, *.stk*, *.tif*.
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
