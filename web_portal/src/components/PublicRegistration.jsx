import React, { useState } from 'react';
import { 
  Building2, 
  UserPlus, 
  Stethoscope, 
  ShieldCheck, 
  CheckCircle2, 
  ArrowRight, 
  Copy, 
  Check, 
  Clock, 
  FileCheck2,
  Sparkles,
  Users
} from 'lucide-react';
import { registrationService } from '../services/registrationService';

export default function PublicRegistration({ onApplicationSubmitted, onNavigateTracker }) {
  const [formMode, setFormMode] = useState('clinic'); // 'clinic' | 'staff'
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submittedApp, setSubmittedApp] = useState(null);
  const [isCopied, setIsCopied] = useState(false);

  // Clinic Form State
  const [clinicForm, setClinicForm] = useState({
    clinicName: '',
    clinicType: 'Diş Hekimliği Kliniği',
    doctorName: '',
    email: '',
    phone: '',
    taxOrLicenseNumber: '',
    city: 'İstanbul',
    district: '',
    address: '',
    staffCount: '3-5 Kişi',
    specialty: 'Ortodonti & Genel Diş Hekimliği',
    password: '',
    passwordConfirm: '',
    kvkkConsent: false
  });

  // Staff Form State
  const [staffForm, setStaffForm] = useState({
    fullName: '',
    email: '',
    phone: '',
    licenseNumber: '',
    specialty: 'Diş Hekimi',
    clinicCode: 'c101-clinic-001',
    password: '',
    kvkkConsent: false
  });

  const [formErrors, setFormErrors] = useState({});

  const handleClinicChange = (e) => {
    const { name, value, type, checked } = e.target;
    setClinicForm(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }));
    if (formErrors[name]) {
      setFormErrors(prev => ({ ...prev, [name]: null }));
    }
  };

  const handleStaffChange = (e) => {
    const { name, value, type, checked } = e.target;
    setStaffForm(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }));
    if (formErrors[name]) {
      setFormErrors(prev => ({ ...prev, [name]: null }));
    }
  };

  const validateClinicForm = () => {
    const errors = {};
    if (!clinicForm.clinicName.trim()) errors.clinicName = 'Klinik adı zorunludur.';
    if (!clinicForm.doctorName.trim()) errors.doctorName = 'Yetkili hekim adı soyadı zorunludur.';
    if (!clinicForm.email.trim() || !clinicForm.email.includes('@')) errors.email = 'Geçerli bir e-posta adresi giriniz.';
    if (!clinicForm.phone.trim()) errors.phone = 'Telefon numarası zorunludur.';
    if (!clinicForm.taxOrLicenseNumber.trim()) errors.taxOrLicenseNumber = 'Diploma tescil veya vergi numarası zorunludur.';
    if (clinicForm.password.length < 6) errors.password = 'Şifre en az 6 karakter olmalıdır.';
    if (clinicForm.password !== clinicForm.passwordConfirm) errors.passwordConfirm = 'Şifreler eşleşmiyor.';
    if (!clinicForm.kvkkConsent) errors.kvkkConsent = 'KVKK aydınlatma metnini onaylamanız gerekmektedir.';
    return errors;
  };

  const validateStaffForm = () => {
    const errors = {};
    if (!staffForm.fullName.trim()) errors.fullName = 'Ad soyad zorunludur.';
    if (!staffForm.email.trim() || !staffForm.email.includes('@')) errors.email = 'Geçerli bir e-posta adresi giriniz.';
    if (!staffForm.phone.trim()) errors.phone = 'Telefon numarası zorunludur.';
    if (!staffForm.clinicCode.trim()) errors.clinicCode = 'Klinik davet kodu zorunludur.';
    if (!staffForm.kvkkConsent) errors.kvkkConsent = 'KVKK onayını kabul etmeniz gerekmektedir.';
    return errors;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const errors = formMode === 'clinic' ? validateClinicForm() : validateStaffForm();
    if (Object.keys(errors).length > 0) {
      setFormErrors(errors);
      return;
    }

    setIsSubmitting(true);
    try {
      let created;
      if (formMode === 'clinic') {
        created = await registrationService.submitApplication(clinicForm);
      } else {
        created = await registrationService.submitStaffJoin(staffForm);
      }
      setSubmittedApp(created);
      if (onApplicationSubmitted) onApplicationSubmitted(created);
    } catch (err) {
      console.error(err);
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleCopyCode = () => {
    if (submittedApp?.id) {
      navigator.clipboard.writeText(submittedApp.id);
      setIsCopied(true);
      setTimeout(() => setIsCopied(false), 2000);
    }
  };

  return (
    <div className="registration-container">
      {/* Hero Section */}
      <section className="hero-banner">
        <div className="hero-content">
          <div className="hero-chip">
            <Sparkles size={14} />
            <span>ClinicFlow Sağlık Ekosistemi</span>
          </div>
          <h1 className="hero-title">
            Kliniğinizi Dijitalleştirin, Kayıt Başvurunuzu Anında Başlatın
          </h1>
          <p className="hero-desc">
            Diş klinikleri, psikologlar, fizyoterapistler ve estetik merkezleri için 
            Apple App Store standartlarında randevu, hasta ve ekip yönetimi. 
            Başvurunuz güvenlik denetiminden geçerek doğrudan yöneticinizce onaylanır.
          </p>

          <div className="hero-stats-row">
            <div className="hero-stat-item">
              <span className="hero-stat-val">%100</span>
              <span className="hero-stat-label">KVKK &amp; HIPAA Uyumlu</span>
            </div>
            <div className="hero-stat-item">
              <span className="hero-stat-val">&lt; 2 Saat</span>
              <span className="hero-stat-label">Ortalama Onay Süresi</span>
            </div>
            <div className="hero-stat-item">
              <span className="hero-stat-val">Multi-Tenant</span>
              <span className="hero-stat-label">Klinik İzolasyon Mimarisi</span>
            </div>
          </div>
        </div>
      </section>

      {/* Main Registration Form Card */}
      <div className="card" style={{ maxWidth: '880px', margin: '0 auto' }}>
        <div className="card-header">
          <div>
            <h2 className="card-title">
              <Stethoscope size={22} color="var(--primary)" />
              <span>Sağlık Kuruluşu &amp; Personel Kayıt Başvurusu</span>
            </h2>
            <p className="card-desc">
              Lütfen yasal klinik veya hekimlik bilgilerinizi eksiksiz doldurunuz.
            </p>
          </div>

          <div style={{ display: 'flex', gap: '0.4rem', background: 'var(--slate-100)', padding: '0.3rem', borderRadius: 'var(--radius-md)' }}>
            <button
              type="button"
              className={`btn btn-sm ${formMode === 'clinic' ? 'btn-primary' : 'btn-ghost'}`}
              onClick={() => {
                setFormMode('clinic');
                setFormErrors({});
              }}
            >
              <Building2 size={14} />
              Yeni Klinik
            </button>
            <button
              type="button"
              className={`btn btn-sm ${formMode === 'staff' ? 'btn-primary' : 'btn-ghost'}`}
              onClick={() => {
                setFormMode('staff');
                setFormErrors({});
              }}
            >
              <Users size={14} />
              Hekim / Personel
            </button>
          </div>
        </div>

        <div className="card-body">
          <form onSubmit={handleSubmit}>
            {formMode === 'clinic' ? (
              <>
                {/* 1. Klinik Bilgileri */}
                <div style={{ marginBottom: '1.75rem' }}>
                  <h3 style={{ fontSize: '1rem', color: 'var(--primary-dark)', marginBottom: '1rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                    <Building2 size={18} />
                    <span>1. Klinik &amp; Branş Bilgileri</span>
                  </h3>

                  <div className="form-row">
                    <div className="form-group">
                      <label className="form-label">
                        Klinik / Merkez Resmi Adı <span className="required">*</span>
                      </label>
                      <input
                        type="text"
                        name="clinicName"
                        className="form-input"
                        placeholder="Örn: DentCare Ağız ve Diş Sağlığı Polikliniği"
                        value={clinicForm.clinicName}
                        onChange={handleClinicChange}
                      />
                      {formErrors.clinicName && <div className="form-error">{formErrors.clinicName}</div>}
                    </div>

                    <div className="form-group">
                      <label className="form-label">Klinik Türü / Alanı</label>
                      <select
                        name="clinicType"
                        className="form-select"
                        value={clinicForm.clinicType}
                        onChange={handleClinicChange}
                      >
                        <option value="Diş Hekimliği Kliniği">Diş Hekimliği Kliniği</option>
                        <option value="Fizyoterapi & Rehabilitasyon">Fizyoterapi &amp; Rehabilitasyon</option>
                        <option value="Psikoloji & Terapi Merkezi">Psikoloji &amp; Terapi Merkezi</option>
                        <option value="Estetik & Dermatoloji">Estetik &amp; Dermatoloji</option>
                        <option value="Genel Tıp & Poliklinik">Genel Tıp &amp; Poliklinik</option>
                      </select>
                    </div>
                  </div>

                  <div className="form-row">
                    <div className="form-group">
                      <label className="form-label">
                        Klinik Uzmanlık / Alt Branş
                      </label>
                      <input
                        type="text"
                        name="specialty"
                        className="form-input"
                        placeholder="Örn: Ortodonti, Pedodonti, İmplantoloji"
                        value={clinicForm.specialty}
                        onChange={handleClinicChange}
                      />
                    </div>

                    <div className="form-group">
                      <label className="form-label">Tahmini Personel / Hekim Sayısı</label>
                      <select
                        name="staffCount"
                        className="form-select"
                        value={clinicForm.staffCount}
                        onChange={handleClinicChange}
                      >
                        <option value="1-2 Kişi (Bireysel)">1-2 Kişi (Bireysel Pratik)</option>
                        <option value="3-5 Kişi">3-5 Kişi (Orta Ölçek)</option>
                        <option value="6-15 Kişi">6-15 Kişi (Geniş Ekip)</option>
                        <option value="15+ Kişi">15+ Kişi (Tıp / Poliklinik Merkezi)</option>
                      </select>
                    </div>
                  </div>
                </div>

                {/* 2. Yönetici Hekim Bilgileri */}
                <div style={{ marginBottom: '1.75rem', paddingTop: '1.25rem', borderTop: '1px solid var(--border-subtle)' }}>
                  <h3 style={{ fontSize: '1rem', color: 'var(--primary-dark)', marginBottom: '1rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                    <Stethoscope size={18} />
                    <span>2. Sorumlu Hekim / Yönetici İletişim Bilgileri</span>
                  </h3>

                  <div className="form-row">
                    <div className="form-group">
                      <label className="form-label">
                        Yetkili Hekim Adı Soyadı <span className="required">*</span>
                      </label>
                      <input
                        type="text"
                        name="doctorName"
                        className="form-input"
                        placeholder="Örn: Dr. Zeynep Kaya"
                        value={clinicForm.doctorName}
                        onChange={handleClinicChange}
                      />
                      {formErrors.doctorName && <div className="form-error">{formErrors.doctorName}</div>}
                    </div>

                    <div className="form-group">
                      <label className="form-label">
                        Diploma Tescil / Vergi No <span className="required">*</span>
                      </label>
                      <input
                        type="text"
                        name="taxOrLicenseNumber"
                        className="form-input"
                        placeholder="Örn: DIP-TR-349018 veya Vergi No"
                        value={clinicForm.taxOrLicenseNumber}
                        onChange={handleClinicChange}
                      />
                      {formErrors.taxOrLicenseNumber && <div className="form-error">{formErrors.taxOrLicenseNumber}</div>}
                      <span className="form-helper">Sağlık Bakanlığı onay süreçleri için kullanılır.</span>
                    </div>
                  </div>

                  <div className="form-row">
                    <div className="form-group">
                      <label className="form-label">
                        Kurumsal E-posta Adresi <span className="required">*</span>
                      </label>
                      <input
                        type="email"
                        name="email"
                        className="form-input"
                        placeholder="zeynep@dentcare.com"
                        value={clinicForm.email}
                        onChange={handleClinicChange}
                      />
                      {formErrors.email && <div className="form-error">{formErrors.email}</div>}
                    </div>

                    <div className="form-group">
                      <label className="form-label">
                        İletişim Telefonu <span className="required">*</span>
                      </label>
                      <input
                        type="tel"
                        name="phone"
                        className="form-input"
                        placeholder="0532 100 20 30"
                        value={clinicForm.phone}
                        onChange={handleClinicChange}
                      />
                      {formErrors.phone && <div className="form-error">{formErrors.phone}</div>}
                    </div>
                  </div>

                  <div className="form-row">
                    <div className="form-group">
                      <label className="form-label">Şehir</label>
                      <select
                        name="city"
                        className="form-select"
                        value={clinicForm.city}
                        onChange={handleClinicChange}
                      >
                        <option value="İstanbul">İstanbul</option>
                        <option value="Ankara">Ankara</option>
                        <option value="İzmir">İzmir</option>
                        <option value="Bursa">Bursa</option>
                        <option value="Antalya">Antalya</option>
                        <option value="Diğer">Diğer İl</option>
                      </select>
                    </div>

                    <div className="form-group">
                      <label className="form-label">İlçe / Bölge</label>
                      <input
                        type="text"
                        name="district"
                        className="form-input"
                        placeholder="Örn: Kadıköy / Bağdat Caddesi"
                        value={clinicForm.district}
                        onChange={handleClinicChange}
                      />
                    </div>
                  </div>
                </div>

                {/* 3. Güvenlik & Şifre */}
                <div style={{ marginBottom: '1.75rem', paddingTop: '1.25rem', borderTop: '1px solid var(--border-subtle)' }}>
                  <h3 style={{ fontSize: '1rem', color: 'var(--primary-dark)', marginBottom: '1rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                    <ShieldCheck size={18} />
                    <span>3. Yönetici Giriş Şifresi Belirleme</span>
                  </h3>

                  <div className="form-row">
                    <div className="form-group">
                      <label className="form-label">
                        Giriş Parolası <span className="required">*</span>
                      </label>
                      <input
                        type="password"
                        name="password"
                        className="form-input"
                        placeholder="En az 6 karakter"
                        value={clinicForm.password}
                        onChange={handleClinicChange}
                      />
                      {formErrors.password && <div className="form-error">{formErrors.password}</div>}
                    </div>

                    <div className="form-group">
                      <label className="form-label">
                        Parola Tekrarı <span className="required">*</span>
                      </label>
                      <input
                        type="password"
                        name="passwordConfirm"
                        className="form-input"
                        placeholder="Parolanızı tekrar yazın"
                        value={clinicForm.passwordConfirm}
                        onChange={handleClinicChange}
                      />
                      {formErrors.passwordConfirm && <div className="form-error">{formErrors.passwordConfirm}</div>}
                    </div>
                  </div>
                </div>
              </>
            ) : (
              /* Hekim / Personel Katılım Formu */
              <div style={{ marginBottom: '1.75rem' }}>
                <div style={{ background: 'var(--info-bg)', border: '1px solid var(--info-border)', borderRadius: 'var(--radius-lg)', padding: '1rem', marginBottom: '1.5rem', color: 'var(--info-text)', fontSize: '0.875rem' }}>
                  <strong>Klinik Davet Kodu:</strong> Kliniğinizin yöneticisi tarafından size iletilen 
                  kod ile mevcut kliniğe katılabilirsiniz (Örn: <code>c101-clinic-001</code>).
                </div>

                <div className="form-row">
                  <div className="form-group">
                    <label className="form-label">
                      Klinik Davet Kodu / ID <span className="required">*</span>
                    </label>
                    <input
                      type="text"
                      name="clinicCode"
                      className="form-input"
                      placeholder="Örn: c101-clinic-001"
                      value={staffForm.clinicCode}
                      onChange={handleStaffChange}
                    />
                    {formErrors.clinicCode && <div className="form-error">{formErrors.clinicCode}</div>}
                  </div>

                  <div className="form-group">
                    <label className="form-label">
                      Adınız ve Soyadınız <span className="required">*</span>
                    </label>
                    <input
                      type="text"
                      name="fullName"
                      className="form-input"
                      placeholder="Örn: Dr. Mehmet Yılmaz"
                      value={staffForm.fullName}
                      onChange={handleStaffChange}
                    />
                    {formErrors.fullName && <div className="form-error">{formErrors.fullName}</div>}
                  </div>
                </div>

                <div className="form-row">
                  <div className="form-group">
                    <label className="form-label">
                      E-posta Adresiniz <span className="required">*</span>
                    </label>
                    <input
                      type="email"
                      name="email"
                      className="form-input"
                      placeholder="mehmet@klinik.com"
                      value={staffForm.email}
                      onChange={handleStaffChange}
                    />
                    {formErrors.email && <div className="form-error">{formErrors.email}</div>}
                  </div>

                  <div className="form-group">
                    <label className="form-label">
                      Telefon Numaranız <span className="required">*</span>
                    </label>
                    <input
                      type="tel"
                      name="phone"
                      className="form-input"
                      placeholder="0532 999 88 77"
                      value={staffForm.phone}
                      onChange={handleStaffChange}
                    />
                    {formErrors.phone && <div className="form-error">{formErrors.phone}</div>}
                  </div>
                </div>

                <div className="form-row">
                  <div className="form-group">
                    <label className="form-label">Uzmanlık / Görev</label>
                    <input
                      type="text"
                      name="specialty"
                      className="form-input"
                      placeholder="Örn: Pedodonti Uzmanı veya Klinik Asistanı"
                      value={staffForm.specialty}
                      onChange={handleStaffChange}
                    />
                  </div>

                  <div className="form-group">
                    <label className="form-label">Diploma / Tescil No</label>
                    <input
                      type="text"
                      name="licenseNumber"
                      className="form-input"
                      placeholder="Örn: DIP-TR-128934"
                      value={staffForm.licenseNumber}
                      onChange={handleStaffChange}
                    />
                  </div>
                </div>
              </div>
            )}

            {/* KVKK Onayı */}
            <div className="form-group" style={{ marginTop: '1.25rem' }}>
              <label className="checkbox-label">
                <input
                  type="checkbox"
                  name="kvkkConsent"
                  className="checkbox-input"
                  checked={formMode === 'clinic' ? clinicForm.kvkkConsent : staffForm.kvkkConsent}
                  onChange={formMode === 'clinic' ? handleClinicChange : handleStaffChange}
                />
                <span>
                  6698 sayılı Kişisel Verilerin Korunması Kanunu (KVKK) uyarınca hazırlanan 
                  <strong> Aydınlatma Metni</strong>'ni okudum ve sağlık kuruluşu kaydımın incelenmesini kabul ediyorum.
                </span>
              </label>
              {formErrors.kvkkConsent && <div className="form-error">{formErrors.kvkkConsent}</div>}
            </div>

            {/* Submit Action */}
            <div style={{ marginTop: '2rem', display: 'flex', alignItems: 'center', justifyContent: 'flex-end', gap: '1rem' }}>
              <button
                type="submit"
                disabled={isSubmitting}
                className="btn btn-primary btn-lg"
                style={{ minWidth: '220px' }}
              >
                {isSubmitting ? (
                  <span>Gönderiliyor...</span>
                ) : (
                  <>
                    <span>Başvuruyu Tamamla</span>
                    <ArrowRight size={18} />
                  </>
                )}
              </button>
            </div>
          </form>
        </div>
      </div>

      {/* Success Modal */}
      {submittedApp && (
        <div className="modal-backdrop">
          <div className="modal-dialog">
            <div className="modal-header" style={{ background: 'var(--success-bg)', borderBottomColor: 'var(--success-border)' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
                <div style={{ width: '36px', height: '36px', borderRadius: '50%', background: 'var(--success)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'white' }}>
                  <CheckCircle2 size={22} />
                </div>
                <div>
                  <h3 className="modal-title" style={{ color: 'var(--success-text)' }}>Kayıt Başvurunuz Alındı!</h3>
                  <p style={{ fontSize: '0.8rem', color: 'var(--success-text)', margin: 0 }}>Kayıt olayı sisteme işlendi ve denetime gönderildi.</p>
                </div>
              </div>
            </div>

            <div className="modal-body">
              <div style={{ textAlign: 'center', padding: '1rem 0' }}>
                <p style={{ fontSize: '0.95rem', color: 'var(--slate-600)', marginBottom: '1.25rem' }}>
                  Sayın <strong>{submittedApp.doctorName}</strong>, <strong>{submittedApp.clinicName}</strong> için 
                  kayıt talebiniz başarıyla kaydedildi. Başvuru takip numaranız aşağıdadır:
                </p>

                <div style={{ background: 'var(--slate-100)', border: '2px dashed var(--slate-300)', borderRadius: 'var(--radius-lg)', padding: '1.25rem', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '1rem', marginBottom: '1.5rem' }}>
                  <span style={{ fontSize: '1.5rem', fontWeight: 800, fontFamily: 'var(--font-family-mono)', color: 'var(--primary-dark)', letterSpacing: '0.05em' }}>
                    {submittedApp.id}
                  </span>
                  <button
                    type="button"
                    className="btn btn-secondary btn-sm"
                    onClick={handleCopyCode}
                    title="Kodu kopyala"
                  >
                    {isCopied ? <Check size={14} color="var(--success)" /> : <Copy size={14} />}
                    <span>{isCopied ? 'Kopyalandı' : 'Kopyala'}</span>
                  </button>
                </div>

                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '0.75rem', textAlign: 'left', background: 'var(--slate-50)', padding: '1rem', borderRadius: 'var(--radius-md)', fontSize: '0.825rem' }}>
                  <div>
                    <span style={{ color: 'var(--slate-400)', display: 'block' }}>Kayıt Durumu</span>
                    <span className="badge badge-warning" style={{ marginTop: '0.2rem' }}>Onay Bekliyor</span>
                  </div>
                  <div>
                    <span style={{ color: 'var(--slate-400)', display: 'block' }}>Kayıtlı E-posta</span>
                    <strong style={{ color: 'var(--slate-800)' }}>{submittedApp.email}</strong>
                  </div>
                  <div>
                    <span style={{ color: 'var(--slate-400)', display: 'block' }}>Tarih</span>
                    <strong style={{ color: 'var(--slate-800)' }}>{new Date(submittedApp.appliedAt).toLocaleDateString('tr-TR')}</strong>
                  </div>
                </div>
              </div>
            </div>

            <div className="modal-footer">
              <button
                type="button"
                className="btn btn-secondary"
                onClick={() => setSubmittedApp(null)}
              >
                Kapat
              </button>
              <button
                type="button"
                className="btn btn-primary"
                onClick={() => {
                  const id = submittedApp.id;
                  setSubmittedApp(null);
                  if (onNavigateTracker) onNavigateTracker(id);
                }}
              >
                <span>Durumu Sorgula</span>
                <ArrowRight size={14} />
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
