!-------------------------------------------------------------------------------
!> module ATMOSPHERE / Physics Turbulence
!!
!! @par Description
!!          Sub-grid scale turbulent process for DNS
!!
!! @author Team SCALE
!!
!! @par History
!! @li      2014-03-30 (A.Noda)       [new] produced based on scale_atmos_phy_tb_smg.F90
!!
!<
!-------------------------------------------------------------------------------
module scale_atmos_phy_tb_dns
  !-----------------------------------------------------------------------------
  !
  !++ used modules
  !
  use scale_precision
  use scale_stdio
  use scale_prof
  use scale_grid_index
  use scale_tracer

#ifdef DEBUG
  use scale_debug, only: &
     CHECK
  use scale_const, only: &
     UNDEF  => CONST_UNDEF, &
     IUNDEF => CONST_UNDEF2
#endif
  !-----------------------------------------------------------------------------
  implicit none
  private
  !-----------------------------------------------------------------------------
  !
  !++ Public procedure
  !
  public :: ATMOS_PHY_TB_dns_config
  public :: ATMOS_PHY_TB_dns_setup
  public :: ATMOS_PHY_TB_dns

  !-----------------------------------------------------------------------------
  !
  !++ Public parameters & variables
  !
  !-----------------------------------------------------------------------------
  !
  !++ Private procedure
  !
  !-----------------------------------------------------------------------------
  !
  !++ Private parameters & variables
  !
  real(RP), private :: ATMOS_PHY_TB_DNS_NU = 1.512E-5_RP ! [m2/s] kinematic viscosity coefficient for air at 20degC
! real(RP), private :: mu = 1.8E-5_RP   ! [m2/s] molecular diffusive coefficient for air at 20degC
  real(RP), private :: ATMOS_PHY_TB_DNS_MU = 1.512E-5_RP ! same as NU (needed based on hyposes. see Mellado 2010)

  !-----------------------------------------------------------------------------
