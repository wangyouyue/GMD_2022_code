!-------------------------------------------------------------------------------
!> module Atmosphere / Dynamical scheme
!!
!! @par Description
!!          Dynamical scheme selecter for dynamical short time step
!!
!! @author Team SCALE
!!
!! @par History
!! @li      2016-04-18 (S.Nishizawa) [new]
!!
!<
!-------------------------------------------------------------------------------
#include "inc_openmp.h"
module scale_atmos_dyn_tstep_short
  !-----------------------------------------------------------------------------
  !
  !++ used modules
  !
  use scale_precision
  use scale_stdio
  use scale_prof
  use scale_grid_index
  use scale_index
  use scale_tracer
  !-----------------------------------------------------------------------------
  implicit none
  private
  !-----------------------------------------------------------------------------
  !
  !++ Public procedure
  !
  public :: ATMOS_DYN_Tstep_short_regist

  abstract interface
     !> setup
     subroutine short_setup
     end subroutine short_setup

     !> calculation values at next temporal step
     subroutine short( DENS_new, MOMZ_new, MOMX_new, MOMY_new, RHOT_new, & ! (out)
                       PROG_new,                                         & ! (out)
                       mflx_hi,  tflx_hi,                                & ! (out)
                       DENS0,    MOMZ0,    MOMX0,    MOMY0,    RHOT0,    & ! (in)
                       DENS,     MOMZ,     MOMX,     MOMY,     RHOT,     & ! (in)
                       DENS_t,   MOMZ_t,   MOMX_t,   MOMY_t,   RHOT_t,   & ! (in)
                       PROG0, PROG,                                      & ! (in)
                       DPRES0, RT2P, CORIOLI,                            & ! (in)
                       num_diff, wdamp_coef, divdmp_coef, DDIV,          & ! (in)
                       FLAG_FCT_MOMENTUM, FLAG_FCT_T,                    & ! (in)
                       FLAG_FCT_ALONG_STREAM,                            & ! (in)
                       CDZ, FDZ, FDX, FDY,                               & ! (in)
                       RCDZ, RCDX, RCDY, RFDZ, RFDX, RFDY,               & ! (in)
                       PHI, GSQRT, J13G, J23G, J33G, MAPF,               & ! (in)
                       REF_dens, REF_rhot,                               & ! (in)
                       BND_W, BND_E, BND_S, BND_N,                       & ! (in)
                       dtrk, last                                        ) ! (in)
       use scale_precision
       use scale_grid_index
       use scale_index
       real(RP), intent(out) :: DENS_new(KA,IA,JA)   ! prognostic variables
       real(RP), intent(out) :: MOMZ_new(KA,IA,JA)   !
       real(RP), intent(out) :: MOMX_new(KA,IA,JA)   !
       real(RP), intent(out) :: MOMY_new(KA,IA,JA)   !
       real(RP), intent(out) :: RHOT_new(KA,IA,JA)   !
       real(RP), intent(out) :: PROG_new(KA,IA,JA,VA)  !

       real(RP), intent(inout) :: mflx_hi(KA,IA,JA,3) ! mass flux
       real(RP), intent(out)   :: tflx_hi(KA,IA,JA,3) ! internal energy flux

       real(RP), intent(in),target :: DENS0(KA,IA,JA) ! prognostic variables at previous dynamical time step
       real(RP), intent(in),target :: MOMZ0(KA,IA,JA) !
       real(RP), intent(in),target :: MOMX0(KA,IA,JA) !
       real(RP), intent(in),target :: MOMY0(KA,IA,JA) !
       real(RP), intent(in),target :: RHOT0(KA,IA,JA) !

       real(RP), intent(in)  :: DENS(KA,IA,JA)      ! prognostic variables at previous RK step
       real(RP), intent(in)  :: MOMZ(KA,IA,JA)      !
       real(RP), intent(in)  :: MOMX(KA,IA,JA)      !
       real(RP), intent(in)  :: MOMY(KA,IA,JA)      !
       real(RP), intent(in)  :: RHOT(KA,IA,JA)      !

       real(RP), intent(in)  :: DENS_t(KA,IA,JA)    ! tendency
       real(RP), intent(in)  :: MOMZ_t(KA,IA,JA)    !
       real(RP), intent(in)  :: MOMX_t(KA,IA,JA)    !
       real(RP), intent(in)  :: MOMY_t(KA,IA,JA)    !
       real(RP), intent(in)  :: RHOT_t(KA,IA,JA)    !

       real(RP), intent(in)  :: PROG0(KA,IA,JA,VA)
       real(RP), intent(in)  :: PROG (KA,IA,JA,VA)

       real(RP), intent(in)  :: DPRES0  (KA,IA,JA)
       real(RP), intent(in)  :: RT2P    (KA,IA,JA)
       real(RP), intent(in)  :: CORIOLI (1, IA,JA)
       real(RP), intent(in)  :: num_diff(KA,IA,JA,5,3)
       real(RP), intent(in)  :: wdamp_coef(KA)
       real(RP), intent(in)  :: divdmp_coef
       real(RP), intent(in)  :: DDIV(KA,IA,JA)

       logical,  intent(in)  :: FLAG_FCT_MOMENTUM
       logical,  intent(in)  :: FLAG_FCT_T
       logical,  intent(in)  :: FLAG_FCT_ALONG_STREAM

       real(RP), intent(in)  :: CDZ (KA)
       real(RP), intent(in)  :: FDZ (KA-1)
       real(RP), intent(in)  :: FDX (IA-1)
       real(RP), intent(in)  :: FDY (JA-1)
       real(RP), intent(in)  :: RCDZ(KA)
       real(RP), intent(in)  :: RCDX(IA)
       real(RP), intent(in)  :: RCDY(JA)
       real(RP), intent(in)  :: RFDZ(KA-1)
       real(RP), intent(in)  :: RFDX(IA-1)
       real(RP), intent(in)  :: RFDY(JA-1)

       real(RP), intent(in)  :: PHI     (KA,IA,JA)   !< geopotential
       real(RP), intent(in)  :: GSQRT   (KA,IA,JA,7) !< vertical metrics {G}^1/2
       real(RP), intent(in)  :: J13G    (KA,IA,JA,7) !< (1,3) element of Jacobian matrix
       real(RP), intent(in)  :: J23G    (KA,IA,JA,7) !< (2,3) element of Jacobian matrix
       real(RP), intent(in)  :: J33G                 !< (3,3) element of Jacobian matrix
       real(RP), intent(in)  :: MAPF    (IA,JA,2,4)  !< map factor
       real(RP), intent(in)  :: REF_dens(KA,IA,JA)   !< reference density
       real(RP), intent(in)  :: REF_rhot(KA,IA,JA)

       logical,  intent(in)  :: BND_W
       logical,  intent(in)  :: BND_E
       logical,  intent(in)  :: BND_S
       logical,  intent(in)  :: BND_N

       real(RP), intent(in)  :: dtrk
       logical,  intent(in)  :: last
     end subroutine short

  end interface

  procedure(short_setup), pointer :: ATMOS_DYN_Tstep_short_setup => NULL()
  public :: ATMOS_DYN_Tstep_short_setup
  procedure(short), pointer :: ATMOS_DYN_Tstep_short => NULL()
  public :: ATMOS_DYN_Tstep_short

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
  !> Register
  subroutine ATMOS_DYN_Tstep_short_regist( &
       ATMOS_DYN_TYPE, &
       VA_out, &
       VAR_NAME, VAR_DESC, VAR_UNIT )
    use scale_precision
    use scale_grid_index
    use scale_index
    use scale_process, only: &
       PRC_MPIstop
    use scale_atmos_dyn_tstep_short_fvm_heve, only: &
       ATMOS_DYN_Tstep_short_fvm_heve_regist, &
       ATMOS_DYN_Tstep_short_fvm_heve_setup, &
       ATMOS_DYN_Tstep_short_fvm_heve
    use scale_atmos_dyn_tstep_short_fvm_hevi, only: &
       ATMOS_DYN_Tstep_short_fvm_hevi_regist, &
       ATMOS_DYN_Tstep_short_fvm_hevi_setup, &
       ATMOS_DYN_Tstep_short_fvm_hevi
    use scale_atmos_dyn_tstep_short_fvm_hivi, only: &
       ATMOS_DYN_Tstep_short_fvm_hivi_regist, &
       ATMOS_DYN_Tstep_short_fvm_hivi_setup, &
       ATMOS_DYN_Tstep_short_fvm_hivi
    implicit none

    character(len=*),       intent(in)  :: ATMOS_DYN_TYPE
    integer,                intent(out) :: VA_out         !< number of prognostic variables
    character(len=H_SHORT), intent(out) :: VAR_NAME(:)    !< name  of the variables
    character(len=H_MID),   intent(out) :: VAR_DESC(:)    !< desc. of the variables
    character(len=H_SHORT), intent(out) :: VAR_UNIT(:)    !< unit  of the variables
    !---------------------------------------------------------------------------

    select case( ATMOS_DYN_TYPE )
    case( 'FVM-HEVE', 'HEVE' )

       call ATMOS_DYN_Tstep_short_fvm_heve_regist( ATMOS_DYN_TYPE,              & ! [IN]
                                                   VA_out,                      & ! [OUT]
                                                   VAR_NAME, VAR_DESC, VAR_UNIT ) ! [OUT]

       ATMOS_DYN_Tstep_short_setup => ATMOS_DYN_Tstep_short_fvm_heve_setup
       ATMOS_DYN_Tstep_short       => ATMOS_DYN_Tstep_short_fvm_heve

    case( 'FVM-HEVI', 'HEVI' )

       call ATMOS_DYN_Tstep_short_fvm_hevi_regist( ATMOS_DYN_TYPE,              & ! [IN]
                                                   VA_out,                      & ! [OUT]
                                                   VAR_NAME, VAR_DESC, VAR_UNIT ) ! [OUT]

       ATMOS_DYN_Tstep_short_setup => ATMOS_DYN_Tstep_short_fvm_hevi_setup
       ATMOS_DYN_Tstep_short       => ATMOS_DYN_Tstep_short_fvm_hevi

    case( 'FVM-HIVI', 'HIVI' )

       write(*,*) 'xxx HIVI is tentatively disabled'
       call PRC_MPIstop

       call ATMOS_DYN_Tstep_short_fvm_hivi_regist( ATMOS_DYN_TYPE,              & ! [IN]
                                                   VA_out,                      & ! [OUT]
                                                   VAR_NAME, VAR_DESC, VAR_UNIT ) ! [OUT]

       ATMOS_DYN_Tstep_short_setup => ATMOS_DYN_Tstep_short_fvm_hivi_setup
       ATMOS_DYN_Tstep_short       => ATMOS_DYN_Tstep_short_fvm_hivi

    case( 'OFF', 'NONE' )

       VA_out      = 0
       VAR_NAME(:) = ""
       VAR_DESC(:) = ""
       VAR_UNIT(:) = ""

    case default
       write(*,*) 'xxx ATMOS_DYN_TYPE is invalid: ', ATMOS_DYN_TYPE
       call PRC_MPIstop
    end select

    return
  end subroutine ATMOS_DYN_Tstep_short_regist

end module scale_atmos_dyn_tstep_short
