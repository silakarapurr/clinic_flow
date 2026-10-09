import React, { useState } from 'react';
import { X, AlertTriangle, XCircle } from 'lucide-react';

export default function RejectReasonModal({ application, onClose, onConfirm }) {
  const [reason, setReason] = useState('Başvuru bilgileri ve diploma/tescil numarası doğrulanamadı.');

  if (!application) return null;

  const handleSubmit = (e) => {
    e.preventDefault();
    onConfirm(application.id, reason);
    onClose();
  };

  return (
    <div className="modal-backdrop" onClick={onClose}>
      <div className="modal-dialog" onClick={(e) => e.stopPropagation()}>
        <div className="modal-header" style={{ background: 'var(--error-bg)', borderBottomColor: 'var(--error-border)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.65rem' }}>
            <div style={{ width: '36px', height: '36px', borderRadius: '50%', background: 'var(--error)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'white' }}>
              <AlertTriangle size={20} />
            </div>
            <div>
              <h3 className="modal-title" style={{ color: 'var(--error-text)' }}>Başvuruyu Reddet</h3>
              <p style={{ fontSize: '0.8rem', color: 'var(--error-text)', margin: 0 }}>
                {application.clinicName} — {application.doctorName}
              </p>
            </div>
          </div>
          <button type="button" className="btn btn-ghost btn-sm" onClick={onClose}>
            <X size={18} />
          </button>
        </div>

        <form onSubmit={handleSubmit}>
          <div className="modal-body">
            <p style={{ fontSize: '0.875rem', color: 'var(--slate-600)', marginBottom: '1rem' }}>
              Bu başvuruyu reddettiğinizde başvuru sahibine bildirim logu oluşturulacak ve 
              sistem denetim günlüğüne "REGISTRATION_REJECTED" olayı kaydedilecektir.
            </p>

            <div className="form-group">
              <label className="form-label">
                Red Gerekçesi Belirtin <span className="required">*</span>
              </label>
              <textarea
                rows={4}
                className="form-textarea"
                value={reason}
                onChange={(e) => setReason(e.target.value)}
                placeholder="Örn: Diploma tescil belgesi eksik veya geçersiz..."
              />
            </div>
          </div>

          <div className="modal-footer">
            <button type="button" className="btn btn-secondary" onClick={onClose}>
              Vazgeç
            </button>
            <button type="submit" className="btn btn-danger">
              <XCircle size={16} />
              <span>Reddet ve Olayı Kaydet</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
