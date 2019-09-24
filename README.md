# RuffleQuantification

This script quantifies F-actin rich projections on the plasma membrane surface of fixed cells automatically without any user interaction, making it highly useful for high-throughput screening.



Developed by Dr Nicholas Condon.

[ACRF:Cancer Biology Imaging Facility](https://imb.uq.edu.au/microscopy), 
Institute for Molecular Biosciences, The University of Queensland
Brisbane, Australia 2019.

This script is written in the ImageJ1 Macro Language.


Background
-----

This script takes two colour Z-stack images (Ch1 = Phalloidin/Actin; Ch2 = Nuclei Marker) and determines the mid-point of the nuclei based on their maxium size. The phalloidin channel is split into the base of the cell (cell area) and dorsal ruffling region (top of the cell). Measurements are made on both images, as well as normalisation again total cell number and area per image field of view.

Using Bio-Formats and FIJI the script can be run on any image type, and is batch processable on an entire directory of multiple images. The script outputs mask images as well as an .xls file containing the quantification outputs ready for statistical analysis.


Running the script
-----
The first dialog box to appear explains the script, acknowledges the creator and the ACRF:Cancer Biology Imaging Facility at the University of Queensland, Brisbane, Australia.

The second dialog to open prompts the user to navigate to a directory which contains the images to be processed.

The next dialog asks for the file's extension (eg, .oir, .tif, etc) and whether to run in batch mode (background).

The file extension is actually a file ‘filter’ running the command ‘ends with’ which means for example .tif may be different from .txt in your folder only opening .tif files. Perhaps you wish to process files in a folder containing <Filename>.tif and <filename>+deconvolved.tif you could enter in the box here "deconvolved.tif" to select only those files. It also uses this information to tidy up file names it creates (i.e. no example.tif.avi)

The final dialog box is an alert to the user that the batch is completed. 


Output files
-----
Files are put into a results directory called 'Analysis_Results_<date&time>' within the chosen working directory. Files will be saved as either a .tif, .xls or .txt for the log file. Original filenames are kept and have tags appended to them based upon the chosen parameters.

A text file called log.txt is included which has the chosen parameters and date and time of the run.

<filename>-Summed-Ruffles.tif   = a flattened & merged output image showing green ruffles/red cell area regions
<filename>-Threshed-Area.tif    = a binary mask of the cell area selection
<filename>-Threshed-ruffles.tif = a binary mask of the ruffle area selection
<filename>-Nuc.tif              = a binary mask of the nuclei area selection


Turning off Bio-Formats Import Window
-----
Preventing the Bio-formats Importer window from displaying:
1. Open FIJI
2. Navigate to Plugins > Bio-Formats > Bio-Formats Plugins Configuration
3. Select Formats
4. Select your desired file format (e.g. “Zeiss CZI”) and select “Windowless”
5. Close the Bio-Formats Plugins Configuration window

Now the importer window won’t open for this file-type. To restore this, simply untick ‘Windowless”

￼
