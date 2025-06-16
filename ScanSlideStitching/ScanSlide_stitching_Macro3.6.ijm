//The backbone of this Macro was established by Jasper Grindl (or so) in teamwork with Nathalie Hertrich
//Afterwards it has been updated and improved by Erich Weisheim
//As of 3.2: ND file gets moved to a subfolder on auto in case user forgets to remove it.
//As of 3.3: No writing needs to be done anymore; script will ask user about everything required (Folders, dimensions, Order of stitching and Max-Projection); Added Overlap parameter
////////////////////////////////////////
// End of User Input
////////////////////////////////////////
Adding = true;
Folders = newArray();
ColumnsAll = newArray();
RowsAll = newArray();
j = 0;
while (Adding){
	if (lengthOf(Folders)>0) {
			File.setDefaultDir(Folders[j-1]);
		}
	folder = getDir("Choose Folder containing Scan Slide images.");
	Folders = Array.concat(Folders,folder); //do while loop didn't work, that does the trick
	Adding = getBoolean("Do you need to add more Folders?");
	j = j+1;
}
for (i = 0; i < lengthOf(Folders); i++) {
	if (File.isDirectory(Folders[i]) != true) {
			waitForUser("Provided path: <<"+Folders[i]+">> is not a real path. Please cross-check.");
			Folders[i] = getDir("Please choose the correct Folder.");
	}
	col = getNumber("From the path: "+Folders[i]+"; how many columns do You have? ", 0);
	row = getNumber("From the path: "+Folders[i]+"; how many rows do You have? ", 0);
	ColumnsAll = Array.concat(ColumnsAll, col);
	RowsAll = Array.concat(RowsAll, row);
}
Overlap = getNumber("How big is the overlap between tiles? In %", 10);
Grid = getNumber("How does the Grid Pattern look like? From 0 up to 3 --> 0 = row-by-row,  1 = column-by-column, 2 = snake by rows, 3 = snake by columns For more details look at Grid/Collection Stitching", 0);
Order = getNumber("How does the Order of the Grid-Pattern look like? From 0 up to 3 --> 0 = Right & Down,  1 = Left & Down, 2 = Right & Up, 3 = Left & Up For more details look at Grid/Collection Stitching", 0);

