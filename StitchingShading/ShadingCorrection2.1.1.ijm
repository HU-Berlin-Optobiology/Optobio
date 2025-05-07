//Check whether BaSiC is installed
List.setCommands;
if (List.get("BaSiC ")!="") {// Plugin is installed
}
else {exit("Plugin BaSiC is not installed");}

LoadDir = getDir("Path from where to load images");
Save = getString("Where to save images", "Def");
SaveDir = LoadDir + "/" + Save;
if (File.exists(SaveDir)!= true){
	File.makeDirectory(SaveDir);
}
Imgs = getFileList(LoadDir);
ChannelsUnique = newArray();
FileNamesUnique = newArray();
BoolStitch = getBoolean("Would you like the shading corrected images to be stitched?");
if (BoolStitch) {
	//Init of parameters for stitching
	Columns = getNumber("From the path: "+LoadDir+"; how many columns do You have? ", 0);
	Rows = getNumber("From the path: "+LoadDir+"; how many rows do You have? ", 0);
	Overlap = getNumber("How big is the overlap between tiles? In %", 10);
	Grid = getNumber("How does the Grid Pattern look like? From 0 up to 3 --> 0 = row-by-row,  1 = column-by-column, 2 = snake by rows, 3 = snake by columns For more details look at Grid/Collection Stitching", 0);
	Order = getNumber("How does the Order of the Grid-Pattern look like? From 0 up to 3 --> 0 = Right & Down,  1 = Left & Down, 2 = Right & Up, 3 = Left & Up For more details look at Grid/Collection Stitching", 0);
	Grids = newArray("row-by-row", "column-by-column", "snake by rows", "snake by columns");
	Orders = newArray("Right & Down                ", "Left & Down", "Right & Up", "Left & Up");
	NrOfPlanes = 1;
}
//Getting information about data
for (i=0; i<Imgs.length; i++){
	file = Imgs[i];
	if (endsWith(file, ".nd") |endsWith(file, ".ome")) { //If there is an ND- or OME-File it gets moved away into a ND folder
		ndPath = LoadDir+"/ND";
		if (File.isDirectory(ndPath)==0) {
			File.makeDirectory(ndPath);
		}
		File.rename(LoadDir+"/"+file, ndPath+"/"+file);
	}
	else if (endsWith(file, "_s1.stk")) {
		FileNamesUnique = Array.concat(FileNamesUnique, file);
		filetype = ".stk";
		begin = 14;
		end = 10;
		base = 16;
		channelBegin = 10;
		channelEnd = 7;
		wl = substring(file, lengthOf(file)-channelBegin, lengthOf(file)-channelEnd);
		ChannelsUnique = Array.concat(ChannelsUnique,wl);
		//New as of 2.0
		if (substring(FileNamesUnique[0], lengthOf(FileNamesUnique[0])-begin, lengthOf(FileNamesUnique[0])-end) != "Conf") {
			if (substring(FileNamesUnique[0], lengthOf(FileNamesUnique[0])-begin+1, lengthOf(FileNamesUnique[0])-end) != "sdc") {
				exit("Couldn't find either <<Conf>> or <<sdc>> inside the name");
			}
			else Method = "sdc";
			base = 15;
		}
		else Method = "Conf";
	}
	else if (endsWith(file, "_s1.ome.tif")) {
		FileNamesUnique = Array.concat(FileNamesUnique, file);
		filetype = ".ome.tif";
		begin = 17;
		end = 14;
		base = 19;
		channelBegin = 14;
		channelEnd = 11;
		wl = substring(file, lengthOf(file)-channelBegin, lengthOf(file)-channelEnd);
		ChannelsUnique = Array.concat(ChannelsUnique,wl);
		//New as of 2.0
		if (substring(FileNamesUnique[0], lengthOf(FileNamesUnique[0])-begin, lengthOf(FileNamesUnique[0])-end) != "sdc") {
			if (substring(FileNamesUnique[0], lengthOf(FileNamesUnique[0])-begin-1, lengthOf(FileNamesUnique[0])-end) != "Conf") {
				exit("Couldn't find either <<Conf>> or <<sdc>> inside the name");
			}
			else Method = "Conf";
			base = 18;
		}
		else Method = "sdc";
	}
}
// If only one channel used, file names won't have w1 and so on
if (lengthOf(FileNamesUnique) == 1) n = 2;
else n = 0;
//Getting Base Name of Images based on used Method (everything before w1... if available)
if (Method == "sdc") {
	FileNameBase = substring(FileNamesUnique[0], 0, lengthOf(FileNamesUnique[0])-base+n);
}
else if (Method == "Conf") {
	FileNameBase = substring(FileNamesUnique[0], 0, lengthOf(FileNamesUnique[0])-base+n);
}
//Open images in ascending order -> max-proj 'em -> stack 'em -> shading correct 'em -> split 'em -> save 'em in correct order
for (a=0;a<ChannelsUnique.length;a++){
	wl = ChannelsUnique[a];
	for (s=1;s<Imgs.length+1;s++) {
		for (i=0; i<Imgs.length;i++){
			file = Imgs[i];
			name = wl+"_s"+s+filetype;
			if (endsWith(file, name)==true) {
				if (filetype == ".ome.tif") run("Bio-Formats Windowless Importer", "open="+LoadDir+"/"+file);
				else if (filetype == ".stk") open(LoadDir+"/"+file);
				rename(wl+"_s0"+s+filetype);
			}
		}
	}
	Wins = getList("image.titles");
	for (i=0; i<Wins.length; i++){
		selectImage(Wins[i]);
		getDimensions(width, height, channels, slices, frames);
		if (slices!=1 || channels!=1 || frames!=1) { //Avoid Errors when ecountering a scan slide without optical sections
			run("Z Project...", "projection=[Max Intensity]");}
		rename("0"+i);
	}
	run("Convert Images to Stack");
	rename(wl+".tif");
	run("BaSiC ", "processing_stack="+wl+".tif flat-field=None dark-field=None shading_estimation=[Estimate shading profiles] shading_model=[Estimate flat-field only (ignore dark-field)] setting_regularisationparametes=Automatic temporal_drift=Ignore correction_options=[Compute shading and correct images] lambda_flat=0.50 lambda_dark=0.50");
	close("Log");
	selectImage("Corrected:"+wl+".tif");
	close("\\Others");
	run("Stack to Images");
	Wins2 = getList("image.titles");
	for (i=0; i<Wins2.length;i++){
		selectImage(Wins2[i]);
		if (ChannelsUnique.length>1) {
			saveAs("Tiff", SaveDir+"/"+FileNameBase+"w"+(a+1)+Method+wl+"_s"+(i+1)+".tif");}
		else if (ChannelsUnique.length==1) {
			saveAs("Tiff", SaveDir+"/"+FileNameBase+Method+wl+"_s"+(i+1)+".tif");}
	}
	close("*");
}
if (BoolStitch) {
	filetype = ".tif";
	NrOfChannels = lengthOf(ChannelsUnique); // Amount of Entries in that Array
if (NrOfChannels == 1) {
	Ch1 = ChannelsUnique[0];
	Ch2 = "";
	Ch3 = "";
	Ch4 = "";
}
else if (NrOfChannels == 2) {
	Ch1 = ChannelsUnique[0];
	Ch2 = ChannelsUnique[1];
	Ch3 = "";
	Ch4 = "";
}
else if (NrOfChannels == 3) {
	Ch1 = ChannelsUnique[0];
	Ch2 = ChannelsUnique[1];
	Ch3 = ChannelsUnique[2];
	Ch4 = "";
}
else if (NrOfChannels == 4) {
	Ch1 = ChannelsUnique[0];
	Ch2 = ChannelsUnique[1];
	Ch3 = ChannelsUnique[2];
	Ch4 = ChannelsUnique[3];
}
//Checking how many planes there are in one stack
if (File.exists(SaveDir + "/" + FileNameBase + "w4"+Method+Ch1+"_s1"+filetype)){
	run("Bio-Formats Windowless Importer", "open=["+SaveDir + "/" + FileNameBase + "w4"+Method+Ch1+"_s1"+filetype+"]");}
else if (File.exists(SaveDir + "/" + FileNameBase + "w3"+Method+Ch1+"_s1"+filetype)){
	run("Bio-Formats Windowless Importer", "open=["+SaveDir + "/" + FileNameBase + "w3"+Method+Ch1+"_s1"+filetype+"]");}
else if (File.exists(SaveDir + "/" + FileNameBase + "w2"+Method+Ch1+"_s1"+filetype)){
	run("Bio-Formats Windowless Importer", "open=["+SaveDir + "/" + FileNameBase + "w2"+Method+Ch1+"_s1"+filetype+"]");}
else if (File.exists(SaveDir + "/" + FileNameBase + "w1"+Method+Ch1+"_s1"+filetype)){
	run("Bio-Formats Windowless Importer", "open=["+SaveDir + "/" + FileNameBase + "w1"+Method+Ch1+"_s1"+filetype+"]");}
else if (File.exists(SaveDir + "/" + FileNameBase + Method+Ch1+"_s1"+filetype)){
	run("Bio-Formats Windowless Importer", "open=["+SaveDir + "/" + FileNameBase + Method+Ch1+"_s1"+filetype+"]");}

getDimensions(width, height, channels, slices, frames);
close();

for (a = 0; a < NrOfChannels; a++) {
	if (a==0) {
		File.makeDirectory(SaveDir + "/Temp");
		File.makeDirectory(SaveDir + "/TempSmall");
		File.makeDirectory(SaveDir + "/"+Ch1);
		File.makeDirectory(SaveDir + "/"+Ch1+"Small");}
	if (a==1) {
		File.makeDirectory(SaveDir + "/"+Ch2);
		File.makeDirectory(SaveDir + "/"+Ch2+"Small");}
	if (a==2) {
		File.makeDirectory(SaveDir + "/"+Ch3);
		File.makeDirectory(SaveDir + "/"+Ch3+"Small");}
	if (a==3) {
		File.makeDirectory(SaveDir + "/"+Ch4);
		File.makeDirectory(SaveDir + "/"+Ch4+"Small");}
}
//Generating suffix
if (NrOfChannels==1) {
suffix1 = Method+Ch1+"_s";
subfolder1 = Ch1;}
if (NrOfChannels==2) {
suffix1 = "w1"+Method+Ch1+"_s";
subfolder1 = Ch1;
suffix2 = "w2"+Method+Ch2+"_s";
subfolder2 = Ch2;}
if (NrOfChannels==3) {
suffix1 = "w1"+Method+Ch1+"_s";
subfolder1 = Ch1;
suffix2 = "w2"+Method+Ch2+"_s";
subfolder2 = Ch2;
suffix3 = "w3"+Method+Ch3+"_s";
subfolder3 = Ch3;}
if (NrOfChannels==4) {
suffix1 = "w1"+Method+Ch1+"_s";
subfolder1 = Ch1;
suffix2 = "w2"+Method+Ch2+"_s";
subfolder2 = Ch2;
suffix3 = "w3"+Method+Ch3+"_s";
subfolder3 = Ch3;
suffix4 = "w4"+Method+Ch4+"_s";
subfolder4 = Ch4;}
//Run stitching on two separate channels and store them in separate folders; stitching order depends on used microscope
for (b = 0; b < NrOfChannels; b++) {
	if (b==0) {
	Params="type=[Grid: "+ Grids[Grid]+"] order=["+Orders[Order]+"] grid_size_x=" + Columns + " grid_size_y=" + Rows + " tile_overlap="+Overlap+" first_file_index_i=1 directory=[" + SaveDir + "] file_names=[" + FileNameBase + suffix1 + "{i}" + filetype + "] output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 computation_parameters=[Save memory (but be slower)] image_output=[Write to disk] output_directory=[" + SaveDir + "/"+subfolder1+"]";
	run("Grid/Collection stitching", Params);}
	if (b==1) {
	Params2="type=[Grid: "+ Grids[Grid]+"] order=["+Orders[Order]+"] grid_size_x=" + Columns + " grid_size_y=" + Rows + " tile_overlap="+Overlap+" first_file_index_i=1 directory=[" + SaveDir + "] file_names=[" + FileNameBase + suffix2 + "{i}" + filetype + "] + output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 computation_parameters=[Save memory (but be slower)] image_output=[Write to disk] output_directory=[" + SaveDir + "/"+subfolder2+"]";
	run("Grid/Collection stitching", Params2);}
	if (b==2) {
	Params3="type=[Grid: "+ Grids[Grid]+"] order=["+Orders[Order]+"] grid_size_x=" + Columns + " grid_size_y=" + Rows + " tile_overlap="+Overlap+" first_file_index_i=1 directory=[" + SaveDir + "] file_names=[" + FileNameBase + suffix3 + "{i}" + filetype + "] output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 computation_parameters=[Save memory (but be slower)] image_output=[Write to disk] output_directory=[" + SaveDir + "/"+subfolder3+"]";
	run("Grid/Collection stitching", Params3);}
	if (b==3) {
	Params4="type=[Grid: "+ Grids[Grid]+"] order=["+Orders[Order]+"] grid_size_x=" + Columns + " grid_size_y=" + Rows + " tile_overlap="+Overlap+" first_file_index_i=1 directory=[" + SaveDir + "] file_names=[" + FileNameBase + suffix4 + "{i}" + filetype + "] output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 computation_parameters=[Save memory (but be slower)] image_output=[Write to disk] output_directory=[" + SaveDir + "/"+subfolder4+"]";
	run("Grid/Collection stitching", Params4);}}


//When there are more than 9 planes, plane number 1 becomes 01 so I'm correcting for that case.
if (NrOfPlanes>9 && NrOfPlanes<100)
{for  (i = 1; i < 10; i++){
	if (NrOfChannels==1) {
    File.rename(SaveDir + "/"+Ch1+"/img_t1_z" + "0" + i + "_c1", SaveDir + "/"+Ch1+"/img_t1_z" + i + "_c1");}
    if (NrOfChannels==2) {
    File.rename(SaveDir + "/"+Ch1+"/img_t1_z" + "0" + i + "_c1", SaveDir + "/"+Ch1+"/img_t1_z" + i + "_c1");
    File.rename(SaveDir + "/"+Ch2+"/img_t1_z" + "0" + i + "_c1", SaveDir + "/"+Ch2+"/img_t1_z" + i + "_c1");}
    if (NrOfChannels==3) {
    File.rename(SaveDir + "/"+Ch1+"/img_t1_z" + "0" + i + "_c1", SaveDir + "/"+Ch1+"/img_t1_z" + i + "_c1");
    File.rename(SaveDir + "/"+Ch2+"/img_t1_z" + "0" + i + "_c1", SaveDir + "/"+Ch2+"/img_t1_z" + i + "_c1");
    File.rename(SaveDir + "/"+Ch3+"/img_t1_z" + "0" + i + "_c1", SaveDir + "/"+Ch3+"/img_t1_z" + i + "_c1");}
    if (NrOfChannels==4) {
    File.rename(SaveDir + "/"+Ch1+"/img_t1_z" + "0" + i + "_c1", SaveDir + "/"+Ch1+"/img_t1_z" + i + "_c1");
    File.rename(SaveDir + "/"+Ch2+"/img_t1_z" + "0" + i + "_c1", SaveDir + "/"+Ch2+"/img_t1_z" + i + "_c1");
    File.rename(SaveDir + "/"+Ch3+"/img_t1_z" + "0" + i + "_c1", SaveDir + "/"+Ch3+"/img_t1_z" + i + "_c1");
    File.rename(SaveDir + "/"+Ch4+"/img_t1_z" + "0" + i + "_c1", SaveDir + "/"+Ch4+"/img_t1_z" + i + "_c1");}
    }
}
// Yeah, and if more than 99 planes, all will be 001 and 010, so need to correct for that
else if (NrOfPlanes>99){
for  (i = 1; i < 10; i++){
    if (NrOfChannels==1) {
    File.rename(SaveDir + "/"+Ch1+"/img_t1_z" + "00" + i + "_c1", SaveDir + "/"+Ch1+"/img_t1_z" + i + "_c1");}
    if (NrOfChannels==2) {
    File.rename(SaveDir + "/"+Ch1+"/img_t1_z" + "00" + i + "_c1", SaveDir + "/"+Ch1+"/img_t1_z" + i + "_c1");
    File.rename(SaveDir + "/"+Ch2+"/img_t1_z" + "00" + i + "_c1", SaveDir + "/"+Ch2+"/img_t1_z" + i + "_c1");}
    if (NrOfChannels==3) {
    File.rename(SaveDir + "/"+Ch1+"/img_t1_z" + "00" + i + "_c1", SaveDir + "/"+Ch1+"/img_t1_z" + i + "_c1");
    File.rename(SaveDir + "/"+Ch2+"/img_t1_z" + "00" + i + "_c1", SaveDir + "/"+Ch2+"/img_t1_z" + i + "_c1");
    File.rename(SaveDir + "/"+Ch3+"/img_t1_z" + "00" + i + "_c1", SaveDir + "/"+Ch3+"/img_t1_z" + i + "_c1");}
    if (NrOfChannels==4) {
    File.rename(SaveDir + "/"+Ch1+"/img_t1_z" + "00" + i + "_c1", SaveDir + "/"+Ch1+"/img_t1_z" + i + "_c1");
    File.rename(SaveDir + "/"+Ch2+"/img_t1_z" + "00" + i + "_c1", SaveDir + "/"+Ch2+"/img_t1_z" + i + "_c1");
    File.rename(SaveDir + "/"+Ch3+"/img_t1_z" + "00" + i + "_c1", SaveDir + "/"+Ch3+"/img_t1_z" + i + "_c1");
    File.rename(SaveDir + "/"+Ch4+"/img_t1_z" + "00" + i + "_c1", SaveDir + "/"+Ch4+"/img_t1_z" + i + "_c1");}
    }
for (i=10; i<100; i++){
	if (NrOfChannels==1) {
    File.rename(SaveDir + "/"+Ch1+"/img_t1_z" + "0" + i + "_c1", SaveDir + "/"+Ch1+"/img_t1_z" + i + "_c1");}
    if (NrOfChannels==2) {
    File.rename(SaveDir + "/"+Ch1+"/img_t1_z" + "0" + i + "_c1", SaveDir + "/"+Ch1+"/img_t1_z" + i + "_c1");
    File.rename(SaveDir + "/"+Ch2+"/img_t1_z" + "0" + i + "_c1", SaveDir + "/"+Ch2+"/img_t1_z" + i + "_c1");}
    if (NrOfChannels==3) {
    File.rename(SaveDir + "/"+Ch1+"/img_t1_z" + "0" + i + "_c1", SaveDir + "/"+Ch1+"/img_t1_z" + i + "_c1");
    File.rename(SaveDir + "/"+Ch2+"/img_t1_z" + "0" + i + "_c1", SaveDir + "/"+Ch2+"/img_t1_z" + i + "_c1");
    File.rename(SaveDir + "/"+Ch3+"/img_t1_z" + "0" + i + "_c1", SaveDir + "/"+Ch3+"/img_t1_z" + i + "_c1");}
    if (NrOfChannels==4) {
    File.rename(SaveDir + "/"+Ch1+"/img_t1_z" + "0" + i + "_c1", SaveDir + "/"+Ch1+"/img_t1_z" + i + "_c1");
    File.rename(SaveDir + "/"+Ch2+"/img_t1_z" + "0" + i + "_c1", SaveDir + "/"+Ch2+"/img_t1_z" + i + "_c1");
    File.rename(SaveDir + "/"+Ch3+"/img_t1_z" + "0" + i + "_c1", SaveDir + "/"+Ch3+"/img_t1_z" + i + "_c1");
    File.rename(SaveDir + "/"+Ch4+"/img_t1_z" + "0" + i + "_c1", SaveDir + "/"+Ch4+"/img_t1_z" + i + "_c1");}
	}
}

//Load all planes sequentially and create smaller versions from them.

for (i = 1; i < NrOfPlanes+1; i++) {
	if (File.exists(SaveDir + "/"+Ch1+"/img_t1_z" + i + "_c1")) {
    open(SaveDir + "/"+Ch1+"/img_t1_z" + i + "_c1");
    saveAs("Tiff", SaveDir + "/"+Ch1+"/" + i + ".tif");
    getDimensions(width, height, channels, slices, frames);
    NewWidth=round(width/10);
    NewHeight=round(height/10);
	run("Scale...", "x=0.1 y=0.1 width=" + NewWidth + " height=" + NewHeight + " interpolation=Bilinear average create");
	saveAs("Tiff", SaveDir + "/"+Ch1+"Small/" + i + ".tif");
	close("*");
	File.delete(SaveDir + "/"+Ch1+"/img_t1_z" + i + "_c1");}

	if (File.exists(SaveDir + "/"+Ch2+"/img_t1_z" + i + "_c1")) {
	open(SaveDir + "/"+Ch2+"/img_t1_z" + i + "_c1");
	saveAs("Tiff", SaveDir + "/"+Ch2+"/" + i + ".tif");
    getDimensions(width, height, channels, slices, frames);
    NewWidth=round(width/10);
    NewHeight=round(height/10);
	run("Scale...", "x=0.1 y=0.1 width=" + NewWidth + " height=" + NewHeight + " interpolation=Bilinear average create");
	saveAs("Tiff", SaveDir + "/"+Ch2+"Small/" + i + ".tif");
	close("*");
	File.delete(SaveDir + "/"+Ch2+"/img_t1_z" + i + "_c1");}

	if (File.exists(SaveDir + "/"+Ch3+"/img_t1_z" + i + "_c1")) {
	open(SaveDir + "/"+Ch3+"/img_t1_z" + i + "_c1");
	saveAs("Tiff", SaveDir + "/"+Ch3+"/" + i + ".tif");
    getDimensions(width, height, channels, slices, frames);
    NewWidth=round(width/10);
    NewHeight=round(height/10);
	run("Scale...", "x=0.1 y=0.1 width=" + NewWidth + " height=" + NewHeight + " interpolation=Bilinear average create");
	saveAs("Tiff", SaveDir + "/"+Ch3+"Small/" + i + ".tif");
	close("*");
	File.delete(SaveDir + "/"+Ch3+"/img_t1_z" + i + "_c1");}

	if (File.exists(SaveDir + "/"+Ch4+"/img_t1_z" + i + "_c1")) {
	open(SaveDir + "/"+Ch4+"/img_t1_z" + i + "_c1");
	saveAs("Tiff", SaveDir + "/"+Ch4+"/" + i + ".tif");
    getDimensions(width, height, channels, slices, frames);
    NewWidth=round(width/10);
    NewHeight=round(height/10);
	run("Scale...", "x=0.1 y=0.1 width=" + NewWidth + " height=" + NewHeight + " interpolation=Bilinear average create");
	saveAs("Tiff", SaveDir + "/"+Ch4+"Small/" + i + ".tif");
	close("*");
	File.delete(SaveDir + "/"+Ch4+"/img_t1_z" + i + "_c1");}
}


//Interleave the small channels into a separate folder (necessary, because Stack-to-Hyperstack for virtual files ONLY allows the xyczt(default) order option)
for (i = 1; i < NrOfPlanes+1; i++){
    Index1=(i-1)*NrOfChannels+1;
    if (File.exists(SaveDir + "/"+Ch1+"Small")) {
	File.rename(SaveDir + "/"+Ch1+"Small/" + i + ".tif", SaveDir + "/TempSmall/" + Index1 + ".tif");}
	Index2=(i-1)*NrOfChannels+2;
	if (File.exists(SaveDir + "/"+Ch2+"Small")) {
	File.rename(SaveDir + "/"+Ch2+"Small/" + i + ".tif", SaveDir + "/TempSmall/" + Index2 + ".tif");}
	Index3=(i-1)*NrOfChannels+3;
	if (File.exists(SaveDir + "/"+Ch3+"Small")) {
	File.rename(SaveDir + "/"+Ch3+"Small/" + i + ".tif", SaveDir + "/TempSmall/" + Index3 + ".tif");}
	Index4=(i-1)*NrOfChannels+4;
	if (File.exists(SaveDir + "/"+Ch4+"Small")) {
	File.rename(SaveDir + "/"+Ch4+"Small/" + i + ".tif", SaveDir + "/TempSmall/" + Index4 + ".tif");}
}
if (File.exists(SaveDir + "/"+Ch1+"Small")) {
	File.delete(SaveDir + "/"+Ch1+"Small");}
if (File.exists(SaveDir + "/"+Ch2+"Small")) {
	File.delete(SaveDir + "/"+Ch2+"Small");}
if (File.exists(SaveDir + "/"+Ch3+"Small")) {
	File.delete(SaveDir + "/"+Ch3+"Small");}
if (File.exists(SaveDir + "/"+Ch4+"Small")) {
	File.delete(SaveDir + "/"+Ch4+"Small");}

run("Image Sequence...", "open=[" + SaveDir + "/TempSmall/1.tif] number=" + NrOfPlanes*NrOfChannels + " file=tif sort use");
if (NrOfChannels>1){
	run("Stack to Hyperstack...", "order=xyczt(default) channels=" + NrOfChannels + " slices=" + NrOfPlanes + " frames=1 display=Color");}
saveAs("Tiff", SaveDir + "/"+NrOfChannels+"ChannelsSmall.tif");
close();

for (i = 1; i < NrOfPlanes*NrOfChannels+1; i++){
    File.delete(SaveDir + "/TempSmall/" + i + ".tif");
}
File.delete(SaveDir + "/TempSmall");


//Interleave the big channels into a separate folder (necessary, because Stack-to-Hyperstack for virtual files ONLY allows the xyczt(default) order option)
for (i = 1; i < NrOfPlanes+1; i++){
    Index1=(i-1)*NrOfChannels+1;
    if (File.exists(SaveDir + "/"+Ch1)) {
	File.rename(SaveDir + "/"+Ch1+"/" + i + ".tif", SaveDir + "/Temp/" + Index1 + ".tif");}
	Index2=(i-1)*NrOfChannels+2;
	if (File.exists(SaveDir + "/"+Ch2)) {
	File.rename(SaveDir + "/"+Ch2+"/" + i + ".tif", SaveDir + "/Temp/" + Index2 + ".tif");}
	Index3=(i-1)*NrOfChannels+3;
	if (File.exists(SaveDir + "/"+Ch3)) {
	File.rename(SaveDir + "/"+Ch3+"/" + i + ".tif", SaveDir + "/Temp/" + Index3 + ".tif");}
	Index4=(i-1)*NrOfChannels+4;
	if (File.exists(SaveDir + "/"+Ch4)) {
	File.rename(SaveDir + "/"+Ch4+"/" + i + ".tif", SaveDir + "/Temp/" + Index4 + ".tif");}
}
if (File.exists(SaveDir + "/"+Ch1)) {
	File.delete(SaveDir + "/"+Ch1);}
if (File.exists(SaveDir + "/"+Ch2)) {
	File.delete(SaveDir + "/"+Ch2);}
if (File.exists(SaveDir + "/"+Ch3)) {
	File.delete(SaveDir + "/"+Ch3);}
if (File.exists(SaveDir + "/"+Ch4)) {
	File.delete(SaveDir + "/"+Ch4);}

run("Image Sequence...", "open=[" + SaveDir + "/Temp/1.tif] number=" + NrOfPlanes*NrOfChannels + " file=tif sort use");
if (NrOfChannels>1) {
	run("Stack to Hyperstack...", "order=xyczt(default) channels=" + NrOfChannels + " slices=" + NrOfPlanes + " frames=1 display=Color");}
saveAs("Tiff", SaveDir + "/"+NrOfChannels+"Channels.tif");
close();	

for (i = 1; i < NrOfPlanes*NrOfChannels+1; i++){
    File.delete(SaveDir + "/Temp/" + i + ".tif");
}
File.delete(SaveDir + "/Temp");
close("Log");



//Show when Stitching has been completed (Copy Pasta from the Internet)
macro "Get Time" {
     MonthNames = newArray("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
     DayNames = newArray("Sun", "Mon","Tue","Wed","Thu","Fri","Sat");
     getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
     TimeString ="Date: "+DayNames[dayOfWeek]+" ";
     if (dayOfMonth<10) {TimeString = TimeString+"0";}
     TimeString = TimeString+dayOfMonth+"-"+MonthNames[month]+"-"+year+"\nTime: ";
     if (hour<10) {TimeString = TimeString+"0";}
     TimeString = TimeString+hour+":";
     if (minute<10) {TimeString = TimeString+"0";}
     TimeString = TimeString+minute+":";
     if (second<10) {TimeString = TimeString+"0";}
     TimeString = TimeString+second;
     showMessage(TimeString);
  }
}
