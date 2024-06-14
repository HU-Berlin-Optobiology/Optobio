## Yuhao is the author :)) ##

from ij import IJ, WindowManager, ImagePlus
from ij.gui import Roi, OvalRoi, GenericDialog, Plot 
from ij.plugin.frame import RoiManager
from ij.process import ImageProcessor, FloatProcessor
from ij.measure import ResultsTable, Measurements
from ij.plugin.filter import ParticleAnalyzer
from java.lang import Double
from ij.gui import Roi, PolygonRoi, Plot, ShapeRoi
from ij.measure import ResultsTable
from ij.io import DirectoryChooser
import os
from ij.io import RoiDecoder
from javax.swing import JOptionPane
from ij.text import TextWindow
from ij.gui import ShapeRoi
from ij.process import ByteProcessor
from ij.process import Blitter
from ij.plugin import Duplicator
import java.lang.Double as Double
import java.lang.reflect.Array as Array
from ij.plugin.filter import Analyzer
from collections import Counter
import math
from java.awt import Color

## Create a GenericDialog for user input ##
gd = GenericDialog("User Input")
gd.addMessage("Choose directories:")
gd.addDirectoryField("Select image folder:", "")
gd.addDirectoryField("Select ROI folder:", "")
gd.addDirectoryField("Select folder to save results table:", "")
gd.addMessage("Specify channels for processing:")
gd.addStringField("Channels (e.g. 1, 2 or 1-4):", "1-4")
gd.showDialog()

if gd.wasCanceled():
    IJ.log("User canceled dialog!")
    exit()
else:
    IJ.log("user input: ")

## Get user inputs from dialog
image_folder = gd.getNextString()
roi_folder = gd.getNextString()
results_save_folder = gd.getNextString()
channels_input = gd.getNextString()

## define function to parse channels 
def parse_channels(channels_input):
    channels = []
    parts = channels_input.split(',')
    for part in parts:
        if '-' in part:
            start, end = map(int, part.split('-'))
            channels.extend(range(start, end + 1))
        else:
            channels.append(int(part.strip()))
    return sorted(set(channels))  # Remove duplicates and sort

# Parse the channels input
try:
    channels = parse_channels(channels_input)
    
except ValueError:
    IJ.error("Invalid channel input. Please provide a comma-separated list of integers or ranges.")
    exit()
IJ.log("channels for processing: "+ str(channels))

## define function to measure intensity on an image with specific rois ##
def intensity_measurement ():
    IJ.log("Initialising parameters for image handling...")
    image = None
    num_pro_images=0
        
    ## check if the directory exist
    IJ.log("Sorting image directories...")
    if not image_folder:   
        IJ.showMessage("image directory not found!")
        return
    IJ.log("")
    
    ## check status of ROI manager. If there is no ROI manager, open a new one  
    rm = RoiManager.getInstance()                            
    if rm is None:
        IJ.log("ROI manager (rm) is closed. Opening new rm ")
        rm = RoiManager()
        rm = RoiManager.getInstance()
    
    ## set results table and roi manager ##
    rt = ResultsTable()
    ## creat empty dictionary to store values for all images ##
    det_image={}
    IJ.log("")    
    IJ.log("=== Processing start... ===")
    IJ.log("")
     ## list all images in the image_directory, creat name for saving detected ROIs in zip file and corresponding results in csv format ##    
    for f in os.listdir(image_folder):
        if f.endswith(".tif"):
        ## prepare for information storage ##
            IJ.log("TIF file detected!")
            IJ.log("file being processed: "+ f)
            num_pro_images+=1 #count how many images are being processed
            
            ## open corresponding ROI and load into rm ##
            roi_name = os.path.splitext(f)[0] + ".zip" # set name of corresponding roi
            if not os.path.exists(os.path.join(roi_folder, roi_name)):  ## check if ROI directory exist ##
                IJ.showMessage("Error!! (no ROI directory found)")
                return
            IJ.log("matching ROI found!")  ## return matching ROI found in the log file
            IJ.log("Loading ROI: " + str(roi_name))  ## log name of the ROI being loaded    
            rm.runCommand("Open", os.path.join(roi_folder, roi_name)) ## open the ROI and load into rm ##
            n_r = rm.getCount() ## count how many ROIs in rm
            IJ.log("Number of ROIs loaded in rm: " + str(n_r)) ## log numer of ROIs ##    
            ## only if there are ROIs in rm, start image processing ##
            if not n_r > 0:
                IJ.showMessage("no roi added")
                return

            detect={} # creat empty dictionary to store values ##
        
            ## start actual process ##
            image = IJ.openImage(os.path.join(image_folder, f))  # open image
            image.show()  # show image
            image_p=IJ.getImage() # get front image
            image_idx=image_p.getTitle() # get title of image
            stack=image_p.getStack() # activate stack selection function
            nr_ch=stack.getSize() # check number of channels
            IJ.log("Number of channels in current image: "+str(nr_ch)) # log number of channels in image stack
            
            for i in channels:     # loop through the channels specified by user input
                iip=ImagePlus("C"+str(i), stack.getProcessor(i)) ## select single channel from stack image 
                IJ.log("")
                IJ.log("processing channel: "+str(i)) #report which channel is being processed
                
                channel_info = {}
                # set measurment
                IJ.run("Set Measurements...", 
                "area mean standard min max centroid perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction stack display redirect=None decimal=3")
                for r in range(n_r):  # loop through rois in manager
                    roi=rm.getRoi(r) # get roi from manager
                    #IJ.log("ROI number "+str(r))
                    iip.setRoi(roi) # set the roi on the channel of the image
                    IJ.run(iip, "Measure", "") # measure things
                    area = rt.getResultsTable().getValue("Area",0)
                    mean = rt.getResultsTable().getValue("Mean",0)
                    intden = rt.getResultsTable().getValue("IntDen",0)
                    rawintden = rt.getResultsTable().getValue("RawIntDen",0)
                    # Store measured values in the dictionary
                    channel_info["ROI_" + str(r)] = {"Area": area,
                                                     "Mean": mean,
                                                     "IntDen": intden,
                                                     "RawIntDen": rawintden
                                                     }

                    rt.getResultsTable().reset()
                
                detect["Channel_" + str(i)] = channel_info
                
            det_image[image_idx]=detect
            rm.runCommand("Reset") ## remove all rois for next image
            IJ.log("")
            IJ.log("=== current image finished ===")
            IJ.run("Close All") ## close all images
            IJ.log("")
    
    rm.runCommand("Reset") ## remove all rois for next image
    IJ.run("Close All") ## close all images
    IJ.log("Generating final results table...")
    # Create a ResultsTable to display the data
    table = ResultsTable()

    # Populate the ResultsTable with the data from 'detect'
    for k in det_image.keys():
        for ch, channel_info in det_image[k].items():
            for roi, roi_info in channel_info.items():
                table.incrementCounter()
                table.addValue("Image", k)
                table.addValue("Channel", ch)
                table.addValue("ROI", roi)
                table.addValue("Area", roi_info["Area"])
                table.addValue("Mean", roi_info["Mean"])
                table.addValue("IntDen", roi_info["IntDen"])
                table.addValue("RawIntDen", roi_info["RawIntDen"])

    # Show the ResultsTable
    table.show("Measurement Results")
    # Save the ResultsTable
    results_path = os.path.join(results_save_folder, "results.csv")
    table.save(results_path)
    IJ.log("Results saved to: " + results_path)
    IJ.log("")
    IJ.log("!!! Done !!!")


if __name__ == '__main__':
    intensity_measurement()   
            
            
            
            
            
            
           
    
    
    
    