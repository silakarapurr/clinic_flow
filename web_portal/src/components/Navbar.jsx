import React from 'react';
import { 
  Activity, 
  ShieldCheck, 
  ClipboardList, 
  UserPlus, 
  Search, 
  Database,
  Building2,
  CheckCircle2
} from 'lucide-react';

export default function Navbar({ 
  currentTab, 
  setCurrentTab, 
  pendingCount, 
  isAdmin, 
  setIsAdmin,
  isOnline 
}) {
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
            onClick={() => {
              setCurrentTab('admin');
              setIsAdmin(true);
            }}
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

          <button
            type="button"
            className={`btn btn-sm ${isAdmin ? 'btn-primary' : 'btn-secondary'}`}
            onClick={() => {
              setIsAdmin(!isAdmin);
              if (!isAdmin) setCurrentTab('admin');
            }}
            title="Yönetici oturumunu değiştir"
          >
            <Building2 size={14} />
            <span>{isAdmin ? 'Dr. Zeynep (Yönetici)' : 'Yönetici Girişi'}</span>
          </button>
        </div>
      </div>
    </header>
  );
}
