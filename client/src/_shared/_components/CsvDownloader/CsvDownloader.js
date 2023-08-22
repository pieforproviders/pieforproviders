import React from 'react'
import PropTypes from 'prop-types'
import { CSVLink } from 'react-csv'

const CsvDownloader = ({ data, filename }) => {
  return (
    <>
      <CSVLink
        data={data}
        filename={filename}
        separator=","
        enclosingCharacter={`"`}
        asyncOnClick={false}
      >
        Download
      </CSVLink>
    </>
  )
}

CsvDownloader.propTypes = {
  data: PropTypes.any,
  filename: PropTypes.string
}

export default CsvDownloader
