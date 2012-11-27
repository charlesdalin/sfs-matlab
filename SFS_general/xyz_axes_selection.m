function [dimensions,x1,x2] = xyz_axes_selection(x,y,z)
%XYZ_AXES_SELECTION returns the first two active dimensions and a vector
%indicating which axes are selected
%
%   Usage: [dimensions,x1,x2] = xyz_axes_selection(x,y,z)
%
%   Input options:
%       x,y,z      - vectors conatining the x-, y- and z-axis values
%
%   Output options:
%       dimensions - 1x3 vector containing 1 or 0 to indicate the activity
%                    of the single dimensions in the order [x y z]
%       x1         - vector containing the first active axis
%       x2         - vector containing the second active axis
%
%   XYZ_AXES_SELECTION(x,y,z) returns a vector indicating for the x-, y- and
%   z-axis if we have any activity on this axis or if it is a singleton axis.
%   In addition the first non-singleton axis a returned.
%
%   see also: norm_wavefield, plot_wavefield, xyz_axes, xyz_grid

%*****************************************************************************
% Copyright (c) 2010-2012 Quality & Usability Lab                            *
%                         Deutsche Telekom Laboratories, TU Berlin           *
%                         Ernst-Reuter-Platz 7, 10587 Berlin, Germany        *
%                                                                            *
% This file is part of the Sound Field Synthesis-Toolbox (SFS).              *
%                                                                            *
% The SFS is free software:  you can redistribute it and/or modify it  under *
% the terms of the  GNU  General  Public  License  as published by the  Free *
% Software Foundation, either version 3 of the License,  or (at your option) *
% any later version.                                                         *
%                                                                            *
% The SFS is distributed in the hope that it will be useful, but WITHOUT ANY *
% WARRANTY;  without even the implied warranty of MERCHANTABILITY or FITNESS *
% FOR A PARTICULAR PURPOSE.                                                  *
% See the GNU General Public License for more details.                       *
%                                                                            *
% You should  have received a copy  of the GNU General Public License  along *
% with this program.  If not, see <http://www.gnu.org/licenses/>.            *
%                                                                            *
% The SFS is a toolbox for Matlab/Octave to  simulate and  investigate sound *
% field  synthesis  methods  like  wave  field  synthesis  or  higher  order *
% ambisonics.                                                                *
%                                                                            *
% http://dev.qu.tu-berlin.de/projects/sfs-toolbox       sfstoolbox@gmail.com *
%*****************************************************************************


%% ===== Checking of input parameters ====================================
nargmin = 3;
nargmax = 3;
error(nargchk(nargmin,nargmax,nargin));
isargvector(x,y,z);


%% ===== Computation =====================================================
dimensions = [1 1 1];
x1 = x;
x2 = y;
% Check if we have any inactive dimensions
if x(1)==x(end)
    dimensions(1) = 0;
    x1 = y;
    x2 = z;
end
if y(1)==y(end)
    dimensions(2) = 0;
    x2 = z;
end
if z(1)==z(end)
    dimensions(3) = 0;
end
