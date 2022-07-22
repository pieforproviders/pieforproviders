export default function getFormattedMonthYearDate(
  date = new Date(),
  monthDisplayLength = 'short'
) {
  return {
    displayDate: date.toLocaleDateString('default', {
      month: monthDisplayLength,
      year: 'numeric'
    }),
    date: date.toISOString().split('T')[0]
  }
}