Grids = newArray("row-by-row", "column-by-column", "snake by rows", "snake by columns");
Orders = newArray("Right & Down                ", "Left & Down", "Right & Up", "Left & Up");
Max_Projection = getBoolean("Do you want to apply a maximum z-projection at the end to generated images?"); // Max z-projection to stitched images y/n
for (l = 0; l < lengthOf(Folders); l++) {
	
Folder=Folders[l];
FileNamesOrig = getFileList(Folder);
// Get all files that end with "_s1.stk"
FileNamesUnique = newArray();
ChannelsUnique = newArray();
for (i = 0; i < lengthOf(FileNamesOrig); i++) {
	if (endsWith(FileNamesOrig[i], ".nd") | endsWith(FileNamesOrig[i], ".ome")) { // If there is an ND- or OME-File it gets moved away into a ND folder
		ndPath = Folder+"/ND";
		if (File.isDirectory(ndPath)==0) {
			File.makeDirectory(ndPath);
		}
		File.rename(Folder+"/"+FileNamesOrig[i], ndPath+"/"+FileNamesOrig[i]);
	}
	if (endsWith(FileNamesOrig[i], "_s1.stk") | endsWith(FileNamesOrig[i], "_s1.tif")) {
		FileNamesUnique = Array.concat(FileNamesUnique, FileNamesOrig[i]);
		if (endsWith(FileNamesOrig[i], "_s1.stk")) filetype = ".stk";
		else if (endsWith(FileNamesOrig[i], "_s1.tif")) filetype = ".tif";
		begin = 14;
		end = 10;
		base = 16;
		channelBegin = 10;
		channelEnd = 7;
		//New as of 3.4.5 //Figuring out the method of aquisition (Conf or sdc)
		if (substring(FileNamesUnique[0], lengthOf(FileNamesUnique[0])-begin, lengthOf(FileNamesUnique[0])-end) != "Conf") {
			if (substring(FileNamesUnique[0], lengthOf(FileNamesUnique[0])-begin+1, lengthOf(FileNamesUnique[0])-end) != "sdc") {
				exit("Couldn't find either <<Conf>> or <<sdc>> inside the name");
			}
			else { 
				Method = "sdc";
				base = 15;
			}
		}
		else Method = "Conf";
		
	}
	else if (endsWith(FileNamesOrig[i], "_s1.ome.tif")) {
		FileNamesUnique = Array.concat(FileNamesUnique, FileNamesOrig[i]);
		filetype = ".ome.tif";
		begin = 17;
		end = 14;
		base = 19;
		channelBegin = 14;
		channelEnd = 11;
		//New as of 3.4.5 //Figuring out the method of aquisition (Conf or sdc)
		if (substring(FileNamesUnique[0], lengthOf(FileNamesUnique[0])-begin, lengthOf(FileNamesUnique[0])-end) != "sdc") {
			if (substring(FileNamesUnique[0], lengthOf(FileNamesUnique[0])-begin-1, lengthOf(FileNamesUnique[0])-end) != "Conf") {
				exit("Couldn't find either <<Conf>> or <<sdc>> inside the name");
			}
			else { 
				Method = "Conf";
				base = 18;
			}
		}
		else Method = "sdc";
	}
}
// If only one channel used, file names won't have w1 and so on
if (lengthOf(FileNamesUnique) == 1) {
	n = 2;
}
else {
	n = 0;
}
//Getting Base Name of Images based on used Method (everything before w1... if available)
FileNameBase = substring(FileNamesUnique[0], 0, lengthOf(FileNamesUnique[0])-base+n);

for (i = 0; i < lengthOf(FileNamesUnique); i++) {
	channel = substring(FileNamesUnique[i], lengthOf(FileNamesUnique[i])-channelBegin, lengthOf(FileNamesUnique[i])-channelEnd);
	ChannelsUnique = Array.concat(ChannelsUnique, channel);
}
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
if (filetype == ".ome.tif") {
	if (File.exists(Folder + "/" + FileNameBase + "w4"+Method+Ch1+"_s1"+filetype)){
		run("Bio-Formats Windowless Importer", "open=["+Folder + FileNameBase + "w4"+Method+Ch1+"_s1"+filetype+"]");}
	else if (File.exists(Folder + "/" + FileNameBase + "w3"+Method+Ch1+"_s1"+filetype)){
		run("Bio-Formats Windowless Importer", "open=["+Folder + FileNameBase + "w3"+Method+Ch1+"_s1"+filetype+"]");}
	else if (File.exists(Folder + "/" + FileNameBase + "w2"+Method+Ch1+"_s1"+filetype)){
		run("Bio-Formats Windowless Importer", "open=["+Folder + FileNameBase + "w2"+Method+Ch1+"_s1"+filetype+"]");}
	else if (File.exists(Folder + "/" + FileNameBase + "w1"+Method+Ch1+"_s1"+filetype)){
		run("Bio-Formats Windowless Importer", "open=["+Folder + FileNameBase + "w1"+Method+Ch1+"_s1"+filetype+"]");}
	else if (File.exists(Folder + "/" + FileNameBase + Method+Ch1+"_s1"+filetype)){
		run("Bio-Formats Windowless Importer", "open=["+Folder + FileNameBase + Method+Ch1+"_s1"+filetype+"]");}
}
if (filetype == ".stk") {
	if (File.exists(Folder + "/" + FileNameBase + "w4"+Method+Ch1+"_s1"+filetype)){
		open(Folder + "/" + FileNameBase + "w4"+Method+Ch1+"_s1"+filetype);}
	else if (File.exists(Folder + FileNameBase + "w3"+Method+Ch1+"_s1"+filetype)){
		open(Folder + "/" + FileNameBase + "w3"+Method+Ch1+"_s1"+filetype);}
	else if (File.exists(Folder + FileNameBase + "w2"+Method+Ch1+"_s1"+filetype)){
		open(Folder + "/" + FileNameBase + "w2"+Method+Ch1+"_s1"+filetype);}
	else if (File.exists(Folder + FileNameBase + "w1"+Method+Ch1+"_s1"+filetype)){
		open(Folder + "/" + FileNameBase + "w1"+Method+Ch1+"_s1"+filetype);}
	else if (File.exists(Folder + FileNameBase + Method+Ch1+"_s1"+filetype)){
		open(Folder + "/" + FileNameBase +Method+Ch1+"_s1"+filetype);}
}
if (filetype == ".tif") {
	if (File.exists(Folder + "/" + FileNameBase + "w4"+Method+Ch1+"_s1"+filetype)){
		run("Bio-Formats Windowless Importer", "open=["+Folder + "/" + FileNameBase + "w4"+Method+Ch1+"_s1"+filetype+"]");}
	else if (File.exists(Folder + FileNameBase + "w3"+Method+Ch1+"_s1"+filetype)){
		run("Bio-Formats Windowless Importer", "open=["+Folder + "/" + FileNameBase + "w3"+Method+Ch1+"_s1"+filetype+"]");}
	else if (File.exists(Folder + FileNameBase + "w2"+Method+Ch1+"_s1"+filetype)){
		run("Bio-Formats Windowless Importer", "open=["+Folder + "/" + FileNameBase + "w2"+Method+Ch1+"_s1"+filetype+"]");}
	else if (File.exists(Folder + FileNameBase + "w1"+Method+Ch1+"_s1"+filetype)){
		run("Bio-Formats Windowless Importer", "open=["+Folder + "/" + FileNameBase + "w1"+Method+Ch1+"_s1"+filetype+"]");}
	else if (File.exists(Folder + FileNameBase + Method+Ch1+"_s1"+filetype)){
		run("Bio-Formats Windowless Importer", "open=["+Folder + "/" + FileNameBase + Method+Ch1+"_s1"+filetype+"]");}
}

getDimensions(width, height, channels, slices, frames);
close();
//New as of 3.4.4 //If for some reason the metadata has saved the z-planes as timepoints or something fails completely (else-statement)
if (slices<frames){
	NrOfPlanes=frames;
}
else if (slices>=frames){
	NrOfPlanes=slices;
}
else {
	print("Something is wrong with the number of Z-Planes. Abort Everything");
	exit;
}
Columns=ColumnsAll[l];
Rows=RowsAll[l];

for (a = 0; a < NrOfChannels; a++) {
	if (a==0) {
		File.makeDirectory(Folder + "/Temp");
		File.makeDirectory(Folder + "/TempSmall");
		File.makeDirectory(Folder + "/"+Ch1);
		File.makeDirectory(Folder + "/"+Ch1+"Small");}
	if (a==1) {
		File.makeDirectory(Folder + "/"+Ch2);
		File.makeDirectory(Folder + "/"+Ch2+"Small");}
	if (a==2) {
		File.makeDirectory(Folder + "/"+Ch3);
		File.makeDirectory(Folder + "/"+Ch3+"Small");}
	if (a==3) {
		File.makeDirectory(Folder + "/"+Ch4);
		File.makeDirectory(Folder + "/"+Ch4+"Small");}
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
	Params="type=[Grid: "+ Grids[Grid]+"] order=["+Orders[Order]+"] grid_size_x=" + Columns + " grid_size_y=" + Rows + " tile_overlap="+Overlap+" first_file_index_i=1 directory=[" + Folder + "] file_names=[" + FileNameBase + suffix1 + "{i}" + filetype + "] output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 computation_parameters=[Save memory (but be slower)] image_output=[Write to disk] output_directory=[" + Folder + "/"+subfolder1+"]";
	run("Grid/Collection stitching", Params);}
	if (b==1) {
	Params2="type=[Grid: "+ Grids[Grid]+"] order=["+Orders[Order]+"] grid_size_x=" + Columns + " grid_size_y=" + Rows + " tile_overlap="+Overlap+" first_file_index_i=1 directory=[" + Folder + "] file_names=[" + FileNameBase + suffix2 + "{i}" + filetype + "] + output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 computation_parameters=[Save memory (but be slower)] image_output=[Write to disk] output_directory=[" + Folder + "/"+subfolder2+"]";
	run("Grid/Collection stitching", Params2);}
	if (b==2) {
	Params3="type=[Grid: "+ Grids[Grid]+"] order=["+Orders[Order]+"] grid_size_x=" + Columns + " grid_size_y=" + Rows + " tile_overlap="+Overlap+" first_file_index_i=1 directory=[" + Folder + "] file_names=[" + FileNameBase + suffix3 + "{i}" + filetype + "] output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 computation_parameters=[Save memory (but be slower)] image_output=[Write to disk] output_directory=[" + Folder + "/"+subfolder3+"]";
	run("Grid/Collection stitching", Params3);}
	if (b==3) {
	Params4="type=[Grid: "+ Grids[Grid]+"] order=["+Orders[Order]+"] grid_size_x=" + Columns + " grid_size_y=" + Rows + " tile_overlap="+Overlap+" first_file_index_i=1 directory=[" + Folder + "] file_names=[" + FileNameBase + suffix4 + "{i}" + filetype + "] output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 computation_parameters=[Save memory (but be slower)] image_output=[Write to disk] output_directory=[" + Folder + "/"+subfolder4+"]";
	run("Grid/Collection stitching", Params4);}}


