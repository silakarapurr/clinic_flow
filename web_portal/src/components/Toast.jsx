import React from 'react';
import { CheckCircle2, AlertTriangle, Info, X } from 'lucide-react';

export default function Toast({ toasts = [], onDismiss }) {
  if (!toasts.length) return null;

  return (
    <div className="toast-container">
      {toasts.map(t => {
        const isSuccess = t.type === 'success';
        const isError = t.type === 'error';
        const isInfo = t.type === 'info';

        return (
          <div key={t.id} className={`toast ${t.type}`}>
            {isSuccess && <CheckCircle2 size={18} />}
            {isError && <AlertTriangle size={18} />}
            {isInfo && <Info size={18} />}
            <span style={{ flex: 1 }}>{t.message}</span>
            <button
              type="button"
              onClick={() => onDismiss(t.id)}
              style={{ background: 'transparent', border: 'none', color: 'inherit', cursor: 'pointer', padding: '0.2rem' }}
            >
              <X size={14} />
            </button>
          </div>
        );
      })}
    </div>
  );
}
