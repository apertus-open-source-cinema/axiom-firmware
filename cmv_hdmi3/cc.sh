#!/bin/bash

sed '	/met the timing requirement/	{ s/.*/[32m&[0m/; T }
	/^[iI][nN][fF][oO]/		{ s/.*/[34m&[0m/; T }
	/^[eE][rR][rR][oO][rR]/		{ s/.*/[31m&[0m/; T }
	/^[mM][eE][sS][sS][aA][gG][eE]/	{ s/.*/[32m&[0m/; T }
	/^[wW][aA][rR][nN]/		{ s/.*/[33m&[0m/; T }
	/^CRITICAL/			{ s/.*/[31m&[0m/; T }
	/^IODELAY/			{ d }
	'
