#!/bin/sh
# Purpose: geoid of Panama
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# http://soliton.vm.bytemark.co.uk/pub/cpt-city/kst/tn/25_mac_style.png.index.html

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

gmt grdconvert n00w90/w001001.adf geoid_02.grd
gdalinfo geoid_02.grd -stats

# Generate a color palette table from grid
gmt makecpt -C25_mac_style.cpt -T-5/20 > colors.cpt
#-Ic Reverse sense of color table spectrum

# Generate a file
ps=Geoid_PA.ps
gmt grdimage geoid_02.grd -Ccolors.cpt -R276.5/283/6.5/10.5 -JM6.5i -P -Xc -I+a15+ne0.75 -K > $ps

# Add shorelines
gmt grdcontour geoid_02.grd -R -J -C0.5 -A1.0+f8p,0,black -Wthinner,dimgray -O -K >> $ps

# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    -Bpx1f0.5a1 -Bpyg1f0.5a0.5 -Bsxg0.5 -Bsyg0.5 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_LABEL=7p,25,black \
    --FONT_TITLE=13p,25,black \
    -B+t"Geoid gravitational model of Panama" -O -K >> $ps
    
# Add legend
gmt psscale -Dg276.5/6.05+w16.5c/0.4c+h+o0.0/0i+ml+e -R -J -Ccolors.cpt \
    --FONT_LABEL=7p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    --FONT_TITLE=8p,25,black \
    -Bg2f0.2a2+l"Color scale '25 mac style': colour tables of IDL from the KDE scientific plotting tool [RGB, 254 segments, -T-5/20]" \
    -I0.2 -By+lm -O -K >> $ps

# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=7p,0,black \
    --FONT_ANNOT_PRIMARY=6p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.7c/-2.3c+c50+w100k+l"Mercator projection. Scale (km)"+f \
    -UBL/-5p/-60p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P -Ia/thinnest,blue -Na -N1/thick,brown -Wthick,darkslategray -Df -O -K >> $ps

# Add GMT logo
gmt logo -Dx7.0/-3.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.1c -Y5.0c -N -O \
    -F+f10p,25,black+jLB >> $ps << EOF
3.0 9.0 World geoid image EGM2008 vertical datum 2.5 min resolution
EOF

# Convert to image file using GhostScript
gmt psconvert Geoid_PA.ps -A1.0c -E720 -Tj -Z
