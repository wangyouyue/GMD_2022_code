!-------------------------------------------------------------------------------
!> module USER
!!
!! @par Description
!!          User defined module
!!
!! @author Team SCALE
!!
!! @par History
!! @li      2012-12-26 (H.Yashiro)   [new]
!!
!<
!-------------------------------------------------------------------------------
module mod_user
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
  public :: USER_config
  public :: USER_setup
  public :: USER_resume0
  public :: USER_resume
  public :: USER_step

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
  logical, private :: USER_do = .false. !< do user step?

  !-----------------------------------------------------------------------------
contains
  !-----------------------------------------------------------------------------
  !> Config before setup of other components
  subroutine USER_config
    use scale_tracer, only: &
       TRACER_regist
    implicit none

    ! if you want to add tracers, call the TRACER_regist subroutine.
    ! e.g.,
!    integer, parameter     :: NQ = 1
!    integer                :: QS
!    character(len=H_SHORT) :: NAME(NQ)
!    character(len=H_MID)   :: DESC(NQ)
!    character(len=H_SHORT) :: UNIT(NQ)
!
!    data NAME (/ 'name' /)
!    data DESC (/ 'tracer name' /)
!    data UNIT (/ 'kg/kg' /)
    !---------------------------------------------------------------------------

!    call TRACER_regist( QS,   & ! [OUT]
!                        NQ,   & ! [IN]
!                        NAME, & ! [IN]
!                        DESC, & ! [IN]
!                        UNIT  ) ! [IN]

    return
  end subroutine USER_config

  !-----------------------------------------------------------------------------
  !> Setup before setup of other components
  subroutine USER_setup
    use scale_process, only: &
       PRC_MPIstop
    implicit none

    namelist / PARAM_USER / &
       USER_do

    integer :: ierr
    !---------------------------------------------------------------------------

    if( IO_L ) write(IO_FID_LOG,*)
    if( IO_L ) write(IO_FID_LOG,*) '++++++ Module[DRIVER] / Categ[USER] / Origin[SCALE-RM]'

    !--- read namelist
    rewind(IO_FID_CONF)
    read(IO_FID_CONF,nml=PARAM_USER,iostat=ierr)
    if( ierr < 0 ) then !--- missing
       if( IO_L ) write(IO_FID_LOG,*) '*** Not found namelist. Default used.'
    elseif( ierr > 0 ) then !--- fatal error
       write(*,*) 'xxx Not appropriate names in namelist PARAM_USER. Check!'
       call PRC_MPIstop
    endif
    if( IO_NML ) write(IO_FID_NML,nml=PARAM_USER)

    if( IO_L ) write(IO_FID_LOG,*)
    if( IO_L ) write(IO_FID_LOG,*) '*** This module is dummy.'

    return
  end subroutine USER_setup

  !-----------------------------------------------------------------------------
  !> Resuming operation, before calculating tendency
  subroutine USER_resume0
    implicit none
    !---------------------------------------------------------------------------

    ! If you need, calculate first step and put diagnostic value to history buffer.
    ! USER_resume0 calls before setup of Atmos/Ocean/Land/Urban submodels.
    ! All variables are set before surface coupling.

    !call USER_step

    return
  end subroutine USER_resume0

  !-----------------------------------------------------------------------------
  !> Resuming operation
  subroutine USER_resume
    implicit none
    !---------------------------------------------------------------------------

    ! If you need, calculate first step and put diagnostic value to history buffer.
    ! USER_resume calls after setup of Atmos/Ocean/Land/Urban submodels.
    ! All variables are set after surface coupling.

    !call USER_step

    return
  end subroutine USER_resume

  !-----------------------------------------------------------------------------
  !> User step
  subroutine USER_step
    use scale_process, only: &
       PRC_MPIstop
    implicit none
    !---------------------------------------------------------------------------

    if ( USER_do ) then
       call PRC_MPIstop
    endif

    return
  end subroutine USER_step

end module mod_user
