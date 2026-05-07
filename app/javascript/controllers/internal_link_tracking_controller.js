import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect () {
    document.querySelectorAll('a[data-track-internal-link]').forEach(link => {
      link.addEventListener('click', this.trackClick.bind(this))
    })
  }

  async trackClick (event) {
    const link = event.currentTarget
    const href = link.href
    const text = link.textContent.trim()

    await fetch('/events', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({
        event: {
          type: 'internal_link_clicked',
          data: {
            href,
            text
          }
        }
      })
    })
  }
}
