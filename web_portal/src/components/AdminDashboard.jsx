import React, { useState } from 'react';
import { 
  Activity, 
  Users, 
  Building2, 
  Clock, 
  CheckCircle2, 
  XCircle, 
  AlertTriangle, 
  Search, 
  Download, 
  UserPlus, 
  ShieldCheck, 
  KeyRound, 
  ExternalLink, 
  Filter, 
  RotateCcw,
  Sparkles,
  Database,
  Eye,
  Check,
  UserCheck
} from 'lucide-react';
import { eventService } from '../services/eventService';
import { registrationService } from '../services/registrationService';
import EventDetailModal from './EventDetailModal';
import InviteUserModal from './InviteUserModal';
import RejectReasonModal from './RejectReasonModal';

export default function AdminDashboard({ 
  events = [], 
  applications = [], 
  users = [],
  onShowToast,
  isOnline
}) {
  const [subTab, setSubTab] = useState('events'); // 'events' | 'approvals' | 'users' | 'system'
  
  // Event stream filters
  const [eventFilterCategory, setEventFilterCategory] = useState('ALL');
  const [eventSearch, setEventSearch] = useState('');
  const [selectedEvent, setSelectedEvent] = useState(null);

  // Application filters
  const [appStatusFilter, setAppStatusFilter] = useState('ALL');
  const [appSearch, setAppSearch] = useState('');
  const [rejectingApp, setRejectingApp] = useState(null);

  // Modals
  const [isInviteOpen, setIsInviteOpen] = useState(false);

  // Counters
  const pendingCount = applications.filter(a => a.status === 'pending').length;
  const approvedCount = applications.filter(a => a.status === 'approved').length;
  const rejectedCount = applications.filter(a => a.status === 'rejected').length;

  // Filtered Events
  const filteredEvents = events.filter(e => {
    if (eventFilterCategory !== 'ALL' && e.type !== eventFilterCategory) {
      return false;
    }
    if (eventSearch.trim()) {
      const q = eventSearch.toLowerCase();
      const matchText = `${e.title} ${e.description} ${e.targetUser} ${e.targetClinic} ${e.actor} ${e.id}`.toLowerCase();
      if (!matchText.includes(q)) return false;
    }
    return true;
  });

  // Filtered Applications
  const filteredApps = applications.filter(a => {
    if (appStatusFilter !== 'ALL' && a.status !== appStatusFilter) {
      return false;
    }
    if (appSearch.trim()) {
      const q = appSearch.toLowerCase();
      const matchText = `${a.clinicName} ${a.doctorName} ${a.email} ${a.id} ${a.city} ${a.specialty}`.toLowerCase();
      if (!matchText.includes(q)) return false;
    }
    return true;
  });

  // Handlers
  const handleApprove = async (appId) => {
    const updated = await registrationService.approveApplication(appId);
    if (updated) {
      onShowToast(`"${updated.clinicName}" başvurusu onaylandı ve yönetici hesabı oluşturuldu!`, 'success');
    }
  };

  const handleConfirmReject = async (appId, reason) => {
    const updated = await registrationService.rejectApplication(appId, reason);
    if (updated) {
      onShowToast(`"${updated.clinicName}" başvurusu reddedildi.`, 'error');
    }
  };

  const handleToggleUser = async (userId) => {
    const updated = await registrationService.toggleUserStatus(userId);
    if (updated) {
      onShowToast(`${updated.fullName} durumu ${updated.isActive ? 'Aktif' : 'Pasif'} yapıldı.`, 'info');
    }
  };

  const handleRoleChange = async (userId, newRole) => {
    const updated = await registrationService.updateUserRole(userId, newRole);
    if (updated) {
      onShowToast(`${updated.fullName} rolü ${newRole === 'admin' ? 'Klinik Yöneticisi' : 'Personel'} yapıldı.`, 'info');
    }
  };

  const handleResetPassword = async (email) => {
    await registrationService.sendPasswordReset(email);
    onShowToast(`${email} adresine şifre sıfırlama talimatı iletildi.`, 'info');
  };

  const handleInviteUser = async (formData) => {
    const user = await registrationService.inviteUser(formData);
    onShowToast(`${user.fullName} (${user.email}) için davet gönderildi.`, 'success');
  };

  const handleExportCsv = () => {
    eventService.exportEventsToCsv();
    onShowToast('Kayıt olay günlüğü CSV olarak dışa aktarıldı.', 'success');
  };

  const handleResetData = () => {
    if (window.confirm('Tüm veriler varsayılan tohum (seed) verilerine sıfırlansın mı?')) {
      registrationService.resetToDefault();
      onShowToast('Tüm örnek veriler ve olay kayıtları sıfırlandı.', 'info');
    }
  };

  return (
    <div>
      {/* 4 KPI Cards */}
      <div className="kpi-grid">
        <div className="kpi-card teal">
          <div className="kpi-meta">
            <span className="kpi-label">Toplam Başvuru</span>
            <span className="kpi-value">{applications.length}</span>
            <span className="kpi-subtext">
              <Building2 size={12} />
              <span>{approvedCount} Onaylanmış Klinik</span>
            </span>
          </div>
          <div className="kpi-icon-box teal">
            <Building2 size={24} />
          </div>
        </div>

        <div className="kpi-card amber">
          <div className="kpi-meta">
            <span className="kpi-label">Onay Bekleyenler</span>
            <span className="kpi-value" style={{ color: pendingCount > 0 ? 'var(--warning)' : 'inherit' }}>
              {pendingCount}
            </span>
            <span className="kpi-subtext">
              <Clock size={12} />
              <span>{pendingCount > 0 ? 'İnceleme bekliyor' : 'Tümü incelendi'}</span>
            </span>
          </div>
          <div className="kpi-icon-box amber">
            <Clock size={24} />
          </div>
        </div>

        <div className="kpi-card emerald">
          <div className="kpi-meta">
            <span className="kpi-label">Kayıtlı Hekim / Personel</span>
            <span className="kpi-value">{users.length}</span>
            <span className="kpi-subtext">
              <Users size={12} />
              <span>{users.filter(u => u.isActive).length} Aktif Kullanıcı</span>
            </span>
          </div>
          <div className="kpi-icon-box emerald">
            <Users size={24} />
          </div>
        </div>

        <div className="kpi-card indigo">
          <div className="kpi-meta">
            <span className="kpi-label">Kayıt Olayı Hacmi</span>
            <span className="kpi-value">{events.length}</span>
            <span className="kpi-subtext">
              <Activity size={12} />
              <span>Canlı Denetim Günlüğü</span>
            </span>
          </div>
          <div className="kpi-icon-box indigo">
            <Activity size={24} />
          </div>
        </div>
      </div>

      {/* Main Admin Card */}
      <div className="card">
        {/* Navigation Sub-Tabs */}
        <div className="tabs-header" style={{ padding: '0 1.5rem', marginBottom: 0 }}>
          <button
            type="button"
            className={`tab-btn ${subTab === 'events' ? 'active' : ''}`}
            onClick={() => setSubTab('events')}
          >
            <Activity size={18} />
            <span>Kayıt Olayları Canlı Akışı</span>
            <span className="badge badge-teal" style={{ fontSize: '0.7rem' }}>{events.length}</span>
          </button>

          <button
            type="button"
            className={`tab-btn ${subTab === 'approvals' ? 'active' : ''}`}
            onClick={() => setSubTab('approvals')}
          >
            <Clock size={18} />
            <span>Bekleyen Başvurular</span>
            {pendingCount > 0 && (
              <span className="badge badge-warning" style={{ fontSize: '0.7rem' }}>
                {pendingCount} Yeni
              </span>
            )}
          </button>

          <button
            type="button"
            className={`tab-btn ${subTab === 'users' ? 'active' : ''}`}
            onClick={() => setSubTab('users')}
          >
            <Users size={18} />
            <span>Kayıtlı Kullanıcı Rehberi</span>
            <span className="badge badge-gray" style={{ fontSize: '0.7rem' }}>{users.length}</span>
          </button>

          <button
            type="button"
            className={`tab-btn ${subTab === 'system' ? 'active' : ''}`}
            onClick={() => setSubTab('system')}
          >
            <Database size={18} />
            <span>Sistem &amp; Firebase</span>
          </button>
        </div>

        <div className="card-body">
          {/* ========================================================================= */}
          {/* SUB-TAB 1: REGISTRATION EVENTS STREAM (AUDIT LOGS) */}
          {/* ========================================================================= */}
          {subTab === 'events' && (
            <div>
              {/* Event Controls Bar */}
              <div style={{ display: 'flex', flexWrap: 'wrap', alignItems: 'center', justifyContent: 'space-between', gap: '1rem', marginBottom: '1.5rem' }}>
                {/* Search */}
                <div style={{ position: 'relative', minWidth: '280px', flex: 1 }}>
                  <input
                    type="text"
                    className="form-input"
                    placeholder="Olay, aktör, kullanıcı veya klinik ara..."
                    value={eventSearch}
                    onChange={(e) => setEventSearch(e.target.value)}
                    style={{ paddingLeft: '2.25rem' }}
                  />
                  <Search size={16} color="var(--slate-400)" style={{ position: 'absolute', left: '0.75rem', top: '50%', transform: 'translateY(-50%)' }} />
                </div>

                {/* Export Action */}
                <div style={{ display: 'flex', gap: '0.5rem' }}>
                  <button
                    type="button"
                    className="btn btn-secondary btn-sm"
                    onClick={handleExportCsv}
                  >
                    <Download size={14} />
                    <span>CSV Dışa Aktar</span>
                  </button>
                </div>
              </div>

              {/* Event Category Filter Pills */}
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: '0.4rem', marginBottom: '1.75rem' }}>
                {[
                  { id: 'ALL', label: 'Tüm Olaylar' },
                  { id: 'REGISTRATION_SUBMITTED', label: 'Yeni Başvuru' },
                  { id: 'REGISTRATION_APPROVED', label: 'Onaylandı' },
                  { id: 'REGISTRATION_REJECTED', label: 'Reddedildi' },
                  { id: 'USER_INVITED', label: 'Davet Gönderildi' },
                  { id: 'ROLE_ASSIGNED', label: 'Rol Atandı' },
                  { id: 'STATUS_TOGGLED', label: 'Durum Değişikliği' },
                  { id: 'PASSWORD_RESET_SENT', label: 'Şifre Sıfırlama' }
                ].map(cat => (
                  <button
                    key={cat.id}
                    type="button"
                    className={`btn btn-sm ${eventFilterCategory === cat.id ? 'btn-primary' : 'btn-ghost'}`}
                    onClick={() => setEventFilterCategory(cat.id)}
                    style={{ fontSize: '0.785rem' }}
                  >
                    {cat.label}
                  </button>
                ))}
              </div>

              {/* Event Timeline List */}
              {filteredEvents.length > 0 ? (
                <div className="timeline-container">
                  {filteredEvents.map((evt, idx) => {
                    const isSuccess = evt.severity === 'success';
                    const isError = evt.severity === 'error';
                    const isWarning = evt.severity === 'warning';

                    return (
                      <div key={evt.id} className="timeline-item">
                        <div className="timeline-line"></div>
                        <div className={`timeline-icon-node ${isSuccess ? 'emerald' : isError ? 'amber' : isWarning ? 'amber' : 'teal'}`} style={{
                          background: isSuccess ? 'var(--success-bg)' : isError ? 'var(--error-bg)' : isWarning ? 'var(--warning-bg)' : 'var(--primary-tint)',
                          color: isSuccess ? 'var(--success)' : isError ? 'var(--error)' : isWarning ? 'var(--warning)' : 'var(--primary)',
                          border: `1px solid ${isSuccess ? 'var(--success-border)' : isError ? 'var(--error-border)' : isWarning ? 'var(--warning-border)' : 'var(--primary-light)'}`
                        }}>
                          {isSuccess && <CheckCircle2 size={18} />}
                          {isError && <XCircle size={18} />}
                          {isWarning && <Clock size={18} />}
                          {!isSuccess && !isError && !isWarning && <Activity size={18} />}
                        </div>

                        <div className="timeline-content-card">
                          <div className="timeline-header">
                            <div className="timeline-title">
                              <span>{evt.title}</span>
                              <span className={`badge ${isSuccess ? 'badge-success' : isError ? 'badge-error' : isWarning ? 'badge-warning' : 'badge-teal'}`}>
                                {evt.type}
                              </span>
                            </div>
                            <div className="timeline-timestamp">
                              {new Date(evt.timestamp).toLocaleString('tr-TR')}
                            </div>
                          </div>

                          <p className="timeline-details">{evt.description}</p>

                          <div className="timeline-meta-bar">
                            <span>
                              <strong>İşlem Yapan:</strong> {evt.actor}
                            </span>
                            {evt.targetUser && (
                              <span>
                                <strong>Hedef:</strong> {evt.targetUser}
                              </span>
                            )}
                            {evt.targetClinic && (
                              <span>
                                <strong>Klinik:</strong> {evt.targetClinic}
                              </span>
                            )}
                            <button
                              type="button"
                              className="btn btn-ghost btn-sm"
                              onClick={() => setSelectedEvent(evt)}
                              style={{ marginLeft: 'auto', padding: '0.15rem 0.5rem', fontSize: '0.75rem' }}
                            >
                              <Eye size={12} />
                              <span>Veri Yükü (JSON)</span>
                            </button>
                          </div>
                        </div>
                      </div>
                    );
                  })}
                </div>
              ) : (
                <div style={{ textAlign: 'center', padding: '3rem 1rem', color: 'var(--slate-500)' }}>
                  <Activity size={36} color="var(--slate-400)" style={{ margin: '0 auto 0.75rem' }} />
                  <p>Seçilen filtreye uygun kayıt olayı bulunamadı.</p>
                </div>
              )}
            </div>
          )}

          {/* ========================================================================= */}
          {/* SUB-TAB 2: APPLICATION APPROVALS */}
          {/* ========================================================================= */}
          {subTab === 'approvals' && (
            <div>
              {/* Approvals Control Bar */}
              <div style={{ display: 'flex', flexWrap: 'wrap', alignItems: 'center', justifyContent: 'space-between', gap: '1rem', marginBottom: '1.5rem' }}>
                <div style={{ position: 'relative', minWidth: '280px', flex: 1 }}>
                  <input
                    type="text"
                    className="form-input"
                    placeholder="Klinik, hekim, diploma no veya e-posta ara..."
                    value={appSearch}
                    onChange={(e) => setAppSearch(e.target.value)}
                    style={{ paddingLeft: '2.25rem' }}
                  />
                  <Search size={16} color="var(--slate-400)" style={{ position: 'absolute', left: '0.75rem', top: '50%', transform: 'translateY(-50%)' }} />
                </div>

                <div style={{ display: 'flex', gap: '0.4rem' }}>
                  {[
                    { id: 'ALL', label: `Tümü (${applications.length})` },
                    { id: 'pending', label: `Bekleyen (${pendingCount})` },
                    { id: 'approved', label: `Onaylı (${approvedCount})` },
                    { id: 'rejected', label: `Reddedilen (${rejectedCount})` }
                  ].map(tab => (
                    <button
                      key={tab.id}
                      type="button"
                      className={`btn btn-sm ${appStatusFilter === tab.id ? 'btn-primary' : 'btn-ghost'}`}
                      onClick={() => setAppStatusFilter(tab.id)}
                    >
                      {tab.label}
                    </button>
                  ))}
                </div>
              </div>

              {/* Applications Table / Cards */}
              {filteredApps.length > 0 ? (
                <div className="table-responsive">
                  <table className="table-custom">
                    <thead>
                      <tr>
                        <th>Başvuru ID / Klinik</th>
                        <th>Yetkili Hekim &amp; Uzmanlık</th>
                        <th>İletişim &amp; Şehir</th>
                        <th>Diploma / Tescil</th>
                        <th>Başvuru Tarihi</th>
                        <th>Durum</th>
                        <th style={{ textAlign: 'right' }}>İşlemler</th>
                      </tr>
                    </thead>
                    <tbody>
                      {filteredApps.map(app => {
                        const isPending = app.status === 'pending';
                        const isApproved = app.status === 'approved';
                        const isRejected = app.status === 'rejected';

                        return (
                          <tr key={app.id}>
                            <td>
                              <div>
                                <strong style={{ color: 'var(--slate-900)', display: 'block' }}>{app.clinicName}</strong>
                                <span style={{ fontSize: '0.75rem', color: 'var(--slate-400)', fontFamily: 'var(--font-family-mono)' }}>
                                  {app.id} • {app.clinicType}
                                </span>
                              </div>
                            </td>
                            <td>
                              <div>
                                <span style={{ fontWeight: 600, color: 'var(--slate-800)' }}>{app.doctorName}</span>
                                <span style={{ fontSize: '0.75rem', color: 'var(--slate-500)', display: 'block' }}>{app.specialty}</span>
                              </div>
                            </td>
                            <td>
                              <div>
                                <span style={{ fontSize: '0.85rem', color: 'var(--slate-700)', display: 'block' }}>{app.email}</span>
                                <span style={{ fontSize: '0.75rem', color: 'var(--slate-500)' }}>{app.phone} • {app.city}</span>
                              </div>
                            </td>
                            <td>
                              <span style={{ fontFamily: 'var(--font-family-mono)', fontSize: '0.8rem', background: 'var(--slate-100)', padding: '0.15rem 0.4rem', borderRadius: 'var(--radius-xs)' }}>
                                {app.taxOrLicenseNumber || '—'}
                              </span>
                            </td>
                            <td>
                              <span style={{ fontSize: '0.8rem', color: 'var(--slate-500)' }}>
                                {new Date(app.appliedAt).toLocaleDateString('tr-TR')}
                              </span>
                            </td>
                            <td>
                              {isPending && <span className="badge badge-warning">Onay Bekliyor</span>}
                              {isApproved && <span className="badge badge-success">Onaylandı</span>}
                              {isRejected && <span className="badge badge-error">Reddedildi</span>}
                            </td>
                            <td style={{ textAlign: 'right' }}>
                              {isPending ? (
                                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'flex-end', gap: '0.4rem' }}>
                                  <button
                                    type="button"
                                    className="btn btn-sm btn-success"
                                    onClick={() => handleApprove(app.id)}
                                    title="Başvuruyu Onayla"
                                  >
                                    <Check size={14} />
                                    <span>Onayla</span>
                                  </button>
                                  <button
                                    type="button"
                                    className="btn btn-sm btn-danger"
                                    onClick={() => setRejectingApp(app)}
                                    title="Başvuruyu Reddet"
                                  >
                                    <XCircle size={14} />
                                    <span>Reddet</span>
                                  </button>
                                </div>
                              ) : (
                                <span style={{ fontSize: '0.75rem', color: 'var(--slate-400)' }}>
                                  {isApproved ? `Klinik ID: ${app.clinicId}` : 'İşlem Tamamlandı'}
                                </span>
                              )}
                            </td>
                          </tr>
                        );
                      })}
                    </tbody>
                  </table>
                </div>
              ) : (
                <div style={{ textAlign: 'center', padding: '3rem 1rem', color: 'var(--slate-500)' }}>
                  <Building2 size={36} color="var(--slate-400)" style={{ margin: '0 auto 0.75rem' }} />
                  <p>Kayıtlı başvuru bulunamadı.</p>
                </div>
              )}
            </div>
          )}

          {/* ========================================================================= */}
          {/* SUB-TAB 3: REGISTERED USERS DIRECTORY */}
          {/* ========================================================================= */}
          {subTab === 'users' && (
            <div>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '1.5rem', gap: '1rem', flexWrap: 'wrap' }}>
                <div>
                  <h3 style={{ fontSize: '1.1rem', fontWeight: 700 }}>Kayıtlı ve Aktif Klinik Kullanıcıları</h3>
                  <p style={{ fontSize: '0.85rem', color: 'var(--slate-500)' }}>
                    ClinicFlow mobil ve web uygulamalarına erişim yetkisi olan hekimler ve personel.
                  </p>
                </div>

                <button
                  type="button"
                  className="btn btn-primary"
                  onClick={() => setIsInviteOpen(true)}
                >
                  <UserPlus size={16} />
                  <span>Yeni Kullanıcı / Hekim Davet Et</span>
                </button>
              </div>

              <div className="table-responsive">
                <table className="table-custom">
                  <thead>
                    <tr>
                      <th>Kullanıcı Adı Soyadı</th>
                      <th>E-posta &amp; İletişim</th>
                      <th>Klinik / Şube</th>
                      <th>Rol &amp; Yetki</th>
                      <th>Durum</th>
                      <th style={{ textAlign: 'right' }}>İşlemler</th>
                    </tr>
                  </thead>
                  <tbody>
                    {users.map(u => (
                      <tr key={u.id}>
                        <td>
                          <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
                            <div style={{ width: '36px', height: '36px', borderRadius: '50%', background: 'var(--primary-tint)', border: '1px solid var(--primary-light)', color: 'var(--primary-dark)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 700, fontSize: '0.85rem' }}>
                              {u.fullName.slice(0, 2).toUpperCase()}
                            </div>
                            <div>
                              <strong style={{ color: 'var(--slate-900)' }}>{u.fullName}</strong>
                              <span style={{ fontSize: '0.75rem', color: 'var(--slate-500)', display: 'block' }}>{u.specialty}</span>
                            </div>
                          </div>
                        </td>
                        <td>
                          <div>
                            <span style={{ fontSize: '0.875rem', color: 'var(--slate-800)', display: 'block' }}>{u.email}</span>
                            <span style={{ fontSize: '0.75rem', color: 'var(--slate-400)' }}>{u.phone}</span>
                          </div>
                        </td>
                        <td>
                          <div>
                            <span style={{ fontSize: '0.85rem', fontWeight: 600, color: 'var(--slate-800)' }}>{u.clinicName}</span>
                            <span style={{ fontSize: '0.725rem', color: 'var(--slate-400)', fontFamily: 'var(--font-family-mono)', display: 'block' }}>
                              {u.clinicId}
                            </span>
                          </div>
                        </td>
                        <td>
                          <select
                            className="form-select"
                            value={u.role}
                            onChange={(e) => handleRoleChange(u.id, e.target.value)}
                            style={{ fontSize: '0.8rem', padding: '0.3rem 0.6rem', width: 'auto' }}
                          >
                            <option value="admin">Klinik Yöneticisi (Admin)</option>
                            <option value="staff">Klinik Çalışanı (Staff)</option>
                          </select>
                        </td>
                        <td>
                          <span className={`badge ${u.isActive ? 'badge-success' : 'badge-error'}`}>
                            {u.isActive ? 'Aktif' : 'Askıya Alındı'}
                          </span>
                        </td>
                        <td style={{ textAlign: 'right' }}>
                          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'flex-end', gap: '0.4rem' }}>
                            <button
                              type="button"
                              className="btn btn-sm btn-secondary"
                              onClick={() => handleResetPassword(u.email)}
                              title="Şifre sıfırlama bağlantısı gönder"
                            >
                              <KeyRound size={13} />
                              <span>Şifre Sıfırla</span>
                            </button>
                            <button
                              type="button"
                              className={`btn btn-sm ${u.isActive ? 'btn-ghost' : 'btn-success'}`}
                              onClick={() => handleToggleUser(u.id)}
                            >
                              {u.isActive ? 'Askıya Al' : 'Aktifleştir'}
                            </button>
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* ========================================================================= */}
          {/* SUB-TAB 4: SYSTEM & FIREBASE SYNC */}
          {/* ========================================================================= */}
          {subTab === 'system' && (
            <div>
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '1.5rem', marginBottom: '2rem' }}>
                <div style={{ background: 'var(--slate-50)', padding: '1.5rem', borderRadius: 'var(--radius-lg)', border: '1px solid var(--border-subtle)' }}>
                  <h4 style={{ fontSize: '1rem', fontWeight: 700, color: 'var(--slate-900)', display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '1rem' }}>
                    <Database size={18} color="var(--primary)" />
                    <span>Firebase Entegrasyon Durumu</span>
                  </h4>

                  <div style={{ display: 'flex', flexDirection: 'column', gap: '0.65rem', fontSize: '0.85rem' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                      <span style={{ color: 'var(--slate-500)' }}>Firebase Proje ID:</span>
                      <strong style={{ fontFamily: 'var(--font-family-mono)' }}>clinicflow-app-4281</strong>
                    </div>
                    <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                      <span style={{ color: 'var(--slate-500)' }}>Firestore Veritabanı:</span>
                      <span className="badge badge-success">Aktif (Auto-Sync)</span>
                    </div>
                    <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                      <span style={{ color: 'var(--slate-500)' }}>İstemci SDK:</span>
                      <strong>Firebase JS SDK v13.0</strong>
                    </div>
                    <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                      <span style={{ color: 'var(--slate-500)' }}>Çalışma Modu:</span>
                      <strong style={{ color: 'var(--primary-dark)' }}>{isOnline ? 'Canlı Bulut & Bellek' : 'Yerel Demo Deposu'}</strong>
                    </div>
                  </div>
                </div>

                <div style={{ background: 'var(--slate-50)', padding: '1.5rem', borderRadius: 'var(--radius-lg)', border: '1px solid var(--border-subtle)' }}>
                  <h4 style={{ fontSize: '1rem', fontWeight: 700, color: 'var(--slate-900)', display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '1rem' }}>
                    <ShieldCheck size={18} color="var(--success)" />
                    <span>KVKK &amp; Güvenlik Uyumluluğu</span>
                  </h4>

                  <ul style={{ listStyle: 'none', display: 'flex', flexDirection: 'column', gap: '0.65rem', fontSize: '0.85rem', color: 'var(--slate-600)' }}>
                    <li style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                      <CheckCircle2 size={16} color="var(--success)" />
                      <span>Multi-tenant klinik veri tecridi (Tenant Isolation)</span>
                    </li>
                    <li style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                      <CheckCircle2 size={16} color="var(--success)" />
                      <span>Kayıt ve yetki değişikliklerinde denetim günlüğü (Audit Trail)</span>
                    </li>
                    <li style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                      <CheckCircle2 size={16} color="var(--success)" />
                      <span>Apple Guideline 5.1.1(v) ve KVKK hesap yönetimi</span>
                    </li>
                  </ul>
                </div>
              </div>

              {/* Maintenance Tools */}
              <div style={{ borderTop: '1px solid var(--border-subtle)', paddingTop: '1.5rem', display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: '1rem' }}>
                <div>
                  <h4 style={{ fontSize: '0.95rem', fontWeight: 700 }}>Test ve Demo Verilerini Sıfırlama</h4>
                  <p style={{ fontSize: '0.8rem', color: 'var(--slate-500)' }}>
                    Tüm başvuru ve kayıt olaylarını başlangıç durumuna döndürür.
                  </p>
                </div>

                <button
                  type="button"
                  className="btn btn-secondary"
                  onClick={handleResetData}
                >
                  <RotateCcw size={16} />
                  <span>Örnek Tohum Verilerini Sıfırla</span>
                </button>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Modals */}
      {selectedEvent && (
        <EventDetailModal
          event={selectedEvent}
          onClose={() => setSelectedEvent(null)}
        />
      )}

      {isInviteOpen && (
        <InviteUserModal
          onClose={() => setIsInviteOpen(false)}
          onInvite={handleInviteUser}
        />
      )}

      {rejectingApp && (
        <RejectReasonModal
          application={rejectingApp}
          onClose={() => setRejectingApp(null)}
          onConfirm={handleConfirmReject}
        />
      )}
    </div>
  );
}
