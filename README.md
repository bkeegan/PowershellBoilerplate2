PowershellBoilerplate2
======================

PowerShell Boilerplate v2 is the second iteration of this library. This library contains both generic cmdlets as well as script targeted towards specific use cases. 

As compared to PSCX: PSCX or Powershell Community Extensions is another set of boilerplate powershell cmdlets available on codeplex (http://pscx.codeplex.com/). Powershell Boilerplate, while overlaps in some ways, differs in the following

-Licensing: PSCX is under the "Microsoft Public License" (MS-PL) while this repository is under GPLv3.

-Looser definition of "boilerplate": This repository contains some more particular implentations (for example, methods for deploying applications and applying patches). The code is, however, designed to work in any Windows environment. 

-Code with module prerequistes: PSCX is designed to be usable on any machine with Powershell installed. This repository contains cmdlets that requires other modules to be installed (for example, active directory)

Changes in Version 2
======================
Version 2 is committed to making the following changes over version 1

-Better input validation

-Powershell headers to be read from Get-help, get-details cmdlets.

-GPLv3 licensing (version 1 was GPLv2)

-More cmdlets!

-An installable module (eventually)

License
======================
PowerShell Boilerplate v2 - A collection of reusable powershell cmdlets
Copyright (C) 2014  Brenton Keegan

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
