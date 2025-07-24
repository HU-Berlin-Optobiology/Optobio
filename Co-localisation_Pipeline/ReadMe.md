# Analysis for Co-localisation (WIP)
## How it works; How data has to look like
This macro enables batch-processing of multiple folders with multiple images.\
Analysis itself is performed using the [ComDet Plugin]. (https://imagej.net/plugins/spots-colocalization-comdet)\
Most of parameters ypu provide are named exactly how they are called when using the ComDet plugin.\
Images can have multiple channels, while up to four can be analysed simultaneously while having only one plane (usually achieved with a Z-projection of some sort)\
It is possible to provides ROIs for the analysis of images. These ROIs must be of filetype *.roi* and have to be ordered in the same way as the images are. For example, if images are ordered by increasing numbers (01,02,03,04,...), it is recommended to name the ROIs in an indentical pattern.\
It is not necessary that the number of ROIs is identical to number of Images in a folder. Just know that without a provided roi, the whole image will be analysed.\
You can decide where the results are saved: Either all results in a newly created folder or inside a newly created folder located inside the data-folder. All folders, where the results are stored, will be generated automatically if they are not available.
