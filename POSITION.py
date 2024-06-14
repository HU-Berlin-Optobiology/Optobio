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
gd.addDirectoryField("Select folder to save detected ROIs:", "")
gd.addDirectoryField("Select folder to save results table:", "")
gd.addDirectoryField("Select folder to save log file:", "")

gd.addMessage("Specify channels for detection:")
gd.addNumericField("first channel:", 1, 0) # set minimum particle size
gd.addNumericField("second channel:", 2,0) # set maximum particle size

gd.addMessage("Set detection thresholds:")
gd.addMessage("Channel_01:")
gd.addNumericField("Minimum particle size (pixels):", 0.0, 2) # set minimum particle size
gd.addNumericField("Maximum particle size (pixels):", Double.POSITIVE_INFINITY, 2) # set maximum particle size
gd.addNumericField("Minimum circularity:", 0.2, 2) # set minimum circularity
gd.addNumericField("Maximum circularity:", 1.0, 2) # set maximum circularity
gd.addMessage("Channel_02:")
gd.addNumericField("Minimum particle size (pixels):", 0.0, 2) # set minimum particle size
gd.addNumericField("Maximum particle size (pixels):", Double.POSITIVE_INFINITY, 2) # set maximum particle size
gd.addNumericField("Minimum circularity:", 0.2, 2) # set minimum circularity
gd.addNumericField("Maximum circularity:", 1.0, 2) # set maximum circularity
gd.addMessage("co-localisation threshold:")
gd.addNumericField("Threshold (pixels):", 1.0, 2) # set co-localisation threshold
gd.addMessage("Set image threshold (e.g. 0.5 times higher than automatically calculated Otsu image threshold):")
#gd.addMessage("(e.g. 0.5 times higher than automatically calculated Otsu image threshold)")
gd.addNumericField("Threshold:", 0.5, 2) # set co-localisation threshold

gd.showDialog()

if gd.wasCanceled():
    IJ.log("User canceled dialog!")
    exit()
else:
    IJ.log("user input: ")

## Get user inputs from dialog
image_folder = gd.getNextString()
roi_folder = gd.getNextString()
roi_save_folder = gd.getNextString()
results_save_folder = gd.getNextString()
log_folder = gd.getNextString()

## specify channels 
ch1_d=gd.getNextNumber()
ch2_d=gd.getNextNumber()

## get input for channel_01
min_size_c1 = gd.getNextNumber()
max_size_c1 = gd.getNextNumber()
min_circularity_c1 = gd.getNextNumber()
max_circularity_c1 = gd.getNextNumber()

## get input for channel_02
min_size_c2 = gd.getNextNumber()
max_size_c2 = gd.getNextNumber()
min_circularity_c2 = gd.getNextNumber()
max_circularity_c2 = gd.getNextNumber()

## get co-localisation threshold
co_threshold = gd.getNextNumber()

## get image threshold value
input_thre=gd.getNextNumber()

## log detection values
IJ.log("C1_Minimum particle size (pixels): "+str(min_size_c1))
IJ.log("C1_Maximum particle size (pixels): "+str(max_size_c1))
IJ.log("C1_Minimum circularity: "+str(min_circularity_c1))
IJ.log("C1_Maximum circularity: "+str(max_circularity_c1))
IJ.log("")
IJ.log("C2_Minimum particle size (pixels): "+str(min_size_c2))
IJ.log("C2_Maximum particle size (pixels): "+str(max_size_c2))
IJ.log("C2_Minimum circularity: "+str(min_circularity_c2))
IJ.log("C2_Maximum circularity: "+str(max_circularity_c2))
IJ.log("")

