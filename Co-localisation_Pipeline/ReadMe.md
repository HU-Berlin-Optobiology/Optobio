# Batch processing of raw data
## How it works
To prepare your raw data for the co-localisation macro, use the macro titled "BatchProcessing_Z-Projections.ijm". \
This macro can handle *ome.tif*, *.tif*, *.stk* and *.tiff* files. \
All generated images will be saved inside a folder created inside the original folder with a prefix indicating used Z-projection. \
The name of the generated folder is provided by the user and will be generated on the go. \
At first, the user will be asked to provide all folders that should be processed. The Log-window helps to keep track what folders are already provided. \
Afterwards, some information need to be provided:
  - Name of folder where generated images will be safed
  - What sort of Z-Projection should be applied to all images
  - What colour-code should be used

In the end, the user has to provide the number of channels per folder. This implies that all images inside one folder have the same amount of channels. If this is not the case, please adjust the data accordingly.
# Analysis for Co-localisation
## How it works; How data has to look like
This macro enables batch-processing of multiple folders with multiple images. When multiple folders are provided, make sure that all images have the same channels that need to be analyzed. \
⚠️You can only provide one combination of channels that should be analyzed⚠️ \
Analysis itself is performed using the [ComDet Plugin](https://imagej.net/plugins/spots-colocalization-comdet) \
Most of parameters you provide are named exactly how they are called when using the ComDet plugin.\
Images can have multiple channels, while up to four can be analysed simultaneously while having only one plane (usually achieved with a Z-projection of some sort)\
It is possible to provides ROIs for the analysis of images. They have to be ordered in the same way as the images are. For example, if images are ordered by increasing numbers (01,02,03,04,...), it is recommended to name the ROIs with an indentical pattern.\
It is not necessary that the number of ROIs is identical to number of Images in a folder. Just know that without a provided roi, the whole image will be analysed.\
Furthermore, this macro assumes that the first provided ROIs are for the first images. Thus far it is not possible to provide a ROI for an image in the middle of the dataset when the previous images within the same folder don't have one.
You can decide where the results are saved: Either all results in a newly created folder or inside a newly created folder located inside the data-folder. All folders, where the results are stored, will be generated automatically if they are not available. \
Future work to be done: \
Making it possible to provide multiple ROIs for one image in a *.zip* file as well as one ROI per image. \
Having this macro working together with weka segmentation, so that segmented rois can be provided for this macro.
## Detailed description of every pop up window
1st: With this window the user is asked to chose a folder where images, that should be analyzed, are stored. \
Afterwards a small yes/no/cancel window shows up asking whether more folders should be analyzed. ⚠️Clicking on Cancel will abort the macro⚠️ \
If Yes has been clicked, the same window as before appears asking for a folder containing images. Repeat ad nauseam until all folders have been chosen. \
If all folders have been chosen, click on No to continue. Now another window pops up asking for a folder where results will be saved. The provided folder doesn't need to exist and the directory can be changed later on. This window is optional and can be skipped. ⚠️Don't click on close or the X to close the window, just hit Enter to pass the default directory to skip this⚠️ \
2nd: Now the main Window appears asking the user about many parameters, most of which are passed to ComDet and are therefore named identical. \
At the very top displayed is the saving directory that can be adjusted. Again, the directory doesn't need to exist. \
Below are two options to over-ride the provided saving directoy. Enabling this option will create a folder inside every folder that has been chosen before. The name of the folder can be provided in the empty field. \
Afterwards are parameters that are passed forward to ComDet's spot colocalization. If you have questions about these parameters, the Help button on the bottom right directs you to their web-site. \
About "What combination of channels to analyze" droplist: With this droplist you provide information about what channels are to analyzed. The default 12 refers to channel 1 and 2. \
Toggle "Save generated images": with this you can decide whether generated multichannel images should be saved. The images with the detected spots will be saved anyways. This option allows to save images before the spot detection. \
Toggle "ROIs are provided for the analysis": With this you tell the script whether some folder have ROIs inside that can be used on images to analyze a certain region in the images. \  
3rd: After continuing by pressing OK, another window pops up. With this window, you provide channel specific parameters for ComDet's spot colocalization. \
After pressing OK, the macro will start to process all folders and their individual images and saving the results in the provided directory.



