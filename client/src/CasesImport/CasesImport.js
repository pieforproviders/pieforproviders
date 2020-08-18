import React, { useState } from 'react'
import { Alert, Typography } from 'antd'
import { sha1 } from 'hash-anything'
import { CasesImportReview } from './CasesImportReview'
import { parserTypes, columns } from './utils'

const { Title } = Typography

export function CasesImport() {
  const [kids, setKids] = useState([])
  const [error, setError] = useState('')

  const onFileChange = e => {
    setError('')

    const [file] = e.target.files
    const { type } = file
    if (!(type in parserTypes)) {
      setKids([])
      setError('Invalid file format. Supported formats: CSV, XLS, and XLSX')
      return
    }

    const reader = new FileReader()
    const readAsBinaryString = !!reader.readAsBinaryString
    reader.onload = e => {
      const { data } = parserTypes[type].parse(e.target.result, {
        readAsBinaryString
      })
      // Skip the instruction, header and column description rows
      const rows = data.slice(3)
      const kids = rows
        .map(row =>
          row.reduce(
            (acc, item, index) => ({
              ...acc,
              [columns[index].key]: item
            }),
            {}
          )
        )
        .map(kid => ({
          ...kid,
          key: sha1(kid.firstName, kid.lastName, kid.dateOfBirth)
        }))
        .filter(kid => kid.firstName && kid.lastName && kid.dateOfBirth)
      setKids(kids)
    }

    if (readAsBinaryString) {
      return reader.readAsBinaryString(file)
    }

    reader.readAsArrayBuffer(file)
  }

  return (
    <div>
      <Title>Upload Cases</Title>
      {error && (
        <Alert
          message={error}
          type="error"
          showIcon
          style={{ marginBottom: '16px' }}
        />
      )}
      <input type="file" accept=".csv,.xls,.xlsx" onChange={onFileChange} />
      <CasesImportReview kids={kids} />
    </div>
  )
}
