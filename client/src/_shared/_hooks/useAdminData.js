export function useAdminData() {
  const reduceAdminData = data => {
    return data.map((item, index) => ({
      id: item.id ?? '',
      key: `${index}-${item.first_name}-${item.last_name}`,
      active: item.active ?? true,
      approvalEffectiveOn: item.effective_on ?? '',
      approvalExpiresOn: item.expires_on ?? '',
      child: {
        childFirstName: item.first_name ?? '',
        childLastName: item.last_name ?? '',
        cNumber: item.case_number ?? '',
        business: item.business_name ?? ''
      },
      partDays: { text: item.part_time.toString() ?? '0', info: '' },
      fullDays: { text: item.full_time.toString() ?? '0', tag: '' },
      absences: `${item.absences_count.toString() ?? '0'} of 5`,
      absences_dates: item.absences?.split(',') ?? [],
      hoursAttended: item.max_hours_per_week ?? '',
      familyFee: item.family_fee ?? ''
    }))
  }

  return { reduceAdminData }
}
