################################################################################
#
# Makefile for scale library
#
################################################################################

TOPDIR      = ../..
SYSDEP_DIR := ../../sysdep

include $(SYSDEP_DIR)/Makedef.$(SCALE_SYS)
include $(TOPDIR)/Mkinclude

LIBNAME = libscale.a

DEPENDLIB = $(LIBDIR)/libgtool.a $(LIBDIR)/libdcutils.a

VPATH = common:                     \
        common/tracer:              \
        coupler:                    \
        io:                         \
        atmos-physics:              \
        atmos-physics/share:        \
        atmos-physics/cumulus:      \
        atmos-physics/microphysics: \
        atmos-physics/radiation:    \
        atmos-physics/surfaceflux:  \
        atmos-physics/turbulence:   \
        atmos-physics/aerosol:      \
        atmos-physics/chemistry:    \
        atmos-rm:                   \
        atmos-rm/communication:     \
        atmos-rm/grid:              \
        atmos-rm/io:                \
        atmos-rm/numeric:           \
        atmos-rm/dynamics:          \
        atmos-rm/forcing:           \
        land:                       \
        land/grid:                  \
        ocean:                      \
        urban:                      \
        urban/grid:

LIBVERSION = $(shell git rev-parse --short HEAD 2> /dev/null)
ifeq ($(LIBVERSION),)
  LIBVERSION  = $(shell cat VERSION)
else
  LIBVERSION := $(LIBVERSION)
endif

SDM_EXIST := $(shell find $(TOPDIR)/contrib -name SDM 2> /dev/null )

OBJS_MP = scale_atmos_phy_mp_dry.o	\
          scale_atmos_phy_mp_kessler.o	\
          scale_atmos_phy_mp_sn14.o	\
          scale_atmos_phy_mp_sdm.o	\
          scale_atmos_phy_mp_suzuki10.o	\
          scale_atmos_phy_mp_tomita08.o

OBJS_CP = scale_atmos_phy_cp_kf.o

OBJS_AE = scale_atmos_phy_ae_dummy.o	\
          scale_atmos_phy_ae_kajino13.o

OBJS_RD = scale_atmos_phy_rd_mstrnx.o	\
          scale_atmos_phy_rd_mm5sw.o	\
          scale_atmos_phy_rd_offline.o	\
          scale_atmos_phy_rd_profile.o

OBJS_TB = scale_atmos_phy_tb_smg.o	\
          scale_atmos_phy_tb_d1980.o	\
          scale_atmos_phy_tb_dns.o	\
          scale_atmos_phy_tb_mynn.o	\
          scale_atmos_phy_tb_hybrid.o

OBJS_DYN = scale_atmos_dyn_fvm_flux_cd2.o	\
           scale_atmos_dyn_fvm_flux_cd4.o	\
           scale_atmos_dyn_fvm_flux_cd6.o	\
           scale_atmos_dyn_fvm_flux_ud1.o	\
           scale_atmos_dyn_fvm_flux_ud3.o	\
           scale_atmos_dyn_fvm_flux_ud3Koren1993.o	\
           scale_atmos_dyn_fvm_flux_ud5.o	\
           scale_atmos_dyn_fvm_flux.o	\
           scale_atmos_dyn_tinteg_large_euler.o	\
           scale_atmos_dyn_tinteg_large_rk3.o	\
           scale_atmos_dyn_tinteg_large.o	\
           scale_atmos_dyn_tinteg_short_rk3.o	\
           scale_atmos_dyn_tinteg_short_rk4.o	\
           scale_atmos_dyn_tinteg_short.o	\
           scale_atmos_dyn_tinteg_tracer_euler.o	\
           scale_atmos_dyn_tinteg_tracer_rk3.o	\
           scale_atmos_dyn_tinteg_tracer.o	\
           scale_atmos_dyn_tstep_large_fvm_heve.o	\
           scale_atmos_dyn_tstep_large.o	\
           scale_atmos_dyn_tstep_short_fvm_heve.o	\
           scale_atmos_dyn_tstep_short_fvm_hevi.o	\
           scale_atmos_dyn_tstep_short_fvm_hivi.o	\
           scale_atmos_dyn_tstep_short.o	\
           scale_atmos_dyn_tstep_tracer_fvm_heve.o	\
           scale_atmos_dyn_tstep_tracer.o

