
BEGIN			{ FS="[ \t()]+"; }


/^! Program CFG/	{ CFG=1; }
/^! Program the UFM/	{ UFM=1; CFG=0; }
/^! Program USERCODE/	{ UCD=1; UFM=0; }

($1=="SDR" && $2==128)	{ if (CFG) print $4 }
