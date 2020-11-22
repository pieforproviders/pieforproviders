import XLSX from 'xlsx'
import Papa from 'papaparse'
import { sha1 } from 'hash-anything'

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

export const getColumns = t => [
  {
    dataIndex: 'firstName',
    key: 'firstName',
    title: t('firstName')
  },
  {
    dataIndex: 'lastName',
    key: 'lastName',
    title: t('lastName')
  },
  {
    dataIndex: 'dateOfBirth',
    key: 'dateOfBirth',
    title: t('dateOfBirth'),
    render: text => XLSX.SSF.format('yyyy-mm-dd', text)
  },
  {
    dataIndex: 'caseStatus',
    key: 'caseStatus',
    title: t('caseStatus'),
    responsive: ['sm']
  },
  {
    dataIndex: 'caseNumber',
    key: 'caseNumber',
    title: t('caseNumber'),
    responsive: ['sm']
  },
  {
    dataIndex: 'fullDaysPerMonth',
    key: 'fullDaysPerMonth',
    title: t('fullDaysPerMonth'),
    responsive: ['md']
  },
  {
    dataIndex: 'partDaysPerMonth',
    key: 'partDaysPerMonth',
    title: t('partDaysPerMonth'),
    responsive: ['md']
  },
  {
    dataIndex: 'effectiveOn',
    key: 'effectiveOn',
    title: t('effectiveOn'),
    responsive: ['md']
  },
  {
    dataIndex: 'expiresOn',
    key: 'expiresOn',
    title: t('expiresOn'),
    responsive: ['md']
  },
  {
    dataIndex: 'copay',
    key: 'copay',
    title: t('copay'),
    responsive: ['lg']
  },
  {
    dataIndex: 'copayFrequency',
    key: 'copayFrequency',
    title: t('copayFrequency'),
    responsive: ['lg']
  }
]

export const randomHash = array => {
  const randomString =
    Math.random().toString(36).substring(2, 5) +
    Math.random().toString(36).substring(2, 5)
  return sha1(`${array.join()}${randomString}`)
}
