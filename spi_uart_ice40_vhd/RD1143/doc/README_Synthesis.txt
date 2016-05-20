----------------------------------------------------------------------------------------------------------------------------------------
RD1143 SPI to UART Expander Source Files Setup:

To load pre-compiled project in icecube2:
	1. Open iCEcube2 and select "Open Project".
	2. Browse to  the directory "RD1143\Project\SPI_to_UART_Expander".
	3. Select the project file "SPI_to_UART_Expander_sbt.project" to load the project in iCEcube2.

To Synthesize with iCEcube2:
	1. Create a new Project in the iCEcube2 software, choose appropriate Device(Select "iCE40 HX8K CT256" for this project).
	2. To add design source files add files from the directory "RD1143\Source".
	3. Select the files 
		a.spi_mxdmx
		b.spi_slave
		c.spi_uart_expander
		d.spi_uart_package
	4. Launch Synthesis tool, RUN synthesis in Synplify and close upon successful completion.

-----------------------------------------------------------------------------------------------------------------------------------------
