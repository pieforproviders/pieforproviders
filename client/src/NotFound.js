import React from 'react'
import { Link } from 'react-router-dom'

function NotFound() {
  return (
    <div className="four-oh-four">
      <h1>404: Not found</h1>
      <Link to="/">Back home</Link>
    </div>
  )
}

export default NotFound
