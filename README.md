[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![DOI](https://img.shields.io/badge/DOI-10.1002%2Fsmtd.202301766-orange)](https://doi.org/10.1002/smtd.202301766)

# NanoLocz-MATLAB-Library 📦  
*A MATLAB library for atomic force microscopy (AFM) image analysis*

NanoLocz-lib is a lightweight, scriptable MATLAB library designed for high-throughput AFM, high-speed AFM (HS-AFM), and Localization-AFM (LAFM) image analysis. It provides the core functionality behind the [NanoLocz GUI app](https://github.com/George-R-Heath/NanoLocz) for users who prefer scripting or batch processing workflows.

---

## 🔍 Key Features
* Read AFM file types: .spm,  .asd,  .jpk, .h5-jpk,  .ibw,  .ARIS,  .tiff, .nhf, .gwy
* Image Levelling
* Image Alignment
* Mask Analysis
* Particle Detection
* Single Particle Tracking
* Simulation AFM
* *Localization AFM* 
* Export as: .tiff, .gif, .avi, .png, .jpeg, .pdf, .txt, .csv, .xls, .h5
* Batch processing–ready functions for automated workflows

---

## 🛠 Requirements

NanoLocz-lib uses core MATLAB and requires the following toolboxes:

- Image Processing Toolbox  
- Computer Vision Toolbox  
- Signal Processing Toolbox  
- Curve Fitting Toolbox  
- Statistics and Machine Learning Toolbox  
- Optimization Toolbox  

---

## 📦 Installation & Usage

1. Clone or download this repository.
2. Add the NanoLocz-lib folder (and its subfolders) to your MATLAB path:
   ```matlab
   addpath(genpath('path/to/NanoLocz-lib'))

3. Call functions directly in your scripts, see the [Example Workbooks](https://github.com/George-R-Heath/NanoLocz-Matlab-Library/tree/main/Example%20Workbooks) scripts included in the repository as templates for common analysis workflows.
   
## Disclaimer:
THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
BE LIABLE
FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
THE
USE OR OTHER DEALINGS IN THE SOFTWARE.

## Contributing
Contributions are extremely welcome.

## License
Distributed under the terms of the [GNU GPL v3.0](https://www.gnu.org/licenses/gpl-3.0.txt) license.

## Citation

If using the NanoLocz libary please cite:\
[Heath, G.R, Micklethwaite, E. and Storer, T.M.\
NanoLocz: Image analysis platform for AFM, high-speed AFM and localization AFM.\
*Small Methods* 2024, 2301766.](https://doi.org/10.1002/smtd.202301766) 

If using the Localization Atomic Force Microscopy method please cite:\
[Heath, G.R., Kots, E., Robertson, J.L. et al.\
Localization atomic force microscopy.\
 Nature 594, 385–390 (2021)](https://doi.org/10.1038/s41586-021-03551-x)