## define a function to threshold image using Otsu ## 
def image_threshold (processing_image, title_suffix):
    title = processing_image.getTitle() # get image title
    IJ.log("thresholding "+title+"...")
    iip = processing_image.getProcessor() ## select image in process (iip)
    pixels=iip.getPixels() ## Get pixel values of the whole image
    x_min = iip.getMin() ## get min intensity
    x_max = iip.getMax() ## get max intensity

    ## to creat histogram using FIJI built in plugin ##
    #IJ.run(gep, "Histogram", "bins=256 x_min=" + str(x_min) + " x_max=" + str(x_max) + " y_max=Auto")
    ## Create histogram manually ##
    pixel_values = [int(p) for p in pixels]
    hist = Counter(pixel_values)
    hist_max_value = max(hist.keys())
    IJ.log("hist_max_value"+str(hist_max_value))

    ## Ensure histogram has entries for all intensity values from 0 to max_value
    hist_list = [hist[i] if i in hist else 0 for i in range(hist_max_value + 1)]
    total_pixels = sum(hist_list)

    ## Implement Otsu's method to find the threshold
    current_max = 0
    threshold = 0
    sum_total = 0
    sum_foreground = 0
    weight_background = 0
    weight_foreground = 0

    for t in range(len(hist_list)):
        sum_total += t * hist_list[t]

    for t in range(len(hist_list)):
        weight_background += hist_list[t]
        if weight_background == 0:
            continue
    
        weight_foreground = total_pixels - weight_background
        if weight_foreground == 0:
            break
    
        sum_foreground += t * hist_list[t]
    
        mean_background = sum_foreground / weight_background
        mean_foreground = (sum_total - sum_foreground) / weight_foreground
    
        between_class_variance = weight_background * weight_foreground * (mean_background - mean_foreground) ** 2
    
        if between_class_variance > current_max:
            current_max = between_class_variance
            threshold = t

    ## Log the calculated threshold
    IJ.log("Calculated Threshold: " + str(threshold))

    ## Apply the calculated threshold to the image; lower threshold is increased for additional 0.5%
    if input_thre < 1:
        applied_thre=threshold+threshold*input_thre
    if input_thre > 1:
        applied_thre=threshold*input_thre
    if input_thre == 1:
        applied_thre=threshold*2
        
    iip.setThreshold(applied_thre, 65535, ImageProcessor.RED_LUT)
    IJ.log("applied Threshold: " + str(applied_thre))
    IJ.run(processing_image, "Convert to Mask", "")
    
    processing_image.setTitle(title + "_" + title_suffix)
    processing_image.show()  # Display the thresholded image
    
