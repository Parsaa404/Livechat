class VisitorTracking {
  constructor(accountId) {
    this.accountId = accountId;
    this.visitorId = this.getVisitorId();
    this.sessionId = this.generateSessionId();
    this.baseUrl = '/api/v1/visitor_tracking';
    this.initialize();
  }

  initialize() {
    this.trackPageView();
    this.setupEventListeners();
    this.setupBeforeUnload();
  }

  getVisitorId() {
    let visitorId = localStorage.getItem('visitor_id');
    if (!visitorId) {
      visitorId = this.generateVisitorId();
      localStorage.setItem('visitor_id', visitorId);
    }
    return visitorId;
  }

  generateVisitorId() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
      const r = Math.random() * 16 | 0;
      const v = c === 'x' ? r : (r & 0x3 | 0x8);
      return v.toString(16);
    });
  }

  generateSessionId() {
    return Date.now().toString(36) + Math.random().toString(36).substr(2);
  }

  async trackPageView() {
    const pageData = {
      name: 'page_view',
      url: window.location.href,
      title: document.title
    };

    const visitorData = {
      visitor_id: this.visitorId,
      session_id: this.sessionId,
      location: await this.getLocationData(),
      device: this.getDeviceData(),
      utm: this.getUtmParams(),
      session_data: {
        referrer: document.referrer,
        landing_page: window.location.href
      },
      page_data: pageData
    };

    try {
      const response = await fetch(`${this.baseUrl}/track`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-Account-ID': this.accountId
        },
        body: JSON.stringify({ visitor: visitorData })
      });
      return await response.json();
    } catch (error) {
      console.error('Error tracking page view:', error);
    }
  }

  async trackEvent(eventName, properties = {}) {
    const eventData = {
      name: eventName,
      properties,
      value: {}
    };

    try {
      const response = await fetch(`${this.baseUrl}/track_event`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-Account-ID': this.accountId
        },
        body: JSON.stringify({
          visitor_id: this.visitorId,
          session_id: this.sessionId,
          event_type: 'custom',
          event: eventData
        })
      });
      return await response.json();
    } catch (error) {
      console.error('Error tracking event:', error);
    }
  }

  async getLocationData() {
    try {
      const response = await fetch('https://ipapi.co/json/');
      const data = await response.json();
      return {
        country: data.country_name,
        city: data.city,
        region: data.region,
        latitude: data.latitude,
        longitude: data.longitude
      };
    } catch (error) {
      console.error('Error getting location data:', error);
      return {};
    }
  }

  getDeviceData() {
    const ua = navigator.userAgent;
    return {
      browser: this.getBrowser(ua),
      os: this.getOS(ua),
      device_type: this.getDeviceType(ua),
      screen_resolution: `${window.screen.width}x${window.screen.height}`
    };
  }

  getUtmParams() {
    const urlParams = new URLSearchParams(window.location.search);
    return {
      source: urlParams.get('utm_source'),
      medium: urlParams.get('utm_medium'),
      campaign: urlParams.get('utm_campaign'),
      term: urlParams.get('utm_term'),
      content: urlParams.get('utm_content')
    };
  }

  getBrowser(ua) {
    if (ua.includes('Chrome')) return 'Chrome';
    if (ua.includes('Firefox')) return 'Firefox';
    if (ua.includes('Safari')) return 'Safari';
    if (ua.includes('Edge')) return 'Edge';
    return 'Other';
  }

  getOS(ua) {
    if (ua.includes('Windows')) return 'Windows';
    if (ua.includes('Mac')) return 'MacOS';
    if (ua.includes('Linux')) return 'Linux';
    if (ua.includes('Android')) return 'Android';
    if (ua.includes('iOS')) return 'iOS';
    return 'Other';
  }

  getDeviceType(ua) {
    if (/(tablet|ipad|playbook|silk)|(android(?!.*mobi))/i.test(ua)) {
      return 'tablet';
    }
    if (/Mobile|Android|iP(hone|od)|IEMobile|BlackBerry|Kindle|Silk-Accelerated|(hpw|web)OS|Opera M(obi|ini)/.test(ua)) {
      return 'mobile';
    }
    return 'desktop';
  }

  setupEventListeners() {
    // Track clicks on specific elements
    document.addEventListener('click', (e) => {
      const target = e.target;
      if (target.dataset.track) {
        this.trackEvent('click', {
          element: target.dataset.track,
          text: target.textContent,
          href: target.href
        });
      }
    });

    // Track form submissions
    document.addEventListener('submit', (e) => {
      const form = e.target;
      if (form.dataset.track) {
        this.trackEvent('form_submit', {
          form: form.dataset.track,
          action: form.action
        });
      }
    });
  }

  setupBeforeUnload() {
    window.addEventListener('beforeunload', () => {
      fetch(`${this.baseUrl}/end_session`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-Account-ID': this.accountId
        },
        body: JSON.stringify({
          visitor_id: this.visitorId,
          session_id: this.sessionId
        })
      });
    });
  }
}

// Initialize visitor tracking
window.visitorTracking = new VisitorTracking(window.CHATWOOT_ACCOUNT_ID); 