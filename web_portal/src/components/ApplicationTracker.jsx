import React, { useState } from 'react';
import { 
  Search, 
  CheckCircle2, 
  Clock, 
  XCircle, 
  Building2, 
  User, 
  Calendar, 
  FileText, 
  ArrowRight,
  ShieldAlert,
  ShieldCheck
} from 'lucide-react';
import { registrationService } from '../services/registrationService';

export default function ApplicationTracker({ initialCode = '', onNavigateRegister }) {
  const [searchQuery, setSearchQuery] = useState(initialCode);
  const [searchResult, setSearchResult] = useState(
    initialCode ? registrationService.findApplication(initialCode) : null
  );
  const [hasSearched, setHasSearched] = useState(Boolean(initialCode));

  const handleSearch = (e) => {
    e?.preventDefault();
    if (!searchQuery.trim()) return;
    const found = registrationService.findApplication(searchQuery);
    setSearchResult(found || null);
    setHasSearched(true);
  };

  const handleQuickPick = (code) => {
    setSearchQuery(code);
    const found = registrationService.findApplication(code);
    setSearchResult(found || null);
    setHasSearched(true);
  };

  return (
    <div style={{ maxWidth: '840px', margin: '0 auto' }}>
      <div className="card" style={{ marginBottom: '2rem' }}>
        <div className="card-header">
          <div>
            <h2 className="card-title">
              <Search size={22} color="var(--primary)" />
              <span>Başvuru Durumu ve Kayıt Sorgulama</span>
            </h2>
            <p className="card-desc">
              Başvuru referans kodunuzu veya kayıt sırasında kullandığınız kurumsal e-posta adresinizi girin.
            </p>
          </div>
        </div>

        <div className="card-body">
          <form onSubmit={handleSearch} style={{ display: 'flex', gap: '0.75rem', marginBottom: '1.25rem' }}>
            <input
              type="text"
              className="form-input"
              placeholder="Örn: CF-REQ-2026-902 veya dr.zeynep@clinicflow.com"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              style={{ flex: 1, fontSize: '1rem', padding: '0.75rem 1rem' }}
            />
            <button type="submit" className="btn btn-primary btn-lg">
              <Search size={18} />
              <span>Sorgula</span>
            </button>
          </form>

          {/* Quick sample buttons */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', flexWrap: 'wrap', fontSize: '0.8rem', color: 'var(--slate-500)' }}>
            <span>Hızlı Test Örnekleri:</span>
            <button
              type="button"
              className="btn btn-sm btn-secondary"
              onClick={() => handleQuickPick('CF-REQ-2026-902')}
            >
              CF-REQ-2026-902 (Bekleyen)
            </button>
            <button
              type="button"
              className="btn btn-sm btn-secondary"
              onClick={() => handleQuickPick('CF-REQ-2026-901')}
            >
              CF-REQ-2026-901 (Onaylı)
            </button>
          </div>
        </div>
      </div>

      {/* Result Section */}
      {hasSearched && (
        <>
          {searchResult ? (
            <div className="card">
              <div className="card-header">
                <div>
                  <span style={{ fontSize: '0.8rem', color: 'var(--slate-400)', fontFamily: 'var(--font-family-mono)', display: 'block' }}>
                    REFERANS NO: {searchResult.id}
                  </span>
                  <h3 className="card-title" style={{ marginTop: '0.2rem' }}>
                    {searchResult.clinicName}
                  </h3>
                </div>

                <div>
                  {searchResult.status === 'approved' && (
                    <span className="badge badge-success" style={{ fontSize: '0.85rem', padding: '0.35rem 0.8rem' }}>
                      <CheckCircle2 size={16} />
                      Onaylandı &amp; Aktif
                    </span>
                  )}
                  {searchResult.status === 'pending' && (
                    <span className="badge badge-warning" style={{ fontSize: '0.85rem', padding: '0.35rem 0.8rem' }}>
                      <Clock size={16} />
                      Yönetici Onayı Bekliyor
                    </span>
                  )}
                  {searchResult.status === 'rejected' && (
                    <span className="badge badge-error" style={{ fontSize: '0.85rem', padding: '0.35rem 0.8rem' }}>
                      <XCircle size={16} />
                      Başvuru Reddedildi
                    </span>
                  )}
                </div>
              </div>

              <div className="card-body">
                {/* 4-Step Verification Progress Bar */}
                <div style={{ marginBottom: '2.5rem', marginTop: '0.5rem' }}>
                  <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '0.75rem', position: 'relative' }}>
                    {/* Step 1 */}
                    <div style={{ textAlign: 'center' }}>
                      <div style={{ width: '36px', height: '36px', borderRadius: '50%', background: 'var(--success)', color: 'white', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 0.5rem' }}>
                        <CheckCircle2 size={20} />
                      </div>
                      <div style={{ fontSize: '0.8rem', fontWeight: 700, color: 'var(--slate-800)' }}>1. Başvuru Alındı</div>
                      <div style={{ fontSize: '0.7rem', color: 'var(--slate-400)' }}>{new Date(searchResult.appliedAt).toLocaleDateString('tr-TR')}</div>
                    </div>

                    {/* Step 2 */}
                    <div style={{ textAlign: 'center' }}>
                      <div style={{ width: '36px', height: '36px', borderRadius: '50%', background: 'var(--success)', color: 'white', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 0.5rem' }}>
                        <CheckCircle2 size={20} />
                      </div>
                      <div style={{ fontSize: '0.8rem', fontWeight: 700, color: 'var(--slate-800)' }}>2. Ön İnceleme</div>
                      <div style={{ fontSize: '0.7rem', color: 'var(--success-text)' }}>Tamamlandı</div>
                    </div>

                    {/* Step 3 */}
                    <div style={{ textAlign: 'center' }}>
                      <div style={{ 
                        width: '36px', 
                        height: '36px', 
                        borderRadius: '50%', 
                        background: searchResult.status === 'approved' ? 'var(--success)' : searchResult.status === 'rejected' ? 'var(--error)' : 'var(--warning)', 
                        color: 'white', 
                        display: 'flex', 
                        alignItems: 'center', 
                        justifyContent: 'center', 
                        margin: '0 auto 0.5rem' 
                      }}>
                        {searchResult.status === 'approved' ? <CheckCircle2 size={20} /> : <Clock size={20} />}
                      </div>
                      <div style={{ fontSize: '0.8rem', fontWeight: 700, color: 'var(--slate-800)' }}>3. Belge Tescili</div>
                      <div style={{ fontSize: '0.7rem', color: 'var(--slate-500)' }}>
                        {searchResult.taxOrLicenseNumber || 'Kontrol Edildi'}
                      </div>
                    </div>

                    {/* Step 4 */}
                    <div style={{ textAlign: 'center' }}>
                      <div style={{ 
                        width: '36px', 
                        height: '36px', 
                        borderRadius: '50%', 
                        background: searchResult.status === 'approved' ? 'var(--success)' : searchResult.status === 'rejected' ? 'var(--error)' : 'var(--slate-200)', 
                        color: searchResult.status === 'approved' || searchResult.status === 'rejected' ? 'white' : 'var(--slate-500)', 
                        display: 'flex', 
                        alignItems: 'center', 
                        justifyContent: 'center', 
                        margin: '0 auto 0.5rem' 
                      }}>
                        {searchResult.status === 'approved' ? <ShieldCheck size={20} /> : searchResult.status === 'rejected' ? <ShieldAlert size={20} /> : <Clock size={20} />}
                      </div>
                      <div style={{ fontSize: '0.8rem', fontWeight: 700, color: 'var(--slate-800)' }}>4. Sistem Aktivasyonu</div>
                      <div style={{ fontSize: '0.7rem', color: 'var(--slate-500)' }}>
                        {searchResult.status === 'approved' ? 'Klinik Aktif' : searchResult.status === 'rejected' ? 'Reddedildi' : 'Sırada'}
                      </div>
                    </div>
                  </div>
                </div>

                {/* Details Breakdown */}
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '1rem', background: 'var(--slate-50)', padding: '1.25rem', borderRadius: 'var(--radius-lg)' }}>
                  <div>
                    <span style={{ fontSize: '0.75rem', color: 'var(--slate-400)', display: 'block' }}>Yetkili Hekim</span>
                    <strong style={{ fontSize: '0.9rem', color: 'var(--slate-900)' }}>{searchResult.doctorName}</strong>
                    <span style={{ fontSize: '0.8rem', color: 'var(--slate-500)', display: 'block' }}>{searchResult.specialty}</span>
                  </div>

                  <div>
                    <span style={{ fontSize: '0.75rem', color: 'var(--slate-400)', display: 'block' }}>İletişim Bilgileri</span>
                    <strong style={{ fontSize: '0.9rem', color: 'var(--slate-900)' }}>{searchResult.email}</strong>
                    <span style={{ fontSize: '0.8rem', color: 'var(--slate-500)', display: 'block' }}>{searchResult.phone}</span>
                  </div>

                  <div>
                    <span style={{ fontSize: '0.75rem', color: 'var(--slate-400)', display: 'block' }}>Lokasyon</span>
                    <strong style={{ fontSize: '0.9rem', color: 'var(--slate-900)' }}>{searchResult.city} / {searchResult.district}</strong>
                    <span style={{ fontSize: '0.8rem', color: 'var(--slate-500)', display: 'block' }}>{searchResult.address || 'Kayıtlı Adres'}</span>
                  </div>

                  <div>
                    <span style={{ fontSize: '0.75rem', color: 'var(--slate-400)', display: 'block' }}>Atanan Klinik ID</span>
                    <strong style={{ fontSize: '0.9rem', color: 'var(--primary-dark)', fontFamily: 'var(--font-family-mono)' }}>
                      {searchResult.clinicId || 'Onay Sonrası Belirlenecek'}
                    </strong>
                  </div>
                </div>

                {/* Rejection / Note notification */}
                {searchResult.rejectionReason && (
                  <div style={{ marginTop: '1rem', background: 'var(--error-bg)', border: '1px solid var(--error-border)', color: 'var(--error-text)', padding: '1rem', borderRadius: 'var(--radius-md)', fontSize: '0.875rem' }}>
                    <strong>Red Gerekçesi:</strong> {searchResult.rejectionReason}
                  </div>
                )}

                {searchResult.status === 'approved' && (
                  <div style={{ marginTop: '1rem', background: 'var(--success-bg)', border: '1px solid var(--success-border)', color: 'var(--success-text)', padding: '1rem', borderRadius: 'var(--radius-md)', fontSize: '0.875rem', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                    <span>
                      Kliniğiniz onaylandı! ClinicFlow iOS uygulamasından veya web panelinden doğrudan giriş yapabilirsiniz.
                    </span>
                    <span className="badge badge-success">Giriş Yapılabilir</span>
                  </div>
                )}
              </div>
            </div>
          ) : (
            <div className="card" style={{ textAlign: 'center', padding: '3rem 2rem' }}>
              <XCircle size={44} color="var(--error)" style={{ margin: '0 auto 1rem' }} />
              <h3 style={{ fontSize: '1.25rem', marginBottom: '0.5rem' }}>Başvuru Kaydı Bulunamadı</h3>
              <p style={{ color: 'var(--slate-500)', maxWidth: '460px', margin: '0 auto 1.5rem', fontSize: '0.9rem' }}>
                "<strong>{searchQuery}</strong>" aramasına uygun başvuru bulunamadı. Lütfen referans kodunuzu 
                veya e-posta adresinizi kontrol ediniz.
              </p>
              <button
                type="button"
                className="btn btn-primary"
                onClick={onNavigateRegister}
              >
                Yeni Kayıt Başvurusu Yap
              </button>
            </div>
          )}
        </>
      )}
    </div>
  );
}
