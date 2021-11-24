# SPDX-FileCopyrightText: © 2016 Herbert Poetzl <herbert@13thfloor.at>
# SPDX-License-Identifier: GPL-2.0-only

BEGIN			{ FS="[ \t()]+"; }


/^! Program CFG/	{ CFG=1; }
/^! Program the UFM/	{ UFM=1; CFG=0; }
/^! Program USERCODE/	{ UCD=1; UFM=0; }

($1=="SDR" && $2==128)	{ if (UFM) print $4 }
