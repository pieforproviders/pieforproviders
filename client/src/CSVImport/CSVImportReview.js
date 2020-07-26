import React from 'react'
import { sha1 } from 'hash-anything'
import PropTypes from 'prop-types'

export function CSVImportReview({ kids }) {
  return (
    <div className="csv-import-review">
      <h1 className="sr-only">Review Imported CSV</h1>
      {kids && (
        <div className="kids-list">
          <span className="sr-only">List of kids</span>
          {kids.map(kid => {
            return (
              <div key={sha1(kid[0], kid[1], kid[2])}>
                {kid[0]} {kid[1]} {kid[2]}
              </div>
            )
          })}
        </div>
      )}
    </div>
  )
}

CSVImportReview.propTypes = {
  kids: PropTypes.arrayOf(PropTypes.array)
}
