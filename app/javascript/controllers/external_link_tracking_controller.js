import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    document.querySelectorAll('a').forEach(link => {
      if (this.isExternalLink(link.href)) {
        link.addEventListener('click', this.trackClick.bind(this))
      }
    })
  }

  isExternalLink(href) {
    try {
      const url = new URL(href)
      return url.hostname !== window.location.hostname
    } catch {
      return false
    }
  }

  async trackClick(event) {
    event.preventDefault();
    const link = event.currentTarget
    const href = link.href
    const text = link.textContent.trim()

    try {
      await fetch('/dfe_analytics_external_links', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({
          event: {
            type: 'external_link_clicked',
            data: {
              href,
              text,
            }
          }
        })
      })
    } finally {
      window.open(href, '_blank', 'noopener,noreferrer');
    }
  }
}
