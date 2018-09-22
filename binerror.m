## Copyright (C) 2018 gehhi
## 
## This program is free software: you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see
## <https://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {} {@var{retval} =} binerror (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: gehhi <gehhi@TIM-SURFACE-BOO>
## Created: 2018-09-22

function retval = binerror (bins)

ires = bitshift((0:255)*(bins-1), -8) + bitand(bitshift(((0:255))*(bins-1), -7), 1);
dres = round((0:255)./256.0*(double(bins)-1));

retval = sum(abs(dres-ires));
endfunction
