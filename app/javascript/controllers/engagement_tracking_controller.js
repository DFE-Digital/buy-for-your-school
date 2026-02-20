import { Controller } from '@hotwired/stimulus'

const EVENTS = ['mousedown', 'mousemove', 'keypress', 'keydown', 'input', 'scroll', 'touchstart', 'click', 'wheel', 'pointermove']
const ACTIVITY_WINDOW_MS = 30000
const SEND_INTERVAL_MS = 60000
const CHECK_INTERVAL_MS = 10000

export default class extends Controller {
  connect () {
    this.startTime = Date.now()
    this.lastActivity = this.startTime
    this.lastCheckTime = this.startTime
    this.totalEngagedTime = 0
    this.lastSentEngagedTime = 0
    this.isVisible = !document.hidden
    this.checkInterval = CHECK_INTERVAL_MS

    this.boundHandleActivity = this.handleActivity.bind(this)
    this.boundHandleVisibilityChange = this.handleVisibilityChange.bind(this)
    this.boundHandleBeforeUnload = this.handleBeforeUnload.bind(this)

    this.addEventListeners()
    this.startPeriodicCheck()
  }

  disconnect () {
    this.removeEventListeners()
    this.clearPeriodicCheck()
    this.sendEngagementData()
  }

  addEventListeners () {
    EVENTS.forEach(event => {
      document.addEventListener(event, this.boundHandleActivity, { passive: true })
    })

    document.addEventListener('visibilitychange', this.boundHandleVisibilityChange)
    window.addEventListener('beforeunload', this.boundHandleBeforeUnload)
  }

  removeEventListeners () {
    EVENTS.forEach(event => {
      document.removeEventListener(event, this.boundHandleActivity)
    })

    document.removeEventListener('visibilitychange', this.boundHandleVisibilityChange)
    window.removeEventListener('beforeunload', this.boundHandleBeforeUnload)
  }

  handleActivity () {
    this.lastActivity = Date.now()
  }

  handleVisibilityChange () {
    const now = Date.now()

    if (document.hidden && this.isVisible) {
      this.updateEngagedTime(now)
      this.isVisible = false
    } else if (!document.hidden && !this.isVisible) {
      this.lastActivity = now
      this.isVisible = true
    }
  }

  handleBeforeUnload () {
    this.sendEngagementData()
  }

  startPeriodicCheck () {
    this.intervalId = setInterval(() => {
      this.checkEngagement()
    }, this.checkInterval)
  }

  clearPeriodicCheck () {
    clearInterval(this.intervalId)
  }

  checkEngagement () {
    const now = Date.now()
    this.updateEngagedTime(now)

    if (
      this.totalEngagedTime > 0 &&
      this.totalEngagedTime - this.lastSentEngagedTime >= SEND_INTERVAL_MS
    ) {
      this.sendEngagementData()
      this.lastSentEngagedTime = this.totalEngagedTime
    }
  }

  updateEngagedTime (now) {
    if (this.isVisible && this.isRecentlyActive(now)) {
      const timeSinceLastCheck = now - (this.lastCheckTime || this.startTime)
      this.totalEngagedTime += Math.min(timeSinceLastCheck, this.checkInterval)
    }
    this.lastCheckTime = now
  }

  isRecentlyActive (now) {
    return (now - this.lastActivity) < ACTIVITY_WINDOW_MS
  }

  async sendEngagementData () {
    if (this.totalEngagedTime === 0) return

    const engagementData = {
      engaged_time_ms: this.totalEngagedTime,
      page_path: window.location.pathname,
      page_title: document.title,
      session_duration_ms: Date.now() - this.startTime,
      timestamp: new Date().toISOString()
    }

    await fetch('/events', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({
        event: {
          type: 'page_engagement',
          data: engagementData
        }
      }),
      keepalive: true
    })
  }
}