//When there are more than 9 planes, plane number 1 becomes 01 so I'm correcting for that case.
if (NrOfPlanes>9 && NrOfPlanes<100)
{for  (i = 1; i < 10; i++){
	if (NrOfChannels==1) {
    File.rename(Folder + "/"+Ch1+"/img_t1_z" + "0" + i + "_c1", Folder + "/"+Ch1+"/img_t1_z" + i + "_c1");}
    if (NrOfChannels==2) {
    File.rename(Folder + "/"+Ch1+"/img_t1_z" + "0" + i + "_c1", Folder + "/"+Ch1+"/img_t1_z" + i + "_c1");
    File.rename(Folder + "/"+Ch2+"/img_t1_z" + "0" + i + "_c1", Folder + "/"+Ch2+"/img_t1_z" + i + "_c1");}
    if (NrOfChannels==3) {
    File.rename(Folder + "/"+Ch1+"/img_t1_z" + "0" + i + "_c1", Folder + "/"+Ch1+"/img_t1_z" + i + "_c1");
    File.rename(Folder + "/"+Ch2+"/img_t1_z" + "0" + i + "_c1", Folder + "/"+Ch2+"/img_t1_z" + i + "_c1");
    File.rename(Folder + "/"+Ch3+"/img_t1_z" + "0" + i + "_c1", Folder + "/"+Ch3+"/img_t1_z" + i + "_c1");}
    if (NrOfChannels==4) {
    File.rename(Folder + "/"+Ch1+"/img_t1_z" + "0" + i + "_c1", Folder + "/"+Ch1+"/img_t1_z" + i + "_c1");
    File.rename(Folder + "/"+Ch2+"/img_t1_z" + "0" + i + "_c1", Folder + "/"+Ch2+"/img_t1_z" + i + "_c1");
    File.rename(Folder + "/"+Ch3+"/img_t1_z" + "0" + i + "_c1", Folder + "/"+Ch3+"/img_t1_z" + i + "_c1");
    File.rename(Folder + "/"+Ch4+"/img_t1_z" + "0" + i + "_c1", Folder + "/"+Ch4+"/img_t1_z" + i + "_c1");}
    }
}
// Yeah, and if more than 99 planes, all will be 001 and 010, so need to correct for that
else if (NrOfPlanes>99){
for  (i = 1; i < 10; i++){
    if (NrOfChannels==1) {
    File.rename(Folder + "/"+Ch1+"/img_t1_z" + "00" + i + "_c1", Folder + "/"+Ch1+"/img_t1_z" + i + "_c1");}
    if (NrOfChannels==2) {
    File.rename(Folder + "/"+Ch1+"/img_t1_z" + "00" + i + "_c1", Folder + "/"+Ch1+"/img_t1_z" + i + "_c1");
    File.rename(Folder + "/"+Ch2+"/img_t1_z" + "00" + i + "_c1", Folder + "/"+Ch2+"/img_t1_z" + i + "_c1");}
    if (NrOfChannels==3) {
    File.rename(Folder + "/"+Ch1+"/img_t1_z" + "00" + i + "_c1", Folder + "/"+Ch1+"/img_t1_z" + i + "_c1");
    File.rename(Folder + "/"+Ch2+"/img_t1_z" + "00" + i + "_c1", Folder + "/"+Ch2+"/img_t1_z" + i + "_c1");
    File.rename(Folder + "/"+Ch3+"/img_t1_z" + "00" + i + "_c1", Folder + "/"+Ch3+"/img_t1_z" + i + "_c1");}
    if (NrOfChannels==4) {
    File.rename(Folder + "/"+Ch1+"/img_t1_z" + "00" + i + "_c1", Folder + "/"+Ch1+"/img_t1_z" + i + "_c1");
    File.rename(Folder + "/"+Ch2+"/img_t1_z" + "00" + i + "_c1", Folder + "/"+Ch2+"/img_t1_z" + i + "_c1");
    File.rename(Folder + "/"+Ch3+"/img_t1_z" + "00" + i + "_c1", Folder + "/"+Ch3+"/img_t1_z" + i + "_c1");
    File.rename(Folder + "/"+Ch4+"/img_t1_z" + "00" + i + "_c1", Folder + "/"+Ch4+"/img_t1_z" + i + "_c1");}
    }
for (i=10; i<100; i++){
	if (NrOfChannels==1) {
    File.rename(Folder + "/"+Ch1+"/img_t1_z" + "0" + i + "_c1", Folder + "/"+Ch1+"/img_t1_z" + i + "_c1");}
    if (NrOfChannels==2) {
    File.rename(Folder + "/"+Ch1+"/img_t1_z" + "0" + i + "_c1", Folder + "/"+Ch1+"/img_t1_z" + i + "_c1");
    File.rename(Folder + "/"+Ch2+"/img_t1_z" + "0" + i + "_c1", Folder + "/"+Ch2+"/img_t1_z" + i + "_c1");}
    if (NrOfChannels==3) {
    File.rename(Folder + "/"+Ch1+"/img_t1_z" + "0" + i + "_c1", Folder + "/"+Ch1+"/img_t1_z" + i + "_c1");
    File.rename(Folder + "/"+Ch2+"/img_t1_z" + "0" + i + "_c1", Folder + "/"+Ch2+"/img_t1_z" + i + "_c1");
    File.rename(Folder + "/"+Ch3+"/img_t1_z" + "0" + i + "_c1", Folder + "/"+Ch3+"/img_t1_z" + i + "_c1");}
    if (NrOfChannels==4) {
    File.rename(Folder + "/"+Ch1+"/img_t1_z" + "0" + i + "_c1", Folder + "/"+Ch1+"/img_t1_z" + i + "_c1");
    File.rename(Folder + "/"+Ch2+"/img_t1_z" + "0" + i + "_c1", Folder + "/"+Ch2+"/img_t1_z" + i + "_c1");
    File.rename(Folder + "/"+Ch3+"/img_t1_z" + "0" + i + "_c1", Folder + "/"+Ch3+"/img_t1_z" + i + "_c1");
    File.rename(Folder + "/"+Ch4+"/img_t1_z" + "0" + i + "_c1", Folder + "/"+Ch4+"/img_t1_z" + i + "_c1");}
	}
}

