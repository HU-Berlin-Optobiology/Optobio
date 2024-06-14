dir = getDirectory("Choose a image Directory");
dir_save=getDirectory("choose directory for saving MAX");
//dir_save_AnkG=getDirectory("choose directory for saving AnkG");
//dir_save_TRIM46=getDirectory("choose directory for saving AnkG");

//File.makeDirectory(dir_save + "/C1");
//File.makeDirectory(dir_save + "/C2");
//File.makeDirectory(dir_save + "/C3");
filelist=getFileList(dir);
for (i = 0; i < lengthOf(filelist); i++) {
	//ROI = File.exists(filelist[i]+".roi");
    //ZIP = File.exists(filelist[i]+".zip");
	if (endsWith(filelist[i], ".lif")) {
		run("Bio-Formats", "open=[" + dir + filelist[i] + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		run("Z Project...", "projection=[Sum Slices]");
		title=getTitle();
		//titleShort=substring(title, 1, 57);
		//run("Split Channels");
        //title=getTitle();	
        //for (c = 1; c < 4; c++) {
        	//selectWindow("C"+c+"-"+title);
            path=dir_save+title+".tif";
            saveAs("tiff", path);
        }
        run("Close All");
        
     if (endsWith(filelist[i], ".nd")) {
		run("Bio-Formats", "open=[" + dir + filelist[i] + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		run("Z Project...", "projection=[Sum Slices]");
		title=getTitle();
		//titleShort=substring(title, 1, 57);
		//run("Split Channels");
        //title=getTitle();	
        //for (c = 1; c < 4; c++) {
        	//selectWindow("C"+c+"-"+title);
            path=dir_save+title+".tif";
            saveAs("tiff", path);
        }
        run("Close All");
        
     if (endsWith(filelist[i], ".nd2")) {
		run("Bio-Formats", "open=[" + dir + filelist[i] + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		run("Z Project...", "projection=[Sum Slices]");
		title=getTitle();
		//titleShort=substring(title, 1, 57);
		//run("Split Channels");
        //title=getTitle();	
        //for (c = 1; c < 4; c++) {
        	//selectWindow("C"+c+"-"+title);
            path=dir_save+title+".tif";
            saveAs("tiff", path);
        }
        run("Close All");
	
	}
    