## define a function for particle detection ##
def particle_detect_batch ():
    IJ.log("Initialising parameters for image handling...")
    image = None
    num_pro_images=0
        
    ## check if the directory exist
    IJ.log("Sorting directories...")
    if not image_folder:   
        IJ.showMessage("image directory not found!")
        return
    
    #IJ.log("image folder detected!")
    IJ.log("")
    
    ## check status of ROI manager. If there is no ROI manager, open a new one  
    roi_manager = RoiManager.getInstance()                            
    if roi_manager is None:
        IJ.log("ROI manager (rm) is closed, no ROIs in rm. Opening new rm ")
        roi_manager = RoiManager()
        roi_manager = RoiManager.getInstance()

    IJ.log("=== Processing start... ===")
    IJ.log("")
    
    ## creat empty dict for storing information ##
    det_par={} # dict to store information overall
    det_C1={} # dict to store info for gephyrin and VGAT
    det_C2={} # dict to store info for VGAT
    det_coloc={} # dict to store colocalisation info

    ## list all images in the image_directory, creat name for saving detected ROIs in zip file and corresponding results in csv format ##    
    for f in os.listdir(image_folder):
        if f.endswith(".tif"):
            IJ.log("TIF file detected!")
            IJ.log("file being processed: "+ f)
            num_pro_images+=1
            
            ## creat path to save detected rois and information
            f_1=str("C1_"+f) # name for channel 1
            f_2=str("C2_"+f) # name for channel 2
            roi_save_path_c1 = os.path.join(roi_save_folder, f_1 + ".zip")
            result_table_path_c1 = os.path.join(results_save_folder, f_1 + ".csv")
            roi_save_path_c2 = os.path.join(roi_save_folder, f_2 + ".zip")
            result_table_path_c2 = os.path.join(results_save_folder, f_2 + ".csv")
            
            ## set corresponding roi name. Note!!! the name of the ROI file should be the same as images
            roi_name = os.path.splitext(f)[0] + ".roi"
            
            IJ.log("")
            IJ.log("opening image...")
            ## open image if it is in tif format ##
            image = IJ.openImage(os.path.join(image_folder, f))  ## open image
            #IJ.log("image being processed: " + str(f)) ## log image that is being processed
            image.show()  ## show image
            
            image_p=IJ.getImage() ## get front image
            image_idx=image_p.getTitle()
            duplicator=Duplicator()  ##activate duplicator          
            dup_im=duplicator.run(image_p, ch1_d, ch2_d) # duplicate channel 3 and 4 from the stack image (convert to user input)
            dup_im.setTitle("gephyrin_vgat") # name the duplicated image (convert to user input)
            dup_im.show() # show the duplicated stack
            
            stack=dup_im.getStack() ##activate stack selection function

            gep=ImagePlus("gephyrin", stack.getProcessor(1)) ## select channel1 from dup_im for gephyrin 
            vgat=ImagePlus("VGAT", stack.getProcessor(2)) ## select channel1 from dup_im for VGAT 
            gep.show() ## show gephyrin
            vgat.show() ## show VGAT

            ## Apply the threshold function to gephyrin and VGAT channels
            image_threshold(gep, "thresholded_gephyrin")
            image_threshold(vgat, "thresholded_VGAT")
            
            ## extract the histogram of original image to double check ## 
            #IJ.run(gep, "Histogram", "bins=256 x_min=" + str(x_min) + " x_max=" + str(x_max) + " y_max=Auto")

            ## duplicate the thresholded image for further processing
            gep_duplicate = duplicator.run(gep)
            gep_duplicate.setTitle("gephyrin_proc")
            gep_duplicate.show()
            
            ## open corresponding ROI and load into rm ##
            if not os.path.exists(os.path.join(roi_folder, roi_name)):  ## check if ROI directory exist ##
                IJ.showMessage("Error!! (no ROI directory found)")
                return
            IJ.log("matching ROI found!")  ## return matching ROI found in the log file
            IJ.log("Loading ROI: " + str(roi_name))  ## log name of the ROI being loaded    
            roi_manager.runCommand("Open", os.path.join(roi_folder, roi_name)) ## open the ROI and load into rm ##
            num_rois = roi_manager.getCount() ## count how many ROIs in rm
            IJ.log("Number of ROIs loaded in rm: " + str(num_rois)) ## log numer of ROIs ##    
            ## only if there are ROIs in rm, start image processing ##
            if not num_rois > 0:
                IJ.showMessage("no roi added")
                return
                
            roi = roi_manager.getRoi(0) ## get ROI from rm
            if roi.getType() != Roi.POLYGON:   ## check roi type if it is polygon
                raise TypeError("The ROI is not a polygon")
            ## Get the polygon points of roi
            xpoints = roi.getPolygon().xpoints
            ypoints = roi.getPolygon().ypoints
            npoints = roi.getPolygon().npoints
            ## copy the roi as a new one for the other channel
            new_roi= PolygonRoi(xpoints, ypoints, npoints, Roi.POLYGON)
            gep_duplicate.setRoi(roi) ## set the roi on to image
            
            # Prepare a ResultsTable to store particle analysis results
            rt = ResultsTable()
            ## clear rm to store detected rois
            roi_manager.reset() 
            ## Configure the ParticleAnalyzer
            ## Set the options and measurements you want (e.g., area, centroid, etc.)
            options = ParticleAnalyzer.ADD_TO_MANAGER | ParticleAnalyzer.SHOW_RESULTS | ParticleAnalyzer.IN_SITU_SHOW
            measurements = Measurements.CENTROID | Measurements.AREA 
            ## Initialize the ParticleAnalyzer
            pa = ParticleAnalyzer(options, measurements, rt, min_size_c1, max_size_c1, min_circularity_c1, max_circularity_c1)

            ## Run the ParticleAnalyzer on the image within the ROI
            pa.analyze(gep_duplicate)
            ## Display the ResultsTable with the detected particles (spots)
            rt.show("Results_C1")
            
            ## save detected rois from Ch1 as green ##
            for roi in roi_manager.getRoisAsArray():
                roi.setStrokeColor(Color.green)
            
            ## save detected rois in a specific color 
            #roi_manager.runCommand("Set Color", "green")
            roi_manager.runCommand("Save", roi_save_path_c1)
            rt.saveAs(result_table_path_c1)
            
            nu_det_rois_c1=roi_manager.getCount() ## count number of detected particles
            IJ.log("Number of detected ROIs in C1:"+str(nu_det_rois_c1))  ## log the detected cluster number
            
            ## loop through the detected ROIs and measure centroid & shape 
            IJ.log("Storing partical information...")
            for index in range(nu_det_rois_c1):
                roi_ind = roi_manager.getRoi(index)  # get roi index
                gep.setRoi(roi_ind) # set roi to thresholded gep image
                stats = gep.getStatistics(Measurements.CENTROID) # measure centroid of the roi 
                ## extract the shape of the roi for reconstruction later
                x_dr = roi_ind.getPolygon().xpoints 
                y_dr = roi_ind.getPolygon().ypoints
                n_dr = roi_ind.getPolygon().npoints
                
                det_C1[str(index)+"_C1"]={'centroid':[stats.xCentroid, stats.yCentroid],
                     'shape': {'xpoints': x_dr, 'ypoints': y_dr, 'npoints': n_dr}
                     }
            det_par[str(image_idx)]=det_C1    # add detected gephyrin info into the general dict
            det_C1={} # empty det_gep for the next image

            IJ.log("=== channel 01 processing done! ===")
            IJ.log("")
           
            IJ.log("Start processing channel 02")
            roi_manager.runCommand("Reset") ## remove the detected rois
            roi_manager.addRoi(new_roi) ## restore original roi for VGAT channel
            
            ##==========================================================================================##
            ## start processing channel 2 ##
            
            vgat_duplicate = duplicator.run(vgat)
            vgat_duplicate.setTitle("VGAT_proc")
            vgat_duplicate.show()

            roi_vgat = roi_manager.getRoi(0)
            vgat_duplicate.setRoi(roi_vgat)

            # Prepare a ResultsTable to store particle analysis results
            rt = ResultsTable()
            ## clear rm to store detected rois
            roi_manager.reset() 

            ## Configure the ParticleAnalyzer
            ## Set the options and measurements you want (e.g., area, centroid, etc.)
            options = ParticleAnalyzer.ADD_TO_MANAGER | ParticleAnalyzer.SHOW_RESULTS | ParticleAnalyzer.IN_SITU_SHOW
            measurements = Measurements.CENTROID | Measurements.AREA 
            pa_c2 = ParticleAnalyzer(options, measurements, rt, min_size_c2, max_size_c2, min_circularity_c2, max_circularity_c2)

            ## Run the ParticleAnalyzer on the image within the ROI
            pa_c2.analyze(vgat_duplicate)
            rt.show("Results_C2")
            ## save detected rois
            #roi_manager.runCommand("Set Color", "red")
            ## save detected rois from Ch1 as green ##
            for roi in roi_manager.getRoisAsArray():
                roi.setStrokeColor(Color.red)
                
            roi_manager.runCommand("Save", roi_save_path_c2)
            rt.saveAs(result_table_path_c2)

            nu_det_rois_c2=roi_manager.getCount() ## count number of detected clusters
            IJ.log("Number of detected ROIs in C2:"+str(nu_det_rois_c2))  ## log the detected cluster number
            ## loop through the detected ROIs and measure centroid & shape 
            IJ.log("Storing partical information...")
            for index in range(nu_det_rois_c2):
                roi_ind_c2 = roi_manager.getRoi(index)  # get roi index
                vgat.setRoi(roi_ind_c2) # set roi to thresholded gep image
                stats = vgat.getStatistics(Measurements.CENTROID) # measure centroid of the roi 
                ## extract the shape of the roi for reconstruction later
                x_dr = roi_ind_c2.getPolygon().xpoints 
                y_dr = roi_ind_c2.getPolygon().ypoints
                n_dr = roi_ind_c2.getPolygon().npoints
                
                det_C2[str(index)+"_C2"]={'centroid':[stats.xCentroid, stats.yCentroid],
                     'shape': {'xpoints': x_dr, 'ypoints': y_dr, 'npoints': n_dr}
                     }
            det_par[str(image_idx)]=det_C2    # add detected gephyrin info into the general dict
            det_C2={} # empty det_gep for the next image

            IJ.log("=== channel 02 processing done! ===")
            IJ.log("")
           
            roi_manager.runCommand("Reset") ## remove all rois for next image
            IJ.run("Close All") ## close all images
            # Get the displayed ResultsTable for channel 1
            rt_c1 = WindowManager.getFrame("Results_C1").getTextPanel().getResultsTable()
            # Get x and y values from the displayed ResultsTable for channel 1
            x_coords_c1 = rt_c1.getColumnAsDoubles(rt_c1.getColumnIndex("X"))
            y_coords_c1 = rt_c1.getColumnAsDoubles(rt_c1.getColumnIndex("Y"))
            # Get the displayed ResultsTable for channel 2
            rt_c2 = WindowManager.getFrame("Results_C2").getTextPanel().getResultsTable()

            # Get x and y values from the displayed ResultsTable for channel 2
            x_coords_c2 = rt_c2.getColumnAsDoubles(rt_c2.getColumnIndex("X"))
            y_coords_c2 = rt_c2.getColumnAsDoubles(rt_c2.getColumnIndex("Y"))

            #threshold = 5.0
            
            plot = Plot(f+"_co-local", "X Coordinate", "Y Coordinate")
            # Plot points from Channel 1 in green
            plot.setColor("green")  # Set color to green
            plot.addPoints(x_coords_c1, y_coords_c1, Plot.CIRCLE)
            # Plot points from Channel 2 in red
            plot.setColor("red")  # Set color to red
            plot.addPoints(x_coords_c2, y_coords_c2, Plot.CIRCLE)
            
            coloc_par=0 # set a variable for counting colocalised particles
            co_dis=[] # creat an empty list to store distance between co-localised particles 
            perc_coloc_c1=0
            perc_coloc_c2=0
            
            # Find the nearest neighbor for each point in Channel 1 from the points in Channel 2
            for i in range(len(x_coords_c1)):
                min_distance = float('inf')
                min_j = -1
                for j in range(len(x_coords_c2)):
                    distance = math.sqrt((x_coords_c1[i] - x_coords_c2[j])**2 + (y_coords_c1[i] - y_coords_c2[j])**2)
                    if distance < min_distance:
                        min_distance = distance
                        min_j = j
    
                if min_distance <= co_threshold:
                    co_dis.append(min_distance) # store distance between co-localised particles
                    coloc_par+=1 # count number of co-localised particles
                    plot.setColor("black")  # Set color to black for close points
                    plot.addPoints([x_coords_c1[i]], [y_coords_c1[i]], Plot.CIRCLE)
                    plot.addPoints([x_coords_c2[min_j]], [y_coords_c2[min_j]], Plot.CIRCLE)
            # Display the plot
            plot.show()
            
            perc_coloc_c1 = (float(coloc_par)/float(nu_det_rois_c1))*100 #calculate percentage of co-localised particles in channel 1 
            perc_coloc_c2 = (float(coloc_par)/float(nu_det_rois_c2))*100 #calculate percentage of co-localised particles in channel 2
            aver_distance = sum(co_dis)/len(co_dis) #calculate average distance between co-localised particles

            ## store co-localisation info of current image into a dictionary ##
            
            det_coloc[f]={'co_C1': perc_coloc_c1,
                          'co_C2': perc_coloc_c2,
                          'distance':  aver_distance,
                          'Nr_par_c1': nu_det_rois_c1,
                          'Nr_par_c2': nu_det_rois_c2,
                          'Nr_par_colocl': coloc_par
            }

            IJ.log("=== current image finished! ===")
            IJ.log("")
            ## creat a new results table to store necessary values
            #rt.reset() # first reset the previous rt from particle detection
    
    IJ.log("Generating final results...")        
    rt_out = ResultsTable()
    #rt_out.incrementCounter()
    ## generate final results table ##
    for ID in det_coloc.keys():
        rt_out.incrementCounter()
        rt_out.addValue("Image_ID", ID)
        rt_out.addValue("Nr par in Ch1", det_coloc[ID]['Nr_par_c1'])
        rt_out.addValue("Nr par in Ch2", det_coloc[ID]['Nr_par_c2'])
        rt_out.addValue("Nr colocal par", det_coloc[ID]['Nr_par_colocl'])
        rt_out.addValue("co-localisation % in Ch1", det_coloc[ID]['co_C1'])
        rt_out.addValue("co-localisation % in Ch2", det_coloc[ID]['co_C2'])
        rt_out.addValue("Ave_dis (pixels)", det_coloc[ID]['distance'])        
    
    rt_out.show("output")
    result_table_path_final = os.path.join(results_save_folder, "Final_results" + ".csv")
    rt_out.saveAs(result_table_path_final)
    IJ.log("")
    IJ.log("Done!")
            
## check if the function defination is working. 
## if so, start processing
    
if __name__ == '__main__':
    particle_detect_batch ()            
            



 



