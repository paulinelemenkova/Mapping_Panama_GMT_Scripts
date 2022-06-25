#!/bin/sh
# Purpose: 3D grid, 125/45 azimuth, from the ETOPO1 from 1 arc min (here: Panama)
# GMT modules: grdcut, grd2cpt, grdcontour, pscoast, grdview, logo, psconvert
# Unix prog: rm

# Cut grid
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R276.5/283/5.0/12.0 -Gpa_relief3D.nc
#gmt grdcut earth_relief_05m.grd -R276.5/283/5.0/12.0 -Gpa_relief3D.nc
gdalinfo -stats pa_relief3D.nc
# Minimum=-4622.000, Maximum=3601.000, Mean=-1332.511, StdDev=1497.265
gmt makecpt -Cturbo.cpt -V -T-4700/3700 > myocean.cpt

# generate a file
ps=PA_3D.ps
    
# Add 3D
gmt grdview pa_relief3D.nc -JM10c -R276.5/283/5.0/12.0 -JZ3.2c -Cmyocean.cpt \
    -p155/30 -Qsm -N-3500+glightgray \
    -Wm0.07p -Wf0.1p,red \
    -B1/1/2000:"Bathymetry and topography (m)":wESZ -S5 \
    --FORMAT_GEO_MAP=ddd:mm:ss \
    --FONT_LABEL=8p,0,darkblue \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    --MAP_FRAME_PEN=black -UBL/45p/-20p -K > $ps
    
# Texts+a-12
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,30,white+jLB >> $ps << EOF
278.5 6.6 P  a  c  i  f  i  c     O  c  e  a  n
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,30,white+jLB >> $ps << EOF
280.5 8.0 Gulf of Panama
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,30,white+jLB >> $ps << EOF
279.7 9.5 C a r i b b e a n
280.0 9.2 S e a
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,30,white+jLB >> $ps << EOF
281.58 8.60 Panama
281.63 8.46 City
EOF

# add color legend
gmt psscale -Dg276.5/4.0+w10.3c/0.4c+h+o0.0/0i+ml+e \
    -R -J -p155/30 -Cmyocean.cpt \
    -Bg500f50a1000+l"Color scale legend 'turbo': depth and height elevations (m)" \
    --FONT_LABEL=8p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --MAP_ANNOT_OFFSET=0.1c \
    -I0.2 -By+lm -O -K >> $ps
    
# Add GMT logo
gmt logo -Dx-0.5/-1.0+o0.0c/0.0c+w2c -O -K >> $ps

# Add title
gmt pstext -R0/10/0/10 -Jx1 -X-0.8c -Y0.0c -N -O -K \
-F+f12p,25,black+jLB >> $ps << EOF
0.5 9.0 Panama: 3D topographic mesh model based on ETOPO1
EOF
gmt pstext -R0/10/0/10 -Jx1 -X0.0c -Y0.0c -N -O\
    -F+f8p,0,black+jLB >> $ps << EOF
0.5 8.5 Perspective view
0.5 8.0 azimuth rotation: 155/30\232
EOF

# Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert PA_3D.ps -A0.8c -E720 -Tj -P -Z
