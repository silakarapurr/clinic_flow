import React, { useState } from 'react';
import { X, UserPlus, Mail, User, Stethoscope, Building2 } from 'lucide-react';

export default function InviteUserModal({ onClose, onInvite, clinics = [] }) {
  const [formData, setFormData] = useState({
    fullName: '',
    email: '',
    role: 'staff', // 'admin' | 'staff'
    specialty: 'Ortodonti & Genel Hekim',
    clinicId: 'c101-clinic-001',
    clinicName: 'DentCare & Sağlık Kliniği'
  });
  const [errors, setErrors] = useState({});

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
    if (errors[name]) setErrors(prev => ({ ...prev, [name]: null }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    const newErrors = {};
    if (!formData.fullName.trim()) newErrors.fullName = 'Ad soyad zorunludur.';
    if (!formData.email.trim() || !formData.email.includes('@')) newErrors.email = 'Geçerli bir e-posta adresi giriniz.';
    
    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      return;
    }

    onInvite(formData);
    onClose();
  };

  return (
    <div className="modal-backdrop" onClick={onClose}>
      <div className="modal-dialog" onClick={(e) => e.stopPropagation()}>
        <div className="modal-header">
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.65rem' }}>
            <div className="kpi-icon-box teal" style={{ width: '36px', height: '36px' }}>
              <UserPlus size={18} />
            </div>
            <div>
              <h3 className="modal-title">Yeni Kullanıcı &amp; Hekim Davet Et</h3>
              <p style={{ fontSize: '0.8rem', color: 'var(--slate-500)', margin: 0 }}>
                Kullanıcıya tek kullanımlık aktivasyon bağlantısı iletilir.
              </p>
            </div>
          </div>
          <button type="button" className="btn btn-ghost btn-sm" onClick={onClose}>
            <X size={18} />
          </button>
        </div>

        <form onSubmit={handleSubmit}>
          <div className="modal-body">
            <div className="form-group">
              <label className="form-label">
                Ad Soyad <span className="required">*</span>
              </label>
              <input
                type="text"
                name="fullName"
                className="form-input"
                placeholder="Örn: Dr. Canan Aksoy"
                value={formData.fullName}
                onChange={handleChange}
              />
              {errors.fullName && <div className="form-error">{errors.fullName}</div>}
            </div>

            <div className="form-group">
              <label className="form-label">
                E-posta Adresi <span className="required">*</span>
              </label>
              <input
                type="email"
                name="email"
                className="form-input"
                placeholder="canan@dentcare.com"
                value={formData.email}
                onChange={handleChange}
              />
              {errors.email && <div className="form-error">{errors.email}</div>}
            </div>

            <div className="form-row">
              <div className="form-group">
                <label className="form-label">Yetki Rolü</label>
                <select
                  name="role"
                  className="form-select"
                  value={formData.role}
                  onChange={handleChange}
                >
                  <option value="staff">Klinik Çalışanı / Hekim (Staff)</option>
                  <option value="admin">Klinik Yöneticisi (Admin)</option>
                </select>
              </div>

              <div className="form-group">
                <label className="form-label">Uzmanlık / Unvan</label>
                <input
                  type="text"
                  name="specialty"
                  className="form-input"
                  placeholder="Örn: Periodontoloji Uzmanı"
                  value={formData.specialty}
                  onChange={handleChange}
                />
              </div>
            </div>

            <div className="form-group">
              <label className="form-label">Klinik</label>
              <select
                name="clinicId"
                className="form-select"
                value={formData.clinicId}
                onChange={(e) => {
                  const selVal = e.target.value;
                  const cName = selVal === 'c101-clinic-001' ? 'DentCare & Sağlık Kliniği' : 'Kadıköy Fizyoterapi Merkezi';
                  setFormData(prev => ({
                    ...prev,
                    clinicId: selVal,
                    clinicName: cName
                  }));
                }}
              >
                <option value="c101-clinic-001">DentCare &amp; Sağlık Kliniği (c101)</option>
                <option value="c102-clinic-002">Kadıköy Fizyoterapi Merkezi (c102)</option>
              </select>
            </div>
          </div>

          <div className="modal-footer">
            <button type="button" className="btn btn-secondary" onClick={onClose}>
              Vazgeç
            </button>
            <button type="submit" className="btn btn-primary">
              <UserPlus size={16} />
              <span>Davet Gönder ve Kaydet</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
