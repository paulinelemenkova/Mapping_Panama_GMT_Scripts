#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO dataset (here: Panama)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# http://soliton.vm.bytemark.co.uk/pub/cpt-city/wkp/country/tn/wiki-celtic-sea.png.index.html

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

#chsh -s /bin/bash
chsh -s /bin/zsh

gmt grdcut GEBCO_2019.nc -R276.5/283/6.5/10.5  -Gpa_relief.nc
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R276.5/283/6.5/10.5  -Gpa_relief1.nc

gdalinfo pa_relief.nc -stats
# Minimum=-3954.803, Maximum=2426.246, Mean=-1431.926, StdDev=1462.735

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R276.5/283/6.5/10.5  -Dh -M -EPA > pa.txt
#####################################################################

# Make color palette
gmt makecpt -Cwiki-celtic-sea.cpt > pauline.cpt

# Generate a file
ps=Topography_PA.ps
# Make a transparent background image
gmt grdimage pa_relief.nc -Cpauline.cpt -R276.5/283/6.5/10.5  -JM6.0i -P -I+a15+ne0.75 -t30 -Xc -K > $ps
    
# Add isolines
gmt grdcontour pa_relief1.nc -R -J -C200 -W0.1p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thicker,darkred -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country

gmt psclip -R276.5/283/6.5/10.5  -JM6.0i pa.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage pa_relief.nc -Cpauline.cpt -R276.5/283/6.5/10.5  -JM6.0i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour pa_relief1.nc -R -J -C100 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,darkred -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################

# Add color barlegend
gmt psscale -Dg276.5/6.05+w15.3c/0.4c+h+o0.0/0i+ml -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    --FONT_ANNOT_PRIMARY=6p,0,black \
    -Bg500a500f50+l"Color scale 'wiki-celtic-sea': global bathymetry/topography relief [R=-3954/2426, discrete, RGB, 25 segments]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --MAP_TITLE_OFFSET=0.6c \
    --FONT_TITLE=12p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    -Bpx1f0.5a1 -Bpyg1f0.5a0.5 -Bsxg0.5 -Bsyg0.5 \
    -B+t"Topographic map of Panama" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=6p,0,black \
    --MAP_LABEL_OFFSET=0.1c \
    -Lx13.5c/-2.0c+c50+w100k+l"Mercator projection. Scale: km"+f \
    -UBL/-5p/-60p -O -K >> $ps
    
# Texts -R276.5/283/6.5/10.5
gmt pstext -R -J -N -O -K \
-F+f9p,21,black+jLB -Gwhite@60 >> $ps << EOF
281.12 9.56 El Porvenir
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
281.06 9.56 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,21,black+jLB -Gwhite@60 >> $ps << EOF
281.85 8.26 La Palma
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
281.85 8.41 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,21,black+jLB -Gwhite@60 >> $ps << EOF
280.52 9.10 Las Cumbres
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
280.47 9.08 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,21,black+jLB -Gwhite@50 >> $ps << EOF
279.70 8.75 La Chorrera
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
280.22 8.88 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,21,black+jLB -Gwhite@60 >> $ps << EOF
279.80 9.36 Colón
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
280.11 9.36 0.20c
EOF
#gmt pstext -R -J -N -O -K \
#-F+f9p,21,black+jLB+a-315 -Gwhite@60 >> $ps << EOF
#280.72 9.13 Pacora
#EOF
#gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
#280.72 9.08 0.20c
#EOF
gmt pstext -R -J -N -O -K \
-F+f9p,21,black+jLB -Gwhite@60 >> $ps << EOF
279.95 9.00 Arraiján
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
280.35 8.95 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,21,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
277.67 8.43 David
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
277.57 8.43 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,21,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
279.08 8.10 Santiago de
279.08 8.0 Veraguas
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
279.03 8.11 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
280.58 8.93 Panama
280.63 8.79 City
EOF
gmt psxy -R -J -Sc -W0.5p -Gred -O -K << EOF >> $ps
280.48 8.98 0.25c
EOF
# mountains
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,21,white+jLB+a-30 >> $ps << EOF
277.1 9.1 Cordillera de Talamanca
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,21,black+jLB+a-335 -Gwhite@60 >> $ps << EOF
279.1 7.28 Península de Azuero
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,21,black+jLB -Gwhite@60 >> $ps << EOF
280.55 8.35 Pearl
280.5 8.20 Islands
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,21,black+jLB -Gwhite@60 >> $ps << EOF
277.8 9.50 Bocas del Toro
277.8 9.35 Archipelago
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,21,black+jLB -Gwhite@60 >> $ps << EOF
281.2 8.45 Isla
281.2 8.30 del
281.2 8.15 Rey
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,21,black+jLB -Gwhite@60 >> $ps << EOF
278.4 7.33 Isla de
278.4 7.18 Coiba
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,21,black+jLB -Gwhite@60 >> $ps << EOF
276.5 7.90 Punta Burica
EOF

# water
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,30,dodgerblue4+jLB >> $ps << EOF
280.15 8.0 Gulf of Panama
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,23,dodgerblue4+jLB >> $ps << EOF
277.70 10.25 C a r i b b e a n   S e a
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,30,dodgerblue4+jLB >> $ps << EOF
278.5 9.15 Mosquito
278.7 9.00 Gulf
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,30,dodgerblue4+jLB >> $ps << EOF
277.50 7.95 Gulf of
277.50 7.80 Chiriquí
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,30,dodgerblue4+jLB >> $ps << EOF
279.70 8.10 Parita
279.75 7.95 Bay
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,23,dodgerblue4+jLB >> $ps << EOF
279.1 6.6 P  a  c  i  f  i  c     O  c  e  a  n
EOF

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjTR+w3.0c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,white -Rg -JG270/16N/$w -Da -Gkhaki2 -A5000 -Bg -Wfaint -ESA+gpeachpuff -EPA+gindianred4 -Sskyblue2 -O -K -X$x0 -Y$y0 >> $ps
gmt psbasemap -R -J \
    -D274/5/285/12r -F+pthin,red \
    -O -K >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx6.2/-2.8+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y2.7c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
1.7 11.0 SRTM/GEBCO 15 arc sec resolution global terrain model grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topography_PA.ps -A0.3c -E720 -Tj -Z
