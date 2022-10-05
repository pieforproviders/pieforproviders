const NAME = 'name'
const addNameAttributeToSelectById = (elementId, name) => {
  const element = document.getElementById(elementId)
  element.setAttribute(NAME, name)
}

export default addNameAttributeToSelectById