OBJS_NAME = $(scale_rdma)	\
	scale_atmos_dyn.o	\
	scale_atmos_dyn_common.o	\
	$(OBJS_DYN)	\
	scale_atmos_phy_ae.o	\
	scale_atmos_phy_ae_dummy.o	\
	$(OBJS_NUMERIC_FDM)	\
	$(OBJS_AE)	\
	scale_atmos_phy_cp.o	\
	$(OBJS_CP)	\
	scale_atmos_phy_mp.o	\
	scale_atmos_phy_mp_common.o	\
	$(OBJS_MP)	\
	scale_atmos_phy_mp_convert.o	\
	scale_atmos_phy_rd.o	\
	scale_atmos_phy_rd_common.o	\
	$(OBJS_RD)	\
	scale_atmos_phy_sf.o	\
	scale_atmos_phy_sf_bulk.o	\
	scale_atmos_phy_sf_const.o	\
	scale_atmos_phy_tb.o	\
	scale_atmos_phy_tb_common.o	\
	$(OBJS_TB)	\
	scale_atmos_sub_bottom.o	\
	scale_atmos_sub_boundary.o	\
	scale_atmos_sub_hydrostatic.o	\
	scale_atmos_sub_profile.o	\
	scale_atmos_sub_refstate.o	\
	scale_atmos_sub_saturation.o	\
	scale_atmos_sub_solarins.o	\
	scale_atmos_sub_thermodyn.o	\
	scale_atmos_sub_aerosol.o	\
	scale_atmos_sub_hydrometeor.o	\
	scale_atmos_sub_adiabat.o	\
	scale_atmos_sub_diagnostic.o	\
	scale_bulkflux.o	\
	scale_calendar.o	\
	scale_comm.o	\
	scale_const.o	\
	scale_debug.o	\
	scale_external_io.o	\
	scale_external_input.o	\
	scale_external_input_rm.o	\
	scale_fileio.o	\
	scale_grid_cartesian.o	\
	scale_grid_index.o	\
	scale_grid_nest.o	\
	scale_grid_real.o	\
	scale_index.o		\
	scale_gridtrans.o	\
	scale_history.o	\
	scale_interpolation.o	\
	scale_interpolation_nest.o	\
	scale_land_grid.o	\
	scale_land_grid_index.o	\
	scale_land_phy.o	\
	scale_land_phy_const.o	\
	scale_land_phy_slab.o	\
	scale_land_phy_matsiro.o	\
	scale_land_sfc.o	\
	scale_land_sfc_const.o	\
	scale_land_sfc_thin-slab.o	\
	scale_land_sfc_thick-slab.o	\
	scale_landuse.o	\
	scale_rm_process.o	\
	scale_rm_statistics.o	\
	scale_mapproj.o	\
	scale_matrix.o	\
	scale_monitor.o	\
	scale_ocean_phy.o	\
	scale_ocean_phy_const.o	\
	scale_ocean_phy_slab.o	\
	scale_ocean_phy_file.o	\
	scale_ocean_sfc.o	\
	scale_ocean_sfc_const.o	\
	scale_ocean_sfc_slab.o	\
	scale_precision.o	\
	scale_process.o	\
	scale_prof.o	\
	scale_random.o	\
	scale_roughness.o	\
	scale_specfunc.o	\
	scale_stdio.o	\
	scale_time.o	\
	scale_topography.o	\
	scale_tracer.o	\
	scale_urban_grid.o	\
	scale_urban_grid_index.o	\
	scale_urban_phy.o	\
	scale_urban_phy_slc.o	\
	scale_vector.o

OBJS = $(patsubst %,$(OBJ_DIR)/%,$(OBJS_NAME))

OBJS_FOR_DYN = $(OBJ_DIR)/scale_atmos_dyn.o	\
	$(OBJ_DIR)/scale_atmos_dyn_common.o	\
	$(patsubst %,$(OBJ_DIR)/%,$(OBJS_DYN))

OBJS_FOR_SDM = $(OBJ_DIR)/scale_precision.o	\
	$(OBJ_DIR)/scale_prof.o	\
	$(OBJ_DIR)/scale_comm.o	\
	$(OBJ_DIR)/scale_atmos_sub_thermodyn.o	\
	$(OBJ_DIR)/scale_atmos_sub_saturation.o	\
	$(OBJ_DIR)/scale_atmos_phy_mp_common.o	\
	$(OBJ_DIR)/scale_tracer.o	\
	$(OBJ_DIR)/scale_stdio.o	\
	$(OBJ_DIR)/scale_history.o	\
	$(OBJ_DIR)/scale_monitor.o	\
	$(OBJ_DIR)/scale_const.o	\
	$(OBJ_DIR)/scale_time.o	\
	$(OBJ_DIR)/scale_grid_index.o	\
	$(OBJ_DIR)/scale_topography.o	\
	$(OBJ_DIR)/scale_grid_cartesian.o	\
	$(OBJ_DIR)/scale_grid_real.o	\
	$(OBJ_DIR)/scale_gridtrans.o	\
	$(OBJ_DIR)/scale_rm_process.o

all:
	$(MAKE) makedir
	@echo;echo "Entering scalelib..."; echo "Current version is " $(LIBVERSION)
	$(MAKE) -C $(DCUTILSDIR)
	$(MAKE) -C $(GTOOLDIR)
ifeq ($(SCALE_ENABLE_SDM),T)
	$(MAKE) checksdm
	$(MAKE) makesdm
	$(MAKE) overridesdm
endif
	$(MAKE) $(LIBDIR)/$(LIBNAME)
	$(MAKE) modules
	@echo "Complete making scalelib."

