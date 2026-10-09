import React, { useState, useEffect } from 'react';
import Navbar from './components/Navbar';
import PublicRegistration from './components/PublicRegistration';
import ApplicationTracker from './components/ApplicationTracker';
import AdminDashboard from './components/AdminDashboard';
import AdminLogin from './components/AdminLogin';
import Toast from './components/Toast';
import { eventService } from './services/eventService';
import { registrationService } from './services/registrationService';
import { authService } from './services/authService';
import { isFirebaseInitialized } from './firebase';
import { ShieldCheck, HeartHandshake, Sparkles, Building2 } from 'lucide-react';

export default function App() {
  const [currentTab, setCurrentTab] = useState('register'); // 'register' | 'track' | 'admin'
  const [trackerCode, setTrackerCode] = useState('');
  
  // Admin auth session state (credentials: admin / admin123)
  const [adminSession, setAdminSession] = useState(authService.getCurrentUser());

  // Real-time states
  const [events, setEvents] = useState([]);
  const [applications, setApplications] = useState([]);
  const [users, setUsers] = useState([]);
  
  // Toast notifications
  const [toasts, setToasts] = useState([]);

  useEffect(() => {
    const unsubAuth = authService.subscribe(setAdminSession);
    const unsubEvents = eventService.subscribe(setEvents);
    const unsubApps = registrationService.subscribeApplications(setApplications);
    const unsubUsers = registrationService.subscribeUsers(setUsers);

    return () => {
      unsubAuth();
      unsubEvents();
      unsubApps();
      unsubUsers();
    };
  }, []);

  const showToast = (message, type = 'info') => {
    const id = Date.now() + Math.random();
    setToasts(prev => [...prev, { id, message, type }]);
    setTimeout(() => {
      setToasts(prev => prev.filter(t => t.id !== id));
    }, 4500);
  };

  const handleDismissToast = (id) => {
    setToasts(prev => prev.filter(t => t.id !== id));
  };

  const pendingCount = applications.filter(a => a.status === 'pending').length;

  const handleApplicationSubmitted = (newApp) => {
    showToast(`"${newApp.clinicName}" başvurusu başarıyla kaydedildi!`, 'success');
  };

  const handleNavigateTracker = (code) => {
    setTrackerCode(code);
    setCurrentTab('track');
  };

  const handleLoginSuccess = (user) => {
    showToast(`Hoş geldiniz, ${user.displayName}!`, 'success');
  };

  const handleLogout = () => {
    authService.logout();
    showToast('Yönetici oturumu güvenle kapatıldı.', 'info');
  };

  const isAdminAuthenticated = Boolean(adminSession && adminSession.isAuthenticated);

  return (
    <div className="app-container">
      {/* Top Sticky Navigation */}
      <Navbar
        currentTab={currentTab}
        setCurrentTab={setCurrentTab}
        pendingCount={pendingCount}
        adminSession={adminSession}
        onLogout={handleLogout}
        isOnline={isFirebaseInitialized}
      />

      {/* Main Content Area */}
      <main className="main-content">
        {currentTab === 'register' && (
          <PublicRegistration
            onApplicationSubmitted={handleApplicationSubmitted}
            onNavigateTracker={handleNavigateTracker}
          />
        )}

        {currentTab === 'track' && (
          <ApplicationTracker
            initialCode={trackerCode}
            onNavigateRegister={() => setCurrentTab('register')}
          />
        )}

        {currentTab === 'admin' && (
          <>
            {isAdminAuthenticated ? (
              <AdminDashboard
                events={events}
                applications={applications}
                users={users}
                adminSession={adminSession}
                onShowToast={showToast}
                isOnline={isFirebaseInitialized}
              />
            ) : (
              <AdminLogin onLoginSuccess={handleLoginSuccess} />
            )}
          </>
        )}
      </main>

      {/* Footer */}
      <footer style={{ borderTop: '1px solid var(--border-subtle)', background: 'var(--white)', padding: '2rem 1.5rem', marginTop: 'auto' }}>
        <div style={{ maxWidth: '1400px', margin: '0 auto', display: 'flex', flexWrap: 'wrap', alignItems: 'center', justifyContent: 'space-between', gap: '1rem', fontSize: '0.825rem', color: 'var(--slate-500)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.65rem' }}>
            <div style={{ width: '28px', height: '28px', borderRadius: '6px', background: 'var(--primary-gradient)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'white' }}>
              <ShieldCheck size={16} />
            </div>
            <span>
              <strong>ClinicFlow Portal</strong> — Sağlık Kuruluşları &amp; Hekim Kayıt / Denetim Yönetim Platformu
            </span>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '1.25rem' }}>
            <span>6698 Sayılı KVKK Uyumlu</span>
            <span>•</span>
            <span>Firebase Proje: <code>clinicflow-app-4281</code></span>
            <span>•</span>
            <span>v1.0.0 Web</span>
          </div>
        </div>
      </footer>

      {/* Toast Popups */}
      <Toast toasts={toasts} onDismiss={handleDismissToast} />
    </div>
  );
}
