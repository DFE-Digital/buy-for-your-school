import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    document.querySelectorAll('a').forEach(link => {
        const eventType = 'external_link_clicked'
        if (this.isExternalLink(link.href)) {
          link.addEventListener('click', (event) => this.trackClick(event, eventType));
        }
    });
  }

  isExternalLink(href) {
    try {
      const url = new URL(href)
      return url.hostname !== window.location.hostname
    } catch {
      return false
    }
  }

  async trackClick(event, eventType) {
    event.preventDefault();
    const element = event.currentTarget
    const href = element.href
    const text = element.textContent?.trim()

    try {
      await fetch('/dfe_analytics_events', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({
          event: {
            type: eventType,
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
