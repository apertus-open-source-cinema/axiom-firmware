#!/bin/bash

sed '
	/Message\[302\]/ d;
	/Message\[312\]/ d;

	/[eE][rR][rR][oO][rR]/		{ s/.*/[31m&[0m/; T }
	/[mM][eE][sS][sS][aA][gG][eE]/	{ s/.*/[32m&[0m/; T }
	/[wW][aA][rR][nN]/		{ s/.*/[33m&[0m/; T }
	'
