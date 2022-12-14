!-------------------------------------------------------------------------------
!> module OCEAN / Surface flux with constant ocean model
!!
!! @par Description
!!          Surface flux with constant ocean model
!!
!! @author Team SCALE
!!
!<
!-------------------------------------------------------------------------------
module scale_ocean_sfc_const
  !-----------------------------------------------------------------------------
  !
  !++ used modules
  !
  use scale_precision
  use scale_stdio
  use scale_grid_index
  !-----------------------------------------------------------------------------
  implicit none
  private
  !-----------------------------------------------------------------------------
  !
  !++ Public procedure
  !
  public :: OCEAN_SFC_CONST_setup
  public :: OCEAN_SFC_CONST

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
  !-----------------------------------------------------------------------------
contains
  !-----------------------------------------------------------------------------
  !> Setup
  subroutine OCEAN_SFC_CONST_setup( OCEAN_TYPE )
    implicit none

    character(len=*), intent(in) :: OCEAN_TYPE
    !---------------------------------------------------------------------------

    if( IO_L ) write(IO_FID_LOG,*)
    if( IO_L ) write(IO_FID_LOG,*) '++++++ Module[CONST] / Categ[OCEAN SFC] / Origin[SCALElib]'

    return
  end subroutine OCEAN_SFC_CONST_setup

  !-----------------------------------------------------------------------------
  subroutine OCEAN_SFC_CONST( &
        SST_t,  & ! [OUT]
        ZMFLX,  & ! [OUT]
        XMFLX,  & ! [OUT]
        YMFLX,  & ! [OUT]
        SHFLX,  & ! [OUT]
        LHFLX,  & ! [OUT]
        WHFLX,  & ! [OUT]
        U10,    & ! [OUT]
        V10,    & ! [OUT]
        T2,     & ! [OUT]
        Q2,     & ! [OUT]
        TMPA,   & ! [IN]
        PRSA,   & ! [IN]
        WA,     & ! [IN]
        UA,     & ! [IN]
        VA,     & ! [IN]
        RHOA,   & ! [IN]
        QVA,    & ! [IN]
        Z1,     & ! [IN]
        PBL,    & ! [IN]
        PRSS,   & ! [IN]
        LWD,    & ! [IN]
        SWD,    & ! [IN]
        TW,     & ! [IN]
        SST,    & ! [IN]
        ALB_LW, & ! [IN]
        ALB_SW, & ! [IN]
        Z0M,    & ! [IN]
        Z0H,    & ! [IN]
        Z0E,    & ! [IN]
        dt      ) ! [IN]
    use scale_process, only: &
      PRC_MPIstop
    use scale_const, only: &
      PRE00 => CONST_PRE00, &
      Rdry  => CONST_Rdry,  &
      CPdry => CONST_CPdry, &
      STB   => CONST_STB
    use scale_landuse, only: &
      LANDUSE_fact_ocean
    use scale_bulkflux, only: &
      BULKFLUX
    use scale_atmos_hydrometeor, only: &
      HYDROMETEOR_LHV => ATMOS_HYDROMETEOR_LHV
    use scale_atmos_saturation, only: &
      qsat => ATMOS_SATURATION_pres2qsat_all
    implicit none

    ! arguments
    real(RP), intent(out) :: SST_t(IA,JA) ! tendency of sea surface temperature
    real(RP), intent(out) :: ZMFLX(IA,JA) ! z-momentum flux at the surface [kg/m/s2]
    real(RP), intent(out) :: XMFLX(IA,JA) ! x-momentum flux at the surface [kg/m/s2]
    real(RP), intent(out) :: YMFLX(IA,JA) ! y-momentum flux at the surface [kg/m/s2]
    real(RP), intent(out) :: SHFLX(IA,JA) ! sensible heat flux at the surface [W/m2]
    real(RP), intent(out) :: LHFLX(IA,JA) ! latent heat flux at the surface [W/m2]
    real(RP), intent(out) :: WHFLX(IA,JA) ! water heat flux at the surface [W/m2]
    real(RP), intent(out) :: U10  (IA,JA) ! velocity u at 10m [m/s]
    real(RP), intent(out) :: V10  (IA,JA) ! velocity v at 10m [m/s]
    real(RP), intent(out) :: T2   (IA,JA) ! temperature at 2m [K]
    real(RP), intent(out) :: Q2   (IA,JA) ! water vapor at 2m [kg/kg]

    real(RP), intent(in) :: TMPA(IA,JA) ! temperature at the lowest atmospheric layer [K]
    real(RP), intent(in) :: PRSA(IA,JA) ! pressure at the lowest atmospheric layer [Pa]
    real(RP), intent(in) :: WA  (IA,JA) ! velocity w at the lowest atmospheric layer [m/s]
    real(RP), intent(in) :: UA  (IA,JA) ! velocity u at the lowest atmospheric layer [m/s]
    real(RP), intent(in) :: VA  (IA,JA) ! velocity v at the lowest atmospheric layer [m/s]
    real(RP), intent(in) :: RHOA(IA,JA) ! density at the lowest atmospheric layer [kg/m3]
    real(RP), intent(in) :: QVA (IA,JA) ! ratio of water vapor mass to total mass at the lowest atmospheric layer [kg/kg]
    real(RP), intent(in) :: Z1  (IA,JA) ! cell center height at the lowest atmospheric layer [m]
    real(RP), intent(in) :: PBL (IA,JA) ! the top of atmospheric mixing layer [m]
    real(RP), intent(in) :: PRSS(IA,JA) ! pressure at the surface [Pa]
    real(RP), intent(in) :: LWD (IA,JA) ! downward long-wave radiation flux at the surface [W/m2]
    real(RP), intent(in) :: SWD (IA,JA) ! downward short-wave radiation flux at the surface [W/m2]

    real(RP), intent(in) :: TW    (IA,JA) ! water temperature [K]
    real(RP), intent(in) :: SST   (IA,JA) ! sea surface temperature [K]
    real(RP), intent(in) :: ALB_LW(IA,JA) ! surface albedo for LW (0-1)
    real(RP), intent(in) :: ALB_SW(IA,JA) ! surface albedo for SW (0-1)
    real(RP), intent(in) :: Z0M   (IA,JA) ! roughness length for momentum [m]
    real(RP), intent(in) :: Z0H   (IA,JA) ! roughness length for heat [m]
    real(RP), intent(in) :: Z0E   (IA,JA) ! roughness length for vapor [m]
    real(DP), intent(in) :: dt            ! delta time

    ! works
    real(RP) :: Ustar ! friction velocity [m]
    real(RP) :: Tstar ! friction temperature [K]
    real(RP) :: Qstar ! friction mixing rate [kg/kg]
    real(RP) :: Uabs  ! modified absolute velocity [m/s]

    real(RP) :: QVsat        ! saturation water vapor mixing ratio at surface [kg/kg]
    real(RP) :: LHV(IA,JA)   ! latent heat of vaporization [J/kg]

    real(RP) :: FracU10 ! calculation parameter for U10 [-]
    real(RP) :: FracT2  ! calculation parameter for T2 [-]
    real(RP) :: FracQ2  ! calculation parameter for Q2 [-]

    integer :: i, j
    !---------------------------------------------------------------------------

    if( IO_L ) write(IO_FID_LOG,*) '*** Ocean surface step: Const'

    call HYDROMETEOR_LHV( LHV(:,:), TMPA(:,:) )

    ! calculate tendency
    do j = JS, JE
    do i = IS, IE
      SST_t(i,j) = 0.0_RP
    enddo
    enddo

    ! calculate surface flux
    do j = JS, JE
    do i = IS, IE

      if( LANDUSE_fact_ocean(i,j) > 0.0_RP ) then

        ! saturation at the surface
        call qsat( QVsat,     & ! [OUT]
                   SST (i,j), & ! [IN]
                   PRSS(i,j)  ) ! [IN]

        call BULKFLUX( &
            Ustar,     & ! [OUT]
            Tstar,     & ! [OUT]
            Qstar,     & ! [OUT]
            Uabs,      & ! [OUT]
            FracU10,   & ! [OUT]
            FracT2,    & ! [OUT]
            FracQ2,    & ! [OUT]
            TMPA(i,j), & ! [IN]
            SST (i,j), & ! [IN]
            PRSA(i,j), & ! [IN]
            PRSS(i,j), & ! [IN]
            QVA (i,j), & ! [IN]
            QVsat,     & ! [IN]
            UA  (i,j), & ! [IN]
            VA  (i,j), & ! [IN]
            Z1  (i,j), & ! [IN]
            PBL (i,j), & ! [IN]
            Z0M (i,j), & ! [IN]
            Z0H (i,j), & ! [IN]
            Z0E (i,j)  ) ! [IN]

        ZMFLX(i,j) = -RHOA(i,j) * Ustar**2 / Uabs * WA(i,j)
        XMFLX(i,j) = -RHOA(i,j) * Ustar**2 / Uabs * UA(i,j)
        YMFLX(i,j) = -RHOA(i,j) * Ustar**2 / Uabs * VA(i,j)

        SHFLX(i,j) = - RHOA(i,j) * Ustar * Tstar &
                   * CPdry * ( PRSS(i,j) / PRE00 )**( Rdry/CPdry )
        LHFLX(i,j) = - RHOA(i,j) * Ustar * Qstar * LHV(i,j)

        ! calculation for residual
        WHFLX(i,j) = ( 1.0_RP - ALB_SW(i,j) ) * SWD(i,j) * (-1.0_RP) &
                   - ( 1.0_RP - ALB_LW(i,j) ) * ( LWD(i,j) - STB * SST(i,j)**4 ) &
                   + SHFLX(i,j) + LHFLX(i,j)

        ! diagnostic variables considering unstable/stable state
        !U10(i,j) = FracU10 * UA(i,j)
        !V10(i,j) = FracU10 * VA(i,j)
        !T2 (i,j) = ( 1.0_RP - FracT2 ) * SST(i,j) + FracT2 * TMPA(i,j)
        !Q2 (i,j) = ( 1.0_RP - FracQ2 ) * QVsat    + FracQ2 * QVA (i,j)

        ! diagnostic variables for neutral state
        U10(i,j) = UA (i,j) * log( 10.0_RP / Z0M(i,j) ) / log( Z1(i,j) / Z0M(i,j) )
        V10(i,j) = VA (i,j) * log( 10.0_RP / Z0M(i,j) ) / log( Z1(i,j) / Z0M(i,j) )
        T2 (i,j) = SST(i,j) + ( TMPA(i,j) - SST(i,j) ) * ( log(  2.0_RP / Z0M(i,j) ) * log(  2.0_RP / Z0H(i,j) ) ) &
                                                       / ( log( Z1(i,j) / Z0M(i,j) ) * log( Z1(i,j) / Z0H(i,j) ) )
        Q2 (i,j) = QVsat    + (  QVA(i,j) - QVsat    ) * ( log(  2.0_RP / Z0M(i,j) ) * log(  2.0_RP / Z0E(i,j) ) ) &
                                                       / ( log( Z1(i,j) / Z0M(i,j) ) * log( Z1(i,j) / Z0E(i,j) ) )

      else

        ! not calculate surface flux
        ZMFLX(i,j) = 0.0_RP
        XMFLX(i,j) = 0.0_RP
        YMFLX(i,j) = 0.0_RP
        SHFLX(i,j) = 0.0_RP
        LHFLX(i,j) = 0.0_RP
        WHFLX(i,j) = 0.0_RP
        U10  (i,j) = 0.0_RP
        V10  (i,j) = 0.0_RP
        T2   (i,j) = 0.0_RP
        Q2   (i,j) = 0.0_RP

      end if

    enddo
    enddo

    return
  end subroutine OCEAN_SFC_CONST

end module scale_ocean_sfc_const
