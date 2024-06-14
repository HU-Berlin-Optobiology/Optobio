dir = getDirectory("Choose a image Directory");
dir_save = getDirectory("choose directory for saving MAX");

filelist = getFileList(dir);
for (i = 0; i < filelist.length; i++) {
    if (endsWith(filelist[i], ".lif")) {
        // Set options for opening .lif files
        run("Bio-Formats", "open=[" + dir + filelist[i] + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");

        run("Z Project...", "projection=[Max Intensity]");
        title = getTitle();

        path = dir_save + title + ".tif";
        saveAs("Tiff", path);

        run("Close All");
    }
    
    if (endsWith(filelist[i], ".nd")) {
        // Set options for opening .lif files
        run("Bio-Formats", "open=[" + dir + filelist[i] + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");

        run("Z Project...", "projection=[Max Intensity]");
        title = getTitle();

        path = dir_save + title + ".tif";
        saveAs("Tiff", path);

        run("Close All");
    }
}
