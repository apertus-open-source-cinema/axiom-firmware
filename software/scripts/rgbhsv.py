#!/bin/env python3

from mat4_conf import *
import numpy as np
import numpy.linalg as linalg


if cnt == 0:    # no arguments, just print
    mat = mat_get()
    off = off_get()
    write, three = False, False

elif cnt == 1:  # scalar factor
    mat3 = np.identity(3)*val[0]
    off3 = np.zeros(3)

elif cnt == 3:  # three scalars
    mat3 = np.diag(val[0:3])
    off3 = np.zeros(3)

elif cnt == 6: # RGB and HSV
    H, S, V = val[3:6]
    U = np.cos(H*np.pi/180)
    W = np.sin(H*np.pi/180)
    T_HSV = np.array([[V,0,0],[0,V*S*U,-V*S*W],[0,V*S*W,V*S*U]])
    #T_RGB = np.array([[1,.956,.621],[1,-.272,-.647],[1,-1.107,1.705]])
    #print(linalg.inv(T_RGB))
    T_YIQ = np.array([[.299,.587,.114],[.596,-.274,-.321],[.211,-.523,.311]])
    T_RGB = linalg.inv(T_YIQ)
    print(T_HSV)
    mat3 = np.dot(np.diag(val[0:3]), np.dot(T_RGB, np.dot(T_HSV, T_YIQ)))
    off3 = np.zeros(3)

else:
    print("Sorry, don't know how to interpret %d values." % cnt)
    exit(1)

if three:
    print(mat3)
    mat = mat3_to4(mat3)
    print(off3)
    off = off3_to4(off3)

print(mat)
# print(adj)
print(off)

if write:
    mat_set(mat)
    # adj_set(adj)
    off_set(off)


