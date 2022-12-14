!-------------------------------------------------------------------------------
!> module ATMOSPHERE / Physics Aerosol Microphysics
!!
!! @par Description
!!          dummy code
!!
!! @author Team SCALE
!!
!! @par History
!! @li      2013-02-06 (H.Yashiro)  [new]
!!
!<
!-------------------------------------------------------------------------------
module scale_atmos_phy_ae_dummy
  !-----------------------------------------------------------------------------
  !
  !++ used modules
  !
  use scale_precision
  use scale_stdio
  use scale_prof
  use scale_grid_index
  use scale_tracer
  !-----------------------------------------------------------------------------
  implicit none
  private
  !-----------------------------------------------------------------------------
  !
  !++ Public procedure
  !
  public :: ATMOS_PHY_AE_dummy_config
  public :: ATMOS_PHY_AE_dummy_setup
  public :: ATMOS_PHY_AE_dummy

  public :: ATMOS_PHY_AE_dummy_EffectiveRadius

  !-----------------------------------------------------------------------------
  !
  !++ Public parameters & variables
  !
  integer, public, parameter :: QA_AE  = 0

  character(len=H_SHORT), public, target :: ATMOS_PHY_AE_dummy_NAME(QA_AE)
  character(len=H_MID)  , public, target :: ATMOS_PHY_AE_dummy_DESC(QA_AE)
  character(len=H_SHORT), public, target :: ATMOS_PHY_AE_dummy_UNIT(QA_AE)

  real(RP), public, target :: ATMOS_PHY_AE_dummy_DENS(QA_AE) ! hydrometeor density [kg/m3]=[g/L]

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
  !> Config
  subroutine ATMOS_PHY_AE_dummy_config( &
       AE_TYPE, &
       QA_AE, QS_AE )
    use scale_process, only: &
       PRC_MPIstop
    implicit none
    character(len=*), intent(in)  :: AE_TYPE
    integer,          intent(out) :: QA_AE
    integer,          intent(out) :: QS_AE
    !---------------------------------------------------------------------------

    if( IO_L ) write(IO_FID_LOG,*)
    if( IO_L ) write(IO_FID_LOG,*) '++++++ Module[Aerosol Tracer] / Categ[ATMOS PHYSICS] / Origin[SCALElib]'
    if( IO_L ) write(IO_FID_LOG,*) '*** No tracers for dummy process'

    if ( AE_TYPE /= 'DUMMY' .AND. AE_TYPE /= 'NONE' ) then
       write(*,*) 'xxx ATMOS_PHY_AE_TYPE is not DUMMY. Check!'
       call PRC_MPIstop
    endif

    QA_AE = 0
    QS_AE = -1

    return
  end subroutine ATMOS_PHY_AE_dummy_config

  !-----------------------------------------------------------------------------
  !> Setup
  subroutine ATMOS_PHY_AE_dummy_setup
    implicit none

    if( IO_L ) write(IO_FID_LOG,*)
    if( IO_L ) write(IO_FID_LOG,*) '++++++ Module[Aerosol] / Categ[ATMOS PHYSICS] / Origin[SCALElib]'
    if( IO_L ) write(IO_FID_LOG,*) '*** dummy process'

    return
  end subroutine ATMOS_PHY_AE_dummy_setup

  !-----------------------------------------------------------------------------
  !> Aerosol Microphysics
  subroutine ATMOS_PHY_AE_dummy( &
       QQA,  &
       DENS, &
       MOMZ, &
       MOMX, &
       MOMY, &
       RHOT, &
       EMIT, &
       NREG, &
       QTRC, &
       CN,   &
       CCN,  &
       RHOQ_t_AE )
    use scale_grid_index
    use scale_tracer
    implicit none
    integer,  intent(in)    :: QQA
    real(RP), intent(inout) :: DENS(KA,IA,JA)
    real(RP), intent(inout) :: MOMZ(KA,IA,JA)
    real(RP), intent(inout) :: MOMX(KA,IA,JA)
    real(RP), intent(inout) :: MOMY(KA,IA,JA)
    real(RP), intent(inout) :: RHOT(KA,IA,JA)
    real(RP), intent(inout) :: EMIT(KA,IA,JA,QQA)
    real(RP), intent(in)    :: NREG(KA,IA,JA)
    real(RP), intent(inout) :: QTRC(KA,IA,JA,QA)
    real(RP), intent(out)   :: CN(KA,IA,JA)
    real(RP), intent(out)   :: CCN(KA,IA,JA)
    real(RP), intent(inout) :: RHOQ_t_AE(KA,IA,JA,QA)

    if( IO_L ) write(IO_FID_LOG,*) '*** Atmos physics  step: Aerosol(dummy)'

    CN(:,:,:) = 0.0_RP
    CCN(:,:,:) = 0.0_RP

    return
  end subroutine ATMOS_PHY_AE_dummy

  !-----------------------------------------------------------------------------
  !> Calculate Effective Radius
  subroutine ATMOS_PHY_AE_dummy_EffectiveRadius( &
       Re,   &
       QTRC, &
       RH    )
    use scale_grid_index
    use scale_tracer
    use scale_const, only: &
       UNDEF => CONST_UNDEF
    use scale_atmos_aerosol, only: &
       N_AE
    implicit none
    real(RP), intent(out) :: Re  (KA,IA,JA,N_AE) ! effective radius
    real(RP), intent(in)  :: QTRC(KA,IA,JA,QA)   ! tracer mass concentration [kg/kg]
    real(RP), intent(in)  :: RH  (KA,IA,JA)      ! relative humidity         (0-1)
    integer :: iq
    !---------------------------------------------------------------------------

    do iq = 1, N_AE
       Re(:,:,:,iq) = 0.0_RP
    end do

!    Re(:,:,:,I_ae_seasalt) = 2.E-4_RP
!    Re(:,:,:,I_ae_dust   ) = 4.E-6_RP
!    Re(:,:,:,I_ae_bc     ) = 4.E-8_RP
!    Re(:,:,:,I_ae_oc     ) = RH(:,:,:)
!    Re(:,:,:,I_ae_sulfate) = RH(:,:,:)

    return
  end subroutine ATMOS_PHY_AE_dummy_EffectiveRadius

end module scale_atmos_phy_ae_dummy
