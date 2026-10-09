import React from 'react';
import { 
  Activity, 
  ShieldCheck, 
  ClipboardList, 
  UserPlus, 
  Search, 
  Database,
  Building2,
  CheckCircle2,
  LogOut,
  Lock
} from 'lucide-react';

export default function Navbar({ 
  currentTab, 
  setCurrentTab, 
  pendingCount, 
  adminSession,
  onLogout,
  isOnline 
}) {
  const isAuthenticated = Boolean(adminSession && adminSession.isAuthenticated);

  return (
    <header className="navbar">
      <div className="navbar-inner">
        {/* Brand */}
        <div className="brand-wrapper" onClick={() => setCurrentTab('register')}>
          <div className="brand-logo">
            <Activity size={24} strokeWidth={2.5} />
          </div>
          <div className="brand-titles">
            <div className="brand-title">
              ClinicFlow
              <span className="brand-tag">PORTAL</span>
            </div>
            <span className="brand-subtitle">Kayıt &amp; Olay Yönetim Merkezi</span>
          </div>
        </div>

        {/* Center Nav Items */}
        <nav className="nav-links">
          <button 
            type="button"
            className={`nav-item ${currentTab === 'register' ? 'active' : ''}`}
            onClick={() => setCurrentTab('register')}
          >
            <UserPlus size={16} />
            <span>Kayıt Başvurusu</span>
          </button>

          <button 
            type="button"
            className={`nav-item ${currentTab === 'track' ? 'active' : ''}`}
            onClick={() => setCurrentTab('track')}
          >
            <Search size={16} />
            <span>Başvuru Sorgula</span>
          </button>

          <button 
            type="button"
            className={`nav-item ${currentTab === 'admin' ? 'active' : ''}`}
            onClick={() => setCurrentTab('admin')}
          >
            <ShieldCheck size={16} />
            <span>Yönetici &amp; Olay Paneli</span>
            {pendingCount > 0 && (
              <span className="nav-badge-pill warning">
                {pendingCount} Bekleyen
              </span>
            )}
          </button>
        </nav>

        {/* Right Actions */}
        <div className="nav-actions">
          <div className="system-status-indicator" title="Firebase clinicflow-app-4281 entegrasyonu devrede">
            <span className={`status-dot ${isOnline ? '' : 'warning'}`}></span>
            <span>{isOnline ? 'Firebase Aktif' : 'Demo / Yerel Mod'}</span>
          </div>

          {isAuthenticated ? (
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <div style={{ 
                display: 'inline-flex', 
                alignItems: 'center', 
                gap: '0.35rem', 
                background: 'var(--primary-tint)', 
                border: '1px solid var(--primary-light)', 
                borderRadius: 'var(--radius-md)', 
                padding: '0.35rem 0.65rem',
                fontSize: '0.8rem',
                fontWeight: 700,
                color: 'var(--primary-dark)'
              }}>
                <ShieldCheck size={14} color="var(--primary)" />
                <span>admin</span>
              </div>
              <button
                type="button"
                className="btn btn-sm btn-ghost"
                onClick={onLogout}
                title="Yönetici oturumunu kapat"
                style={{ color: 'var(--error)' }}
              >
                <LogOut size={14} />
                <span>Çıkış</span>
              </button>
            </div>
          ) : (
            <button
              type="button"
              className="btn btn-sm btn-primary"
              onClick={() => setCurrentTab('admin')}
              title="Yönetici paneline giriş yap (admin / admin123)"
            >
              <Lock size={14} />
              <span>Yönetici Girişi</span>
            </button>
          )}
        </div>
      </div>
    </header>
  );
}
