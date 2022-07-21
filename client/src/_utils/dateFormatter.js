export default function getFormattedMonthYearDate(date = new Date()) {
  return {
    displayDate: date.toLocaleDateString('default', {
      month: 'short',
      year: 'numeric'
    }),
    date: date.toISOString().split('T')[0]
  }
}
