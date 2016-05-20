# =============================================================================
#                           COPYRIGHT NOTICE
# Copyright 2012 (c) Lattice Semiconductor Corporation
# ALL RIGHTS RESERVED
# This confidential and proprietary software may be used only as authorised by
# a licensing agreement from Lattice Semiconductor Corporation.
# The entire notice above must be reproduced on all authorized copies and
# copies may only be made to the extent permitted by a licensing agreement from
# Lattice Semiconductor Corporation.
#
# Lattice Semiconductor Corporation        TEL : 1-800-Lattice (USA and Canada)
# 5555 NE Moore Court                            503-268-8001 (other locations)
# Hillsboro, OR 97124                     web  : http:www.latticesemi.com/
# U.S.A                                   email: techsupport@latticesemi.com
# =============================================================================
#                         FILE DETAILS
# Projec2t         : RD1143 Simulation Script (Aldec)
# File             : RD1143.do 
# Title            :
# Dependencies     : 
# Description      :
# =============================================================================
#                        REVISION HISTORY
# Version          : 1
# Author(s)        : Apps
# Mod. Date        : September, 2012
# Changes Made     :
#
# =============================================================================

# To successfully run this script, make the following change:
# 1. Update the path  "<User Directory >\RD1143\Project" with your directory path.
 
set path G:\ICE_RD\RD1143\Project
cd $path
##============================================

design create aldec_sim $path
design open aldec_sim

##============================================

adel -all
cd $path

##============================================
##compliation  

acom -O3 -work aldec_sim -2002  /../../source/VHDL/spi_uart_package.vhd \
/../../source/VHDL/spi_mxdmx.vhd /../../source/VHDL/spi_slave.vhd /../../source/VHDL/spi_uart_expander.vhd \
/../../testbench/VHDL/spi_uart_expander_tb.vhd

##============================================
##sim

asim -O5 -L ice -L ovi_ice -PL ovi_ice -PL ice +access +w_nets +access +r +access +r+w spi_uart_expander_tb tb_behave

##============================================
##waves

add wave /spi_uart_expander_tb/*

##============================================ 

run 200 us

##============================================
##End of Simulation
##============================================