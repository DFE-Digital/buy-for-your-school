import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    document.querySelectorAll('a').forEach(link => {
        const eventType = this.isExternalLink(link.href) ? 'external_link_clicked' : 'link_click'
        link.addEventListener('click', (event) => this.trackClick(event, eventType));
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
      if (eventType == 'external_link_clicked')
        window.open(href, '_blank', 'noopener,noreferrer');
      else
        window.location.href = href
    }
  }
}
