#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Panama)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
#http://soliton.vm.bytemark.co.uk/pub/cpt-city/esri/hillshade/tn/purple_gray_dk.png.index.html

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
    FONT_ANNOT_PRIMARY=7p,0,dimgray \
    FONT_LABEL=7p,0,dimgray \
# Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

# Extract a subset of ETOPO1m for the study area
#gmt grdcut ETOPO1_Ice_g_gmt4.grd -R276.5/283/6.5/10.5 -Gpa_relief.nc
gmt grdcut GEBCO_2019.nc -R276.5/283/6.5/10.5 -Gpa_relief.nc
gdalinfo -stats pa_relief.nc
# Min=-5401.590 Max=6232.578

# Make color palette
gmt makecpt -Cbone.cpt -V -T-5401/6233 > pauline.cpt
gmt makecpt -Cseis -T2.1/7.6/0.5 -Z > steps.cpt

ps=Seis_PA.ps
# Make raster image
gmt grdimage pa_relief.nc -Cpauline.cpt -R276.5/283/6.5/10.5 -JM6.5i -I+a15+ne0.75 -Xc -P -K > $ps

# Add legend
gmt psscale -Dg276.5/6.05+w16.5c/0.4c+h+o0.0/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
    -Bg500f50a500+l"Colormap: 'bone' scheme of h5utils package by MIT's S.G. Johnson, continuous, RGB, 63 segments [R=-5401/6233, H, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add isolines
gmt grdcontour pa_relief.nc -R -J -C1000 -A1000+f7p,26,lavender -Wthinner,lavender -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thickest,olivedrab1 -Wthin,lightcyan2 -Df -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    -Bpx2f1a1 -Bpyg2f1a1 -Bsxg2 -Bsyg2 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_LABEL=8p,25,black \
    --FONT_TITLE=14p,25,black \
    -B+t"Seismicity in Panama according to IRIS (1970-2021)" -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=10p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.0c/-3.7c+c50+w150k+l"Mercator projection. Scale: km"+f \
    -UBL/-5p/-110p -O -K >> $ps

# Add earthquake points
# separator in numbers of table: dot (.), not comma (British style)
gmt psxy -R -J quakes_PA_s.ngdc -Wfaint -i4,3,6,6s0.05 -h3 -Scc -Csteps.cpt -O -K >> $ps

# Add geological lines and points
gmt psxy -R -J volcanoes.gmt -St0.4c -Gred -Wthinnest -O -K >> $ps

# fabric and magnetic lineation picks fracture zones
gmt psxy -R -J GSFML_SF_FZ_KM.gmt -Wthicker,goldenrod1 -O -K >> $ps
gmt psxy -R -J GSFML_SF_FZ_RM.gmt -Wthicker,pink -O -K >> $ps
gmt psxy -R -J ridge.gmt -Sf0.5c/0.15c+l+t -Wthick,red -Gyellow -O -K >> $ps
gmt psxy -R -J ridge.gmt -Sc0.05c -Gred -Wthickest,red -O -K >> $ps
# tectonic plates
gmt psxy -R -J TP_Caribbean.txt -L -Wthickest,purple -O -K >> $ps
gmt psxy -R -J TP_Cocos.txt -L -Wthickest,purple -O -K >> $ps
gmt psxy -R -J TP_Nazca.txt -L -Wthickest,purple -O -K >> $ps
gmt psxy -R -J TP_South_Am.txt -L -Wthickest,purple -O -K >> $ps

gmt pslegend -R -J -Dx1.5/-3.0+w17.8c+o-2.0/0.1c \
    -F+pthin+ithinner+gwhite \
    --FONT=8p,black -O -K << FIN >> $ps
H 10 Helvetica Seismicity: earthquakes magnitude (M) from 2.1 to 7.6
N 9
S 0.3c c 0.3c red 0.01c 0.5c M (7.4-7.8)
S 0.3c c 0.3c tomato 0.01c 0.5c M (7.1-7.3)
S 0.3c c 0.3c orange 0.01c 0.5c M (6.4-7.0)
S 0.3c c 0.3c yellow 0.01c 0.5c M (5.7-6.3)
S 0.3c c 0.3c chartreuse1 0.01c 0.5c M (5.0-5.6)
S 0.3c c 0.3c chartreuse1 0.01c 0.5c M (4.3-4.9)
S 0.3c c 0.3c cyan3 0.01c 0.5c M (3.6-4.2)
S 0.3c c 0.3c blue 0.01c 0.5c M (2.9-3.5)

S 0.3c t 0.3c red 0.03c 0.5c Volcanoes
FIN

# Add GMT logo
gmt logo -Dx7.0/-4.5+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y5.0c -N -O \
    -F+f11p,25,black+jLB >> $ps << EOF
0.7 9.0 DEM: SRTM/GEBCO, 15 arc sec grid. Earthquakes: IRIS Seismic Event Database
EOF

# Convert to image file using GhostScript
gmt psconvert Seis_PA.ps -A1.7c -E720 -Tj -Z
