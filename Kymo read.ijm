dir = getDirectory("Choose a Directory");
dir_ROI=getDirectory("Choose ROI dir");
dir_save=getDirectory("choose directory")

filelist=getFileList(dir);
ROIlist=getFileList(dir_ROI);


for (i = 0; i < lengthOf(filelist); i++) {
	//ROI = File.exists(filelist[i]+".roi");
    //ZIP = File.exists(filelist[i]+".zip");
	if (endsWith(filelist[i], ".tif")) {
		open(dir + File.separator + filelist[i]);
		title=getTitle();
		roiManager("open", dir_ROI + File.separator + ROIlist[i]);
	    //run("Clear Results");
	    NrOfROIs=roiManager("count");
	    for (k = 0; k < NrOfROIs; k++) {
			roiManager("select",k);
			run("Clear Results");
	        run("KymoResliceWide ", "intensity=Maximum ignore");
	        title2=getTitle();
	        selectWindow(title2);
	        path = dir_save+title2+".tif";      
	        saveAs("Tiff", path);
	        
	}
      roiManager("deselect");
      roiManager("delete");
      run("Close All");
    
  }
}
	    
	    
	    
	    
	    