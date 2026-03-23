import { ref } from 'vue'

const visible = ref(false)
const posX = ref(0)
const posY = ref(0)
const text = ref('')

const DURATION_MS = 2000
let moveHandler = null
let timeoutId = null

function clearListeners() {
  if (moveHandler) {
    window.removeEventListener('mousemove', moveHandler)
    moveHandler = null
  }
  if (timeoutId) {
    clearTimeout(timeoutId)
    timeoutId = null
  }
}

function updatePosition(event) {
  posX.value = event.clientX
  posY.value = event.clientY
}

export function useCopyFeedback() {
  function showFeedback(event) {
    clearListeners()
    text.value = 'copié !'
    updatePosition(event)
    visible.value = true

    moveHandler = (evt) => updatePosition(evt)
    window.addEventListener('mousemove', moveHandler)

    timeoutId = setTimeout(() => {
      clearListeners()
      visible.value = false
    }, DURATION_MS)
  }

  function showHoverFeedback(event) {
    clearListeners()
    text.value = 'copier ?'
    updatePosition(event)
    visible.value = true

    moveHandler = (evt) => updatePosition(evt)
    window.addEventListener('mousemove', moveHandler)
  }

  function hideFeedback() {
    clearListeners()
    visible.value = false
  }

  return { visible, posX, posY, text, showFeedback, showHoverFeedback, hideFeedback }
}
