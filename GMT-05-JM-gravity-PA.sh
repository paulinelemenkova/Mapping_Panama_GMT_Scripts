#!/bin/sh
# Purpose: free-air gravity of Panama
# GMT modules: gmtset, gmtdefaults, img2grd, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert, pscoast
# http://soliton.vm.bytemark.co.uk/pub/cpt-city/pj/4/index.html

# GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=1c \
    MAP_ANNOT_OFFSET=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thin,white \
    MAP_GRID_PEN_SECONDARY=thinnest,white \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    FONT_LABEL=7p,Helvetica,dimgray
# Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

gmt img2grd grav_27.1.img -R276.5/283/6.5/10.5 -Ggrav_PA.grd -T1 -I1 -E -S0.1 -V
gdalinfo grav_PA.grd -stats
# Minimum=-128.709, Maximum=453.253, Mean=32.898, StdDev=70.388

# Generate a color palette table from grid
gmt makecpt -Csundeck.cpt -T-129/454 > colors.cpt

# Generate a file
ps=Grav_PA.ps

gmt grdimage grav_PA.grd -Ccolors.cpt -R276.5/283/6.5/10.5 -JM6.0i -P -I+a15+ne0.75 -Xc -K > $ps

# Add isolines
gmt grdcontour grav_PA.grd -R -J -C50 -A100 -Wthinner -O -K >> $ps

# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    -Bpxg1f0.5a1 -Bpyg1f0.5a0.5 -Bsxg1 -Bsyg1 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_LABEL=7p,25,black \
    --FONT_TITLE=13p,25,black \
    -B+t"Free-air gravity anomaly for Panama" -O -K >> $ps
    
# Add legend
gmt psscale -Dg276.5/6.05+w15.3c/0.4c+h+o0.0/0i+ml+e -R -J -Ccolors.cpt \
    --FONT_LABEL=7p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=8p,25,black \
    -Bg20f2a20+l"Color scale 'sundeck' by Peggy Jentoft (sets of gradients for digital art: Set four) [C=RGB -T-129/454]" \
    -I0.2 -By+l"mGal" -O -K >> $ps

# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=7p,0,black \
    --FONT_ANNOT_PRIMARY=6p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-2.4c+c50+w100k+l"Mercator projection. Scale (km)"+f \
    -UBL/-5p/-70p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P -Ia/thinnest,blue -Na -N1/thick,white -Wthin,darkslategray -Df -O -K >> $ps

# Add GMT logo
gmt logo -Dx7.2/-3.1+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y2.8c -N -O \
    -F+f10p,25,black+jLB >> $ps << EOF
0.0 11.0 Global gravity grid from CryoSat-2 and Jason-1, 1 min resolution, SIO, NOAA, NGA.
EOF

# Convert to image file using GhostScript
gmt psconvert Grav_PA.ps -A0.5c -E720 -Tj -Z
