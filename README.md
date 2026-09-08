# MeMRI PTB

**Installation**
MeMRI-PTB can be downloaded from github or retrieved via the MATLAB environment. See below for the latter assuming git is installed on your PC (see https://gitforwindows.org/ ).
Download:	https://github.com/Illuminate-MeMRI/Metabolic-MRI-Processing-Toolbox

**Github in MATLAB**
Create an empty folder for MeMRI-PTB named Metabolic-MRI-Processing-Toolbox in MATLAB using the “Current Folder” pane via right-click > New > Folder. For a custom root directory name, see the paragraph below. Open the directory Metabolic-MRI-Processing-Toolbox, right-click inside the “Current Folder” pane and select “Source Control”. The window below will appear:

<img width="936" height="466" alt="image" src="https://github.com/user-attachments/assets/05df92b2-88d5-42fa-8147-6a7e8bc0fcc0" />

Select Git as “Source Control Integration” and enter the github path “https://github.com/Illuminate-MeMRI/Metabolic-MRI-Processing-Toolbox” in the “Repository path” editfield. Click “retrieve” at the bottom right and wait until MATLAB has downloaded the required files. 

**Custom root directory**
A custom directory name for the github repository is possible but requires a change to the function memri_findRoot(). The defined root-directory is stored as variable “stroi” and must be changed to the desired directory name.

**Example data**
The MRS example data is too large for default use with github and therefore stored at a different location: 

**Background**
Large x-nuclei spectroscopy data sets from high-field MR systems are becoming more prevalent in the recent decades due to technological advances in both hardware and computing power. Increases in RF coil density i.e. phased arrays, allow acquisition over large field of views (FOV) paving the way for upper and lower body MRS applications.
However, MR systems cannot handle these data sets using the conventional reconstruction pipelines and are often poorly documented. New processing methods have been introduced to increase sensitivity through new coil-combination and denoising methods. Therefor raw spectroscopy data is often exported for offline reconstruction. 
Multi-centre studies with different MR-system vendors are a crucial part of translating academic research into clinical practice. Unfortunately, there is no consensus on processing methods nor their implementation. Therefore, we collaborated between 4 sites in 3 European countries to streamline data handling and visualization methodology. This resulted in this metabolic MR imaging processing toolbox available for the entire MR spectroscopy community.

For more information about the Illuminate project, please visit: https://www.ihi-illuminate.org/
