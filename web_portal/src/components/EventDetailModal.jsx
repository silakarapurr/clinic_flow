import React, { useState } from 'react';
import { 
  X, 
  Copy, 
  Check, 
  Activity, 
  Clock, 
  User, 
  Building2, 
  Terminal, 
  ShieldCheck 
} from 'lucide-react';

export default function EventDetailModal({ event, onClose }) {
  const [copied, setCopied] = useState(false);

  if (!event) return null;

  const handleCopyJson = () => {
    navigator.clipboard.writeText(JSON.stringify(event, null, 2));
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="modal-backdrop" onClick={onClose}>
      <div className="modal-dialog lg" onClick={(e) => e.stopPropagation()}>
        <div className="modal-header">
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
            <div className={`kpi-icon-box ${event.severity === 'success' ? 'emerald' : event.severity === 'error' ? 'amber' : 'teal'}`} style={{ width: '40px', height: '40px' }}>
              <Activity size={20} />
            </div>
            <div>
              <h3 className="modal-title">{event.title}</h3>
              <span style={{ fontSize: '0.75rem', color: 'var(--slate-400)', fontFamily: 'var(--font-family-mono)' }}>
                OLAY ID: {event.id}
              </span>
            </div>
          </div>
          <button type="button" className="btn btn-ghost btn-sm" onClick={onClose}>
            <X size={18} />
          </button>
        </div>

        <div className="modal-body">
          {/* Summary Row */}
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '1rem', background: 'var(--slate-50)', padding: '1.25rem', borderRadius: 'var(--radius-lg)', marginBottom: '1.5rem' }}>
            <div>
              <span style={{ fontSize: '0.75rem', color: 'var(--slate-400)', display: 'block' }}>Zaman Damgası</span>
              <strong style={{ fontSize: '0.85rem', color: 'var(--slate-800)', fontFamily: 'var(--font-family-mono)' }}>
                {new Date(event.timestamp).toLocaleString('tr-TR')}
              </strong>
            </div>
            <div>
              <span style={{ fontSize: '0.75rem', color: 'var(--slate-400)', display: 'block' }}>İşlemi Yapan Aktör</span>
              <strong style={{ fontSize: '0.85rem', color: 'var(--slate-800)' }}>
                {event.actor || 'Sistem'}
              </strong>
            </div>
            <div>
              <span style={{ fontSize: '0.75rem', color: 'var(--slate-400)', display: 'block' }}>Hedef Kullanıcı</span>
              <strong style={{ fontSize: '0.85rem', color: 'var(--slate-800)' }}>
                {event.targetUser || '—'}
              </strong>
            </div>
            <div>
              <span style={{ fontSize: '0.75rem', color: 'var(--slate-400)', display: 'block' }}>Hedef Klinik / ID</span>
              <strong style={{ fontSize: '0.85rem', color: 'var(--primary-dark)' }}>
                {event.targetClinic || event.clinicId || '—'}
              </strong>
            </div>
          </div>

          <div style={{ marginBottom: '1.5rem' }}>
            <h4 style={{ fontSize: '0.875rem', color: 'var(--slate-700)', marginBottom: '0.4rem', fontWeight: 600 }}>
              Açıklama &amp; Olay Özeti
            </h4>
            <p style={{ fontSize: '0.925rem', color: 'var(--slate-600)', background: 'var(--white)', border: '1px solid var(--border-subtle)', padding: '0.85rem 1rem', borderRadius: 'var(--radius-md)' }}>
              {event.description}
            </p>
          </div>

          {/* Raw JSON Payload */}
          <div>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '0.5rem' }}>
              <h4 style={{ fontSize: '0.875rem', color: 'var(--slate-700)', fontWeight: 600, display: 'flex', alignItems: 'center', gap: '0.4rem' }}>
                <Terminal size={16} />
                <span>Olay Veri Yükü (JSON Payload &amp; Metadata)</span>
              </h4>
              <button
                type="button"
                className="btn btn-secondary btn-sm"
                onClick={handleCopyJson}
              >
                {copied ? <Check size={12} color="var(--success)" /> : <Copy size={12} />}
                <span>{copied ? 'Kopyalandı' : 'JSON Kopyala'}</span>
              </button>
            </div>
            <pre className="json-viewer">
              {JSON.stringify(event, null, 2)}
            </pre>
          </div>
        </div>

        <div className="modal-footer">
          <button type="button" className="btn btn-secondary" onClick={onClose}>
            Kapat
          </button>
        </div>
      </div>
    </div>
  );
}