//Load all planes sequentially and create smaller versions from them.

for (i = 1; i < NrOfPlanes+1; i++) {
	if (File.exists(Folder + "/"+Ch1+"/img_t1_z" + i + "_c1")) {
    open(Folder + "/"+Ch1+"/img_t1_z" + i + "_c1");
    saveAs("Tiff", Folder + "/"+Ch1+"/" + i + ".tif");
    getDimensions(width, height, channels, slices, frames);
    NewWidth=round(width/10);
    NewHeight=round(height/10);
	run("Scale...", "x=0.1 y=0.1 width=" + NewWidth + " height=" + NewHeight + " interpolation=Bilinear average create");
	saveAs("Tiff", Folder + "/"+Ch1+"Small/" + i + ".tif");
	close("*");
	File.delete(Folder + "/"+Ch1+"/img_t1_z" + i + "_c1");}

	if (File.exists(Folder + "/"+Ch2+"/img_t1_z" + i + "_c1")) {
	open(Folder + "/"+Ch2+"/img_t1_z" + i + "_c1");
	saveAs("Tiff", Folder + "/"+Ch2+"/" + i + ".tif");
    getDimensions(width, height, channels, slices, frames);
    NewWidth=round(width/10);
    NewHeight=round(height/10);
	run("Scale...", "x=0.1 y=0.1 width=" + NewWidth + " height=" + NewHeight + " interpolation=Bilinear average create");
	saveAs("Tiff", Folder + "/"+Ch2+"Small/" + i + ".tif");
	close("*");
	File.delete(Folder + "/"+Ch2+"/img_t1_z" + i + "_c1");}

	if (File.exists(Folder + "/"+Ch3+"/img_t1_z" + i + "_c1")) {
	open(Folder + "/"+Ch3+"/img_t1_z" + i + "_c1");
	saveAs("Tiff", Folder + "/"+Ch3+"/" + i + ".tif");
    getDimensions(width, height, channels, slices, frames);
    NewWidth=round(width/10);
    NewHeight=round(height/10);
	run("Scale...", "x=0.1 y=0.1 width=" + NewWidth + " height=" + NewHeight + " interpolation=Bilinear average create");
	saveAs("Tiff", Folder + "/"+Ch3+"Small/" + i + ".tif");
	close("*");
	File.delete(Folder + "/"+Ch3+"/img_t1_z" + i + "_c1");}

	if (File.exists(Folder + "/"+Ch4+"/img_t1_z" + i + "_c1")) {
	open(Folder + "/"+Ch4+"/img_t1_z" + i + "_c1");
	saveAs("Tiff", Folder + "/"+Ch4+"/" + i + ".tif");
    getDimensions(width, height, channels, slices, frames);
    NewWidth=round(width/10);
    NewHeight=round(height/10);
	run("Scale...", "x=0.1 y=0.1 width=" + NewWidth + " height=" + NewHeight + " interpolation=Bilinear average create");
	saveAs("Tiff", Folder + "/"+Ch4+"Small/" + i + ".tif");
	close("*");
	File.delete(Folder + "/"+Ch4+"/img_t1_z" + i + "_c1");}
}


