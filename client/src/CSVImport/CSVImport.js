import React, { useState } from 'react'
import { CSVImportReview } from './CSVImportReview'
import CSVReader from 'react-csv-reader'

export function CSVImport() {
  const [kids, setKids] = useState([])

  return (
    <div className="csv-import">
      <p>Upload Cases</p>
      <CSVReader
        onFileLoaded={(data, _fileInfo) => {
          setKids(data)
        }}
      />
      <CSVImportReview kids={kids} />
    </div>
  )
}
