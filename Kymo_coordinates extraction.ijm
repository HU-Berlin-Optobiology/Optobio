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
	    NrOfROIs=roiManager("count");
	    
	    
		for (k = 0; k < NrOfROIs; k++) {
			roiManager("select",k);
			// plot profile
	        run("Clear Results");
 	 	    getSelectionCoordinates(xpoints, ypoints); 		    
  		    Table.create(title);
            Table.setColumn("X", xpoints);
            Table.setColumn("Y", ypoints);
            path = dir_save+title+i+"_"+k+".csv";
            saveAs("Results", path);
		}
	}
		
		roiManager("deselect");
        roiManager("delete");
        run("Close All");
}
