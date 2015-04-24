function D = driving_function_mono_wfs_cylexpS(x0,n0,Bl,f,xq,conf)
%DRIVING_FUNCTION_MONO_WFS_CYLEXPS computes the time reversed wfs driving 
%functions for a sound field expressed by singular cylindrical expansion coefficients.
%
%   Usage: D = driving_function_mono_wfs_cylexpS(x0,n0,Bl,f,xq,conf)
%
%   Input parameters:
%       x0          - position of the secondary sources / m [nx3]
%       n0          - directions of the secondary sources / m [nx3]
%       Bl          - singular spherical expansion coefficients of sound field
%       f           - frequency in Hz
%       xq          - optional expansion center coordinates, default: [0, 0, 0]
%       conf        - optional configuration struct (see SFS_config)
%
%   Output parameters:
%       D           - driving function signal [nx1]
%
%   DRIVING_FUNCTION_MONO_WFS_CYLEXPS(x0,n0,Bl,f,xq,conf)
%
%   see also: driving_function_mono_wfs_sphexpS
%
%   References:
%     Spors2011 - "Local Sound Field Synthesis by Virtual Acoustic Scattering
%       and Time-Reversal" (AES131)
%     Gumerov,Duraiswami (2004) - "Fast Multipole Methods for the Helmholtz
%       Equation in three Dimensions", ELSEVIER

%*****************************************************************************
% Copyright (c) 2010-2014 Quality & Usability Lab, together with             *
%                         Assessment of IP-based Applications                *
%                         Telekom Innovation Laboratories, TU Berlin         *
%                         Ernst-Reuter-Platz 7, 10587 Berlin, Germany        *
%                                                                            *
% Copyright (c) 2013-2014 Institut fuer Nachrichtentechnik                   *
%                         Universitaet Rostock                               *
%                         Richard-Wagner-Strasse 31, 18119 Rostock           *
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
% http://github.com/sfstoolbox/sfs                      sfstoolbox@gmail.com *
%*****************************************************************************

%% ===== Checking of input  parameters ==================================
nargmin = 4;
nargmax = 6;
narginchk(nargmin,nargmax);
isargmatrix(x0,n0);
isargpositivescalar(f);
if nargin<nargmax
    conf = SFS_config;
else
    isargstruct(conf);
end
if nargin == nargmin
  xq = [0, 0, 0];
end
isargposition(xq);

%% ===== Configuration ==================================================
c = conf.c;
dimension = conf.dimension;
driving_functions = conf.driving_functions;
Nce = conf.scattering.Nce;
showprogress = conf.showprogress;

%% ===== Computation ====================================================
% Calculate the driving function in time-frequency domain


% apply shift to the center of expansion xq
x = x0(:,1)-xq(1);
y = x0(:,2)-xq(2);
z = x0(:,3)-xq(3);

% conversion to cylindrical coordinates
r = sqrt(x.^2 + y.^2);
phi = atan2(y,x);

% frequency depended stuff
omega = 2*pi*f;
k = omega/c;
kr = k.*r;

% gradient in spherical coordinates
Gradr = zeros(size(x0,1),1);
Gradphi = zeros(size(x0,1),1);
Gradz = zeros(size(x0,1),1);

% directional weights for conversion spherical gradient into carthesian 
% coordinates + point product with normal vector n0 (directional derivative 
% in cartesian coordinates)
Sn0r     =  cos(phi).*n0(:,1)...
         +  sin(phi).*n0(:,2);
Sn0phi   = -sin(phi).*n0(:,1)...
         +  cos(phi).*n0(:,2);
Sn0z     =            n0(:,3);

% indexing the expansion coefficients
L = 2*Nce+1;
l = 0;


if strcmp('2D',dimension) || strcmp('3D',dimension)
  
  % === 2- or 3-Dimensional ============================================
  
  if (strcmp('default',driving_functions))    
    % --- SFS Toolbox ------------------------------------------------
    % D using a line source
    % 
    %             d    
    % D(x0, w) = --- conj(-Ps(x0,w))
    %            d n
    % with singular cylindrical expansion of the sound field:
    %           \~~    oo       
    % Ps(x,w) =  >        B  S (x-xq) 
    %           /__ n=-oo  n  n
    % singular cylindrical basis functions
    %          (2) 
    % S (x) = H   (kr) . exp(j n phi)
    %  n       n               
    
    for n=-Nce:Nce
      l = l + 1;      
      h_prime = k.*besselh_derived(n,2,kr);
      h = besselh(n, 2, kr);
      Yn = exp(1j.*n.*phi);      
      Gradr   = Gradr   +       ( Bl(l).*h_prime.*Yn  );
      Gradphi = Gradphi + 1./r.*( Bl(l).*h.*1j.*n.*Yn );
      if showprogress, progress_bar(l,L); end % progress bar
    end
    % directional gradient + time reversion (conjugate complex)
    D = Sn0r.*Gradr + Sn0phi.*Gradphi + Sn0z.*Gradz;
    D = -conj(D);
  else
    error(['%s: %s, this type of driving function is not implemented ', ...
      'for a 2D/3D line source.'],upper(mfilename),driving_functions);
  end  
else
  error('%s: the dimension %s is unknown.',upper(mfilename),dimension);
end