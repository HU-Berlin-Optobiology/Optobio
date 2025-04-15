# Shading Correction macro for FIJI
## What it is used for
Improve visuals of scan slides for representative purposes mostly (removes the visible grid by using the Plugin BaSiC).

![alt text](https://github.com/HU-Berlin-Optobiology/Optobio/blob/main/StitchingShading/BeforeAfter.png?raw=true)
## How it works; How to prepare raw data before usage
- The raw data has to be in a single folder containing only <ins>**one**</ins> scan slide (multiple channels are allowed) and <ins>**not multiple/different**</ins> in one folder.
- The files also have to have a certain naming pattern to be processed by this macro, while the suffix is the most important part:
  - The suffix has to look something like *w1sdc405_s1.stk* (for multi-channel scan slides) or *sdc405_s1.stk* (for single channel scan slides); Everything before that can be random
  - From this suffix, several Parameters can be extracted:
    - Method is either *"sdc"* or *"Conf"* and can be found after the *"w1"*. Up to *"w4"* is supported and it is be able to handle images without the *"w1"*.
    - wl (Wavelength) is read out after Method, "405" in this case, and used to process multiple channels in one go, i.e. *"w1sdc405_s1.stk"*, *"w2sdc488_s1.stk"*, etc.
    - filetype is quite literal the type of the file, in this case *".stk"*. Another type supported is *".ome.tif"*. Those are the ones usually encountered in our lab at this time.
- Macro adjusted to also work with scan slides missing optical sections.
- A new folder, if it doesn't exist beforehand, is being generated in the folder where the raw data is stored. In this folder all generated images will be stored.
- At first the macro checks, whether the Plugin BaSiC is installed. If not, it will terminate the macro with an error message.
- After initiation of the macro (launch and submitting parameters asked by pop-up windows), the macro will open all images from one wavelength (line 90 - 122).
  - Afterwards, a maximum intensity Z-Projection is applied to all images, if either frames!=1 | slices!=1.
  - Then the MAX-intensity images (if generated) are stacked into one stack (otherwise the unchanged images are) under the name *"wl.tif"* where wl is the parameter extracted from the file name.
  - On this stack the plugin BaSiC is then applied, which afterwards creates a corrected stack-file with the name *"Corrected:wl.tif"*
  - Now all other images are closed, the stack is seperated into individual images and they are saved one by one
  - In the end, all open windows are closed and this process starts again for the other wavelengths if available.
- From line 123 'til the end it is a slightly adjusted version of our stitching macro V.3.5