contains
  !-----------------------------------------------------------------------------
  !> Config
  subroutine ATMOS_PHY_TB_dns_config( &
       TYPE_TB,  &
       I_TKE_out )
    use scale_process, only: &
       PRC_MPIstop
    implicit none

    character(len=*), intent(in)  :: TYPE_TB
    integer,          intent(out) :: I_TKE_out
    !---------------------------------------------------------------------------

    if( IO_L ) write(IO_FID_LOG,*)
    if( IO_L ) write(IO_FID_LOG,*) '++++++ Module[Turbulence Tracer] / Categ[ATMOS PHYSICS] / Origin[SCALElib]'
    if( IO_L ) write(IO_FID_LOG,*) '*** Tracers for Deardorff (1980) 1.5th TKE Model'

    if ( TYPE_TB /= 'DNS' ) then
       write(*,*) 'xxx ATMOS_PHY_TB_TYPE is not DNS. Check!'
       call PRC_MPIstop
    endif

    I_TKE_out = -1

    return
  end subroutine ATMOS_PHY_TB_dns_config
  !-----------------------------------------------------------------------------
  subroutine ATMOS_PHY_TB_dns_setup( &
       CDZ, CDX, CDY, CZ )
    use scale_process, only: &
       PRC_MPIstop
    implicit none

    real(RP), intent(in) :: CDZ(KA)
    real(RP), intent(in) :: CDX(IA)
    real(RP), intent(in) :: CDY(JA)
    real(RP), intent(in) :: CZ (KA,IA,JA)

    NAMELIST / PARAM_ATMOS_PHY_TB_DNS / &
       ATMOS_PHY_TB_DNS_NU, &
       ATMOS_PHY_TB_DNS_MU

    integer :: ierr
    !---------------------------------------------------------------------------

    if( IO_L ) write(IO_FID_LOG,*)
    if( IO_L ) write(IO_FID_LOG,*) '++++++ Module[Turbulence] / Categ[ATMOS PHYSICS] / Origin[SCALElib]'
    if( IO_L ) write(IO_FID_LOG,*) '*** Eddy Viscocity Model for DNS'

    !--- read namelist
    rewind(IO_FID_CONF)
    read(IO_FID_CONF,nml=PARAM_ATMOS_PHY_TB_DNS,iostat=ierr)
    if( ierr < 0 ) then !--- missing
       if( IO_L ) write(IO_FID_LOG,*) '*** Not found namelist. Default used.'
    elseif( ierr > 0 ) then !--- fatal error
       write(*,*) 'xxx Not appropriate names in namelist PARAM_ATMOS_PHY_TB_DNS. Check!'
       call PRC_MPIstop
    endif
    if( IO_NML ) write(IO_FID_NML,nml=PARAM_ATMOS_PHY_TB_DNS)

    return
  end subroutine ATMOS_PHY_TB_dns_setup

  !-----------------------------------------------------------------------------
  subroutine ATMOS_PHY_TB_dns( &
       qflx_sgs_MOMZ, qflx_sgs_MOMX, qflx_sgs_MOMY, &
       qflx_sgs_rhot, qflx_sgs_rhoq,                &
       RHOQ_t, nu, Ri, Pr,                          &
       MOMZ, MOMX, MOMY, RHOT, DENS, QTRC, N2,      &
       SFLX_MW, SFLX_MU, SFLX_MV, SFLX_SH, SFLX_Q,  &
       GSQRT, J13G, J23G, J33G, MAPF, dt            )
    use scale_grid_index
    use scale_tracer
    use scale_const, only: &
       GRAV => CONST_GRAV
    use scale_grid, only: &
       RCDZ => GRID_RCDZ, &
       RCDX => GRID_RCDX, &
       RCDY => GRID_RCDY, &
       RFDZ => GRID_RFDZ, &
       RFDX => GRID_RFDX, &
       RFDY => GRID_RFDY
    use scale_gridtrans, only: &
       I_XY, &
       I_UY, &
       I_XV
    implicit none

    ! SGS flux
    real(RP), intent(out) :: qflx_sgs_MOMZ(KA,IA,JA,3)
    real(RP), intent(out) :: qflx_sgs_MOMX(KA,IA,JA,3)
    real(RP), intent(out) :: qflx_sgs_MOMY(KA,IA,JA,3)
    real(RP), intent(out) :: qflx_sgs_rhot(KA,IA,JA,3)
    real(RP), intent(out) :: qflx_sgs_rhoq(KA,IA,JA,3,QA)

    real(RP), intent(inout) :: RHOQ_t(KA,IA,JA,QA) ! tendency of rho * QTRC

    real(RP), intent(out) :: nu(KA,IA,JA) ! eddy viscosity (center)
    real(RP), intent(out) :: Ri(KA,IA,JA) ! Richardson number
    real(RP), intent(out) :: Pr(KA,IA,JA) ! Prantle number

    real(RP), intent(in)  :: MOMZ(KA,IA,JA)
    real(RP), intent(in)  :: MOMX(KA,IA,JA)
    real(RP), intent(in)  :: MOMY(KA,IA,JA)
    real(RP), intent(in)  :: RHOT(KA,IA,JA)
    real(RP), intent(in)  :: DENS(KA,IA,JA)
    real(RP), intent(in)  :: QTRC(KA,IA,JA,QA)
    real(RP), intent(in)  :: N2(KA,IA,JA)

    real(RP), intent(in)  :: SFLX_MW(IA,JA)
    real(RP), intent(in)  :: SFLX_MU(IA,JA)
    real(RP), intent(in)  :: SFLX_MV(IA,JA)
    real(RP), intent(in)  :: SFLX_SH(IA,JA)
    real(RP), intent(in)  :: SFLX_Q (IA,JA,QA)

    real(RP), intent(in)  :: GSQRT   (KA,IA,JA,7) !< vertical metrics {G}^1/2
    real(RP), intent(in)  :: J13G    (KA,IA,JA,7) !< (1,3) element of Jacobian matrix
    real(RP), intent(in)  :: J23G    (KA,IA,JA,7) !< (1,3) element of Jacobian matrix
    real(RP), intent(in)  :: J33G                 !< (3,3) element of Jacobian matrix
    real(RP), intent(in)  :: MAPF    (IA,JA,2,4)  !< map factor
    real(DP), intent(in)  :: dt

    real(RP) :: POTT(KA,IA,JA)

    integer :: IIS, IIE
    integer :: JJS, JJE

    integer :: k, i, j, iq
    !---------------------------------------------------------------------------

#ifdef DEBUG
    qflx_sgs_MOMZ(:,:,:,:)   = UNDEF
    qflx_sgs_MOMX(:,:,:,:)   = UNDEF
    qflx_sgs_MOMY(:,:,:,:)   = UNDEF
    qflx_sgs_rhot(:,:,:,:)   = UNDEF
    qflx_sgs_rhoq(:,:,:,:,:) = UNDEF

    POTT(:,:,:) = UNDEF
