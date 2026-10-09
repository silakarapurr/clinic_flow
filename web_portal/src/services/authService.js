// ============================================================================
// Web Admin Authentication Service
// Authenticates the super admin with credentials: admin / admin123
// ============================================================================

const ADMIN_STORAGE_KEY = 'clinicflow_admin_auth_session';

class AuthService {
  constructor() {
    this.listeners = new Set();
    this.session = this.loadSession();
  }

  loadSession() {
    try {
      const data = localStorage.getItem(ADMIN_STORAGE_KEY);
      if (data) {
        return JSON.parse(data);
      }
    } catch (e) {
      console.warn('Failed to parse admin session:', e);
    }
    return null;
  }

  saveSession(session) {
    this.session = session;
    if (session) {
      localStorage.setItem(ADMIN_STORAGE_KEY, JSON.stringify(session));
    } else {
      localStorage.removeItem(ADMIN_STORAGE_KEY);
    }
    this.notify();
  }

  subscribe(callback) {
    this.listeners.add(callback);
    callback(this.session);
    return () => this.listeners.delete(callback);
  }

  notify() {
    this.listeners.forEach(cb => cb(this.session));
  }

  isAuthenticated() {
    return Boolean(this.session && this.session.isAuthenticated);
  }

  getCurrentUser() {
    return this.session;
  }

  async login(username, password) {
    const cleanUser = (username || '').trim().toLowerCase();
    const cleanPass = (password || '').trim();

    // Check credentials: admin / admin123 (also accept admin@clinicflow.com)
    const isValidUsername = cleanUser === 'admin' || cleanUser === 'admin@clinicflow.com';
    const isValidPassword = cleanPass === 'admin123';

    if (isValidUsername && isValidPassword) {
      const session = {
        isAuthenticated: true,
        username: 'admin',
        displayName: 'Sistem Yöneticisi (Super Admin)',
        email: 'admin@clinicflow.com',
        role: 'super_admin',
        loginTime: new Date().toISOString()
      };
      this.saveSession(session);
      return { success: true, user: session };
    }

    return { 
      success: false, 
      message: 'Kullanıcı adı veya şifre hatalı. (Yönetici girişi: admin / admin123)' 
    };
  }

  logout() {
    this.saveSession(null);
  }
}

export const authService = new AuthService();