//Interleave the small channels into a separate folder (necessary, because Stack-to-Hyperstack for virtual files ONLY allows the xyczt(default) order option)
for (i = 1; i < NrOfPlanes+1; i++){
    Index1=(i-1)*NrOfChannels+1;
    if (File.exists(Folder + "/"+Ch1+"Small")) {
	File.rename(Folder + "/"+Ch1+"Small/" + i + ".tif", Folder + "/TempSmall/" + Index1 + ".tif");}
	Index2=(i-1)*NrOfChannels+2;
	if (File.exists(Folder + "/"+Ch2+"Small")) {
	File.rename(Folder + "/"+Ch2+"Small/" + i + ".tif", Folder + "/TempSmall/" + Index2 + ".tif");}
	Index3=(i-1)*NrOfChannels+3;
	if (File.exists(Folder + "/"+Ch3+"Small")) {
	File.rename(Folder + "/"+Ch3+"Small/" + i + ".tif", Folder + "/TempSmall/" + Index3 + ".tif");}
	Index4=(i-1)*NrOfChannels+4;
	if (File.exists(Folder + "/"+Ch4+"Small")) {
	File.rename(Folder + "/"+Ch4+"Small/" + i + ".tif", Folder + "/TempSmall/" + Index4 + ".tif");}
}
if (File.exists(Folder + "/"+Ch1+"Small")) {
	File.delete(Folder + "/"+Ch1+"Small");}