#endif

    nu (:,:,:) = 0.0_RP
    Ri (:,:,:) = 0.0_RP
    Pr (:,:,:) = 1.0_RP

    ! potential temperature
    do j = JS-1, JE+1
    do i = IS-1, IE+1
    do k = KS, KE
       POTT(k,i,j) = RHOT(k,i,j) / DENS(k,i,j)
    enddo
    enddo
    enddo

    !##### Start Upadate #####
    do JJS = JS, JE, JBLOCK
    JJE = JJS+JBLOCK-1
    do IIS = IS, IE, IBLOCK
    IIE = IIS+IBLOCK-1

       !##### momentum equation (z) #####
       ! (cell center)
       do j = JJS, JJE
       do i = IIS, IIE
       do k = KS+1, KE-1
          qflx_sgs_MOMZ(k,i,j,ZDIR) = -ATMOS_PHY_TB_DNS_NU * ( MOMZ(k,i,j)-MOMZ(k-1,i,j) ) * RCDZ(k)
       enddo
       enddo
       enddo

       do j = JJS, JJE
       do i = IIS, IIE
          qflx_sgs_MOMZ(KS,i,j,ZDIR) = 0.0_RP ! bottom boundary
          qflx_sgs_MOMZ(KE,i,j,ZDIR) = 0.0_RP ! top boundary
       enddo
       enddo

       ! (y edge)
       do j = JJS,   JJE
       do i = IIS-1, IIE
       do k = KS, KE-1
          qflx_sgs_MOMZ(k,i,j,XDIR) = -ATMOS_PHY_TB_DNS_NU * ( MOMZ(k,i+1,j)-MOMZ(k,i,j) ) * RFDX(i) * MAPF(i,j,1,I_XY)
       enddo
       enddo
       enddo

       ! (x edge)
       do j = JJS-1, JJE
       do i = IIS,   IIE
       do k = KS, KE-1
          qflx_sgs_MOMZ(k,i,j,YDIR) = -ATMOS_PHY_TB_DNS_NU * ( MOMZ(k,i,j+1)-MOMZ(k,i,j) ) * RFDY(j) * MAPF(i,j,2,I_XY)
       enddo
       enddo
       enddo

       !##### momentum equation (x) #####
       ! (y edge)
       do j = JJS, JJE
       do i = IIS, IIE
       do k = KS, KE-1
          qflx_sgs_MOMX(k,i,j,ZDIR) = -ATMOS_PHY_TB_DNS_NU * ( MOMX(k+1,i,j)-MOMX(k,i,j) ) * RFDZ(k)
       enddo
       enddo
       enddo

       do j = JJS, JJE
       do i = IIS, IIE
          qflx_sgs_MOMX(KS-1,i,j,ZDIR) = 0.0_RP ! bottom boundary
          qflx_sgs_MOMX(KE  ,i,j,ZDIR) = 0.0_RP ! top boundary
       enddo
       enddo

       ! (cell center)
       do j = JJS, JJE
       do i = IIS, IIE+1
       do k = KS, KE
          qflx_sgs_MOMX(k,i,j,XDIR) = -ATMOS_PHY_TB_DNS_NU * ( MOMX(k,i,j)-MOMX(k,i-1,j) ) * RCDX(i) * MAPF(i,j,1,I_UY)
       enddo
       enddo
       enddo

       ! (z edge)
       do j = JJS-1, JJE
       do i = IIS,   IIE
       do k = KS, KE
          qflx_sgs_MOMX(k,i,j,YDIR) = -ATMOS_PHY_TB_DNS_NU * ( MOMX(k,i,j+1)-MOMX(k,i,j) ) * RFDY(j) * MAPF(i,j,2,I_UY)
       enddo
       enddo
       enddo

       !##### momentum equation (y) #####

       ! (x edge)
       do j = JJS, JJE
       do i = IIS, IIE
       do k = KS, KE-1
          qflx_sgs_MOMY(k,i,j,ZDIR) = -ATMOS_PHY_TB_DNS_NU * ( MOMY(k+1,i,j)-MOMY(k,i,j) ) * RFDZ(k)
       enddo
       enddo
       enddo

       do j = JJS, JJE
       do i = IIS, IIE
          qflx_sgs_MOMY(KS-1,i,j,ZDIR) = 0.0_RP ! bottom boundary
          qflx_sgs_MOMY(KE  ,i,j,ZDIR) = 0.0_RP ! top boundary
       enddo
       enddo

       ! (z edge)
       do j = JJS,   JJE
       do i = IIS-1, IIE
       do k = KS, KE
          qflx_sgs_MOMY(k,i,j,XDIR) = -ATMOS_PHY_TB_DNS_NU * ( MOMY(k,i+1,j)-MOMY(k,i,j) ) * RFDX(i) * MAPF(i,j,1,I_XV)
       enddo
       enddo
       enddo

       ! (z-x plane)
       do j = JJS, JJE+1
       do i = IIS, IIE
       do k = KS, KE
          qflx_sgs_MOMY(k,i,j,YDIR) = -ATMOS_PHY_TB_DNS_NU * ( MOMY(k,i,j)-MOMY(k,i,j-1) ) * RCDY(j) * MAPF(i,j,2,I_XV)
       enddo
       enddo
       enddo

       !##### Thermodynamic Equation #####

       ! at x, y ,w
       do j = JJS, JJE
       do i = IIS, IIE
       do k = KS, KE-1
          qflx_sgs_rhot(k,i,j,ZDIR) = -0.5_RP * ( DENS(k+1,i,j)+DENS(k,i,j) ) &
                                    * ATMOS_PHY_TB_DNS_MU * ( POTT(k+1,i,j)-POTT(k,i,j) ) * RFDZ(k)
       enddo
       enddo
       enddo

       do j = JJS, JJE
       do i = IIS, IIE
          qflx_sgs_rhot(KS-1,i,j,ZDIR) = 0.0_RP
          qflx_sgs_rhot(KE  ,i,j,ZDIR) = 0.0_RP
       enddo
       enddo

       ! at u, y, z
       do j = JJS,   JJE
       do i = IIS-1, IIE
       do k = KS, KE
          qflx_sgs_rhot(k,i,j,XDIR) = -0.5_RP * ( DENS(k,i+1,j)+DENS(k,i,j) ) &
                                    * ATMOS_PHY_TB_DNS_MU * ( POTT(k,i+1,j)-POTT(k,i,j) ) * RFDX(i) * MAPF(i,j,1,I_XY)
       enddo
       enddo
       enddo

       ! at x, v, z
       do j = JJS-1, JJE
       do i = IIS,   IIE
       do k = KS, KE
          qflx_sgs_rhot(k,i,j,YDIR) = -0.5_RP * ( DENS(k,i,j+1)+DENS(k,i,j) ) &
                                    * ATMOS_PHY_TB_DNS_MU * ( POTT(k,i,j+1)-POTT(k,i,j) ) * RFDY(j) * MAPF(i,j,2,I_XY)
       enddo
       enddo
       enddo

    enddo
    enddo

    !##### Tracers #####
    do iq = 1, QA

    if ( .not. TRACER_ADVC(iq) ) cycle

    do JJS = JS, JE, JBLOCK
    JJE = JJS+JBLOCK-1
    do IIS = IS, IE, IBLOCK
    IIE = IIS+IBLOCK-1

       ! at x, y ,w
       do j = JJS, JJE
       do i = IIS, IIE
       do k = KS, KE-1
          qflx_sgs_rhoq(k,i,j,ZDIR,iq) = -0.5_RP * ( DENS(k+1,i,j)+DENS(k,i,j) ) &
                                       * ATMOS_PHY_TB_DNS_MU * ( QTRC(k+1,i,j,iq)-QTRC(k,i,j,iq) ) * RFDZ(k)
       enddo
       enddo
       enddo
       do j = JJS, JJE
       do i = IIS, IIE
          qflx_sgs_rhoq(KS-1,i,j,ZDIR,iq) = 0.0_RP
          qflx_sgs_rhoq(KE  ,i,j,ZDIR,iq) = 0.0_RP
       enddo
       enddo

       ! at u, y, z
       do j = JJS,   JJE
       do i = IIS-1, IIE
       do k = KS,   KE
          qflx_sgs_rhoq(k,i,j,XDIR,iq) = -0.5_RP * ( DENS(k,i+1,j)+DENS(k,i,j) ) &
                                       * ATMOS_PHY_TB_DNS_MU * ( QTRC(k,i+1,j,iq)-QTRC(k,i,j,iq) ) * RFDX(i) * MAPF(i,j,1,I_XY)
       enddo
       enddo
       enddo

       ! at x, v, z
       do j = JJS-1, JJE
       do i = IIS,   IIE
       do k = KS,   KE
          qflx_sgs_rhoq(k,i,j,YDIR,iq) = -0.5_RP * ( DENS(k,i,j+1)+DENS(k,i,j) ) &
                                       * ATMOS_PHY_TB_DNS_MU * ( QTRC(k,i,j+1,iq)-QTRC(k,i,j,iq) ) * RFDY(j) * MAPF(i,j,2,I_XY)
       enddo
       enddo
       enddo

    enddo
    enddo

    enddo ! scalar quantities loop

    return
  end subroutine ATMOS_PHY_TB_dns

end module scale_atmos_phy_tb_dns
