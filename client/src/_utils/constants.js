export const attendanceCategories = {
  AHEADOFSCHEDULE: 'ahead_of_schedule',
  ONTRACK: 'on_track',
  SUREBET: 'sure_bet',
  ATRISK: 'at_risk',
  WILLNOTMEET: 'not_met', // TODO: keeping this old value because it needs to stay synced with backend data model.
  NOTENOUGHINFO: 'not_enough_info'
}

export const fullDayCategories = {
  AHEADOFSCHEDULE: 'ahead_of_schedule',
  ONTRACK: 'on_track',
  ATRISK: 'at_risk',
  EXCEEDEDLIMIT: 'exceeded_limit'
}

export default { attendanceCategories, fullDayCategories }