if (File.exists(Folder + "/"+Ch2+"Small")) {
	File.delete(Folder + "/"+Ch2+"Small");}
if (File.exists(Folder + "/"+Ch3+"Small")) {
	File.delete(Folder + "/"+Ch3+"Small");}
if (File.exists(Folder + "/"+Ch4+"Small")) {
	File.delete(Folder + "/"+Ch4+"Small");}

run("Image Sequence...", "open=[" + Folder + "/TempSmall/1.tif] number=" + NrOfPlanes*NrOfChannels + " file=tif sort use");
run("Stack to Hyperstack...", "order=xyczt(default) channels=" + NrOfChannels + " slices=" + NrOfPlanes + " frames=1 display=Color");
saveAs("Tiff", Folder + "/"+NrOfChannels+"ChannelsSmall.tif");
if (Max_Projection) {
	selectWindow(NrOfChannels+"ChannelsSmall.tif");
	run("Z Project...", "projection=[Max Intensity]");
	saveAs("Tiff", Folder + "/MAX_"+NrOfChannels+"ChannelsSmall.tif");
	close("*");
}
else {
	close();
}

for (i = 1; i < NrOfPlanes*NrOfChannels+1; i++){
    File.delete(Folder + "/TempSmall/" + i + ".tif");
}
File.delete(Folder + "/TempSmall");


