!-------------------------------------------------------------------------------
!> module SPECFUNC
!!
!! @par Description
!!          Special functions
!!
!! @author Team SCALE
!!
!! @par History
!! @li      2013-02-06 (S.Nishizawa) [new] SF_gamma
!!
!<
module scale_specfunc
  !-----------------------------------------------------------------------------
  !
  !++ used modules
  !
  use scale_precision
  use scale_stdio
  !-----------------------------------------------------------------------------
  implicit none
  private
  !-----------------------------------------------------------------------------
  !
  !++ Public procedure
  !
  public :: SF_gamma

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
  !> Gamma function
  ! Lanczos approximation
  ! g = 7.0, N = 8
  function SF_gamma(x)
    implicit none

    real(RP), intent(in) :: x        !< input
    real(RP)             :: SF_gamma

    real(DP), parameter :: LRTP = 0.9189385332046727_DP ! log(sqrt(2*PI))
    real(DP)            :: Ag, dx, work
    !---------------------------------------------------------------------------

    dx = real(x-1.0_RP, kind=DP)

    Ag = 0.999999999999809932276847004735_DP                     &
       + 676.520368121885098567009190444_DP    / ( dx + 1.0_DP ) &
       - 1259.13921672240287047156078755_DP    / ( dx + 2.0_DP ) &
       + 771.323428777653078848652825889_DP    / ( dx + 3.0_DP ) &
       - 176.615029162140599065845513540_DP    / ( dx + 4.0_DP ) &
       + 12.5073432786869048144589368533_DP    / ( dx + 5.0_DP ) &
       - 0.138571095265720116895547069851_DP   / ( dx + 6.0_DP ) &
       + 9.98436957801957085956266899569E-6_DP / ( dx + 7.0_DP ) &
       + 1.50563273514931155833835577539E-7_DP / ( dx + 8.0_DP )

    work = exp( LRTP + (dx+0.5_DP)*log(dx+7.5_DP) - (dx+7.5_DP) + log(Ag) )
    SF_gamma = real(work, kind=RP)

    return
  end function SF_gamma

end module scale_specfunc
