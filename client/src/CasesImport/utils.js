import XLSX from 'xlsx'
import Papa from 'papaparse'

const parsers = {
  csv: {
    parse: fileContent => {
      const { data } = Papa.parse(fileContent)
      return { data }
    }
  },
  xlsx: {
    parse: (fileContent, options = {}) => {
      const workbook = XLSX.read(fileContent, {
        type: options.readAsBinaryString ? 'binary' : 'array'
      })
      const [sheetName] = workbook.SheetNames
      const worksheet = workbook.Sheets[sheetName]
      const data = XLSX.utils.sheet_to_json(worksheet, {
        header: 1,
        blankrows: false
      })
      return { data }
    }
  }
}

export const parserTypes = {
  'text/csv': parsers.csv,
  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
    parsers.xlsx,
  'application/vnd.ms-excel': parsers.xlsx
}

export const columns = [
  {
    dataIndex: 'firstName',
    key: 'firstName',
    title: 'First Name'
  },
  {
    dataIndex: 'lastName',
    key: 'lastName',
    title: 'Last Name'
  },
  {
    dataIndex: 'dateOfBirth',
    key: 'dateOfBirth',
    title: 'Date of birth',
    render: text => XLSX.SSF.format('yyyy-mm-dd', text)
  },
  {
    dataIndex: 'siteId',
    key: 'siteId',
    title: 'Site',
    responsive: ['sm']
  },
  {
    dataIndex: 'caseStatus',
    key: 'caseStatus',
    title: 'Case Status',
    responsive: ['sm']
  },
  {
    dataIndex: 'caseNumber',
    key: 'caseNumber',
    title: 'Case Number',
    responsive: ['sm']
  },
  {
    dataIndex: 'fullDaysPerMonth',
    key: 'fullDaysPerMonth',
    title: 'Full days (per month)',
    responsive: ['md']
  },
  {
    dataIndex: 'partDaysPerMonth',
    key: 'partDaysPerMonth',
    title: 'Part days (per month)',
    responsive: ['md']
  },
  {
    dataIndex: 'effectiveOn',
    key: 'effectiveOn',
    title: 'Effective On',
    responsive: ['md']
  },
  {
    dataIndex: 'expiresOn',
    key: 'expiresOn',
    title: 'Expires on',
    responsive: ['md']
  },
  {
    dataIndex: 'copay',
    key: 'copay',
    title: 'Co-pay',
    responsive: ['lg']
  },
  {
    dataIndex: 'copayFrequency',
    key: 'copayFrequency',
    title: 'Co-pay frequency',
    responsive: ['lg']
  }
]