//Interleave the big channels into a separate folder (necessary, because Stack-to-Hyperstack for virtual files ONLY allows the xyczt(default) order option)
for (i = 1; i < NrOfPlanes+1; i++){
    Index1=(i-1)*NrOfChannels+1;
    if (File.exists(Folder + "/"+Ch1)) {
	File.rename(Folder + "/"+Ch1+"/" + i + ".tif", Folder + "/Temp/" + Index1 + ".tif");}
	Index2=(i-1)*NrOfChannels+2;
	if (File.exists(Folder + "/"+Ch2)) {
	File.rename(Folder + "/"+Ch2+"/" + i + ".tif", Folder + "/Temp/" + Index2 + ".tif");}
	Index3=(i-1)*NrOfChannels+3;
	if (File.exists(Folder + "/"+Ch3)) {
	File.rename(Folder + "/"+Ch3+"/" + i + ".tif", Folder + "/Temp/" + Index3 + ".tif");}
	Index4=(i-1)*NrOfChannels+4;
	if (File.exists(Folder + "/"+Ch4)) {
	File.rename(Folder + "/"+Ch4+"/" + i + ".tif", Folder + "/Temp/" + Index4 + ".tif");}
}
if (File.exists(Folder + "/"+Ch1)) {
	File.delete(Folder + "/"+Ch1);}
if (File.exists(Folder + "/"+Ch2)) {
	File.delete(Folder + "/"+Ch2);}
if (File.exists(Folder + "/"+Ch3)) {
	File.delete(Folder + "/"+Ch3);}
if (File.exists(Folder + "/"+Ch4)) {
	File.delete(Folder + "/"+Ch4);}

run("Image Sequence...", "open=[" + Folder + "/Temp/1.tif] number=" + NrOfPlanes*NrOfChannels + " file=tif sort use");
run("Stack to Hyperstack...", "order=xyczt(default) channels=" + NrOfChannels + " slices=" + NrOfPlanes + " frames=1 display=Color");
saveAs("Tiff", Folder + "/"+NrOfChannels+"Channels.tif");
if (Max_Projection) {
	selectWindow(NrOfChannels+"Channels.tif");
	run("Z Project...", "projection=[Max Intensity]");
	saveAs("Tiff", Folder + "/MAX_"+NrOfChannels+"Channels.tif");
	close("*");
}
else {
	close();	
}
for (i = 1; i < NrOfPlanes*NrOfChannels+1; i++){
    File.delete(Folder + "/Temp/" + i + ".tif");
}
File.delete(Folder + "/Temp");
close("Log");
}


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
