import React, { useState } from 'react'
import { CSVImportReview } from './CSVImportReview'
import XLSX from 'xlsx'

export function CSVImport() {
  const [kids, setKids] = useState([])

  const getKids = fileData => {
    const workbook = XLSX.read(fileData, { type: 'binary' })
    const firstSheetName = workbook.SheetNames[0]
    const firstSheet = workbook.Sheets[firstSheetName]
    return XLSX.utils.sheet_to_json(firstSheet, { header: 1 })
  }

  const onChangeHandler = event => {
    const file = event.target.files[0]

    if (!file) return

    const reader = new FileReader()
    reader.onload = event => {
      const fileData = event.target.result
      const kids = getKids(fileData).map((info, index) => {
        return {
          info,
          id: index
        }
      })
      setKids(kids)
    }

    reader.readAsBinaryString(file)
  }

  return (
    <div className="csv-import">
      <div>
        <p>Upload Cases</p>
        <input
          type="file"
          accept=".xls,.xlsx,.csv"
          onChange={onChangeHandler}
        />
      </div>
      <CSVImportReview kids={kids} />
    </div>
  )
}