makedir:
	mkdir -p $(MODDIR)
	mkdir -p $(LIBDIR)

$(LIBDIR)/libdcutils.a:
	$(MAKE) -C $(DCUTILSDIR)

$(LIBDIR)/libgtool.a: $(LIBDIR)/libdcutils.a
	$(MAKE) -C $(GTOOLDIR)

$(LIBNAME): $(LIBDIR)/$(LIBNAME)
	install $< $@

$(LIBDIR)/$(LIBNAME): $(OBJS)
	$(AR) $(ARFLAGS) $@ $?
	$(RANLIB) $@

ifeq ($(SCALE_IGNORE_SRCDEP),T)
modules:
else
modules: $(OBJS)
	install $(MODS) $(MODDIR)
endif

makesdm: $(OBJS_FOR_SDM)
	$(MAKE) -C $(MTDIR)
	$(MAKE) -C $(GAGETRYDIR)
	$(MAKE) -C $(SDMDIR)

checksdm:
ifneq ($(SDM_EXIST),$(SDMDIR))
	@echo "SDM directory is missing!" $(SDM_EXIST)
	@echo "********************************************************************************************* "
	@echo "** SDM module, which is compiled with 'SCALE_ENABLE_SDM=T', is not supported.              ** "
	@echo "** If you want to use SDM module, please contact Dr. S.Shima(s_shima@sim.u-hyogo.ac.jp)    ** "
	@echo "********************************************************************************************* "
	exit 1
endif

overridesdm:
	@echo;echo "Copy SDM-related file from $(SDMDIR)"
	rsync -th $(SDMDIR)/scale_atmos_phy_mp_sdm.F90 $(SCALELIBDIR)/src/atmos-physics/microphysics/
	@echo

restoresdm:
	@echo;echo "Restore SDM-related file"
	rsync -th $(SDMDIR)/scale_atmos_phy_mp_sdm_dummy.F90 $(SCALELIBDIR)/src/atmos-physics/microphysics/scale_atmos_phy_mp_sdm.F90
	@echo

allcleansdm:
	$(MAKE) -C $(MTDIR)      allclean
	$(MAKE) -C $(GAGETRYDIR) allclean
	$(MAKE) -C $(SDMDIR)     allclean

cleansdm:
	$(MAKE) -C $(SDMDIR)     clean



allclean: distclean
	$(MAKE) -C $(DCUTILSDIR) allclean
	$(MAKE) -C $(GTOOLDIR)   allclean
ifeq ($(SCALE_ENABLE_SDM),T)
	$(MAKE) checksdm
	$(MAKE) restoresdm
	$(MAKE) allcleansdm
endif
	rm -f $(LIBDIR)/$(LIBNAME)

distclean: clean
	rm -f $(LIBNAME)

clean:
ifeq ($(SCALE_ENABLE_SDM),T)
	$(MAKE) checksdm
	$(MAKE) restoresdm
	$(MAKE) cleansdm
endif
	rm -f *.o *.mod *.lst

dependency:
	./makedepend .



.SUFFIXES:
.SUFFIXES: .o .f90 .F90 .c .erb .mod

%.F90 : %.F90.erb
	erb $< > $@

%.mod: %.F90
	make $(patsubst %.F90,%.o,$<)

$(MODDIR)/%.mod : %.mod
	install $< $@

$(OBJ_DIR)/%.o : %.F90
	$(FC) $(FFLAGS)     $(ADDITIONAL_FFLAGS) -DVERSION_MACRO=\"$(LIBVERSION)\" -I$(DCUTILSDIR) -I$(GTOOLDIR) -I$(INDEX_DIR) -I$(SCALELIBDIR)/include -I$(OBJ_DIR) $(SCALE_PAPI_INCLUDE) $(SCALE_NETCDF_INCLUDE) $(CONTRIB_INCLUDE) $(MODDIROPT) $(OBJ_DIR) -o $@ -c $<
$(OBJS_FOR_DYN) :
	$(FC) $(FFLAGS_DYN) $(ADDITIONAL_FFLAGS) -DVERSION_MACRO=\"$(LIBVERSION)\" -I$(DCUTILSDIR) -I$(GTOOLDIR) -I$(INDEX_DIR) -I$(SCALELIBDIR)/include -I$(OBJ_DIR) $(SCALE_PAPI_INCLUDE) $(MODDIROPT) $(OBJ_DIR) -o $@ -c $<

scale_atmos_dyn_fvm_flux_%.F90 : scale_atmos_dyn_fvm_flux_udcd.F90.erb
	fname=$@ erb $< > $@
#	erb fname=$@ $< > $@

$(OBJ_DIR)/%.o : %.c
	$(CC) $(CFLAGS) -I$(SCALELIBDIR)/include -o $@ -c $<

.PHONY : clean distclean allclean depend modules dependency

include $(TOPDIR)/utils/Make_environments

ifneq ($(SCALE_IGNORE_SRCDEP),T)
-include depend
endif
# DO NOT DELETE
